import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/study_session.dart';
import '../../domain/policies/content_intake_policy.dart';
import '../../domain/stats/calibration.dart';
import '../../domain/stats/progress_stats.dart';

part 'dashboard_state.freezed.dart';

/// Screen state of the dashboard (H6, H12, H13).
///
/// Every field of [DashboardReady] arrives already computed by the domain:
/// `ProgressStats`, `Calibration`, `DueCardsPolicy` and `MovingCeiling`. The
/// widgets below only paint — a percentage computed in a widget would be a
/// second authority on progress, disagreeing with the session screen.
@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.loading() = DashboardLoading;

  const factory DashboardState.ready({
    /// Cards that crossed into "firm" today.
    required int firmedToday,

    /// Real recall rate of scheduled study; `null` while nothing was reviewed.
    required double? accuracy,

    /// The 0.90 the algorithm aims at — shown next to [accuracy].
    required double targetRetention,

    /// The subject map, worst first.
    required List<SubjectProgress> subjects,

    /// Scoreboard of the last study session; `null` on a fresh install.
    required StudySession? lastSession,

    /// Predicted against real, day by day.
    required List<CalibrationPoint> calibration,

    /// The same days recomputed with the weights in force before the last
    /// tuning. `null` when there has never been one.
    required List<CalibrationPoint>? previousCalibration,

    /// One bar per day of the next seven.
    required List<LoadBar> load,
    required TimeOnCardStats timeOnCard,

    /// Longest interval the schedule may hand out today.
    required Duration ceilingToday,
    required int daysToTarget,
    required DateTime targetDate,

    /// Days since the last export; `null` when no backup was ever taken.
    required int? daysSinceBackup,

    /// Nothing due and nothing to anticipate (H12).
    required bool dayCleared,

    /// The target date arrived and the question of H13 is still unanswered.
    required bool deadlineReached,

    /// Today's release, carrying the reason it was the size it was — the app
    /// never holds cards back silently.
    required IntakeRelease intake,

    /// Hidden when there is nothing to go back to.
    required bool canRevertTuning,

    /// Outcome of the last self-tuning attempt, already in words.
    required String? tuningMessage,
  }) = DashboardReady;

  const factory DashboardState.error(String message) = DashboardError;
}
