import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final targetDate = DateTime(2026, 9, 9);

  Card withStability(double stability) =>
      newCard('c', importedAt: importedAt, stability: stability);

  test('firm means the memory would last a week', () {
    expect(withStability(6.9).isFirm, isFalse);
    expect(withStability(7).isFirm, isTrue);
  });

  test('the ready target tightens as the deadline approaches', () {
    final card = withStability(20);

    expect(card.isReadyOn(DateTime(2026, 8, 11), targetDate), isFalse); // 29 d
    expect(card.isReadyOn(DateTime(2026, 8, 21), targetDate), isTrue); // 19 d
  });

  // The subject map exists for this very day.
  test('on the target date a fragile card is still NOT ready', () {
    final onTarget = DateTime(2026, 9, 9, 20);

    expect(withStability(0.5).isReadyOn(onTarget, targetDate), isFalse);
    expect(withStability(1).isReadyOn(onTarget, targetDate), isTrue);
  });

  test('past the target date the floor of one day still applies', () {
    final after = DateTime(2026, 9, 20);

    expect(withStability(0.4).isReadyOn(after, targetDate), isFalse);
    expect(withStability(1.2).isReadyOn(after, targetDate), isTrue);
  });

  test('a problem card is four lapses in total, not in a row', () {
    expect(newCard('c', importedAt: importedAt, lapses: 3).isProblem, isFalse);
    expect(newCard('c', importedAt: importedAt, lapses: 4).isProblem, isTrue);
  });

  test('importing is not releasing', () {
    expect(newCard('c', importedAt: importedAt).isReleased, isFalse);
    expect(
      newCard('c', importedAt: importedAt, introducedAt: importedAt).isReleased,
      isTrue,
    );
  });
}
