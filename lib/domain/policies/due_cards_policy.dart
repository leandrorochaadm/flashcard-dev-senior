import 'package:collection/collection.dart';

import '../models/card.dart';
import '../models/schedule_window.dart';
import '../ports.dart';

/// Which card comes next, and what "anticipating" is allowed to reach.
///
/// The app may pull forward only cards that would fall due later the same day.
/// Never tomorrow's: that would undo the ceiling in practice.
final class DueCardsPolicy {
  const DueCardsPolicy(this._collection);

  final CollectionView _collection;

  List<Card> _studiable() =>
      _collection.all.where((card) => card.isReleased).toList();

  /// Everything already due, oldest first.
  List<Card> dueNow(DateTime now, {String? subject}) {
    final cards = _studiable()
        .where((card) => card.isDueOn(now))
        .where((card) => subject == null || card.subject == subject)
        .toList()
      ..sort(_byDueDate);
    return cards;
  }

  /// Cards that will fall due later today — the only ones anticipation may
  /// reach.
  List<Card> anticipateToday(DateTime now, {String? subject}) {
    final today = dateOnly(now);
    final cards = _studiable()
        .where((card) => subject == null || card.subject == subject)
        .where((card) {
          final due = card.dueAt;
          return due != null && due.isAfter(now) && dateOnly(due) == today;
        })
        .toList()
      ..sort(_byDueDate);
    return cards;
  }

  /// `null` means nothing due in the subject → anticipate what falls due today.
  Card? nextDueCard(DateTime now, String subject, {Set<String> skip = const {}}) {
    final due = dueNow(now, subject: subject)
        .firstWhereOrNull((card) => !skip.contains(card.id));
    if (due != null) return due;
    return anticipateToday(now, subject: subject)
        .firstWhereOrNull((card) => !skip.contains(card.id));
  }

  /// Nothing due and nothing to anticipate → the idle-time screen (H12).
  bool isDayCleared(DateTime now) =>
      dueNow(now).isEmpty && anticipateToday(now).isEmpty;

  /// Number of released cards due on each of the next [days] days — the bars
  /// of the load forecast, and the input of the intake hold.
  Map<DateTime, int> forecast(DateTime now, {int days = 7}) {
    final start = dateOnly(now);
    final counts = <DateTime, int>{
      for (var i = 0; i < days; i++) start.add(Duration(days: i)): 0,
    };
    for (final card in _studiable()) {
      final due = card.dueAt;
      if (due == null) continue;
      // Everything overdue is work for today.
      final day = due.isBefore(now) ? start : dateOnly(due);
      if (counts.containsKey(day)) counts[day] = counts[day]! + 1;
    }
    return counts;
  }

  static int _byDueDate(Card a, Card b) {
    final dueA = a.dueAt;
    final dueB = b.dueAt;
    if (dueA == null || dueB == null) return a.id.compareTo(b.id);
    return dueA.compareTo(dueB);
  }
}
