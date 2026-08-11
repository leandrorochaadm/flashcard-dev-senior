import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/scheduling/moving_ceiling.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  // The window is injected, never a literal: no DateTime(2026, …) belongs in
  // domain code, and no test may pin "5.0 days on the first day of use".
  final firstOpening = DateTime(2026, 8, 11);
  final window = ScheduleWindow.forFirstOpening(firstOpening);

  double days(Duration ceiling) => ceiling.inMinutes / 1440.0;

  MovingCeiling ceilingWith(int releasedCards, {ScheduleWindow? overrideWindow}) {
    final collection = FakeCollection([
      for (var i = 0; i < releasedCards; i++)
        newCard('c$i', importedAt: firstOpening, introducedAt: firstOpening),
    ]);
    return MovingCeiling(FakeWindow(overrideWindow ?? window), collection);
  }

  test('the window opens on day 1, not day 0', () {
    expect(window.startDate, DateTime(2026, 8, 10));
    expect(window.dayOfUse(firstOpening), 1);
    expect(window.daysRemainingFrom(firstOpening), 29);
  });

  test('day 1 of a 100-card collection is capped around 4.4 days', () {
    expect(days(ceilingWith(100).forDate(firstOpening)), closeTo(4.4, 0.05));
  });

  test('the ceiling is identical at 00:01 and at 23:59 of the same day', () {
    final ceiling = ceilingWith(100);
    final earlyMorning = DateTime(2026, 8, 20, 0, 1);
    final lateNight = DateTime(2026, 8, 20, 23, 59);

    expect(ceiling.forDate(earlyMorning), ceiling.forDate(lateNight));
  });

  // The requirements phrase the home stretch as "no card disappears for more
  // than 1 day from 04/09", and their own table spells the numbers out:
  // 1.2 days on 04/09, reaching the floor of 1.0 on the target date. The
  // formula is the authority; the phrase is its rounding.
  test('the home stretch stays at the bottom of the ramp', () {
    final ceiling = ceilingWith(100);
    expect(days(ceiling.forDate(DateTime(2026, 9, 4))), closeTo(1.2, 0.05));
    for (var day = 4; day <= 9; day++) {
      expect(days(ceiling.forDate(DateTime(2026, 9, day))),
          lessThanOrEqualTo(1.2001),
          reason: 'on 0$day/09 the ceiling must already be near the floor');
    }
    expect(days(ceiling.forDate(DateTime(2026, 9, 9))), 1.0);
  });

  // The distinguishing test: within the original 30-day window, "days
  // remaining" and "days elapsed" produce identical numbers, so a passing test
  // there proves nothing. With the target re-picked, they diverge.
  test('a target re-picked 10 days out keeps the ceiling tight (~1.4 days)', () {
    final now = DateTime(2026, 9, 20);
    final remarked = window.withTarget(now.add(const Duration(days: 10)));

    final ceiling = ceilingWith(100, overrideWindow: remarked);

    expect(days(ceiling.forDate(now)), closeTo(1.4, 0.05));
  });

  test('the ceiling does not depend on startDate', () {
    final now = DateTime(2026, 8, 20);
    final target = DateTime(2026, 9, 9);
    final early = ScheduleWindow(startDate: DateTime(2020, 1, 1), targetDate: target);
    final late = ScheduleWindow(startDate: DateTime(2026, 8, 19), targetDate: target);

    expect(
      ceilingWith(100, overrideWindow: early).forDate(now),
      ceilingWith(100, overrideWindow: late).forDate(now),
    );
  });

  test('past the target date the ceiling stays on the floor of one day', () {
    final ceiling = ceilingWith(100);
    expect(days(ceiling.forDate(DateTime(2026, 10, 1))), 1.0);
  });

  test('a target more than 30 days out stops the ceiling growing at 5 days', () {
    final now = DateTime(2026, 8, 11);
    final faraway = window.withTarget(DateTime(2027, 1, 1));

    expect(
      days(ceilingWith(100, overrideWindow: faraway).forDate(now)),
      closeTo(5.0, 0.01),
    );
  });

  test('a bigger collection loosens the ceiling and keeps the load on the ramp',
      () {
    final now = DateTime(2026, 8, 20); // day 10 of use, 20 days remaining
    expect(days(ceilingWith(100).forDate(now)), closeTo(2.1, 0.05));
    expect(days(ceilingWith(150).forDate(now)), closeTo(3.2, 0.05));
  });

  test('cards not yet released do not inflate the ceiling', () {
    final now = DateTime(2026, 8, 20);
    final collection = FakeCollection([
      for (var i = 0; i < 100; i++)
        newCard('r$i', importedAt: firstOpening, introducedAt: firstOpening),
      for (var i = 0; i < 50; i++) newCard('p$i', importedAt: firstOpening),
    ]);
    final ceiling = MovingCeiling(FakeWindow(window), collection);

    expect(days(ceiling.forDate(now)), closeTo(2.1, 0.05));
  });

  test('a tiny collection never goes below the floor of one day', () {
    expect(days(ceilingWith(3).forDate(firstOpening)), 1.0);
  });
}
