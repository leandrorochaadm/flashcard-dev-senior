import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/core/daily_release.dart';
import 'package:flashcard_dev_senior/core/di/service_locator.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/session_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/import/import_service.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/domain/mock_interview/mock_interview_service.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/card_scheduler.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_gateway.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

/// The whole graph, wired the way the app wires it, but on the Dart VM: the
/// database factory is the swap point, so no browser is needed.
void main() {
  final firstOpening = DateTime(2026, 8, 11, 9);

  setUp(() async {
    await getIt.reset();
    await setupLocator(
      factory: newDatabaseFactoryMemory(),
      databaseName: 'flashcards_wiring_test',
      clock: FakeClock(firstOpening),
    );
  });

  tearDown(() => getIt.reset());

  test('every registration resolves and the window is anchored on opening',
      () async {
    expect(getIt<Clock>().now(), firstOpening);
    expect(getIt<CardRepository>().all, isEmpty);
    expect(getIt<SettingsRepository>().window.startDate, DateTime(2026, 8, 10));
    expect(getIt<SettingsRepository>().window.dayOfUse(firstOpening), 1);

    // Resolving each one proves the constructor arguments are in the right
    // order — a swapped pair would only show up at runtime otherwise.
    expect(getIt<MovingCeiling>(), isNotNull);
    expect(getIt<CardScheduler>(), isNotNull);
    expect(getIt<DueCardsPolicy>(), isNotNull);
    expect(getIt<ContentIntakePolicy>(), isNotNull);
    expect(getIt<MockInterviewService>(), isNotNull);
    expect(getIt<ProgressStats>(), isNotNull);
    expect(getIt<ImportService>(), isNotNull);
    expect(getIt<FsrsGateway>().parameters.length, 21);
    expect(getIt<ReviewLogRepository>().count, 0);
    expect(await getIt<SessionRepository>().unfinished(), isNull);
  });

  // The formatter protects nothing unless the app actually injects it, and a
  // bare `MarkdownParser` is a perfectly valid object that silently skips the
  // check. Asserting behaviour, not the field: only a wired parser tidies.
  test('the parser the app resolves carries the dart formatter', () {
    const source = '''
---
id: est-001
assunto: Estado
dificuldade: básico

**Pergunta**
E o código?

**Resposta**
```dart
var   x=1;
```
''';

    final answer = getIt<MarkdownParser>().parse(source).valid.single.answer;

    expect(answer, contains('var x = 1;'));
  });

  test('import, release and answer: a full first day through the real graph',
      () async {
    final parser = getIt<MarkdownParser>();
    final source = [
      for (var i = 1; i <= 100; i++)
        '''
---
id: est-${i.toString().padLeft(3, '0')}
assunto: Assunto ${i % 5}
dificuldade: intermediário

**Pergunta**
Pergunta $i?

**Resposta**
Resposta $i.
''',
    ].join();

    final outcome = getIt<ImportService>()
        .resolve(parser.parse(source), getIt<Clock>().now());
    await getIt<CardRepository>().saveAll(outcome.created);

    expect(getIt<CardRepository>().all.length, 100);
    // Importing is not releasing: the ceiling counts released cards only, so
    // it sits on its floor while everything is still held back.
    expect(getIt<MovingCeiling>().forDate(firstOpening).inMinutes, 1440);

    final release = getIt<ContentIntakePolicy>().releaseToday(firstOpening);
    expect(release.reason, IntakeReason.initialLoad);
    expect(release.quota, 20);
    // No stamping here: `ContentIntakePolicy` is the only class that writes
    // `introducedAt`, and it hands the batch back already released.
    await getIt<CardRepository>().saveAll(release.cards);

    final due = getIt<DueCardsPolicy>().dueNow(firstOpening);
    expect(due.length, 20);

    final answered = getIt<CardScheduler>()
        .apply(due.first, Rating.good, firstOpening);
    await getIt<CardRepository>().save(answered);

    expect(answered.dueAt, firstOpening.add(const Duration(minutes: 15)));
    expect(
      getIt<ProgressStats>().subjectMap(firstOpening).length,
      5,
      reason: 'the subject map builds itself from whatever was imported',
    );
  });

  group('the daily release, through the real graph', () {
    Future<void> import(int count) async {
      final source = [
        for (var i = 1; i <= count; i++)
          '''
---
id: est-${i.toString().padLeft(3, '0')}
assunto: Assunto ${i % 5}
dificuldade: intermediário

**Pergunta**
Pergunta $i?

**Resposta**
Resposta $i.
''',
      ].join();
      final outcome = getIt<ImportService>()
          .resolve(getIt<MarkdownParser>().parse(source), getIt<Clock>().now());
      await getIt<CardRepository>().saveAll(outcome.created);
    }

    // The bug this whole change exists for: the user imported, went straight
    // to the study tab, and "Começar" landed on "Fim do round" without ever
    // showing a card — because only `DashboardView.initState` released a
    // batch, and every study query filters on `isReleased`.
    test('importing and studying works without ever opening the dashboard',
        () async {
      await import(100);

      expect(getIt<DueCardsPolicy>().isDayCleared(firstOpening), isTrue,
          reason: 'nothing is studiable while the batch is still held');

      await getIt<DailyRelease>().run();

      final subjects = getIt<DueCardsPolicy>().studiableSubjects(firstOpening);
      expect(subjects, isNotEmpty, reason: 'the subject picker has entries');
      expect(
        getIt<DueCardsPolicy>().nextDueCard(firstOpening, subjects.first.subject),
        isNotNull,
        reason: 'pressing Começar serves a real question',
      );
      expect(getIt<DueCardsPolicy>().dueNow(firstOpening), hasLength(20));
    });

    test('a fresh install releases nothing, and does not lock the day', () async {
      // `nothingPending` must not settle the day: importing minutes later has
      // to release the batch, not wait until tomorrow.
      final empty = await getIt<DailyRelease>().run();
      expect(empty.reason, IntakeReason.nothingPending);
      expect(getIt<SettingsRepository>().lastReleaseAt, isNull);

      await import(100);
      await getIt<DailyRelease>().run();

      expect(getIt<DueCardsPolicy>().dueNow(firstOpening), hasLength(20));
    });

    test('opening the app five times over releases exactly one batch', () async {
      await import(100);
      for (var i = 0; i < 5; i++) {
        await getIt<DailyRelease>().run();
      }

      // Before the fix each visit to the dashboard freed another ceil(n/5):
      // 20, then 16, then 13 — six visits and the five-day ramp was gone.
      expect(
        getIt<CardRepository>().all.where((card) => card.isReleased),
        hasLength(20),
      );
      expect(getIt<SettingsRepository>().lastReleaseAt, firstOpening);
      expect(getIt<SettingsRepository>().lastReleaseReason,
          IntakeReason.initialLoad);
    });
  });
}
