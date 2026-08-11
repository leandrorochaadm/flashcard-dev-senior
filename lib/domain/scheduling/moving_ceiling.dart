import 'dart:math' as math;

import '../models/schedule_window.dart';
import '../ports.dart';

/// The maximum interval allowed right now — and the product's central promise.
///
/// It is not chosen directly: the daily study load is, and the ceiling is the
/// consequence. Defining the ceiling first produced a hyperbola that doubled
/// the study time in one step near the deadline.
///
///     load(r)    = C1 - (C1 - C0) * r / T      reviews per day
///     ceiling(r) = max(1, N / load(r))         days
///
/// with `r` = days REMAINING to the target (clamped 0..30) and `N` = number of
/// RELEASED cards.
final class MovingCeiling {
  const MovingCeiling(this._window, this._collection);

  final ScheduleWindowView _window;
  final CollectionView _collection;

  /// Reviews per day when 30 days are still left.
  static const c0 = 20.0;

  /// Reviews per day on the target date itself.
  static const c1 = 100.0;

  Duration forDate(DateTime now) =>
      forDaysRemaining(_window.window.daysRemainingFrom(now), _releasedCount);

  /// The ceiling a candidate target date would produce, for the screen that
  /// lets Leandro re-pick it — no arithmetic in the View.
  Duration forCandidateTarget(DateTime now, DateTime candidateTarget) {
    final remaining = _window.window
        .withTarget(candidateTarget)
        .daysRemainingFrom(now);
    return forDaysRemaining(remaining, _releasedCount);
  }

  /// Cards imported but still held back by the ContentIntakePolicy generate no
  /// reviews, so they must not inflate the ceiling of those already in study.
  int get _releasedCount => _collection.all.where((card) => card.isReleased).length;

  static Duration forDaysRemaining(int daysRemaining, int collectionSize) {
    final r = daysRemaining.clamp(0, ScheduleWindow.rampDays);
    final load = c1 - (c1 - c0) * r / ScheduleWindow.rampDays;
    // The floor of one day: no card ever shows up twice in the same day.
    final days = math.max(1.0, collectionSize / load);
    // Minutes, never days: `Duration(days: 2)` would drop the ".4" of 2.4 days.
    return Duration(minutes: (days * 24 * 60).round());
  }
}
