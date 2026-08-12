/// The time on a card feeds the average, never the schedule (requirement 11).
final class TimeOnCardPolicy {
  const TimeOnCardPolicy();

  /// Above this the time is almost certainly distraction, not thinking.
  ///
  /// Raised from 60 s on 12/08/2026, when the deck moved to the five-section
  /// answer: the 428 cards measure a median of 155 words, which is around
  /// 52 s of reading alone before any thinking. At 60 s the normal card was
  /// being discarded as distraction, and the average time on the dashboard —
  /// what feeds the "there is idle time, bring more content" warning — would
  /// have been fed by the short cards only.
  ///
  /// The number is provisional. The requirements document asks for a week of
  /// real use before fixing it, because the right ceiling depends on a
  /// reading pace nobody has measured yet; 120 s is twice the estimated
  /// reading time, which still catches the card left open during a coffee.
  static const ceiling = Duration(seconds: 120);

  /// The value to store in `ReviewLog.timeOnCard`: `null` drops it from the
  /// average. The review itself still counts.
  Duration? timeToRecord(Duration elapsed) => elapsed > ceiling ? null : elapsed;

  bool isOverCeiling(Duration elapsed) => elapsed > ceiling;
}
