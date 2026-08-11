import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final firstOpening = DateTime(2026, 8, 11, 8);
  final window = ScheduleWindow.forFirstOpening(firstOpening);

  ({ContentIntakePolicy policy, FakeCollection collection, FakeHistory history})
      build({int pending = 100, List<Card> released = const []}) {
    final collection = FakeCollection([
      for (var i = 0; i < pending; i++)
        newCard('p$i', importedAt: firstOpening),
      ...released,
    ]);
    final history = FakeHistory();
    return (
      policy: ContentIntakePolicy(
        FakeWindow(window),
        collection,
        history,
        DueCardsPolicy(collection),
      ),
      collection: collection,
      history: history,
    );
  }

  test('the initial load releases about 20 cards a day for five days', () {
    final built = build();
    for (var day = 1; day <= 5; day++) {
      final now = firstOpening.add(Duration(days: day - 1));
      final release = built.policy.releaseToday(now);

      expect(release.quota, 20, reason: 'day $day of the initial load');
      expect(release.reason, IntakeReason.initialLoad);
      for (final card in release.cards) {
        built.collection.save(card.copyWith(introducedAt: now));
      }
    }
    expect(built.collection.all.where((card) => card.isReleased).length, 100);
  });

  // The rule that disappears in a refactor: if "studied little" applied here,
  // the last cards would enter too late to firm up before the deadline.
  test('"studied little" does NOT reduce the batch during the initial load', () {
    final built = build();
    // No review recorded on any day: the worst possible study history.
    for (var day = 1; day <= 5; day++) {
      final now = firstOpening.add(Duration(days: day - 1));
      final release = built.policy.releaseToday(now);

      expect(release.quota, 20);
      expect(release.reason, IntakeReason.initialLoad);
      expect(release.shouldWarn, isFalse);
      for (final card in release.cards) {
        built.collection.save(card.copyWith(introducedAt: now));
      }
    }
    expect(built.collection.all.where((card) => card.isReleased).length, 100);
  });

  test('outside the initial load, no study at all releases nothing and warns',
      () {
    final built = build();
    final day10 = firstOpening.add(const Duration(days: 9));

    final release = built.policy.releaseToday(day10);

    expect(release.quota, 0);
    expect(release.shouldWarn, isTrue);
  });

  test('the forecast holding the intake back is never silent', () {
    // A pile-up: everything already scheduled for tomorrow.
    final tomorrow = firstOpening.add(const Duration(days: 10));
    final collection = FakeCollection([
      for (var i = 0; i < 200; i++)
        newCard('r$i',
            importedAt: firstOpening,
            introducedAt: firstOpening,
            dueAt: tomorrow),
      for (var i = 0; i < 10; i++) newCard('p$i', importedAt: firstOpening),
    ]);
    final policy = ContentIntakePolicy(
      FakeWindow(window),
      collection,
      FakeHistory(),
      DueCardsPolicy(collection),
    );

    final release = policy.releaseToday(firstOpening.add(const Duration(days: 9)));

    expect(release.reason, IntakeReason.heldByForecast);
    expect(release.cards, isEmpty);
    expect(release.shouldWarn, isTrue);
  });

  group('the 80% signal', () {
    test('warns with the current percentage but never blocks', () {
      final built = build(
        pending: 0,
        released: [
          for (var i = 0; i < 6; i++)
            newCard('firm$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 10),
          for (var i = 0; i < 4; i++)
            newCard('soft$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 2),
        ],
      );

      expect(built.policy.firmRatio(), closeTo(0.60, 0.001));
      expect(built.policy.shouldWarnBeforeImport(), isTrue);
    });

    test('does not warn at 80% or above', () {
      final built = build(
        pending: 0,
        released: [
          for (var i = 0; i < 8; i++)
            newCard('firm$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 10),
          for (var i = 0; i < 2; i++)
            newCard('soft$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 2),
        ],
      );

      expect(built.policy.shouldWarnBeforeImport(), isFalse);
    });
  });
}
