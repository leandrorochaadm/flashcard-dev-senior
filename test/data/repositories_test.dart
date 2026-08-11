import 'package:flashcard_dev_senior/data/database/app_database.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/session_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 10);

  Future<SembastAdapter> openDatabase() =>
      SembastAdapter.open(newDatabaseFactoryMemory(), 'flashcards_test');

  group('card repository', () {
    test('it reloads what was saved and answers null for what is missing',
        () async {
      final db = await openDatabase();
      final repository = CardRepository(db);
      await repository.save(newCard('a', importedAt: importedAt));

      final reopened = CardRepository(db);
      await reopened.load();

      expect(reopened.byId('a'), isNotNull);
      expect(reopened.byId('nope'), isNull);
    });

    test('a card can be recognized by its question text', () async {
      final db = await openDatabase();
      final repository = CardRepository(db);
      await repository.save(newCard('a', importedAt: importedAt));

      expect(repository.byQuestion('Pergunta a')!.id, 'a');
      expect(repository.byQuestion('outra'), isNull);
    });

    test('it lists the subjects of the collection, sorted', () async {
      final db = await openDatabase();
      final repository = CardRepository(db);
      await repository.saveAll([
        newCard('a', subject: 'Widgets', importedAt: importedAt),
        newCard('b', subject: 'Async', importedAt: importedAt),
        newCard('c', subject: 'Async', importedAt: importedAt),
      ]);

      expect(repository.subjects, ['Async', 'Widgets']);
    });

    test('changes are published as a Stream, never as a ValueNotifier',
        () async {
      final db = await openDatabase();
      final repository = CardRepository(db);
      final seen = <int>[];
      final subscription =
          repository.changes.listen((cards) => seen.add(cards.length));

      await repository.save(newCard('a', importedAt: importedAt));
      await repository.save(newCard('b', importedAt: importedAt));
      await repository.delete('a');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [1, 2, 1]);
      await subscription.cancel();
      await repository.dispose();
    });
  });

  group('review log repository', () {
    ReviewLog logAt(DateTime at, {ReviewSource source = ReviewSource.session}) =>
        ReviewLog(
          cardId: 'a',
          reviewedAt: at,
          rating: Rating.good,
          elapsedDays: 1,
          predictedRetention: 0.9,
          stabilityBefore: 3,
          timeOnCard: null,
          source: source,
        );

    test('the daily count feeds the intake rate and ignores mock interviews',
        () async {
      final db = await openDatabase();
      final repository = ReviewLogRepository(db);

      await repository.append(logAt(now));
      await repository.append(logAt(now.add(const Duration(hours: 2))));
      await repository.append(logAt(now, source: ReviewSource.mockInterview));
      await repository.append(logAt(now.subtract(const Duration(days: 1))));

      expect(repository.reviewsOn(now), 2);
      expect(repository.reviewsOn(now.subtract(const Duration(days: 1))), 1);
      expect(repository.reviewsOn(now.add(const Duration(days: 1))), 0);
      expect(repository.count, 4);
      expect(repository.sessionOnly.length, 3);
    });

    test('the history survives a reload', () async {
      final db = await openDatabase();
      await ReviewLogRepository(db).append(logAt(now));

      final reopened = ReviewLogRepository(db);
      await reopened.load();

      expect(reopened.all.single.cardId, 'a');
    });
  });

  group('session repository', () {
    const policy = SessionPolicy();
    const subjects = ['Estado', 'Widgets', 'Testes', 'Async', 'Plataforma'];

    test('an interrupted session comes back on the same round, same time left',
        () async {
      final db = await openDatabase();
      final repository = SessionRepository(db);
      var session = policy.start('s1', now, subjects);
      session = policy.advanceRound(policy.advanceRound(session));
      session = policy.tick(session, const Duration(minutes: 3));
      await repository.save(session);

      final resumed = await repository.unfinished();

      expect(resumed!.currentRound, 2);
      expect(resumed.remainingInRound, const Duration(minutes: 2));
    });

    test('a finished session is not offered for resuming', () async {
      final db = await openDatabase();
      final repository = SessionRepository(db);
      await repository.save(
        policy.start('s1', now, subjects).copyWith(finished: true),
      );

      expect(await repository.unfinished(), isNull);
      expect((await repository.all()).length, 1);
    });

    test('sessions can be deleted', () async {
      final db = await openDatabase();
      final repository = SessionRepository(db);
      await repository.save(policy.start('s1', now, subjects));

      await repository.delete('s1');

      expect(await repository.all(), isEmpty);
    });
  });

  group('settings repository', () {
    test('the backup date is remembered across openings', () async {
      final db = await openDatabase();
      final settings = SettingsRepository(db);
      await settings.load(now);
      expect(settings.lastBackupAt, isNull);

      await settings.markBackup(now);

      final reopened = SettingsRepository(db);
      await reopened.load(now);
      expect(reopened.lastBackupAt, now);
    });

    test('the review counter drives the re-tuning and resets on apply',
        () async {
      final db = await openDatabase();
      final settings = SettingsRepository(db);
      await settings.load(now);

      await settings.countReview();
      await settings.countReview();
      expect(settings.reviewsSinceTuning, 2);

      await settings.applyParameters(List<double>.filled(21, 0.5), now);
      expect(settings.reviewsSinceTuning, 0);
    });

    test('reverting with no tuning at all answers null', () async {
      final db = await openDatabase();
      final settings = SettingsRepository(db);
      await settings.load(now);

      expect(await settings.revertParameters(), isNull);
    });

    test('the deadline question is only asked until it is answered', () async {
      final db = await openDatabase();
      final settings = SettingsRepository(db);
      await settings.load(now);
      expect(settings.deadlineAnswered, isFalse);

      await settings.setDeadlineAnswered(true);

      final reopened = SettingsRepository(db);
      await reopened.load(now);
      expect(reopened.deadlineAnswered, isTrue);
    });

    test('reading the window before load() fails loudly', () {
      expect(() => SettingsRepository(_UnusedDatabase()).window,
          throwsA(isA<StateError>()));
    });
  });
}

/// Never touched: the test above fails before any query happens.
final class _UnusedDatabase implements AppDatabase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
