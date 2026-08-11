import 'package:collection/collection.dart';

import '../models/card.dart';
import '../models/schedule_window.dart';
import '../ports.dart';

/// A subject that has something to study today, and how much.
///
/// The count is everything [DueCardsPolicy.nextDueCard] would be willing to
/// serve in the subject: what is already due plus what anticipation may reach.
final class SubjectQueue {
  const SubjectQueue({required this.subject, required this.cards});

  final String subject;
  final int cards;
}

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

  /// How many cards the subject can still serve, minus the ones already
  /// answered in this round — the counter the study screen shows next to the
  /// clock.
  int studiableCount(
    DateTime now,
    String subject, {
    Set<String> skip = const {},
  }) {
    final ids = {
      for (final card in dueNow(now, subject: subject)) card.id,
      for (final card in anticipateToday(now, subject: subject)) card.id,
    }..removeAll(skip);
    return ids.length;
  }

  /// Subjects worth offering on the picker: the ones that would actually serve
  /// a card today, biggest queue first.
  ///
  /// A subject whose cards are all still held by the [ContentIntakePolicy], or
  /// all scheduled for a later day, has nothing to show — offering it would
  /// start a round that ends on the first card, before any question appears.
  List<SubjectQueue> studiableSubjects(DateTime now) {
    final counts = <String, Set<String>>{};
    for (final card in [...dueNow(now), ...anticipateToday(now)]) {
      counts.putIfAbsent(card.subject, () => {}).add(card.id);
    }
    return [
      for (final entry in counts.entries)
        SubjectQueue(subject: entry.key, cards: entry.value.length),
    ]..sort((a, b) {
        final byCards = b.cards.compareTo(a.cards);
        return byCards != 0 ? byCards : a.subject.compareTo(b.subject);
      });
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

  /// Both lists that use this filter on `dueAt != null` first, so the dates
  /// are known to exist here.
  static int _byDueDate(Card a, Card b) => a.dueAt!.compareTo(b.dueAt!);
}
