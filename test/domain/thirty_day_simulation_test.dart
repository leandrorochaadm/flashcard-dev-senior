import 'dart:math' as math;

import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/card_scheduler.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/domain_fakes.dart';

/// The test that is worth all the others: 30 days of study, day by day, with a
/// movable clock. It answers the question the client does not want to discover
/// on the target date — "does the method work?".
void main() {
  const subjects = ['Estado', 'Widgets', 'Testes', 'Async', 'Plataforma'];

  test('30 whole days respect the ceiling, the ramp and the initial load', () {
    final firstOpening = DateTime(2026, 8, 11, 8);
    final clock = FakeClock(firstOpening);
    final window = FakeWindow(ScheduleWindow.forFirstOpening(firstOpening));

    final collection = FakeCollection();
    final history = FakeHistory();
    final ceiling = MovingCeiling(window, collection);
    final dueCards = DueCardsPolicy(collection);
    final intake = ContentIntakePolicy(window, collection, history, dueCards);
    // Fixed seed: the fuzz is random by design, but the assertions must not be.
    final scheduler = CardScheduler(
      FsrsAdapter(),
      ceiling,
      collection,
      random: math.Random(42),
    );
    final answers = math.Random(7);

    // The 100 cards enter the database at once, each with its first review
    // date already spread — that is what the import preview shows (H5).
    // Releasing them for study is a separate decision (H16).
    for (var i = 0; i < 100; i++) {
      collection.save(
        newCard(
          'c${i.toString().padLeft(3, '0')}',
          subject: subjects[i % subjects.length],
          importedAt: firstOpening,
          dueAt: scheduler.firstDueDate(firstOpening),
        ),
      );
    }

    final reviewsPerDay = <int, int>{};
    var releasedOnDayFive = 0;

    for (var day = 1; day <= 30; day++) {
      final dayStart = dateOnly(clock.now()).add(const Duration(hours: 8));
      clock.set(dayStart);

      // 1. release today's batch (H16).
      final release = intake.releaseToday(clock.now());
      for (final card in release.cards) {
        collection.save(card.copyWith(introducedAt: clock.now()));
      }
      if (day == 5) {
        releasedOnDayFive =
            collection.all.where((card) => card.isReleased).length;
      }

      // 2. study the whole day, hour by hour, so the 15 min / 1 h / 4 h rungs
      //    of the short cycle come back on the same day, as they must.
      var reviews = 0;
      for (var hour = 0; hour < 14; hour++) {
        clock.set(dayStart.add(Duration(hours: hour)));
        final now = clock.now();
        final ceilingToday = ceiling.forDate(now);

        for (final card in dueCards.dueNow(now)) {
          // A 90% recall profile: 9 out of 10 reach the answer.
          final rating = answers.nextDouble() < 0.10
              ? Rating.again
              : (answers.nextDouble() < 0.30 ? Rating.hard : Rating.good);
          final answered = scheduler.apply(card, rating, now);
          collection.save(answered);
          reviews++;

          expect(
            answered.dueAt!.difference(now),
            lessThanOrEqualTo(ceilingToday),
            reason: 'day $day: ${answered.id} broke the ceiling of the day',
          );

          // No graduated card may come back twice on the same day: the ceiling
          // has a floor of one day precisely for this.
          if (answered.state == CardState.review) {
            expect(
              dateOnly(answered.dueAt!),
              isNot(dateOnly(now)),
              reason: 'day $day: ${answered.id} would show up twice today',
            );
          }
        }
      }

      reviewsPerDay[day] = reviews;
      history.record(dateOnly(dayStart), reviews);
      clock.set(dayStart.add(const Duration(days: 1)));
    }

    // Every card entered during the initial load, ~20 a day.
    expect(releasedOnDayFive, 100);
    expect(collection.all.where((card) => card.isReleased).length, 100);

    // The U-shaped curve: a heavy initial load, a short breather, then the ramp.
    final initialLoad = [for (var d = 1; d <= 6; d++) reviewsPerDay[d]!];
    final breather = [for (var d = 7; d <= 11; d++) reviewsPerDay[d]!];
    final homeStretch = [for (var d = 25; d <= 30; d++) reviewsPerDay[d]!];

    expect(_average(initialLoad), greaterThan(_average(breather)),
        reason: 'the first days are heavy, not light');
    expect(_average(homeStretch), greaterThan(_average(breather)),
        reason: 'the ramp grows until the deadline');
    // The requirements predict ~100 reviews a day at the top of the ramp for
    // a flawless run; a 10% miss rate adds the same-day rungs of the short
    // cycle on top of that, so the bound is the ramp plus that slack.
    expect(_average(homeStretch), lessThanOrEqualTo(140),
        reason: 'the ramp tops out around one pass over the collection');

    // Nobody is left behind: every card was studied.
    expect(
      collection.all.where((card) => card.reps == 0),
      isEmpty,
      reason: 'a card never reviewed would be a hole in the method',
    );
  });
}

double _average(List<int> values) =>
    values.reduce((a, b) => a + b) / values.length;
