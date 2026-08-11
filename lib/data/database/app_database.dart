/// The document store, as the repositories need it.
///
/// Deliberately free of any sembast type: the package lives behind
/// `sembast_adapter.dart` and nowhere else, which is what allows the tests to
/// run the whole data layer on the Dart VM with an in-memory factory.
abstract interface class AppDatabase {
  /// Every stored model that changes the persisted JSON has to bump this and
  /// ship a migration — otherwise yesterday's backup breaks tomorrow's app.
  static const schemaVersion = 1;

  Future<List<Map<String, Object?>>> allCards();
  Future<void> saveCard(String id, Map<String, Object?> value);
  Future<void> saveCards(Map<String, Map<String, Object?>> values);
  Future<void> deleteCard(String id);

  Future<void> appendReview(Map<String, Object?> value);
  Future<List<Map<String, Object?>>> allReviews();

  Future<Object?> readSetting(String key);
  Future<void> writeSetting(String key, Object? value);

  Future<List<Map<String, Object?>>> allSessions();
  Future<void> saveSession(String id, Map<String, Object?> value);
  Future<void> deleteSession(String id);

  /// Raw dump of every store — the body of the backup file (H14).
  Future<Map<String, Object?>> exportAll();

  /// Destructive: wipes the database and replaces it with [data].
  Future<void> restore(Map<String, Object?> data);

  Future<void> close();
}

/// A schema migration is a pure function over the exported map, so it is
/// testable without opening any database.
typedef SchemaMigration = Map<String, Object?> Function(Map<String, Object?>);

/// Chained migrations, one per version step: [1] takes a v1 dump to v2.
final class SchemaMigrations {
  const SchemaMigrations([this.steps = const {}]);

  final Map<int, SchemaMigration> steps;

  /// Brings [data], exported at [fromVersion], up to [toVersion].
  ///
  /// A file newer than the app is refused instead of guessed at.
  Map<String, Object?> upgrade(
    Map<String, Object?> data, {
    required int fromVersion,
    int toVersion = AppDatabase.schemaVersion,
  }) {
    if (fromVersion > toVersion) {
      throw StateError(
        'Backup na versão $fromVersion, mais nova que a do app ($toVersion).',
      );
    }
    var migrated = data;
    for (var version = fromVersion; version < toVersion; version++) {
      final step = steps[version];
      if (step == null) {
        throw StateError('Falta a migração da versão $version para ${version + 1}.');
      }
      migrated = step(migrated);
    }
    return migrated;
  }
}
