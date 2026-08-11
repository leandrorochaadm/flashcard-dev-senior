import 'package:sembast_web/sembast_web.dart';

/// The production database factory — IndexedDB.
///
/// Split off from `sembast_adapter.dart` for one reason: `sembast_web` is
/// compiled against browser APIs and cannot be loaded by the Dart VM, so
/// importing it there would drag every repository test onto
/// `--platform chrome`. Nothing but the service locator imports this file; the
/// adapter itself still takes the factory through its constructor.
/// Typed as `dynamic`-free by the package's own export.
DatabaseFactory get webDatabaseFactory => databaseFactoryWeb;
