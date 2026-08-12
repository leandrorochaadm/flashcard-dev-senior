import 'package:sembast/sembast.dart';
// exportDatabase / importDatabase — the backup file is literally this JSON.
import 'package:sembast/utils/sembast_import_export.dart' hide Database, DatabaseFactory;

import 'app_database.dart';

/// The one and only file allowed to touch sembast.
///
/// The [DatabaseFactory] arrives through the constructor on purpose: production
/// passes `databaseFactoryWeb` (IndexedDB), tests pass `databaseFactoryMemory`
/// and run on the Dart VM with plain `flutter test`.
final class SembastAdapter implements AppDatabase {
  SembastAdapter._(this._factory, this._path, this._db);

  static final _cards = stringMapStoreFactory.store('cards');
  static final _reviews = intMapStoreFactory.store('reviews');
  static final _settings = StoreRef<String, Object?>('settings');
  static final _sessions = stringMapStoreFactory.store('sessions');

  final DatabaseFactory _factory;

  /// A parameter, never a constant: `flashcards` in production and
  /// `flashcards_debug` on the time-travel screen, which must never write to
  /// the real history.
  final String _path;

  /// Reassigned on restore: `importDatabase` returns a NEW instance and the
  /// old one would keep writing to the database that was just deleted.
  Database _db;

  static Future<SembastAdapter> open(
    DatabaseFactory factory,
    String path,
  ) async {
    final db = await factory.openDatabase(
      path,
      version: AppDatabase.schemaVersion,
      onVersionChanged: (db, oldVersion, newVersion) async {
        // Version 1 is the first schema; there is nothing to migrate yet.
        // Every future step runs here, in chain, one per version.
      },
    );
    return SembastAdapter._(factory, path, db);
  }

  @override
  Future<List<Map<String, Object?>>> allCards() async {
    final records = await _cards.find(_db);
    return [for (final record in records) Map<String, Object?>.from(record.value)];
  }

  @override
  Future<void> saveCard(String id, Map<String, Object?> value) =>
      _cards.record(id).put(_db, value);

  @override
  Future<void> saveCards(Map<String, Map<String, Object?>> values) =>
      _db.transaction((txn) async {
        for (final entry in values.entries) {
          await _cards.record(entry.key).put(txn, entry.value);
        }
      });

  @override
  Future<void> deleteCard(String id) => _cards.record(id).delete(_db).then((_) {});

  @override
  Future<void> deleteCards(Iterable<String> ids) => _db.transaction((txn) async {
        for (final id in ids) {
          await _cards.record(id).delete(txn);
        }
      });

  @override
  Future<void> deleteReviewsOfCards(Set<String> cardIds) => _reviews
      .delete(
        _db,
        finder: Finder(filter: Filter.inList('cardId', cardIds.toList())),
      )
      .then((_) {});

  @override
  Future<void> appendReview(Map<String, Object?> value) =>
      _reviews.add(_db, value).then((_) {});

  @override
  Future<List<Map<String, Object?>>> allReviews() async {
    final records = await _reviews.find(_db);
    return [for (final record in records) Map<String, Object?>.from(record.value)];
  }

  @override
  Future<Object?> readSetting(String key) => _settings.record(key).get(_db);

  @override
  Future<void> writeSetting(String key, Object? value) =>
      _settings.record(key).put(_db, value);

  @override
  Future<List<Map<String, Object?>>> allSessions() async {
    final records = await _sessions.find(_db);
    return [for (final record in records) Map<String, Object?>.from(record.value)];
  }

  @override
  Future<void> saveSession(String id, Map<String, Object?> value) =>
      _sessions.record(id).put(_db, value);

  @override
  Future<void> deleteSession(String id) =>
      _sessions.record(id).delete(_db).then((_) {});

  @override
  Future<Map<String, Object?>> exportAll() => exportDatabase(_db);

  @override
  Future<void> restore(Map<String, Object?> data) async {
    await _db.close();
    _db = await importDatabase(data, _factory, _path);
  }

  @override
  Future<void> close() => _db.close();
}
