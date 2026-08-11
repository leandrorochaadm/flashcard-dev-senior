import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 12);

  test('the elapsed interval is measured in decimal days', () {
    final card = newCard('a', importedAt: importedAt)
        .copyWith(lastReviewedAt: now.subtract(const Duration(hours: 36)));

    expect(card.observedIntervalDays(now), closeTo(1.5, 0.0001));
  });

  // Truncating here would report 0 for every rung of the short cycle, and the
  // calibration would be fitted on a constant.
  test('a four-hour interval is not truncated to zero', () {
    final card = newCard('a', importedAt: importedAt)
        .copyWith(lastReviewedAt: now.subtract(const Duration(hours: 4)));

    expect(card.observedIntervalDays(now), closeTo(4 / 24, 0.0001));
  });

  test('a card answered for the first time records zero', () {
    expect(newCard('a', importedAt: importedAt).observedIntervalDays(now), 0);
  });
}
