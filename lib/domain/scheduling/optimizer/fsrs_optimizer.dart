import 'dart:math' as math;

import '../../models/enums.dart';
import '../../models/review_log.dart';
import '../../stats/calibration.dart';
import '../fsrs_gateway.dart';

/// Outcome of a training run. A failure is never fatal: the app has to work
/// entirely on the default weights if the optimizer cannot improve them.
sealed class TuningResult {
  const TuningResult();
}

final class TuningApplied extends TuningResult {
  const TuningApplied(this.parameters, this.lossBefore, this.lossAfter);

  final List<double> parameters;
  final double lossBefore;
  final double lossAfter;
}

final class TuningSkipped extends TuningResult {
  const TuningSkipped(this.reason);

  final String reason;
}

/// Self-tuning over Leandro's own reviews.
///
/// `dart:isolate` does not exist in Flutter Web — `Isolate.run` throws
/// `UnsupportedError` — so the training runs in slices on the main thread,
/// handing the frame back to the browser between epochs.
final class FsrsOptimizer {
  FsrsOptimizer(this._gateway, {this.epochs = 8, this.step = 0.05});

  final FsrsGateway _gateway;
  final int epochs;

  /// Relative size of the coordinate probe.
  final double step;

  /// The first tuning needs 400 reviews AND 7 days of use — volume alone would
  /// fire around day 6, when almost every review is still a short-cycle rung
  /// and the sample carries no long interval at all.
  static const firstTuningReviews = 400;
  static const firstTuningDays = 7;

  /// After the first one, every 200 new reviews.
  static const retuningReviews = 200;

  bool shouldTune({
    required int totalReviews,
    required int daysOfUse,
    required int reviewsSinceLastTuning,
    required bool hasTunedBefore,
  }) {
    if (!hasTunedBefore) {
      return totalReviews >= firstTuningReviews && daysOfUse >= firstTuningDays;
    }
    return reviewsSinceLastTuning >= retuningReviews;
  }

  /// Coordinate descent on the log-loss between predicted retention and what
  /// actually happened. Only scheduled study enters: mock-interview reviews
  /// would contaminate the very signal being fitted.
  Future<TuningResult> optimize(List<ReviewLog> logs) async {
    final sample = logs
        .where((log) => log.source == ReviewSource.session)
        .where((log) => log.stabilityBefore > 0)
        .toList();
    if (sample.length < firstTuningReviews) {
      return const TuningSkipped('amostra pequena demais');
    }

    var best = List<double>.from(_gateway.parameters);
    var bestLoss = _logLoss(best, sample);
    final initialLoss = bestLoss;

    for (var epoch = 0; epoch < epochs; epoch++) {
      for (var index = 0; index < best.length; index++) {
        for (final direction in const [1, -1]) {
          final candidate = List<double>.from(best);
          final delta = math.max(best[index].abs(), 0.01) * step * direction;
          candidate[index] = best[index] + delta;
          if (!_gateway.parametersAreInRange(candidate)) continue;

          final loss = _logLoss(candidate, sample);
          if (loss < bestLoss) {
            best = candidate;
            bestLoss = loss;
          }
        }
      }
      // Hands the frame back to the browser: no isolate exists here.
      await Future<void>.delayed(Duration.zero);
    }

    if (bestLoss >= initialLoss) {
      return const TuningSkipped('nenhuma melhora sobre os parâmetros atuais');
    }
    if (!_gateway.parametersAreInRange(best)) {
      return const TuningSkipped('parâmetros fora da faixa do pacote');
    }
    return TuningApplied(best, initialLoss, bestLoss);
  }

  double _logLoss(List<double> parameters, List<ReviewLog> logs) {
    const calibration = Calibration();
    var total = 0.0;
    for (final log in logs) {
      final predicted = calibration
          .retentionWith(parameters, log)
          .clamp(1e-6, 1 - 1e-6);
      final recalled = log.rating != Rating.again;
      total -= recalled ? math.log(predicted) : math.log(1 - predicted);
    }
    return total / logs.length;
  }
}
