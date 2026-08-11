import 'dart:math' as math;

import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/scheduling/card_scheduler.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

/// Always fuzzes to the top of the ±10% band, to prove step 5 still cuts.
final class _MaxFuzzRandom implements math.Random {
  @override
  double nextDouble() => 1;

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => max - 1;
}

void main() {
  final firstOpening = DateTime(2026, 8, 11);
  final window = ScheduleWindow.forFirstOpening(firstOpening);

  ({CardScheduler scheduler, FakeCollection collection}) build({
    math.Random? random,
    int releasedCards = 100,
  }) {
    final collection = FakeCollection([
      for (var i = 0; i < releasedCards; i++)
        newCard('c$i', importedAt: firstOpening, introducedAt: firstOpening),
    ]);
    final ceiling = MovingCeiling(FakeWindow(window), collection);
    return (
      scheduler: CardScheduler(FsrsAdapter(), ceiling, collection,
          random: random),
      collection: collection,
    );
  }

  Card graduated(DateTime now, {double stability = 30}) => newCard(
        'graduated',
        importedAt: firstOpening,
        introducedAt: firstOpening,
        state: CardState.review,
        stability: stability,
        dueAt: now,
      ).copyWith(
        difficultyFsrs: 5,
        lastReviewedAt: now.subtract(const Duration(days: 3)),
        reps: 5,
      );

  group('short cycle', () {
    test('"errei" always sends the card back to 15 minutes', () {
      final built = build();
      final now = DateTime(2026, 8, 11, 9);

      for (final start in [
        newCard('n', importedAt: firstOpening, introducedAt: firstOpening),
        graduated(now),
      ]) {
        final answered = built.scheduler.apply(start, Rating.again, now);
        expect(answered.dueAt, now.add(const Duration(minutes: 15)));
        expect(answered.lapses, start.lapses + 1);
      }
    });

    test('the ladder climbs 15 min → 1 h → 4 h → 1 day and then graduates', () {
      final built = build();
      var now = DateTime(2026, 8, 11, 9);
      var card = newCard('n', importedAt: firstOpening, introducedAt: firstOpening);

      final expected = [
        const Duration(minutes: 15),
        const Duration(hours: 1),
        const Duration(hours: 4),
        const Duration(days: 1),
      ];

      for (final step in expected) {
        card = built.scheduler.apply(card, Rating.good, now);
        expect(card.dueAt!.difference(now), step);
        expect(card.state.isLearning, isTrue);
        now = card.dueAt!;
      }

      card = built.scheduler.apply(card, Rating.good, now);
      expect(card.state, CardState.review, reason: 'it graduated');
      expect(card.dueAt!.difference(now).inHours, greaterThan(24));
    });

    test('missing on any step goes back to step 0', () {
      final built = build();
      var now = DateTime(2026, 8, 11, 9);
      var card = newCard('n', importedAt: firstOpening, introducedAt: firstOpening);

      // Climb two steps, then miss.
      card = built.scheduler.apply(card, Rating.good, now);
      now = card.dueAt!;
      card = built.scheduler.apply(card, Rating.good, now);
      now = card.dueAt!;
      expect(card.learningStep, 2);

      card = built.scheduler.apply(card, Rating.again, now);
      expect(card.learningStep, 0);
      expect(card.dueAt, now.add(const Duration(minutes: 15)));
    });
  });

  group('the moving ceiling has the final word', () {
    test('no rating ever schedules beyond the ceiling of the day', () {
      final dates = [
        DateTime(2026, 8, 11, 9),
        DateTime(2026, 8, 18, 9),
        DateTime(2026, 8, 25, 9),
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 8, 9),
      ];

      for (final now in dates) {
        final built = build();
        final ceiling = MovingCeiling(FakeWindow(window), built.collection)
            .forDate(now);
        for (final rating in Rating.values) {
          final answered =
              built.scheduler.apply(graduated(now), rating, now);
          expect(
            answered.dueAt!.difference(now),
            lessThanOrEqualTo(ceiling),
            reason: '$rating on $now must not exceed $ceiling',
          );
        }
      }
    });

    // The most likely silent bug: a ceiling applied before spreading would let
    // a 3-day card land on 3.3 days.
    test('fuzz pushed to the top of the band is still cut by the ceiling', () {
      final built = build(random: _MaxFuzzRandom());
      final now = DateTime(2026, 8, 11, 9);
      final ceiling =
          MovingCeiling(FakeWindow(window), built.collection).forDate(now);

      final answered = built.scheduler.apply(graduated(now), Rating.easy, now);

      expect(answered.dueAt, now.add(ceiling));
      expect(answered.dueAt!.difference(now), ceiling);
    });

    test('the ceiling limits the scheduled date, never the stability', () {
      final built = build();
      final now = DateTime(2026, 9, 8, 9); // ceiling is at the floor here
      final answered =
          built.scheduler.apply(graduated(now, stability: 40), Rating.easy, now);

      expect(answered.dueAt!.difference(now).inDays, lessThanOrEqualTo(1));
      expect(answered.stability, greaterThan(7),
          reason: 'a card can be due tomorrow and still be firm/ready');
    });
  });

  test('the four buttons produce four different return dates', () {
    final now = DateTime(2026, 8, 11, 9);
    // A big collection far from the deadline leaves the ceiling loose enough
    // for the four intervals to stay apart instead of all being cut to it.
    final built = build(releasedCards: 1200);
    final loose = ScheduleWindow(
      startDate: DateTime(2026, 8, 10),
      targetDate: DateTime(2027, 6, 1),
    );
    final scheduler = CardScheduler(
      FsrsAdapter(),
      MovingCeiling(FakeWindow(loose), built.collection),
      built.collection,
    );

    final intervals = scheduler.previewIntervals(graduated(now), now);

    expect(intervals.values.toSet().length, Rating.values.length);
    expect(intervals[Rating.again], const Duration(minutes: 15));
    expect(intervals[Rating.hard]!, lessThan(intervals[Rating.good]!));
    expect(intervals[Rating.good]!, lessThan(intervals[Rating.easy]!));
  });

  test('load balancing prefers the emptier of the candidate days', () {
    final now = DateTime(2026, 8, 11, 9);
    final built = build(releasedCards: 0);
    // Everything already scheduled piles on one single day.
    final crowdedDay = now.add(const Duration(days: 3));
    built.collection.addAll([
      for (var i = 0; i < 40; i++)
        newCard('busy$i',
            importedAt: firstOpening,
            introducedAt: firstOpening,
            dueAt: crowdedDay),
    ]);

    final loose = ScheduleWindow(
      startDate: DateTime(2026, 8, 10),
      targetDate: DateTime(2027, 6, 1),
    );
    final scheduler = CardScheduler(
      FsrsAdapter(),
      MovingCeiling(FakeWindow(loose), built.collection),
      built.collection,
      random: _MaxFuzzRandom(),
    );

    final answered = scheduler.apply(graduated(now, stability: 3), Rating.good, now);

    expect(dateOnly(answered.dueAt!), isNot(dateOnly(crowdedDay)));
  });

}
