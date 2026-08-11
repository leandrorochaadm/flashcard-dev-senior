import 'dart:math' as math;

import '../models/enums.dart';
import '../models/review_log.dart';
import '../models/schedule_window.dart';

/// One day of the calibration chart: what the app predicted against what
/// actually happened.
final class CalibrationPoint {
  const CalibrationPoint({
    required this.day,
    required this.predicted,
    required this.actual,
    required this.reviews,
  });

  final DateTime day;
  final double predicted;
  final double actual;
  final int reviews;

  double get gap => actual - predicted;
}

/// The only indicator that audits the app itself.
///
/// It compares `ReviewLog.predictedRetention` with the real recall rate, so it
/// must never be derived from the same weights it is auditing — and it must
/// only look at scheduled study: mock-interview reviews draw cards far from
/// their due date and would drag the real curve down for no reason.
final class Calibration {
  const Calibration();

  /// Daily series over the reviews of scheduled sessions.
  List<CalibrationPoint> series(List<ReviewLog> logs) {
    final byDay = <DateTime, List<ReviewLog>>{};
    for (final log in logs.where(_isSessionReview)) {
      byDay.putIfAbsent(dateOnly(log.reviewedAt), () => []).add(log);
    }

    final days = byDay.keys.toList()..sort();
    return [
      for (final day in days)
        CalibrationPoint(
          day: day,
          predicted: _average(
            [for (final log in byDay[day]!) log.predictedRetention],
          ),
          actual: _average(
            [for (final log in byDay[day]!) _recalled(log) ? 1.0 : 0.0],
          ),
          reviews: byDay[day]!.length,
        ),
    ];
  }

  /// The same series recomputed with another set of weights — the "before the
  /// tuning" curve drawn next to the current one.
  List<CalibrationPoint> seriesWithParameters(
    List<ReviewLog> logs,
    List<double> parameters,
  ) {
    final recomputed = [
      for (final log in logs.where(_isSessionReview))
        log.copyWith(
          predictedRetention: retentionWith(parameters, log),
        ),
    ];
    return series(recomputed);
  }

  /// Retrievability on decimal days, the same formula the adapter uses.
  double retentionWith(List<double> parameters, ReviewLog log) {
    if (log.stabilityBefore <= 0) return 1;
    final decay = -parameters[20];
    final factor = math.pow(0.9, 1 / decay) - 1;
    return math
        .pow(1 + factor * log.elapsedDays / log.stabilityBefore, decay)
        .toDouble()
        .clamp(0.0, 1.0);
  }

  /// Real accuracy against the 0.90 target — the dashboard tile.
  double? accuracy(List<ReviewLog> logs) {
    final scheduled = logs.where(_isSessionReview).toList();
    if (scheduled.isEmpty) return null;
    return scheduled.where(_recalled).length / scheduled.length;
  }

  static bool _isSessionReview(ReviewLog log) =>
      log.source == ReviewSource.session;

  /// "Errei" is the only miss; the other three reached the answer.
  static bool _recalled(ReviewLog log) => log.rating != Rating.again;

  static double _average(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
}
