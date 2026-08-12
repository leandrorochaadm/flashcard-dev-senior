import '../models/card.dart';
import '../models/enums.dart';
import '../models/review_log.dart';
import '../models/schedule_window.dart';
import '../policies/due_cards_policy.dart';
import '../ports.dart';

/// One bar of the 7-day load forecast.
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
  });

  final String subject;
  final int total;

  /// Cards the app calculates would still be recalled on the target date.
  final int ready;
  final int firm;

  /// Problem cards: missed four times in total.
  final int stuck;

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

  /// Cards that crossed into "firm" today: the counter that moves every day.
  ///
  /// A card counts when it is firm now and its last review happened today —
  /// the crossing is what the requirement calls "firmar um cartão".
  int firmedToday(DateTime now, List<ReviewLog> logs) {
    final today = dateOnly(now);
    final firstFirmReview = <String, DateTime>{};
    for (final log in logs.where((log) => log.source == ReviewSource.session)) {
      final wasFirmBefore = log.stabilityBefore >= firmStabilityDays;
      if (wasFirmBefore) continue;
      firstFirmReview.putIfAbsent(log.cardId, () => log.reviewedAt);
    }

    return _released
        .where((card) => card.isFirm)
        .where((card) {
          final last = card.lastReviewedAt;
          return last != null && dateOnly(last) == today;
        })
        .where((card) {
          final crossing = firstFirmReview[card.id];
          return crossing == null || dateOnly(crossing) == today;
        })
        .length;
  }

  /// The subject map, sorted from worst to best — which is also the order the
  /// weak-subject screen needs.
  List<SubjectProgress> subjectMap(DateTime now) {
    final target = _window.window.targetDate;
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
        ),
    ]..sort((a, b) => a.readyRatio.compareTo(b.readyRatio));
    return progress;
  }

  /// Bars of the next seven days, one per day.
  List<LoadBar> loadForecast(DateTime now, {int days = 7}) {
    final forecast = _dueCards.forecast(now, days: days);
    final sorted = forecast.keys.toList()..sort();
    return [
      for (final day in sorted) LoadBar(day: day, cards: forecast[day]!),
    ];
  }

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

  List<Card> problemCards() =>
      _collection.all.where((card) => card.isProblem).toList();

  static Duration? _average(List<Duration> values) {
    if (values.isEmpty) return null;
    final total = values.fold(0, (sum, value) => sum + value.inMilliseconds);
    return Duration(milliseconds: total ~/ values.length);
  }
}
