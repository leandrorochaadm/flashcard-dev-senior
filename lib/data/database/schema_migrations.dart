import 'app_database.dart';

/// The migrations a backup file goes through on its way to the current schema.
///
/// Each step is a pure function over the exported dump — the sembast export
/// shape: `{'stores': [{'name': …, 'keys': […], 'values': […]}]}` — so it is
/// testable without opening any database.
const appSchemaMigrations = SchemaMigrations({1: _v1ToV2});

/// 1 → 2: the session learned whether its round was stopped by hand.
///
/// Restoring an older file has to answer that question for rounds recorded
/// before it existed, and the honest answer is "it ran its course".
Map<String, Object?> _v1ToV2(Map<String, Object?> data) => _mapStore(
      data,
      'sessions',
      (session) => {'roundEndedEarly': false, ...session},
    );

/// Rewrites every value of [store], leaving the rest of the dump untouched.
Map<String, Object?> _mapStore(
  Map<String, Object?> data,
  String store,
  Map<String, Object?> Function(Map<String, Object?>) change,
) {
  final stores = data['stores'];
  if (stores is! List) return data;
  return {
    ...data,
    'stores': [
      for (final entry in stores)
        if (entry is Map && entry['name'] == store)
          {
            ...Map<String, Object?>.from(entry),
            'values': [
              for (final value in (entry['values'] as List? ?? const []))
                if (value is Map)
                  change(Map<String, Object?>.from(value))
                else
                  value,
            ],
          }
        else
          entry,
    ],
  };
}
