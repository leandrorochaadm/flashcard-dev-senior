import 'package:flashcard_dev_senior/data/database/app_database.dart';
import 'package:flashcard_dev_senior/data/database/schema_migrations.dart';
import 'package:flashcard_dev_senior/domain/models/study_session.dart';
import 'package:flutter_test/flutter_test.dart';

/// A migration is a pure function over the exported dump, so it is tested
/// without opening any database — which is the whole reason it was written as
/// one.
void main() {
  Map<String, Object?> dumpWithSessions(List<Object?> values) => {
        'sembast_export': 1,
        'version': 1,
        'stores': [
          {
            'name': 'cards',
            'keys': ['card-1'],
            'values': [
              {'id': 'card-1'},
            ],
          },
          {
            'name': 'sessions',
            'keys': [for (var i = 0; i < values.length; i++) 'session-$i'],
            'values': values,
          },
        ],
      };

  test('1 to 2 says the old rounds ran their course', () {
    final upgraded = appSchemaMigrations.upgrade(
      dumpWithSessions([
        {'id': 'session-0', 'finished': false},
      ]),
      fromVersion: 1,
      toVersion: 2,
    );

    final stores = upgraded['stores']! as List;
    final sessions =
        stores.firstWhere((store) => (store as Map)['name'] == 'sessions')
            as Map;
    expect((sessions['values']! as List).single, {
      'roundEndedEarly': false,
      'id': 'session-0',
      'finished': false,
    });

    // Everything else travels untouched.
    final cards =
        stores.firstWhere((store) => (store as Map)['name'] == 'cards') as Map;
    expect((cards['values']! as List).single, {'id': 'card-1'});
  });

  test('a session that already answered the question keeps its answer', () {
    final upgraded = appSchemaMigrations.upgrade(
      dumpWithSessions([
        {'id': 'session-0', 'roundEndedEarly': true},
      ]),
      fromVersion: 1,
      toVersion: 2,
    );

    final stores = upgraded['stores']! as List;
    final sessions =
        stores.firstWhere((store) => (store as Map)['name'] == 'sessions')
            as Map;
    expect(
      ((sessions['values']! as List).single as Map)['roundEndedEarly'],
      isTrue,
    );
  });

  test('a dump with no store list is left alone instead of crashing', () {
    expect(
      appSchemaMigrations
          .upgrade({'empty': true}, fromVersion: 1, toVersion: 2),
      {'empty': true},
    );
  });

  test('the migrated session is readable by the model', () {
    final upgraded = appSchemaMigrations.upgrade(
      dumpWithSessions([
        {
          'id': 'session-0',
          'startedAt': DateTime(2026, 8, 12).toIso8601String(),
          'subjects': ['Estado'],
          'currentRound': 0,
          'remainingInRound': 300,
          'scores': [
            {
              'subject': 'Estado',
              'again': 0,
              'hard': 0,
              'good': 1,
              'easy': 0,
            },
          ],
          'finished': false,
        },
      ]),
      fromVersion: 1,
      toVersion: 2,
    );

    final stores = upgraded['stores']! as List;
    final sessions =
        stores.firstWhere((store) => (store as Map)['name'] == 'sessions')
            as Map;
    final session = StudySession.fromJson(
      Map<String, Object?>.from((sessions['values']! as List).single as Map),
    );

    expect(session.roundEndedEarly, isFalse);
    expect(session.answered, 1);
  });

  test('the chain covers every version the app can restore from', () {
    for (var version = 1; version < AppDatabase.schemaVersion; version++) {
      expect(
        appSchemaMigrations.steps[version],
        isNotNull,
        reason: 'missing the step from $version to ${version + 1}',
      );
    }
  });
}
