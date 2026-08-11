import 'package:get_it/get_it.dart';
// Only the `DatabaseFactory` type, which is the swap point of the whole data
// layer. No store, query or transaction of the package appears outside
// `sembast_adapter.dart`.
import 'package:sembast/sembast.dart' show DatabaseFactory;

import '../../data/database/app_database.dart';
import '../../data/database/sembast_adapter.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/import/import_service.dart';
import '../../domain/import/markdown_parser.dart';
import '../../domain/mock_interview/mock_interview_service.dart';
import '../../domain/policies/content_intake_policy.dart';
import '../../domain/policies/due_cards_policy.dart';
import '../../domain/policies/session_policy.dart';
import '../../domain/policies/time_on_card_policy.dart';
import '../../domain/ports.dart';
import '../../domain/scheduling/card_scheduler.dart';
import '../../domain/scheduling/fsrs_adapter.dart';
import '../../domain/scheduling/fsrs_gateway.dart';
import '../../domain/scheduling/moving_ceiling.dart';
import '../../domain/scheduling/optimizer/fsrs_optimizer.dart';
import '../../domain/stats/calibration.dart';
import '../../domain/stats/progress_stats.dart';
import '../clock.dart';

final getIt = GetIt.instance;

/// Production database name. The time-travel screen opens `flashcards_debug`
/// instead, so the development tool can never corrupt the real history.
const productionDatabaseName = 'flashcards';
const debugDatabaseName = 'flashcards_debug';

/// Wires everything up. The [factory] is the swap point: `databaseFactoryWeb`
/// in production, an in-memory one in tests.
Future<void> setupLocator({
  required DatabaseFactory factory,
  String databaseName = productionDatabaseName,
  Clock clock = const SystemClock(),
}) async {
  final db = await SembastAdapter.open(factory, databaseName);

  getIt
    ..registerSingleton<Clock>(clock)
    ..registerSingleton<AppDatabase>(db)
    ..registerSingleton<CardRepository>(CardRepository(db))
    ..registerSingleton<ReviewLogRepository>(ReviewLogRepository(db))
    ..registerSingleton<SettingsRepository>(SettingsRepository(db))
    ..registerSingleton<SessionRepository>(SessionRepository(db))
    ..registerSingleton<BackupRepository>(BackupRepository(db));

  // The in-memory caches have to be warm before any domain class reads them.
  await getIt<CardRepository>().load();
  await getIt<ReviewLogRepository>().load();
  await getIt<SettingsRepository>().load(clock.now());

  getIt
    ..registerLazySingleton<CollectionView>(() => getIt<CardRepository>())
    ..registerLazySingleton<ScheduleWindowView>(() => getIt<SettingsRepository>())
    ..registerLazySingleton<StudyHistoryView>(() => getIt<ReviewLogRepository>())
    ..registerLazySingleton<FsrsGateway>(
      () => FsrsAdapter(getIt<SettingsRepository>().activeParameters),
    )
    ..registerLazySingleton<MovingCeiling>(
      () => MovingCeiling(getIt(), getIt()),
    )
    ..registerLazySingleton<CardScheduler>(
      () => CardScheduler(getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<SessionPolicy>(SessionPolicy.new)
    ..registerLazySingleton<TimeOnCardPolicy>(TimeOnCardPolicy.new)
    ..registerLazySingleton<DueCardsPolicy>(() => DueCardsPolicy(getIt()))
    ..registerLazySingleton<ContentIntakePolicy>(
      () => ContentIntakePolicy(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<MockInterviewService>(
      () => MockInterviewService(getIt()),
    )
    ..registerLazySingleton<MarkdownParser>(MarkdownParser.new)
    ..registerLazySingleton<ImportService>(() => ImportService(getIt(), getIt()))
    ..registerLazySingleton<Calibration>(Calibration.new)
    ..registerLazySingleton<ProgressStats>(
      () => ProgressStats(getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<FsrsOptimizer>(() => FsrsOptimizer(getIt()));
}

/// Used by the time-travel screen: it swaps the clock and points the whole
/// graph at a separate database, then rebuilds the app.
Future<void> resetLocator({
  required DatabaseFactory factory,
  String databaseName = productionDatabaseName,
  Clock clock = const SystemClock(),
}) async {
  await getIt.reset();
  await setupLocator(
    factory: factory,
    databaseName: databaseName,
    clock: clock,
  );
}
