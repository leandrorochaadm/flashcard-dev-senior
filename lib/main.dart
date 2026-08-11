import 'package:flutter/material.dart';

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
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

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
