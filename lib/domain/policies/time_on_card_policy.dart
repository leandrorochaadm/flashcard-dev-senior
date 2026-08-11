/// The time on a card feeds the average, never the schedule (requirement 11).
final class TimeOnCardPolicy {
  const TimeOnCardPolicy();

  /// Above this the time is almost certainly distraction, not thinking.
  static const ceiling = Duration(seconds: 60);

  /// The value to store in `ReviewLog.timeOnCard`: `null` drops it from the
  /// average. The review itself still counts.
  Duration? timeToRecord(Duration elapsed) => elapsed > ceiling ? null : elapsed;

  bool isOverCeiling(Duration elapsed) => elapsed > ceiling;
}
