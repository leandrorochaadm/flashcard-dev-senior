import 'models/card.dart';
import 'models/schedule_window.dart';

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
