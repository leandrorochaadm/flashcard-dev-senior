import 'package:collection/collection.dart';

import '../models/card.dart';
import '../models/enums.dart';
import '../models/review_log.dart';
import '../models/schedule_window.dart';
import '../policies/due_cards_policy.dart';
import '../ports.dart';
import 'collection_overview.dart';

/// One day of the 7-day load forecast.
final class LoadBar {
  const LoadBar({required this.day, required this.cards});

  final DateTime day;
  final int cards;
}

/// How one subject stands — the subject map and the weak-subject screen.
final class SubjectProgress {
  const SubjectProgress({
    required this.subject,
    required this.total,
    required this.ready,
    required this.firm,
    required this.stuck,
    required this.dueToday,
    required this.neverAnswered,
    required this.nextDueAt,
    required this.averageTime,
  });

  final String subject;
  final int total;

  /// Cards the app calculates would still be recalled on the target date.
  final int ready;
  final int firm;

  /// Problem cards: missed four times in total.
  final int stuck;

  /// Overdue plus what anticipation may reach today, from `DueCardsPolicy` —
  /// the same count the study screen serves, so the two never disagree.
  final int dueToday;

  /// Released cards of the subject nobody has answered yet.
  final int neverAnswered;

  /// The earliest strictly future `dueAt` of the subject.
  ///
  /// `null` when every card is already overdue: such a subject has no "next",
  /// and the screen writes "tudo vencido" instead of doing date arithmetic.
  final DateTime? nextDueAt;

  /// Average time on a card in this subject; `null` when nothing was timed.
  final Duration? averageTime;

  double get readyRatio => total == 0 ? 0 : ready / total;
  double get firmRatio => total == 0 ? 0 : firm / total;
}

/// Average time on a card, overall and broken down by subject.
final class TimeOnCardStats {
  const TimeOnCardStats({required this.overall, required this.bySubject});

  final Duration? overall;
  final Map<String, Duration> bySubject;
}

/// Every dashboard number lives here, not in the ViewModel: an indicator that
/// audits the app cannot be testable only through a widget.
final class ProgressStats {
  const ProgressStats(this._collection, this._window, this._dueCards);

  final CollectionView _collection;
  final ScheduleWindowView _window;
  final DueCardsPolicy _dueCards;

  List<Card> get _released =>
      _collection.all.where((card) => card.isReleased).toList();

  /// The collection funnel: where each number on the dashboard comes from.
  CollectionOverview overview(DateTime now) {
    final all = _collection.all;
    final released = _released;
    final target = _window.window.targetDate;
    final dueToday = {
      for (final card in _dueCards.dueNow(now)) card.id,
      for (final card in _dueCards.anticipateToday(now)) card.id,
    }.length;

    return CollectionOverview(
      total: all.length,
      held: all.where((card) => !card.isReleased).length,
      released: released.length,
      neverAnswered: released.where((card) => card.reps == 0).length,
      inShortCycle:
          released.where((card) => card.state.isLearning && card.reps > 0).length,
      inReview: released.where((card) => card.state == CardState.review).length,
      firm: released.where((card) => card.isFirm).length,
      ready: released.where((card) => card.isReadyOn(now, target)).length,
      stuck: released.where((card) => card.isProblem).length,
      dueToday: dueToday,
      // The policy the session uses is the one the dashboard counts with: the
      // two never disagree about how many subjects have a queue.
      subjectsDueToday: _dueCards.studiableSubjects(now).length,
    );
  }

  /// How many days in a row there was scheduled study.
  StudyStreak streak(DateTime now, List<ReviewLog> logs) {
    // A single pass over the session logs: they feed both the days and today's
    // count.
    final sessionLogs =
        logs.where((log) => log.source == ReviewSource.session).toList();
    final days = <DateTime>{
      for (final log in sessionLogs) dateOnly(log.reviewedAt),
    };
    final today = dateOnly(now);

    // The current streak only counts from today or yesterday: whoever studied
    // up to the day before yesterday has already lost it, and showing "3 days"
    // would be a lie.
    var current = 0;
    var cursor = days.contains(today) ? today : _dayBefore(today);
    while (days.contains(cursor)) {
      current++;
      cursor = _dayBefore(cursor);
    }
    // No correction after the loop: with no study today nor yesterday the
    // cursor falls outside the set on the first turn and `current` stays at 0.

    final sorted = days.toList()..sort();
    var longest = 0;
    var run = 0;
    DateTime? previous;
    for (final day in sorted) {
      run = previous != null && day.difference(previous).inDays == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
      previous = day;
    }

    final weekStart = _daysBefore(today, 6);
    return StudyStreak(
      current: current,
      longest: longest,
      daysStudiedLastSeven: days
          .where((day) => !day.isBefore(weekStart) && !day.isAfter(today))
          .length,
      answeredToday:
          sessionLogs.where((log) => dateOnly(log.reviewedAt) == today).length,
    );
  }

  /// Progress at "firming a card": the series of the last [days] days, today's
  /// number and the daily average.
  ///
  /// One call only. Three public methods over the same [_crossings] would make
  /// the dashboard regroup and reorder the whole history three times per load.
  FirmedProgress firmedSummary(
    DateTime now,
    List<ReviewLog> logs, {
    int days = 7,
  }) {
    final crossings = _crossings(logs);
    final today = dateOnly(now);
    final counts = <DateTime, int>{
      for (var back = days - 1; back >= 0; back--)
        dateOnly(today.subtract(Duration(days: back))): 0,
    };

    // A crossing is counted where it happened, even if the card fell back
    // afterwards: day 14 did not stop being a day of progress because the card
    // slipped on day 16.
    for (final day in crossings.values) {
      if (counts.containsKey(day)) counts[day] = counts[day]! + 1;
    }
    final series = [
      for (final entry in counts.entries)
        FirmedDay(day: entry.key, cards: entry.value),
    ]..sort((a, b) => a.day.compareTo(b.day));

    final byId = {for (final card in _released) card.id: card};
    final firmedToday = crossings.entries
        .where((entry) => entry.value == today)
        .where((entry) => byId[entry.key]?.isFirm ?? false)
        .length;

    final total = series.fold(0, (sum, day) => sum + day.cards);
    return FirmedProgress(
      series: series,
      today: firmedToday,
      dailyAverage: series.isEmpty ? 0 : total / series.length,
    );
  }

  /// Cards that crossed into "firm" today: the counter that moves every day.
  ///
  /// A thin wrapper, kept for callers that only want the number — no second
  /// reconstruction of the traversal happens here.
  int firmedToday(DateTime now, List<ReviewLog> logs) =>
      firmedSummary(now, logs).today;

  /// The day each card crossed into "firm" **for the last time**, rebuilt from
  /// the history. Cards that never crossed do not appear in the map.
  ///
  /// The crossing is rebuilt from the history, not from the card's current
  /// state: a card firmed on day 14 and reviewed on day 18 carries
  /// `lastReviewedAt` on the 18th, and counting it by the card would throw the
  /// crossing onto the wrong day.
  ///
  /// **Why the last crossing, and not the first.** A card that firmed on day 2,
  /// slipped on day 5 and was rescued today has two crossings. Stopping at the
  /// first would record day 2 — outside the 7-day window, invisible in the
  /// series — and today's number would read 0 for someone who spent the whole
  /// session rescuing stuck cards. The indicator answers "which cards ended up
  /// firm today", not "which firmed for the first time ever"; one crossing per
  /// card still holds in the sense that matters, since the same card never adds
  /// two points to one day.
  Map<String, DateTime> _crossings(List<ReviewLog> logs) {
    final cards = {for (final card in _released) card.id: card};
    final byCard = <String, List<ReviewLog>>{};
    for (final log in logs) {
      // The mock interview writes a log and nothing else; it never firms a
      // card. A held-back card is invisible to the whole funnel.
      if (log.source != ReviewSource.session) continue;
      if (!cards.containsKey(log.cardId)) continue;
      byCard.putIfAbsent(log.cardId, () => []).add(log);
    }

    final crossings = <String, DateTime>{};
    for (final entry in byCard.entries) {
      final history = entry.value
        ..sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
      DateTime? crossing;
      for (var i = 0; i < history.length; i++) {
        if (history[i].stabilityBefore >= firmStabilityDays) continue;
        final next = i + 1 < history.length ? history[i + 1] : null;
        final crossed = next == null
            // The last review has no successor to read the stability from, so
            // the card itself answers whether it ended up firm.
            ? cards[entry.key]!.isFirm
            : next.stabilityBefore >= firmStabilityDays;
        if (crossed) crossing = dateOnly(history[i].reviewedAt);
      }
      if (crossing != null) crossings[entry.key] = crossing;
    }
    return crossings;
  }

  /// The subject map, sorted from worst to best — which is also the order the
  /// weak-subject screen needs.
  ///
  /// [logs] is optional so the callers that only need the counts keep working;
  /// without it the average time of every subject is `null`.
  List<SubjectProgress> subjectMap(
    DateTime now, {
    List<ReviewLog> logs = const [],
  }) {
    final target = _window.window.targetDate;
    // Already filtered by the time ceiling when the log was written.
    final times = timeOnCard(logs).bySubject;
    final bySubject = <String, List<Card>>{};
    for (final card in _released) {
      bySubject.putIfAbsent(card.subject, () => []).add(card);
    }

    final progress = [
      for (final entry in bySubject.entries)
        SubjectProgress(
          subject: entry.key,
          total: entry.value.length,
          ready: entry.value.where((c) => c.isReadyOn(now, target)).length,
          firm: entry.value.where((c) => c.isFirm).length,
          stuck: entry.value.where((c) => c.isProblem).length,
          dueToday: _dueCards.studiableCount(now, entry.key),
          neverAnswered: entry.value.where((c) => c.reps == 0).length,
          nextDueAt: _nextDueAt(entry.value, now),
          averageTime: times[entry.key],
        ),
    ]..sort((a, b) => a.readyRatio.compareTo(b.readyRatio));
    return progress;
  }

  /// The weakest subject: the one with the lowest ratio of ready cards.
  ///
  /// It does not assume the order of the list it receives — [subjectMap] hands
  /// back the worst first today, but tying the answer to that order would make
  /// the screen point at the wrong subject the day the sorting changes. `null`
  /// when no subject has been released.
  ///
  /// A tie is broken by subject name, so two equally weak subjects always
  /// resolve to the same one instead of alternating between loads.
  SubjectProgress? weakestSubject(List<SubjectProgress> subjects) => subjects
      .sorted((a, b) {
        final byRatio = a.readyRatio.compareTo(b.readyRatio);
        return byRatio != 0 ? byRatio : a.subject.compareTo(b.subject);
      })
      .firstOrNull;

  /// One point per day of the next seven.
  List<LoadBar> loadForecast(DateTime now, {int days = 7}) {
    final forecast = _dueCards.forecast(now, days: days);
    final sorted = forecast.keys.toList()..sort();
    return [
      for (final day in sorted) LoadBar(day: day, cards: forecast[day]!),
    ];
  }

  /// Average cards per day in the forecast — the reference line of the chart.
  ///
  /// Same argument as `FirmedProgress.dailyAverage`: the screen compares two
  /// finished numbers, it never computes the second one.
  double averageLoad(List<LoadBar> series) => series.isEmpty
      ? 0
      : series.fold(0, (sum, point) => sum + point.cards) / series.length;

  /// Times over `TimeOnCardPolicy.ceiling` were already dropped when the log
  /// was written, so `timeOnCard == null` simply does not enter here.
  TimeOnCardStats timeOnCard(List<ReviewLog> logs) {
    final subjectOf = {for (final card in _collection.all) card.id: card.subject};
    final all = <Duration>[];
    final bySubject = <String, List<Duration>>{};

    for (final log in logs) {
      final time = log.timeOnCard;
      if (time == null) continue;
      all.add(time);
      final subject = subjectOf[log.cardId];
      if (subject != null) bySubject.putIfAbsent(subject, () => []).add(time);
    }

    final averages = <String, Duration>{};
    for (final entry in bySubject.entries) {
      final average = _average(entry.value);
      if (average != null) averages[entry.key] = average;
    }
    return TimeOnCardStats(overall: _average(all), bySubject: averages);
  }

  /// `_released`, not `_collection.all`: `overview.stuck` counts released
  /// cards, and the dashboard shows both numbers on the same screen — the next
  /// action says "N travados" from the overview and the panel lists this list.
  /// They tie by accident today (a held card was never answered, so its
  /// `lapses` is 0), and the accident is what a change to `ContentIntakePolicy`
  /// would undo in silence.
  List<Card> problemCards() =>
      _released.where((card) => card.isProblem).toList();

  /// `firstOrNull`, never `first` or `firstWhere`: a subject whose cards are
  /// all overdue is a normal state of business, not an error.
  static DateTime? _nextDueAt(List<Card> cards, DateTime now) {
    final upcoming = cards
        .map((card) => card.dueAt)
        .whereType<DateTime>()
        .where((due) => due.isAfter(now))
        .toList()
      ..sort();
    return upcoming.firstOrNull;
  }

  static Duration? _average(List<Duration> values) {
    if (values.isEmpty) return null;
    final total = values.fold(0, (sum, value) => sum + value.inMilliseconds);
    return Duration(milliseconds: total ~/ values.length);
  }

  /// One day earlier, **normalized**. Subtracting 24 h from a local `DateTime`
  /// can land 23 h or 25 h earlier where daylight saving exists, and the result
  /// would stop being midnight — the equality check against the set of days
  /// would then fail in silence.
  static DateTime _dayBefore(DateTime day) => _daysBefore(day, 1);

  static DateTime _daysBefore(DateTime day, int count) =>
      dateOnly(day.subtract(Duration(days: count)));
}
