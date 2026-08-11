/// The only source of "now" in the app.
///
/// The moving ceiling, the short cycle and the deadline are all functions of
/// the date, so `DateTime.now()` outside this file makes them untestable:
/// there would be no way to ask "what happens on day 25" other than changing
/// the machine clock.
abstract interface class Clock {
  /// Local time. UTC conversion happens inside the FSRS adapter only.
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Movable clock. Used by the 30-day simulation and by the time-travel screen.
final class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration by) => _now = _now.add(by);

  void set(DateTime to) => _now = to;
}
