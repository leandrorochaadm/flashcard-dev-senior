import 'package:flashcard_dev_senior/domain/policies/next_action_policy.dart';
import 'package:flashcard_dev_senior/domain/stats/collection_overview.dart';
import 'package:flutter_test/flutter_test.dart';

/// The precedence of the next action, one test per step against the step below
/// it: a test that only checks the isolated case proves no precedence at all.
///
/// The policy takes no clock and no date, so nothing here needs a `FakeClock`.
void main() {
  const policy = NextActionPolicy();

  CollectionOverview collection({
    int total = 10,
    int held = 0,
    int released = 10,
    int neverAnswered = 0,
    int firm = 0,
    int ready = 0,
    int stuck = 0,
    int dueToday = 0,
  }) =>
      CollectionOverview(
        total: total,
        held: held,
        released: released,
        neverAnswered: neverAnswered,
        inShortCycle: 0,
        inReview: 0,
        firm: firm,
        ready: ready,
        stuck: stuck,
        dueToday: dueToday,
        subjectsDueToday: dueToday == 0 ? 0 : 1,
      );

  NextAction decide(
    CollectionOverview overview, {
    bool deadlineReached = false,
    int? daysSinceBackup = 0,
  }) =>
      policy.decide(
        overview: overview,
        deadlineReached: deadlineReached,
        daysSinceBackup: daysSinceBackup,
      );

  test('an unanswered deadline wins over cards due today', () {
    final action = decide(
      collection(dueToday: 12),
      deadlineReached: true,
    );

    expect(action.kind, NextActionKind.answerDeadline);
  });

  test('a never-taken backup wins over cards due today', () {
    // A lost history does not come back; one more day of study does not
    // recover it.
    final action = decide(collection(dueToday: 12), daysSinceBackup: null);

    expect(action.kind, NextActionKind.backup);
  });

  test('a backup taken today loses to cards due today', () {
    final action = decide(collection(dueToday: 12));

    expect(action.kind, NextActionKind.study,
        reason: 'the backup must not hijack the dashboard every day');
  });

  test('the backup becomes the next action after seven days', () {
    expect(
      decide(collection(dueToday: 12), daysSinceBackup: 6).kind,
      NextActionKind.study,
    );
    expect(
      decide(collection(dueToday: 12),
              daysSinceBackup: NextActionPolicy.backupStaleDays)
          .kind,
      NextActionKind.backup,
    );
  });

  test('study wins over stuck cards', () {
    final action = decide(collection(dueToday: 3, stuck: 5));

    expect(action.kind, NextActionKind.study);
  });

  test('stuck cards win over the mock interview', () {
    final action = decide(collection(stuck: 5));

    expect(action.kind, NextActionKind.attackStuck);
    expect(action.count, 5);
  });

  test('a collection with everything still held back waits for the release',
      () {
    // The first day of use must not fall into a mock interview with no card to
    // ask about.
    final action = decide(collection(total: 100, held: 100, released: 0));

    expect(action.kind, NextActionKind.awaitRelease);
    expect(action.count, 0);
  });

  test('a fully released collection still suggests the mock interview', () {
    // The step is unreachable if it demands `held > 0`: that is the normal
    // state once the ramp finishes, and the immediate state of whoever used
    // the "Liberar para estudo agora" switch.
    final action = decide(collection(total: 100, held: 0, released: 100));

    expect(action.kind, NextActionKind.mockInterview);
  });

  test('a cleared day with content still coming suggests the mock interview',
      () {
    final action = decide(collection(total: 100, held: 40, released: 60));

    expect(action.kind, NextActionKind.mockInterview);
  });

  test('an empty collection suggests importing, never a mock interview', () {
    final action = decide(collection(total: 0, held: 0, released: 0));

    expect(action.kind, NextActionKind.importMore);
  });

  test('study carries the number of cards due today', () {
    expect(decide(collection(dueToday: 12)).count, 12);
  });

  test('an empty collection never suggests studying', () {
    final action = decide(collection(total: 0, held: 0, released: 0));

    expect(action.kind, isNot(NextActionKind.study));
    expect(action.count, 0);
  });

  test('every step of the ladder is reachable', () {
    final reached = {
      decide(collection(dueToday: 1), deadlineReached: true).kind,
      decide(collection(dueToday: 1), daysSinceBackup: null).kind,
      decide(collection(dueToday: 1)).kind,
      decide(collection(stuck: 1)).kind,
      decide(collection(total: 5, held: 5, released: 0)).kind,
      decide(collection()).kind,
      decide(collection(total: 0, held: 0, released: 0)).kind,
    };

    expect(reached, NextActionKind.values.toSet());
  });
}
