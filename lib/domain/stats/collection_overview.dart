/// Return types of the dashboard indicators that read the collection as a
/// whole. They live here, and not in `progress_stats.dart`, only to keep that
/// file about the calculations.
///
/// Nothing here imports Flutter, and nothing here calls `DateTime.now()`.
library;

/// The collection funnel, from what was imported to what is already ready.
///
/// Every field is a card count; no ratio is computed on the screen.
final class CollectionOverview {
  const CollectionOverview({
    required this.total,
    required this.held,
    required this.released,
    required this.neverAnswered,
    required this.inShortCycle,
    required this.inReview,
    required this.firm,
    required this.ready,
    required this.stuck,
    required this.dueToday,
    required this.subjectsDueToday,
  });

  /// Everything in the database.
  final int total;

  /// Imported and still held back by the intake ramp (`introducedAt == null`).
  final int held;

  /// Released for study.
  final int released;

  /// Released and never answered (`reps == 0`).
  final int neverAnswered;

  /// Inside the short cycle, past the first answer.
  final int inShortCycle;

  /// Graduated out of the short cycle.
  final int inReview;

  /// Would still be recalled a week from now.
  final int firm;

  /// Would still be recalled on the target date.
  final int ready;

  /// Problem cards: missed four times or more.
  final int stuck;

  /// Overdue plus what anticipation may reach today.
  final int dueToday;

  /// Subjects with a queue today — the supporting line of the "due today" tile.
  /// Counting subjects is filtering cards, therefore domain.
  final int subjectsDueToday;

  double get firmRatio => released == 0 ? 0 : firm / released;

  double get readyRatio => released == 0 ? 0 : ready / released;
}

/// How many days in a row there was real study.
///
/// Only session answers count: a mock interview is not scheduled study, and
/// letting it count would turn a Sunday mock into "streak kept".
final class StudyStreak {
  const StudyStreak({
    required this.current,
    required this.longest,
    required this.daysStudiedLastSeven,
    required this.answeredToday,
  });

  /// Consecutive days ending today — or yesterday, while today is not over.
  final int current;

  /// The best run ever, which is not necessarily the current one.
  final int longest;

  final int daysStudiedLastSeven;

  /// Session answers recorded today.
  final int answeredToday;

  bool get studiedToday => answeredToday > 0;
}

/// One day of the firmed-cards series.
final class FirmedDay {
  const FirmedDay({required this.day, required this.cards});

  final DateTime day;
  final int cards;
}

/// Progress at "firming a card", in the three readings the dashboard uses.
///
/// They come together because they fall out of the **same** reconstruction of
/// the history: splitting them into three public methods would make the
/// dashboard ask for the same traversal three times, and each request regroups
/// and reorders the whole history.
final class FirmedProgress {
  const FirmedProgress({
    required this.series,
    required this.today,
    required this.dailyAverage,
  });

  /// One point per day, the last one always today.
  final List<FirmedDay> series;

  /// How many firmed today **and are still firm** — the big number of the tile.
  /// It is not `series.last.cards`; see the named divergence in `_crossings`.
  final int today;

  /// Daily average of the series — the reference [today] is read against.
  final double dailyAverage;
}
