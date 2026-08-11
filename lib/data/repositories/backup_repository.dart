import 'dart:convert';

import '../database/app_database.dart';

/// The only real protection against the browser evicting IndexedDB (H14).
final class BackupRepository {
  BackupRepository(this._db, [this._migrations = const SchemaMigrations()]);

  static const _versionKey = 'schemaVersion';
  static const _dataKey = 'data';
  static const _exportedAtKey = 'exportedAt';

  final AppDatabase _db;
  final SchemaMigrations _migrations;

  /// The whole database as a JSON string, stamped with the schema version —
  /// without it, a file from an older schema would be restored blindly.
  Future<String> export(DateTime now) async {
    final payload = <String, Object?>{
      _versionKey: AppDatabase.schemaVersion,
      _exportedAtKey: now.toIso8601String(),
      _dataKey: await _db.exportAll(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Destructive by nature: the caller must have confirmed with the user.
  ///
  /// Same version → import. Older → migrate first. Newer than the app →
  /// refuse with a clear message, never guess.
  Future<void> restore(String fileContents) async {
    final Object? decoded = jsonDecode(fileContents);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Arquivo de cópia de segurança inválido.');
    }
    final version = decoded[_versionKey];
    final data = decoded[_dataKey];
    if (version is! int || data is! Map) {
      throw const FormatException(
        'Arquivo sem versão de schema — não é uma cópia deste app.',
      );
    }

    final migrated = _migrations.upgrade(
      Map<String, Object?>.from(data),
      fromVersion: version,
    );
    await _db.restore(migrated);
  }

  String fileNameFor(DateTime now) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'flashcards-${now.year}-${two(now.month)}-${two(now.day)}.json';
  }
}
