import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/cards/card_deletion_service.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/ui/cards/cards_state.dart';
import 'package:flashcard_dev_senior/ui/cards/cards_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

/// The collection screen offers a way out of the ~20-a-day ramp: whatever is
/// still held back can be released in one tap (decision of 12/08/2026).
///
/// No `WidgetTester` here: `CardsView` reaches `dart:js_interop` through the
/// router, so a widget test of that screen would not even compile on the Dart
/// VM. The ViewModel is built by hand, which is what the counting and the
/// saving live in.
void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  Future<({CardsViewModel viewModel, CardRepository cards})> build(
    String database,
  ) async {
    final db = await SembastAdapter.open(newDatabaseFactoryMemory(), database);
    final cards = CardRepository(db);
    final logs = ReviewLogRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(now);

    final intake = ContentIntakePolicy(
      settings,
      cards,
      // No history: this test never exercises the daily quota, only the
      // release that happens outside it.
      FakeHistory(),
      DueCardsPolicy(cards),
    );
    return (
      viewModel: CardsViewModel(
        cards,
        settings,
        FakeClock(now),
        CardDeletionService(cards, logs),
        intake,
      ),
      cards: cards,
    );
  }

  test('the screen counts what is held back in the whole collection', () async {
    final built = await build('flashcards_release_pending_count_test');
    await built.cards.saveAll([
      newCard('held-1', importedAt: importedAt),
      newCard('held-2', importedAt: importedAt),
      newCard('out-1', importedAt: importedAt, introducedAt: importedAt),
    ]);

    built.viewModel.start();

    final state = built.viewModel.state.value as CardsReady;
    expect(state.pendingCount, 2);
    expect(state.totalCount, 3);

    built.viewModel.dispose();
  });

  test('releasing them all stamps every held-back card and empties the banner',
      () async {
    final built = await build('flashcards_release_pending_release_test');
    await built.cards.saveAll([
      newCard('held-1', importedAt: importedAt),
      newCard('held-2', importedAt: importedAt),
      newCard('out-1', importedAt: importedAt, introducedAt: importedAt),
    ]);
    built.viewModel.start();

    final released = await built.viewModel.releaseAllPending();

    expect(released, 2);
    expect((built.viewModel.state.value as CardsReady).pendingCount, 0);
    for (final id in ['held-1', 'held-2']) {
      final card = built.cards.byId(id)!;
      expect(card.introducedAt, now, reason: '$id entered the study today');
      expect(card.dueAt, now, reason: '$id is due at once');
    }

    built.viewModel.dispose();
  });

  test('with nothing held back it releases nothing and writes nothing',
      () async {
    final built = await build('flashcards_release_pending_empty_test');
    final dueAt = now.add(const Duration(days: 6));
    await built.cards.saveAll([
      newCard(
        'out-1',
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: dueAt,
      ),
    ]);
    built.viewModel.start();

    final released = await built.viewModel.releaseAllPending();

    expect(released, 0);
    // A save would pull the schedule of an already released card back to now.
    expect(built.cards.byId('out-1')!.dueAt, dueAt);
    expect(built.cards.byId('out-1')!.introducedAt, importedAt);

    built.viewModel.dispose();
  });
}
