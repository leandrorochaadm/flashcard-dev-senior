import 'package:flashcard_dev_senior/domain/policies/card_listing_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);

  test('counts the cards of every subject', () {
    final counts = CardListingPolicy.countBySubject([
      newCard('a', importedAt: importedAt, subject: 'Estado'),
      newCard('b', importedAt: importedAt, subject: 'Estado'),
      newCard('c', importedAt: importedAt, subject: 'Testes'),
    ]);

    expect(counts, {'Estado': 2, 'Testes': 1});
  });

  test('counts nothing for an empty collection', () {
    expect(CardListingPolicy.countBySubject([]), isEmpty);
  });

  test('sorts by dueAt ascending', () {
    final late = newCard('late',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 20));
    final earlier = newCard('earlier',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 15));

    final sorted = CardListingPolicy.sortForCollection([late, earlier]);

    expect(sorted.map((card) => card.id), ['earlier', 'late']);
  });

  test('problem cards surface first regardless of dueAt', () {
    final soonHealthy = newCard('soonHealthy',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 12));
    final laterProblem = newCard('laterProblem',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 25), lapses: 4);

    final sorted =
        CardListingPolicy.sortForCollection([soonHealthy, laterProblem]);

    expect(sorted.map((card) => card.id), ['laterProblem', 'soonHealthy']);
  });

  test('tied dueAt keeps a stable relative order', () {
    final sameDate = DateTime(2026, 8, 20);
    final first = newCard('first', importedAt: importedAt, dueAt: sameDate);
    final second = newCard('second', importedAt: importedAt, dueAt: sameDate);

    final sorted = CardListingPolicy.sortForCollection([first, second]);

    expect(sorted.map((card) => card.id), ['first', 'second']);
  });

  test('cards without dueAt sink to the end of their group', () {
    final dated = newCard('dated',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 20));
    final undated = newCard('undated', importedAt: importedAt, dueAt: null);

    final sorted = CardListingPolicy.sortForCollection([undated, dated]);

    expect(sorted.map((card) => card.id), ['dated', 'undated']);
  });

  test('problem group and healthy group are each sorted independently', () {
    final problemLate = newCard('problemLate',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 25), lapses: 4);
    final problemEarly = newCard('problemEarly',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 15), lapses: 4);
    final healthyLate = newCard('healthyLate',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 22));
    final healthyEarly = newCard('healthyEarly',
        importedAt: importedAt, dueAt: DateTime(2026, 8, 13));

    final sorted = CardListingPolicy.sortForCollection(
      [healthyLate, problemLate, healthyEarly, problemEarly],
    );

    expect(
      sorted.map((card) => card.id),
      ['problemEarly', 'problemLate', 'healthyEarly', 'healthyLate'],
    );
  });
}
