@TestOn('browser')
@Tags(['chrome-only'])
library;

// End-to-end backup test against the REAL production database factory
// (IndexedDB), not `databaseFactoryMemory`. Every other repository test in
// this suite (see `test/data/backup_roundtrip_test.dart`) runs on the Dart
// VM with the in-memory factory — fast, but it never touches
// `sembast_web`/IndexedDB, so a bug specific to the real browser storage
// (quota, serialization, eviction-then-restore) would go unnoticed.
//
// This file exercises H14 (backup) for real: write records, export a
// backup, close and reopen the SAME IndexedDB database (simulating the
// browser wiping it — the risk H14 exists to cover), restore the backup,
// and check the data comes back.
//
// HOW TO RUN — this only works under the `chrome` platform, never the
// default VM runner:
//
//   flutter test --platform chrome test/data/backup_indexeddb_e2e_test.dart
//
// It is tagged `chrome-only` and picked up by the `widget-tests-chrome` CI
// job in `.github/workflows/ci.yml`, which runs on `ubuntu-latest` (Chrome
// is preinstalled there) via `flutter test --platform chrome
// --tags=chrome-only`. The default `flutter test` CI job explicitly
// excludes this tag — loading this file on the Dart VM is not possible: the
// `web` package (via `sembast_web`) reaches `dart:js_interop`, which does
// not exist off the web compiler.
//
// `@TestOn('browser')` is what makes a plain `flutter test` — the command
// `CLAUDE.md` documents — report this file as skipped instead of failing to
// compile. The tag alone did not: it only works for someone who remembers to
// pass `--exclude-tags`, and three red files on every local run teach the
// team to ignore red.
import 'package:flashcard_dev_senior/data/database/app_database.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/database/web_database_factory.dart';
import 'package:flashcard_dev_senior/data/repositories/backup_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/domain_fakes.dart';

void main() {
  // A dedicated database name so a stray run never collides with a real
  // "flashcards" database opened by the app itself in the same browser
  // profile.
  const databaseName = 'flashcards_e2e_indexeddb_test';

  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  Future<SembastAdapter> openDatabase() =>
      SembastAdapter.open(webDatabaseFactory, databaseName);

  Future<void> wipeDatabase() async {
    // Best-effort cleanup so repeated local runs start from a clean slate;
    // IndexedDB persists across test runs inside the same browser profile.
    final db = await openDatabase();
    await db.close();
    await webDatabaseFactory.deleteDatabase(databaseName);
  }

  setUp(wipeDatabase);
  tearDown(wipeDatabase);

  test(
    'IndexedDB: export, lose the database, restore — data and history come back',
    () async {
      final db = await openDatabase();
      final cards = CardRepository(db);
      final reviews = ReviewLogRepository(db);

      await cards.saveAll([
        for (var i = 0; i < 5; i++)
          newCard(
            'idb-c$i',
            importedAt: importedAt,
            introducedAt: importedAt,
            stability: i.toDouble(),
            dueAt: now.add(Duration(hours: i)),
          ),
      ]);
      await reviews.append(
        ReviewLog(
          cardId: 'idb-c1',
          reviewedAt: now,
          rating: Rating.good,
          elapsedDays: 2.5,
          predictedRetention: 0.88,
          stabilityBefore: 4.2,
          timeOnCard: const Duration(seconds: 9),
          source: ReviewSource.session,
        ),
      );

      final before = cards.all;
      final file = await BackupRepository(db).export(now);
      await db.close();

      // Simulate the browser evicting IndexedDB: delete the database and
      // reopen it fresh, exactly as a new tab would find it after eviction.
      await webDatabaseFactory.deleteDatabase(databaseName);
      final reopened = await openDatabase();
      final reopenedCards = CardRepository(reopened);
      await reopenedCards.load();
      expect(reopenedCards.all, isEmpty);

      await BackupRepository(reopened).restore(file);
      await reopenedCards.load();
      final reopenedReviews = ReviewLogRepository(reopened);
      await reopenedReviews.load();

      expect(reopenedCards.all.length, before.length);
      for (final card in before) {
        final back = reopenedCards.byId(card.id);
        expect(back, isNotNull, reason: '${card.id} did not come back');
        expect(back!.dueAt, card.dueAt);
        expect(back.stability, card.stability);
        expect(back.introducedAt, card.introducedAt);
      }
      expect(reopenedReviews.all.single.cardId, 'idb-c1');
      expect(
        reopenedReviews.all.single.timeOnCard,
        const Duration(seconds: 9),
      );

      await reopened.close();
    },
  );

  test('the backup file carries the schema version, on IndexedDB too',
      () async {
    final db = await openDatabase();
    final file = await BackupRepository(db).export(now);

    expect(
      RegExp(r'"schemaVersion":\s*(\d+)').firstMatch(file)!.group(1),
      '${AppDatabase.schemaVersion}',
    );

    await db.close();
  });
}
