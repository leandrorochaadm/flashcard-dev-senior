import 'dart:async';

import 'package:collection/collection.dart';

import '../../domain/models/card.dart';
import '../../domain/ports.dart';
import '../database/app_database.dart';

/// Every card, kept in memory.
///
/// A hundred cards and a few thousand reviews are about 300 KB: an index would
/// not speed up a `.where()` over that, and every query (due, by subject, the
/// firmness map) becomes an in-memory operation.
///
/// It exposes a [Stream], never a `ValueNotifier`: that type comes from
/// `package:flutter/foundation.dart` and would drag Flutter into `data/`.
/// Turning the stream into a notifier is the ViewModel's job.
final class CardRepository implements CollectionView, CardWriter, CardEraser {
  CardRepository(this._db);

  final AppDatabase _db;
  final _cards = <String, Card>{};
  final _changes = StreamController<List<Card>>.broadcast();

  @override
  List<Card> get all => List.unmodifiable(_cards.values);

  Stream<List<Card>> get changes => _changes.stream;

  Future<void> load() async {
    _cards
      ..clear()
      ..addEntries([
        for (final json in await _db.allCards())
          MapEntry(json['id']! as String, Card.fromJson(json)),
      ]);
    _emit();
  }

  /// `null` means the card does not exist — on import, that is a new card.
  Card? byId(String id) => _cards[id];

  /// Fallback match when the file carries no `id:`. Editing the question text
  /// then makes the card enter as new, which is documented behavior, not a bug.
  Card? byQuestion(String question) =>
      _cards.values.firstWhereOrNull((card) => card.question == question);

  List<String> get subjects =>
      _cards.values.map((card) => card.subject).toSet().toList()..sort();

  Future<void> save(Card card) async {
    _cards[card.id] = card;
    await _db.saveCard(card.id, card.toJson());
    _emit();
  }

  @override
  Future<void> saveAll(Iterable<Card> cards) async {
    for (final card in cards) {
      _cards[card.id] = card;
    }
    await _db.saveCards({for (final card in cards) card.id: card.toJson()});
    _emit();
  }

  Future<void> delete(String id) async {
    _cards.remove(id);
    await _db.deleteCard(id);
    _emit();
  }

  @override
  Future<void> deleteAll(Iterable<String> ids) async {
    // Materialized: the caller may be iterating over the very collection this
    // is about to change.
    final targets = ids.toList(growable: false);
    for (final id in targets) {
      _cards.remove(id);
    }
    await _db.deleteCards(targets);
    _emit();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(all);
  }

  Future<void> dispose() => _changes.close();
}
