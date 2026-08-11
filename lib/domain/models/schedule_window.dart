/// The 30-day window the whole method is parameterized by.
///
/// Neither date is a constant: `startDate` is anchored on the first real
/// opening of the app and `targetDate` can be re-picked on a calendar (H13).
/// No `DateTime(2026, …)` literal belongs in `domain/`.
final class ScheduleWindow {
  const ScheduleWindow({required this.startDate, required this.targetDate});

  /// The eve of the first day of use. Written once and never again — otherwise
  /// every opening re-anchors it and the intake ramp never leaves day 1.
  final DateTime startDate;

  /// The deadline that governs the moving ceiling and the "ready" level.
  final DateTime targetDate;

  /// Horizon of the load ramp, in days. `r` is clamped to this.
  static const rampDays = 30;

  /// Default window for a first opening on [firstOpenedOn].
  ///
  /// `startDate` is the eve, and the target lands 29 days after the opening —
  /// opening on the 11th gives a target 30 days after `startDate`, which is
  /// what makes day 1 a ceiling of ~4.4 days instead of 5.0.
  factory ScheduleWindow.forFirstOpening(DateTime firstOpenedOn) {
    final open = dateOnly(firstOpenedOn);
    return ScheduleWindow(
      startDate: open.subtract(const Duration(days: 1)),
      targetDate: open.add(const Duration(days: rampDays - 1)),
    );
  }

  ScheduleWindow withTarget(DateTime newTarget) =>
      ScheduleWindow(startDate: startDate, targetDate: dateOnly(newTarget));

  /// Days remaining until the target, clamped to 0..30.
  ///
  /// Days remaining, never days elapsed: re-picking a target one week out must
  /// keep the ceiling tight instead of releasing it back to 5 days.
  int daysRemainingFrom(DateTime now) =>
      dateOnly(targetDate).difference(dateOnly(now)).inDays.clamp(0, rampDays);

  /// 1-based day of use. Day 1 is the first opening.
  int dayOfUse(DateTime now) => dateOnly(now).difference(startDate).inDays;

  bool isPastDeadline(DateTime now) => !dateOnly(now).isBefore(dateOnly(targetDate));
}

/// Midnight of [value], dropping the time of day.
///
/// Every day-difference in the domain goes through this: `.inDays` truncates,
/// so subtracting two instants would make the ceiling change value in the
/// middle of the afternoon.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
