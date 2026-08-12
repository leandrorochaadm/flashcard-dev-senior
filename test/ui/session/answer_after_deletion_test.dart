import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/session_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/cards/card_deletion_service.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/time_on_card_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/card_scheduler.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flashcard_dev_senior/ui/session/session_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

/// A card can be erased while the session that is showing it sits on the
/// navigation stack — the collection screen and the mirroring import both do
/// it. Answering then used to write the on-screen snapshot back, which brought
/// the erased card back to life together with a review log for it.
///
/// No `WidgetTester` here: the ViewModel is built by hand, which is what keeps
/// this runnable on the plain Dart VM.
void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  test('answering a card that was erased mid-session brings nothing back',
      () async {
    final db = await SembastAdapter.open(
      newDatabaseFactoryMemory(),
      'flashcards_answer_after_deletion_test',
    );
    final cards = CardRepository(db);
    final logs = ReviewLogRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(now);

    await cards.saveAll([
      newCard(
        'due-1',
        subject: 'Estado',
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: now.subtract(const Duration(hours: 1)),
      ),
      newCard(
        'due-2',
        subject: 'Estado',
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);

    final duePolicy = DueCardsPolicy(cards);
    final viewModel = SessionViewModel(
      CardScheduler(
        FsrsAdapter(settings.activeParameters),
        MovingCeiling(settings, cards),
        cards,
      ),
      SessionPolicy(),
      duePolicy,
      TimeOnCardPolicy(),
      cards,
      logs,
      SessionRepository(db),
      settings,
      FsrsAdapter(settings.activeParameters),
      FakeClock(now),
    );

    await viewModel.start(['Estado']);
    final showing = duePolicy.nextDueCard(now, 'Estado', skip: const {})!;

    // What the collection screen does while the session is on the stack.
    await CardDeletionService(cards, logs)
        .delete(CardDeletionSelection.single(cards.all, showing.id));

    await viewModel.answer(Rating.good);

    expect(cards.byId(showing.id), isNull, reason: 'it must stay erased');
    expect(
      logs.all.where((log) => log.cardId == showing.id),
      isEmpty,
      reason: 'no review for a card nobody can see',
    );
    // The round carries on with what is left.
    expect(cards.all, hasLength(1));

    viewModel.dispose();
  });
}
