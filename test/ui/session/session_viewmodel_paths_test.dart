import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/session_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/time_on_card_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/card_scheduler.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flashcard_dev_senior/ui/session/session_state.dart';
import 'package:flashcard_dev_senior/ui/session/session_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

/// The screens the study session can open on, and the ways out of a round —
/// all of it without a `WidgetTester`, which is what keeps the sequencing of
/// the ViewModel testable on the plain Dart VM.
void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  Future<SessionViewModel> buildViewModel(
    String dbName, {
    List<Card> cards = const [],
  }) async {
    final db = await SembastAdapter.open(newDatabaseFactoryMemory(), dbName);
    final cardRepository = CardRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(now);
    await cardRepository.saveAll(cards);

    return SessionViewModel(
      CardScheduler(
        FsrsAdapter(settings.activeParameters),
        MovingCeiling(settings, cardRepository),
        cardRepository,
      ),
      SessionPolicy(),
      DueCardsPolicy(cardRepository),
      TimeOnCardPolicy(),
      cardRepository,
      ReviewLogRepository(db),
      SessionRepository(db),
      settings,
      FsrsAdapter(settings.activeParameters),
      FakeClock(now),
    );
  }

  Card dueCard(String id, String subject) => newCard(
        id,
        subject: subject,
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: now.subtract(const Duration(hours: 1)),
      );

  test('an empty collection opens on the cleared-day screen', () async {
    final viewModel = await buildViewModel('flashcards_vm_empty_test');

    await viewModel.init();

    expect(viewModel.state.value, isA<SessionDayCleared>());
    viewModel.dispose();
  });

  test('with cards due, the session opens on the subject picker', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_picker_test',
      cards: [dueCard('due-1', 'Estado'), dueCard('due-2', 'Widgets')],
    );

    await viewModel.init();

    final state = viewModel.state.value;
    expect(state, isA<SessionChooseSubjects>());
    expect(
      [
        for (final queue in (state as SessionChooseSubjects).availableSubjects)
          queue.subject,
      ],
      containsAll(<String>['Estado', 'Widgets']),
    );
    viewModel.dispose();
  });

  test('revealing the answer shows what each button would schedule', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_reveal_test',
      cards: [dueCard('due-1', 'Estado')],
    );

    await viewModel.start(['Estado']);
    viewModel.reveal();

    final state = viewModel.state.value;
    expect(state, isA<SessionShowingAnswer>());
    expect((state as SessionShowingAnswer).previews.keys, Rating.values);
    viewModel.dispose();
  });

  test('extending gives the subject another full round', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_extend_test',
      cards: [dueCard('due-1', 'Estado'), dueCard('due-2', 'Estado')],
    );

    await viewModel.start(['Estado']);
    await viewModel.endRound();
    await viewModel.extendRound();

    expect(viewModel.state.value, isA<SessionShowingQuestion>());
    expect(viewModel.session!.remainingInRound, SessionPolicy.roundDuration);
    expect(viewModel.roundRemaining.value, SessionPolicy.roundDuration);
    viewModel.dispose();
  });

  test('the last round hands over to the scoreboard', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_scoreboard_test',
      cards: [dueCard('due-1', 'Estado')],
    );

    await viewModel.start(['Estado']);
    await viewModel.endRound();
    await viewModel.nextRound();

    expect(viewModel.state.value, isA<SessionScoreboard>());
    expect(viewModel.session!.finished, isTrue);
    viewModel.dispose();
  });

  test('the next round starts on the next subject', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_next_round_test',
      cards: [dueCard('due-1', 'Estado'), dueCard('due-2', 'Widgets')],
    );

    await viewModel.start(['Estado', 'Widgets']);
    await viewModel.endRound();
    await viewModel.nextRound();

    final state = viewModel.state.value;
    expect(state, isA<SessionShowingQuestion>());
    expect((state as SessionShowingQuestion).subject, 'Widgets');
    viewModel.dispose();
  });

  test('an unfinished session is resumed where it stopped', () async {
    final factory = newDatabaseFactoryMemory();
    const dbName = 'flashcards_vm_resume_test';
    final db = await SembastAdapter.open(factory, dbName);
    final cards = CardRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(now);
    await cards.saveAll([dueCard('due-1', 'Estado')]);

    SessionViewModel build(SembastAdapter database) => SessionViewModel(
          CardScheduler(
            FsrsAdapter(settings.activeParameters),
            MovingCeiling(settings, cards),
            cards,
          ),
          SessionPolicy(),
          DueCardsPolicy(cards),
          TimeOnCardPolicy(),
          cards,
          ReviewLogRepository(database),
          SessionRepository(database),
          settings,
          FsrsAdapter(settings.activeParameters),
          FakeClock(now),
        );

    final first = build(db);
    await first.start(['Estado']);
    first.dispose();

    final resumed = build(await SembastAdapter.open(factory, dbName));
    await resumed.init();

    expect(resumed.state.value, isA<SessionShowingQuestion>());
    expect(resumed.session!.subjects, ['Estado']);
    resumed.dispose();
  });

  test('the stopwatch is opt-in and the pause is a toggle', () async {
    final viewModel = await buildViewModel(
      'flashcards_vm_toggles_test',
      cards: [dueCard('due-1', 'Estado')],
    );

    expect(viewModel.stopwatchVisible.value, isFalse);
    viewModel.toggleStopwatch();
    expect(viewModel.stopwatchVisible.value, isTrue);

    viewModel.togglePause();
    expect(viewModel.paused.value, isTrue);
    viewModel.togglePause();
    expect(viewModel.paused.value, isFalse);

    viewModel.dispose();
  });
}
