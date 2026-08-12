import 'models/card.dart';
import 'models/schedule_window.dart';
import 'policies/content_intake_policy.dart';

/// Read-only view of the collection, as the domain needs it.
///
/// Declared here and implemented in `data/` so that domain classes never
/// import a repository: the 30-day simulation injects a plain list instead of
/// opening a database.
abstract interface class CollectionView {
  List<Card> get all;
}

/// Read-only view of the schedule window (H13).
abstract interface class ScheduleWindowView {
  ScheduleWindow get window;
}

/// How much study actually happened, day by day. Feeds the daily intake rate
/// outside the initial load.
abstract interface class StudyHistoryView {
  /// Session reviews recorded on [day]. Mock-interview reviews do not count.
  int reviewsOn(DateTime day);
}

/// Saving a batch of cards. `CardRepository` implements it.
///
/// Declared as a port so `DailyRelease` can be tested without a database.
abstract interface class CardWriter {
  Future<void> saveAll(Iterable<Card> cards);
}

/// Removing cards for good. `CardRepository` implements it.
abstract interface class CardEraser {
  Future<void> deleteAll(Iterable<String> ids);
}

/// Removing the history of cards that no longer exist.
///
/// The history is append-only for study, but a card that was erased must take
/// its reviews with it: calibration and the optimizer read every session log,
/// and logs pointing at a card nobody can see would keep steering the schedule.
abstract interface class HistoryEraser {
  Future<void> deleteForCards(Set<String> cardIds);
}

/// The day the last batch went out, and why it was the size it was.
///
/// The reason is persisted, not just held in memory: the page reloads — by the
/// user, and by the service worker when a new build activates — and the
/// requirement is that the app never shrinks the intake in silence.
abstract interface class ReleaseJournal {
  DateTime? get lastReleaseAt;
  IntakeReason? get lastReleaseReason;
  int? get lastReleaseQuota;

  Future<void> markReleased(DateTime now, IntakeReason reason, int quota);
}
