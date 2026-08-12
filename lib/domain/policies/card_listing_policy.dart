import '../models/card.dart';

/// How the collection screen (H7) orders the cards it shows.
///
/// Problem cards surface first, as their own group, because they are the
/// ones asking for a rewrite. Inside each group the order is `dueAt`
/// ascending — the most overdue (or soonest) card first. A card without a
/// `dueAt` (not yet released, or never reviewed) has nothing to sort by, so
/// it sinks to the end of its group instead of before every dated card.
/// `abstract final`, the same shape `AppRoutes` uses: everything here is
/// static, so there is nothing to instantiate and no private constructor left
/// sitting uncovered.
abstract final class CardListingPolicy {
  static List<Card> sortForCollection(List<Card> cards) {
    final problems = <Card>[];
    final rest = <Card>[];
    for (final card in cards) {
      (card.isProblem ? problems : rest).add(card);
    }
    problems.sort(_byDueDateAscending);
    rest.sort(_byDueDateAscending);
    return [...problems, ...rest];
  }

  /// How many cards each subject holds, so the filter chips can show the size
  /// of what they select. Counting cards per subject is a question about the
  /// collection, not about the screen that paints it.
  static Map<String, int> countBySubject(List<Card> cards) {
    final counts = <String, int>{};
    for (final card in cards) {
      counts[card.subject] = (counts[card.subject] ?? 0) + 1;
    }
    return counts;
  }

  static int _byDueDateAscending(Card a, Card b) {
    final dueA = a.dueAt;
    final dueB = b.dueAt;
    if (dueA == null && dueB == null) return 0;
    if (dueA == null) return 1;
    if (dueB == null) return -1;
    return dueA.compareTo(dueB);
  }
}
