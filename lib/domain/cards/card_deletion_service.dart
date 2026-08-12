import '../models/card.dart';
import '../ports.dart';

/// Which cards a deletion request actually reaches.
///
/// It looks like screen logic and is not: "erase this subject" is a filter over
/// the collection, and a wrong filter erases study history for good. It is
/// stated once here so the collection screen and the mirroring import cannot
/// disagree about what a request covers.
final class CardDeletionSelection {
  const CardDeletionSelection._(this.ids);

  /// The whole collection, released or not.
  factory CardDeletionSelection.everything(List<Card> cards) =>
      CardDeletionSelection._({for (final card in cards) card.id});

  /// Every card of one subject. An unknown subject selects nothing.
  factory CardDeletionSelection.subject(List<Card> cards, String subject) =>
      CardDeletionSelection._({
        for (final card in cards)
          if (card.subject == subject) card.id,
      });

  /// One card, and only if it exists — deleting an id that is not in the
  /// collection is a no-op, never an error.
  factory CardDeletionSelection.single(List<Card> cards, String id) =>
      CardDeletionSelection._({
        for (final card in cards)
          if (card.id == id) card.id,
      });

  /// An explicit set of cards, already decided elsewhere — what the mirroring
  /// import hands over as "not in the file anymore".
  factory CardDeletionSelection.exactly(Iterable<Card> cards) =>
      CardDeletionSelection._({for (final card in cards) card.id});

  final Set<String> ids;

  int get count => ids.length;

  bool get isEmpty => ids.isEmpty;
}

/// Erases cards and the history they carry, in that order.
///
/// Cards go first: if the second step fails, what is left behind is orphan
/// history, which the indicators can ignore. The other order would leave cards
/// whose history vanished — the schedule would then be recomputed from nothing.
final class CardDeletionService {
  const CardDeletionService(this._cards, this._history);

  final CardEraser _cards;
  final HistoryEraser _history;

  /// Returns how many cards were erased.
  Future<int> delete(CardDeletionSelection selection) async {
    if (selection.isEmpty) return 0;
    await _cards.deleteAll(selection.ids);
    await _history.deleteForCards(selection.ids);
    return selection.count;
  }
}
