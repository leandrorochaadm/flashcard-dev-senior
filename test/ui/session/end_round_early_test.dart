import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/session_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
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

/// Giving up on a round is not giving up on what was answered in it: every
/// answer is already saved card by card, and ending the round only drops the
/// time that was left.
///
/// No `WidgetTester` here: the ViewModel is built by hand, which is what keeps
/// this runnable on the plain Dart VM.
void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  /// [factory] is what makes a second ViewModel see the first one's data:
  /// `newDatabaseFactoryMemory()` creates an empty world every time it is
  /// called, so reopening a database means reusing the factory, not the name.
  Future<(SessionViewModel, CardRepository, ReviewLogRepository,
      SessionRepository)> buildViewModel(
    String dbName, {
    DatabaseFactory? factory,
  }) async {
    final db =
        await SembastAdapter.open(factory ?? newDatabaseFactoryMemory(), dbName);
    final cards = CardRepository(db);
    final logs = ReviewLogRepository(db);
    final settings = SettingsRepository(db);
    final sessions = SessionRepository(db);
    await settings.load(now);

    await cards.saveAll([
      for (var i = 1; i <= 3; i++)
        newCard(
          'due-$i',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(Duration(minutes: 60 - i)),
        ),
    ]);

    final viewModel = SessionViewModel(
      CardScheduler(
        FsrsAdapter(settings.activeParameters),
        MovingCeiling(settings, cards),
        cards,
      ),
      SessionPolicy(),
      DueCardsPolicy(cards),
      TimeOnCardPolicy(),
      cards,
      logs,
      sessions,
      settings,
      FsrsAdapter(settings.activeParameters),
      FakeClock(now),
    );
    return (viewModel, cards, logs, sessions);
  }

  test('ending the round early keeps every answer already given', () async {
    final (viewModel, _, logs, sessions) =
        await buildViewModel('flashcards_end_round_early_test');

    await viewModel.start(['Estado']);
    await viewModel.answer(Rating.good);
    await viewModel.answer(Rating.again);

    await viewModel.endRound();

    final state = viewModel.state.value;
    expect(state, isA<SessionRoundBreak>());
    expect((state as SessionRoundBreak).endedEarly, isTrue);

    expect(logs.all, hasLength(2), reason: 'both answers stay logged');
    expect(viewModel.session!.answered, 2);
    expect(viewModel.session!.recalled, 1);

    // The session is persisted as ended, so resuming does not hand the
    // abandoned time back.
    final saved = await sessions.unfinished();
    expect(saved!.remainingInRound, Duration.zero);

    viewModel.dispose();
  });

  test('reopening the app on an ended round goes straight to the break',
      () async {
    const dbName = 'flashcards_end_round_resume_test';
    final factory = newDatabaseFactoryMemory();
    final (viewModel, _, _, _) = await buildViewModel(dbName, factory: factory);
    await viewModel.start(['Estado', 'Widgets']);
    await viewModel.endRound();
    viewModel.dispose();

    // Same database, new ViewModel: what `init` finds is the session left
    // behind, whose round has no time on it.
    final (resumed, _, _, _) = await buildViewModel(dbName, factory: factory);
    await resumed.init();

    expect(
      resumed.state.value,
      isA<SessionRoundBreak>(),
      reason: 'no card may be served on a round that is already over',
    );
    expect(
      (resumed.state.value as SessionRoundBreak).endedEarly,
      isTrue,
      reason: 'the reload still knows the round was stopped by hand',
    );

    resumed.dispose();
  });

  test('ending the session goes straight to the scoreboard', () async {
    final (viewModel, _, _, sessions) =
        await buildViewModel('flashcards_end_session_test');

    await viewModel.start(['Estado', 'Widgets']);
    await viewModel.answer(Rating.good);
    await viewModel.endSession();

    final state = viewModel.state.value;
    expect(state, isA<SessionScoreboard>());
    expect((state as SessionScoreboard).session.answered, 1);
    expect(state.session.finished, isTrue);

    // Nothing is left behind to resume on the next opening.
    expect(await sessions.unfinished(), isNull);

    viewModel.dispose();
  });

  test('the round commands do nothing before a session starts', () async {
    final (viewModel, _, _, _) =
        await buildViewModel('flashcards_no_session_test');

    await viewModel.endRound();
    await viewModel.endSession();
    await viewModel.extendRound();
    await viewModel.nextRound();

    expect(viewModel.session, isNull);
    expect(viewModel.state.value, isA<SessionLoading>());

    viewModel.dispose();
  });

  test('giving up on the card on screen schedules nothing', () async {
    final (viewModel, cards, logs, _) =
        await buildViewModel('flashcards_end_round_unanswered_test');

    await viewModel.start(['Estado']);
    final showing = (viewModel.state.value as SessionShowingQuestion).card;
    final dueBefore = showing.dueAt;

    viewModel.reveal();
    await viewModel.endRound();

    expect(logs.all, isEmpty, reason: 'nothing was answered');
    expect(
      cards.byId(showing.id)!.dueAt,
      dueBefore,
      reason: 'reading the answer is not rating it',
    );
    expect(viewModel.session!.answered, 0);

    viewModel.dispose();
  });

  test('a round ended while paused does not freeze the next one', () async {
    final (viewModel, _, _, _) =
        await buildViewModel('flashcards_end_round_paused_test');

    await viewModel.start(['Estado', 'Widgets']);
    viewModel.togglePause();
    await viewModel.endRound();
    await viewModel.nextRound();

    expect(viewModel.paused.value, isFalse);

    viewModel.dispose();
  });
}
