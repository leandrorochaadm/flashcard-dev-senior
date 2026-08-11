import '../models/enums.dart';
import 'memory_state.dart';

/// The only contract the scheduler knows about the algorithm.
///
/// Extracting the interval and applying fuzz, load balancing and the ceiling
/// (steps 3 to 5 of the pipeline) is the [CardScheduler]'s job, never the
/// gateway's.
abstract interface class FsrsGateway {
  /// Updated memory state after answering [rating] at [now] (local time).
  MemoryState review(MemoryState state, Rating rating, DateTime now);

  /// Predicted retention right now, computed on decimal days. Feeds
  /// `ReviewLog.predictedRetention` and therefore the calibration chart.
  double retrievability(MemoryState state, DateTime now);

  /// The 21 active weights.
  List<double> get parameters;

  /// Objective range check for the optimizer, using the package's own bounds.
  bool parametersAreInRange(List<double> candidate);

  /// Adopts new weights in place, so a tuning applies to the very next
  /// answer instead of waiting for the app to be opened again.
  void useParameters(List<double> parameters);

  /// Same algorithm with different weights — used to recompute the
  /// calibration curve retroactively, before and after a tuning.
  FsrsGateway withParameters(List<double> parameters);
}
