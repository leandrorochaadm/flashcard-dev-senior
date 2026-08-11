import 'dart:math' as math;

import '../models/card.dart';
import '../models/enums.dart';
import '../models/schedule_window.dart';
import '../ports.dart';
import 'fsrs_adapter.dart' show learningSteps;
import 'fsrs_gateway.dart';
import 'memory_state.dart';
import 'moving_ceiling.dart';

/// The five operations that decide when a card comes back. The order is
/// normative and step 5 cannot be moved: fuzzing and load balancing push the
/// date forward, so a ceiling applied before them would leak.
///
///   1. short cycle has absolute precedence (learning or "errei")
///   2. FSRS computes the interval (target retention 0.90)
///   3. fuzz of ±10% (ours, not the package's)
///   4. load balancing: among candidate dates, the emptiest one
///   5. the moving ceiling cuts last
final class CardScheduler {
  CardScheduler(
    this._fsrs,
    this._ceiling,
    this._collection, {
    math.Random? random,
  }) : _random = random ?? math.Random();

  final FsrsGateway _fsrs;
  final MovingCeiling _ceiling;
  final CollectionView _collection;
  final math.Random _random;

  /// How far the fuzz may move a date, either way.
  static const fuzzFraction = 0.10;

  /// The updated card after pressing one of the four buttons.
  Card apply(Card card, Rating rating, DateTime now) {
    // The algorithm always updates stability and difficulty; the short cycle
    // only decides the date and the position on the ladder.
    final reviewed = _fsrs.review(card.memory, rating, now);
    final memory = _placeOnLadder(card, reviewed, rating, now, spread: true);
    return card.withMemory(memory).copyWith(
          reps: card.reps + 1,
          lapses: rating == Rating.again ? card.lapses + 1 : card.lapses,
        );
  }

  /// Step 1 of the pipeline: the short cycle has absolute precedence.
  ///
  /// `learningStep` counts the rungs already climbed, so answering at rung `s`
  /// serves `learningSteps[s]` and moves to `s + 1`. Missing at any rung sends
  /// the card back to the first one, 15 minutes.
  MemoryState _placeOnLadder(
    Card card,
    MemoryState reviewed,
    Rating rating,
    DateTime now, {
    required bool spread,
  }) {
    if (rating == Rating.again) {
      return reviewed.copyWith(
        state: card.state == CardState.review || card.state == CardState.relearning
            ? CardState.relearning
            : CardState.learning,
        step: 0,
        dueAt: _clampToCeiling(now.add(learningSteps.first), now),
      );
    }

    if (card.state.isLearning && card.learningStep < learningSteps.length) {
      final rung = card.learningStep;
      return reviewed.copyWith(
        state: card.state == CardState.relearning
            ? CardState.relearning
            : CardState.learning,
        step: rung + 1,
        dueAt: _clampToCeiling(now.add(learningSteps[rung]), now),
      );
    }

    // Graduated: free interval, limited by the ceiling.
    return reviewed.copyWith(
      state: CardState.review,
      step: 0,
      dueAt: _freeInterval(reviewed, now, spread: spread),
    );
  }

  /// Interval each of the four buttons would produce, with no fuzz, so the
  /// answer screen can show them side by side and they stay stable.
  Map<Rating, Duration> previewIntervals(Card card, DateTime now) {
    return {
      for (final rating in Rating.values)
        rating: _placeOnLadder(
          card,
          _fsrs.review(card.memory, rating, now),
          rating,
          now,
          spread: false,
        ).dueAt!.difference(now),
    };
  }

  DateTime _freeInterval(MemoryState memory, DateTime now,
      {required bool spread}) {
    // 2. the FSRS interval, as the adapter computed it.
    final interval = (memory.dueAt ?? now).difference(now);

    // 3. fuzz of ±10%.
    final fuzzed = spread ? _fuzz(interval) : interval;

    // 4. load balancing: among the candidate dates, the least loaded one.
    final balanced =
        spread ? _loadBalance(now.add(fuzzed), interval, now) : now.add(fuzzed);

    // 5. the ceiling cuts last — it always has the final word.
    return _clampToCeiling(balanced, now);
  }

  Duration _fuzz(Duration interval) {
    final factor = 1 + (_random.nextDouble() * 2 - 1) * fuzzFraction;
    return Duration(minutes: (interval.inMinutes * factor).round());
  }

  /// Moves the date by at most one calendar day, staying inside the ±10% band,
  /// towards the day that already has fewer cards scheduled.
  DateTime _loadBalance(DateTime candidate, Duration interval, DateTime now) {
    final band = interval.inMinutes * fuzzFraction;
    final lowest = now.add(
      Duration(minutes: (interval.inMinutes - band).round()),
    );
    final highest = now.add(
      Duration(minutes: (interval.inMinutes + band).round()),
    );

    final options = <DateTime>[
      candidate.subtract(const Duration(days: 1)),
      candidate,
      candidate.add(const Duration(days: 1)),
    ].where((date) => !date.isBefore(lowest) && !date.isAfter(highest)).toList();
    if (options.isEmpty) return candidate;

    final load = _loadByDay();
    options.sort((a, b) {
      final byLoad = (load[dateOnly(a)] ?? 0).compareTo(load[dateOnly(b)] ?? 0);
      return byLoad != 0 ? byLoad : a.compareTo(b);
    });
    return options.first;
  }

  Map<DateTime, int> _loadByDay() {
    final load = <DateTime, int>{};
    for (final card in _collection.all) {
      final due = card.dueAt;
      if (due == null) continue;
      final day = dateOnly(due);
      load[day] = (load[day] ?? 0) + 1;
    }
    return load;
  }

  DateTime _clampToCeiling(DateTime date, DateTime now) {
    final maxDate = now.add(_ceiling.forDate(now));
    return date.isAfter(maxDate) ? maxDate : date;
  }
}
