import 'dart:convert';

import 'package:flashcard_dev_senior/data/database/app_database.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/backup_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../support/domain_fakes.dart';

/// Never queried: the name of the backup file needs no database.
final class _NeverUsedDatabase implements AppDatabase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

AppDatabase _never() => _NeverUsedDatabase();

void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  Future<SembastAdapter> openDatabase() =>
      SembastAdapter.open(newDatabaseFactoryMemory(), 'flashcards_test');

  test('export, wipe, restore: same cards, same history, same return dates',
      () async {
    final db = await openDatabase();
    final cards = CardRepository(db);
    final reviews = ReviewLogRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(importedAt);

    await cards.saveAll([
      for (var i = 0; i < 10; i++)
        newCard('c$i',
            importedAt: importedAt,
            introducedAt: importedAt,
            stability: i.toDouble(),
            dueAt: now.add(Duration(hours: i))),
    ]);
    await reviews.append(
      ReviewLog(
        cardId: 'c1',
        reviewedAt: now,
        rating: Rating.good,
        elapsedDays: 2.5,
        predictedRetention: 0.88,
        stabilityBefore: 4.2,
        timeOnCard: const Duration(seconds: 12),
        source: ReviewSource.session,
      ),
    );

    final before = cards.all;
    final file = await BackupRepository(db).export(now);

    // The browser wipes everything.
    final wiped = await openDatabase();
    final restoredCards = CardRepository(wiped);
    await restoredCards.load();
    expect(restoredCards.all, isEmpty);

    await BackupRepository(wiped).restore(file);
    await restoredCards.load();
    final restoredReviews = ReviewLogRepository(wiped);
    await restoredReviews.load();

    expect(restoredCards.all.length, before.length);
    for (final card in before) {
      final back = restoredCards.byId(card.id);
      expect(back, isNotNull, reason: '${card.id} did not come back');
      expect(back!.dueAt, card.dueAt);
      expect(back.stability, card.stability);
      expect(back.introducedAt, card.introducedAt);
      expect(back, card);
    }
    expect(restoredReviews.all.single.cardId, 'c1');
    expect(restoredReviews.all.single.timeOnCard, const Duration(seconds: 12));
  });

  test('the backup file carries the schema version', () async {
    final db = await openDatabase();

    final file = await BackupRepository(db).export(now);

    expect(
      (jsonDecode(file) as Map)['schemaVersion'],
      AppDatabase.schemaVersion,
    );
  });

  test('a file newer than the app is refused, never guessed at', () async {
    final db = await openDatabase();
    final file = jsonEncode({
      'schemaVersion': AppDatabase.schemaVersion + 1,
      'data': <String, Object?>{},
    });

    expect(
      () => BackupRepository(db).restore(file),
      throwsA(isA<StateError>()),
    );
  });

  test('an older file runs the migrations in chain before importing', () {
    final migrations = SchemaMigrations({
      1: (data) => {...data, 'touchedByV1': true},
      2: (data) => {...data, 'touchedByV2': true},
    });

    final upgraded = migrations
        .upgrade({'original': true}, fromVersion: 1, toVersion: 3);

    expect(upgraded, {
      'original': true,
      'touchedByV1': true,
      'touchedByV2': true,
    });
  });

  test('the backup file is named after the day it was taken', () {
    expect(
      BackupRepository(_never()).fileNameFor(DateTime(2026, 9, 5)),
      'flashcards-2026-09-05.json',
    );
  });

  test('a missing migration step is refused instead of skipped', () {
    const migrations = SchemaMigrations();

    expect(
      () => migrations.upgrade({}, fromVersion: 1, toVersion: 2),
      throwsA(isA<StateError>()),
    );
  });

  test('a file that is not a map at all is refused', () async {
    final db = await openDatabase();

    expect(
      () => BackupRepository(db).restore('[1, 2, 3]'),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => BackupRepository(db).restore('{"data": {}}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('restoring points the adapter at the new database, not the old one',
      () async {
    final db = await openDatabase();
    final cards = CardRepository(db);
    await cards.save(newCard('before', importedAt: importedAt));
    final file = await BackupRepository(db).export(now);
    await cards.save(newCard('after', importedAt: importedAt));

    // Same adapter instance: it has to keep writing to the restored database.
    await BackupRepository(db).restore(file);
    await cards.save(newCard('later', importedAt: importedAt));

    final reopened = CardRepository(db);
    await reopened.load();
    expect(reopened.byId('before'), isNotNull);
    expect(reopened.byId('after'), isNull, reason: 'restore is destructive');
    expect(reopened.byId('later'), isNotNull);
  });

  test('the stacked parameters and their dates survive a reload', () async {
    final db = await openDatabase();
    final settings = SettingsRepository(db);
    await settings.load(now);
    await settings.applyParameters(List<double>.filled(21, 0.5), now);
    await settings.applyParameters(
      List<double>.filled(21, 0.6),
      now.add(const Duration(days: 7)),
    );

    final reopened = SettingsRepository(db);
    await reopened.load(now);

    expect(reopened.activeParameters!.first, 0.6);
    expect(reopened.parameterHistory.length, 1);
    expect(reopened.previousParams()!.parameters.first, 0.5);
    expect(
      reopened.previousParams()!.appliedAt,
      now.add(const Duration(days: 7)),
    );
  });

  // Defensive: a base written by an older build could carry the anchor with
  // no target. The window still has to come out complete.
  test('a base with startDate but no target falls back to the default window',
      () async {
    final db = await openDatabase();
    await db.writeSetting('startDate', DateTime(2026, 8, 10).toIso8601String());

    final settings = SettingsRepository(db);
    await settings.load(now);

    expect(settings.window.startDate, DateTime(2026, 8, 10));
    expect(settings.window.targetDate, DateTime(2026, 9, 9));
  });

  test('closing the database releases it', () async {
    final db = await openDatabase();

    await db.close();

    expect(() => db.allCards(), throwsA(isA<Object>()));
  });

  test('startDate is anchored once and never re-anchored', () async {
    final db = await openDatabase();

    final first = SettingsRepository(db);
    await first.load(DateTime(2026, 8, 11, 9));
    final anchored = first.window;

    final later = SettingsRepository(db);
    await later.load(DateTime(2026, 8, 25, 9));

    expect(later.window.startDate, anchored.startDate);
    expect(later.window.targetDate, anchored.targetDate);
    expect(later.window.dayOfUse(DateTime(2026, 8, 25)), 15);
  });

  test('re-picking the target moves only the target', () async {
    final db = await openDatabase();
    final settings = SettingsRepository(db);
    await settings.load(DateTime(2026, 8, 11, 9));

    await settings.setTargetDate(DateTime(2026, 9, 30));

    final reopened = SettingsRepository(db);
    await reopened.load(DateTime(2026, 8, 11, 9));
    expect(reopened.window.targetDate, DateTime(2026, 9, 30));
    expect(reopened.window.startDate, DateTime(2026, 8, 10));
  });

  test('the parameter stack keeps the date each tuning started to apply',
      () async {
    final db = await openDatabase();
    final settings = SettingsRepository(db);
    await settings.load(DateTime(2026, 8, 11, 9));

    expect(settings.previousParams(), isNull, reason: 'no tuning yet');

    await settings.applyParameters([1, 2, 3], DateTime(2026, 8, 17));
    expect(settings.previousParams(), isNull,
        reason: 'the first tuning has no previous weights to fall back on');

    await settings.applyParameters([4, 5, 6], DateTime(2026, 8, 24));
    expect(settings.previousParams()!.parameters, [1.0, 2.0, 3.0]);
    expect(settings.previousParams()!.appliedAt, DateTime(2026, 8, 24));

    expect(await settings.revertParameters(), [1.0, 2.0, 3.0]);
    expect(settings.activeParameters, [1.0, 2.0, 3.0]);
  });
}
