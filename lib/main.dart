import 'dart:async';

import 'package:flutter/material.dart';

import 'core/daily_release.dart';
import 'core/di/service_locator.dart';
import 'core/router.dart';
import 'data/database/web_database_factory.dart';
import 'data/storage_persistence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asks the browser to keep the storage: IndexedDB can be evicted under disk
  // pressure, which is risk 2. It is a browser API, not a database one, so it
  // lives outside the adapter.
  await requestPersistentStorage();
  await setupLocator(factory: webDatabaseFactory);
  // The day's batch goes out before the first screen builds, so entering
  // through Estudar or Simulado works exactly like entering through the
  // dashboard. It used to happen in `DashboardView.initState`, which meant
  // importing and going straight to the study tab found nothing at all.
  await getIt<DailyRelease>().run();
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatefulWidget {
  const FlashcardApp({super.key});

  @override
  State<FlashcardApp> createState() => _FlashcardAppState();
}

class _FlashcardAppState extends State<FlashcardApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A PWA is suspended, not closed: without this, crossing midnight with the
    // app open would keep serving yesterday's batch, and nothing would signal
    // that a day went by. `run()` is idempotent per day, so firing it on every
    // resume costs nothing.
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(getIt<DailyRelease>().run()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F6FEB),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F6FEB),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
