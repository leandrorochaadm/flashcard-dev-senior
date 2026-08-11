import 'dart:math' as math;

import '../models/card.dart';
import '../models/schedule_window.dart';
import '../ports.dart';
import '../scheduling/moving_ceiling.dart';
import 'due_cards_policy.dart';

/// Why today's batch is the size it is — the app never holds cards back
/// silently.
enum IntakeReason {
  /// The first five days of use: the whole collection enters, ~20 a day.
  initialLoad,

  /// Normal daily rate, derived from how much was actually studied.
  steady,

  /// The load forecast shows a pile-up ahead, so nothing new is released.
  heldByForecast,

  /// Little study in the last days, so the batch shrank.
  reducedByLowStudy,

  /// Nothing left to release.
  nothingPending,
}

final class IntakeRelease {
  const IntakeRelease({
    required this.cards,
    required this.quota,
    required this.reason,
  });

  final List<Card> cards;
  final int quota;
  final IntakeReason reason;

  /// The requirements demand a warning: a collection that stops growing with
  /// no explanation is worse than a smaller batch.
  bool get shouldWarn =>
      reason == IntakeReason.heldByForecast ||
      reason == IntakeReason.reducedByLowStudy;
}

/// Importing is not releasing (H16).
///
/// The 100 cards enter the database at once — that is what lets the import
/// screen prove the spread — but only ~20 a day become studiable. This is the
/// only class that writes `introducedAt`.
final class ContentIntakePolicy {
  const ContentIntakePolicy(
    this._window,
    this._collection,
    this._history,
    this._dueCards,
  );

  final ScheduleWindowView _window;
  final CollectionView _collection;
  final StudyHistoryView _history;
  final DueCardsPolicy _dueCards;

  /// The initial load spreads the whole collection over the first five days of
  /// use, so even the last batch gets ~25 days of review before the target.
  static const initialLoadDays = 5;

  /// A card is firm when the app calculates it would still be recalled a week
  /// from now; below this ratio, importing more raises a warning.
  static const firmWarningRatio = 0.80;

  /// Each new card costs about four reviews on entry: three steps of the short
  /// cycle on the same day plus the 1-day step on the next.
  static const reviewsPerNewCard = 4;

  /// Days of history the steady rate looks back on.
  static const recentDays = 3;

  List<Card> get _pending =>
      _collection.all.where((card) => !card.isReleased).toList()
        ..sort((a, b) => a.importedAt.compareTo(b.importedAt));

  /// Today's batch. The caller stamps `introducedAt` and saves.
  IntakeRelease releaseToday(DateTime now) {
    final pending = _pending;
    if (pending.isEmpty) {
      return const IntakeRelease(
        cards: [],
        quota: 0,
        reason: IntakeReason.nothingPending,
      );
    }

    final dayOfUse = _window.window.dayOfUse(now);
    if (dayOfUse >= 1 && dayOfUse <= initialLoadDays) {
      // PRECEDENCE: during the initial load, neither "studied little" nor the
      // forecast hold applies. If they did, the last cards would enter too
      // late to firm up before the target — which is what the initial load
      // exists to prevent.
      final quota = _initialLoadQuota(pending.length, dayOfUse);
      return IntakeRelease(
        cards: pending.take(quota).toList(),
        quota: quota,
        reason: IntakeReason.initialLoad,
      );
    }

    if (_forecastShowsPileUp(now)) {
      return const IntakeRelease(
        cards: [],
        quota: 0,
        reason: IntakeReason.heldByForecast,
      );
    }

    final steady = _steadyQuota(now);
    final baseline = _dailyBaseline();
    return IntakeRelease(
      cards: pending.take(steady).toList(),
      quota: steady,
      reason: steady < baseline
          ? IntakeReason.reducedByLowStudy
          : IntakeReason.steady,
    );
  }

  /// Spreads what is still pending over the days left in the initial load, so
  /// a mid-window import does not pile up on the last day.
  int _initialLoadQuota(int pendingCount, int dayOfUse) {
    final daysLeft = initialLoadDays - dayOfUse + 1;
    return math.max(1, (pendingCount / daysLeft).ceil());
  }

  int _dailyBaseline() {
    final total = _collection.all.length;
    return math.max(1, (total / initialLoadDays).ceil());
  }

  /// Outside the initial load the batch follows how much was really studied:
  /// the recent daily average minus what is already due today, divided by the
  /// cost of a new card.
  int _steadyQuota(DateTime now) {
    final today = dateOnly(now);
    var studied = 0;
    for (var i = 1; i <= recentDays; i++) {
      studied += _history.reviewsOn(today.subtract(Duration(days: i)));
    }
    final average = studied / recentDays;
    final dueToday = _dueCards.dueNow(now).length;
    final room = (average - dueToday) / reviewsPerNewCard;
    return room <= 0 ? 0 : math.min(room.floor(), _dailyBaseline());
  }

  /// A pile-up is any of the next days already scheduled above the load the
  /// ramp asks for on that day.
  bool _forecastShowsPileUp(DateTime now) {
    final forecast = _dueCards.forecast(now);
    for (final entry in forecast.entries) {
      final remaining = _window.window.daysRemainingFrom(entry.key);
      final target = MovingCeiling.c1 -
          (MovingCeiling.c1 - MovingCeiling.c0) *
              remaining /
              ScheduleWindow.rampDays;
      if (entry.value > target) return true;
    }
    return false;
  }

  /// Share of released cards that are firm — the number the 80% warning shows.
  double firmRatio() {
    final released = _collection.all.where((card) => card.isReleased).toList();
    if (released.isEmpty) return 1;
    return released.where((card) => card.isFirm).length / released.length;
  }

  /// A warning, never a gate: Leandro sees the percentage and imports anyway.
  bool shouldWarnBeforeImport() => firmRatio() < firmWarningRatio;
}
