import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/memory_state.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final now = DateTime(2026, 8, 11, 9);

  group('FSRS adapter', () {
    final adapter = FsrsAdapter();

    test('a brand new card enters as learning, step 0, and comes out with '
        'stability', () {
      const fresh = MemoryState.fresh();

      final reviewed = adapter.review(fresh, Rating.good, now);

      expect(reviewed.stability, greaterThan(0));
      expect(reviewed.difficulty, greaterThan(0));
      expect(reviewed.state.isLearning, isTrue);
      expect(reviewed.lastReviewedAt, isNotNull);
    });

    test('local time in, local time out — UTC never leaks into the domain', () {
      const fresh = MemoryState.fresh();

      final reviewed = adapter.review(fresh, Rating.good, now);

      expect(reviewed.dueAt!.isUtc, isFalse);
      expect(reviewed.lastReviewedAt!.isUtc, isFalse);
      expect(reviewed.lastReviewedAt, now);
    });

    test('a missed review sends the card to relearning', () {
      final graduated = MemoryState(
        state: CardState.review,
        step: 0,
        stability: 20,
        difficulty: 5,
        dueAt: now,
        lastReviewedAt: now.subtract(const Duration(days: 5)),
      );

      final reviewed = adapter.review(graduated, Rating.again, now);

      expect(reviewed.state, CardState.relearning);
    });

    // The package truncates elapsed days, so during the whole short cycle its
    // own answer would be a constant 1.0 and the calibration a flat line.
    test('retrievability moves within the short cycle, on decimal days', () {
      final state = MemoryState(
        state: CardState.learning,
        step: 1,
        stability: 1,
        difficulty: 5,
        dueAt: now,
        lastReviewedAt: now,
      );

      final atFifteenMinutes =
          adapter.retrievability(state, now.add(const Duration(minutes: 15)));
      final atFourHours =
          adapter.retrievability(state, now.add(const Duration(hours: 4)));

      expect(atFifteenMinutes, lessThan(1.0));
      expect(atFourHours, lessThan(atFifteenMinutes));
      expect(atFourHours, greaterThan(0));
    });

    test('a card never answered predicts 1, not 0', () {
      expect(adapter.retrievability(const MemoryState.fresh(), now), 1);
    });

    test('retrievability falls towards the target retention over the interval',
        () {
      final state = MemoryState(
        state: CardState.review,
        step: 0,
        stability: 10,
        difficulty: 5,
        dueAt: now.add(const Duration(days: 10)),
        lastReviewedAt: now,
      );

      final atDue = adapter.retrievability(state, now.add(const Duration(days: 10)));

      expect(atDue, closeTo(desiredRetention, 0.02));
    });

    test('the package bounds are the range check for the self-tuning', () {
      expect(adapter.parametersAreInRange(adapter.parameters), isTrue);
      expect(adapter.parametersAreInRange([1, 2, 3]), isFalse);
      expect(
        adapter.parametersAreInRange(
          List<double>.filled(adapter.parameters.length, 1e9),
        ),
        isFalse,
      );
      expect(
        adapter.parametersAreInRange(
          List<double>.filled(adapter.parameters.length, double.nan),
        ),
        isFalse,
      );
    });

    test('adopting new weights applies to the very next answer', () {
      final tunable = FsrsAdapter();
      final before = tunable.review(MemoryState.fresh(), Rating.good, now);

      final tuned = List<double>.from(tunable.parameters);
      // parameters[2] is the initial stability of a card rated "good".
      tuned[2] = tuned[2] * 2;
      tunable.useParameters(tuned);
      final after = tunable.review(MemoryState.fresh(), Rating.good, now);

      expect(tunable.parameters, tuned);
      expect(after.stability, isNot(before.stability));
    });

    test('another set of weights gives another gateway, same algorithm', () {
      final tuned = adapter.withParameters(adapter.parameters);

      expect(tuned.parameters, adapter.parameters);
      expect(identical(tuned, adapter), isFalse);
    });

    test('the four ratings order the resulting stability', () {
      final graduated = MemoryState(
        state: CardState.review,
        step: 0,
        stability: 10,
        difficulty: 5,
        dueAt: now,
        lastReviewedAt: now.subtract(const Duration(days: 10)),
      );

      final stabilities = {
        for (final rating in Rating.values)
          rating: adapter.review(graduated, rating, now).stability,
      };

      expect(stabilities[Rating.again]!, lessThan(stabilities[Rating.hard]!));
      expect(stabilities[Rating.hard]!, lessThan(stabilities[Rating.good]!));
      expect(stabilities[Rating.good]!, lessThan(stabilities[Rating.easy]!));
    });
  });

  group('memory state', () {
    test('a fresh state is a card nobody has answered', () {
      // Built at runtime, not as a const: the short cycle rebuilds it on every
      // miss, and that path has to be exercised.
      final fresh = MemoryState.fresh();

      expect(fresh.state, CardState.newCard);
      expect(fresh.step, 0);
      expect(fresh.stability, 0);
      expect(fresh.dueAt, isNull);
      expect(fresh.lastReviewedAt, isNull);
      expect(fresh.toString(), contains('new'));
    });

    test('copyWith touches only what it was given', () {
      final fresh = MemoryState.fresh();

      final moved = fresh.copyWith(
        dueAt: now,
        state: CardState.review,
        step: 2,
      );

      expect(moved.dueAt, now);
      expect(moved.state, CardState.review);
      expect(moved.step, 2);
      expect(moved.stability, fresh.stability);
      expect(moved.difficulty, fresh.difficulty);
    });
  });

  group('candidate target', () {
    test('the screen gets the resulting ceiling before confirming a new date',
        () {
      final collection = FakeCollection([
        for (var i = 0; i < 100; i++)
          newCard('c$i', importedAt: now, introducedAt: now),
      ]);
      final ceiling = MovingCeiling(
        FakeWindow(ScheduleWindow.forFirstOpening(now)),
        collection,
      );

      final tenDaysOut =
          ceiling.forCandidateTarget(now, now.add(const Duration(days: 10)));

      expect(tenDaysOut.inMinutes / 1440, closeTo(1.4, 0.05));
    });
  });
}
