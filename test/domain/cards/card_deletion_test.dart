import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/domain/cards/card_deletion_service.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final reviewedAt = DateTime(2026, 8, 20, 10);

  ReviewLog logFor(String cardId) => ReviewLog(
        cardId: cardId,
        reviewedAt: reviewedAt,
        rating: Rating.good,
        elapsedDays: 1,
        predictedRetention: 0.9,
        stabilityBefore: 2,
        timeOnCard: const Duration(seconds: 20),
        source: ReviewSource.session,
      );

  /// The real repositories over an in-memory database: deletion is only
  /// correct if the card and its history leave the store together, and a fake
  /// would not prove that.
  Future<(CardRepository, ReviewLogRepository, CardDeletionService)>
      openCollection() async {
    final db = await SembastAdapter.open(
      newDatabaseFactoryMemory(),
      'flashcards_test',
    );
    final cards = CardRepository(db);
    final history = ReviewLogRepository(db);
    await cards.saveAll([
      newCard('a', importedAt: importedAt, subject: 'Estado'),
      newCard('b', importedAt: importedAt, subject: 'Estado'),
      newCard('c', importedAt: importedAt, subject: 'Testes'),
    ]);
    for (final id in ['a', 'b', 'c']) {
      await history.append(logFor(id));
    }
    return (cards, history, CardDeletionService(cards, history));
  }

  group('what a deletion request reaches', () {
    test('everything covers the whole collection', () async {
      final (cards, history, deletion) = await openCollection();

      expect(await deletion.delete(CardDeletionSelection.everything(cards.all)), 3);
      expect(cards.all, isEmpty);
      expect(history.all, isEmpty);
    });

    test('a subject leaves the other subjects untouched', () async {
      final (cards, history, deletion) = await openCollection();

      expect(
        await deletion.delete(CardDeletionSelection.subject(cards.all, 'Estado')),
        2,
      );
      expect(cards.all.single.id, 'c');
      expect(history.all.single.cardId, 'c');
    });

    test('an unknown subject deletes nothing', () async {
      final (cards, _, deletion) = await openCollection();

      expect(
        await deletion.delete(CardDeletionSelection.subject(cards.all, 'Redes')),
        0,
      );
      expect(cards.all, hasLength(3));
    });

    test('a single card takes only its own history', () async {
      final (cards, history, deletion) = await openCollection();

      expect(await deletion.delete(CardDeletionSelection.single(cards.all, 'b')), 1);
      expect(cards.all.map((card) => card.id), ['a', 'c']);
      expect(history.all.map((log) => log.cardId), ['a', 'c']);
    });

    test('deleting an id that is not there is a no-op, not an error', () async {
      final (cards, _, deletion) = await openCollection();

      expect(
        await deletion.delete(CardDeletionSelection.single(cards.all, 'nope')),
        0,
      );
      expect(cards.all, hasLength(3));
    });

    test('an explicit list of cards is taken as given', () async {
      final (cards, _, deletion) = await openCollection();

      expect(
        await deletion.delete(
          CardDeletionSelection.exactly(
            cards.all.where((card) => card.id != 'a'),
          ),
        ),
        2,
      );
      expect(cards.all.single.id, 'a');
    });
  });

  test('the deletion survives a reload — it reached the database', () async {
    final db = await SembastAdapter.open(
      newDatabaseFactoryMemory(),
      'flashcards_test',
    );
    final cards = CardRepository(db);
    final history = ReviewLogRepository(db);
    await cards.saveAll([
      newCard('a', importedAt: importedAt),
      newCard('b', importedAt: importedAt),
    ]);
    await history.append(logFor('a'));
    await history.append(logFor('b'));

    await CardDeletionService(cards, history)
        .delete(CardDeletionSelection.single(cards.all, 'a'));

    final reloadedCards = CardRepository(db);
    final reloadedHistory = ReviewLogRepository(db);
    await reloadedCards.load();
    await reloadedHistory.load();

    expect(reloadedCards.all.single.id, 'b');
    expect(reloadedHistory.all.single.cardId, 'b');
  });

  test('the collection stream announces the deletion', () async {
    final (cards, _, deletion) = await openCollection();
    final sizes = <int>[];
    final subscription = cards.changes.listen((all) => sizes.add(all.length));

    await deletion.delete(CardDeletionSelection.subject(cards.all, 'Estado'));
    await Future<void>.delayed(Duration.zero);

    expect(sizes, contains(1));
    await subscription.cancel();
    await cards.dispose();
  });
}
