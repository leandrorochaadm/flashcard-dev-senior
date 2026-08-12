import '../stats/collection_overview.dart';

/// What the app recommends doing right now.
enum NextActionKind {
  /// The target date arrived and the question of H13 is still unanswered.
  answerDeadline,

  /// The history is exposed to the browser evicting IndexedDB.
  backup,

  /// There are cards due today.
  study,

  /// Nothing due, but there are stuck cards.
  attackStuck,

  /// Nothing released yet, and there are held cards waiting.
  awaitRelease,

  /// Up to date, with released cards at home: train the interview.
  mockInterview,

  /// Nothing at home at all: the collection is empty.
  importMore,
}

/// The recommendation, already carrying the number its sentence needs.
final class NextAction {
  const NextAction({required this.kind, required this.count});

  final NextActionKind kind;

  /// Cards due today (study) or stuck (attackStuck); 0 on the rest.
  final int count;
}

/// Decides the single recommended action, by fixed precedence.
///
/// The order is normative and every step has a reason:
///
/// 1. [NextActionKind.answerDeadline] — while the question of H13 goes
///    unanswered, the moving ceiling runs on the floor of one day; any other
///    recommendation would be given over a schedule the user has not confirmed.
/// 2. [NextActionKind.backup] — never taken, or [backupStaleDays] or more ago.
///    The backup is the only real protection against the browser evicting
///    IndexedDB (risk #2), and one more day of study does not bring a lost
///    history back.
/// 3. [NextActionKind.study] — the work of the day. It comes before everything
///    optional.
/// 4. [NextActionKind.attackStuck] — the day is cleared and there is a card
///    missed four times or more.
/// 5. [NextActionKind.awaitRelease] — nothing released yet (`released == 0`)
///    and held cards waiting. Without this step the first day of use would fall
///    into [NextActionKind.mockInterview] and the app would offer a mock with
///    no card to ask about — the worst possible first sentence.
/// 6. [NextActionKind.mockInterview] — up to date and with released cards at
///    home (`released > 0`): train. It does **not** require `held > 0`: tying
///    the mock to "there are still held cards" would make it unreachable the
///    moment the ramp finishes releasing — which is the normal state at the end
///    of the period, and the immediate state of whoever uses the "Liberar para
///    estudo agora" switch. The app would say "the collection stopped growing"
///    every idle day, forever, and would never offer the mock to the person who
///    is precisely ready for it.
/// 7. [NextActionKind.importMore] — nothing released and nothing held: the
///    collection is empty (`total == 0`). It is the floor of the ladder, and
///    the only case with nothing at home to study nor to ask about.
///
/// "The collection stopped growing" does **not** belong here. That warning is
/// the `_IntakeNotice`'s, through `IntakeRelease.shouldWarn`.
///
/// The policy receives neither a `Clock` nor a `DateTime`: whoever turned the
/// date into "N days ago" was the ViewModel, which formats an age, and
/// [deadlineReached] arrives already decided by `ScheduleWindow.isPastDeadline`.
/// That makes this a pure function of its three arguments, and its test needs
/// no clock.
final class NextActionPolicy {
  const NextActionPolicy();

  /// A backup this old — or none at all — outranks the work of the day.
  ///
  /// The number is domain and lives here, never as a literal on the screen.
  static const backupStaleDays = 7;

  NextAction decide({
    required CollectionOverview overview,
    required bool deadlineReached,
    required int? daysSinceBackup,
  }) {
    // No `if` over stability, dueAt or lapses here: everything was already
    // counted by the overview.
    if (deadlineReached) {
      return const NextAction(kind: NextActionKind.answerDeadline, count: 0);
    }
    // Never taken counts as stale, and so does anything past the threshold.
    if (daysSinceBackup == null || daysSinceBackup >= backupStaleDays) {
      return const NextAction(kind: NextActionKind.backup, count: 0);
    }
    if (overview.dueToday > 0) {
      return NextAction(
        kind: NextActionKind.study,
        count: overview.dueToday,
      );
    }
    if (overview.stuck > 0) {
      return NextAction(
        kind: NextActionKind.attackStuck,
        count: overview.stuck,
      );
    }
    if (overview.released == 0 && overview.held > 0) {
      return const NextAction(kind: NextActionKind.awaitRelease, count: 0);
    }
    if (overview.released > 0) {
      return const NextAction(kind: NextActionKind.mockInterview, count: 0);
    }
    return const NextAction(kind: NextActionKind.importMore, count: 0);
  }
}
