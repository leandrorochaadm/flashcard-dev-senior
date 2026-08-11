import '../models/card.dart';

/// How the collection screen (H7) orders the cards it shows.
///
/// Problem cards surface first, as their own group, because they are the
/// ones asking for a rewrite. Inside each group the order is `dueAt`
/// ascending — the most overdue (or soonest) card first. A card without a
/// `dueAt` (not yet released, or never reviewed) has nothing to sort by, so
/// it sinks to the end of its group instead of before every dated card.
final class CardListingPolicy {
  const CardListingPolicy._();

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

  static int _byDueDateAscending(Card a, Card b) {
    final dueA = a.dueAt;
    final dueB = b.dueAt;
    if (dueA == null && dueB == null) return 0;
    if (dueA == null) return 1;
    if (dueB == null) return -1;
    return dueA.compareTo(dueB);
  }
}
