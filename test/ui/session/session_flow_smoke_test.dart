@Tags(['chrome-only'])
library;

import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/core/di/service_locator.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/ui/session/session_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

/// The one `WidgetTester` test in the project (see CLAUDE.md — every other
/// test avoids it on purpose). It exists to catch wiring mistakes that unit
/// tests cannot see: a `get_it` registration in the wrong order, a state the
/// view forgets to handle, a button that does not call back into the
/// view model. It reuses the same injectable seams as the rest of the suite
/// — `FakeClock` and `databaseFactoryMemory` — through `setupLocator`, the
/// exact wiring `main.dart` uses in production.
///
/// Run with `flutter test --platform chrome`, not the default VM runner.
/// `SessionView` builds `AppScaffold`, which imports `core/router.dart`, which
/// in turn reaches every other feature — including `text_file_picker.dart`
/// and `browser_download.dart`, both `dart:js_interop`. That library does not
/// exist on the Dart VM, so loading this file under the plain `flutter test`
/// runner fails to compile; it only exists under the `chrome` platform,
/// which compiles to JS. The CI workflow (`.github/workflows/ci.yml`) runs
/// `flutter test` on the VM only, so this file needs its own job to run in
/// CI — see the `widget_smoke_chrome` job if one was added, or run it
/// manually otherwise.
void main() {
  final now = DateTime(2026, 8, 20, 10);
  final importedAt = DateTime(2026, 8, 11);

  setUp(() async {
    await getIt.reset();
    await setupLocator(
      factory: newDatabaseFactoryMemory(),
      databaseName: 'flashcards_session_flow_smoke_test',
      clock: FakeClock(now),
    );

    // Two cards, same subject, already released and due: enough to exercise
    // "answer one, see the next" without touching the round-break path.
    await getIt<CardRepository>().saveAll([
      newCard(
        'due-1',
        subject: 'Estado',
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: now.subtract(const Duration(hours: 1)),
      ),
      newCard(
        'due-2',
        subject: 'Estado',
        importedAt: importedAt,
        introducedAt: importedAt,
        dueAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'picking a subject, revealing and rating a card advances the session',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SessionView()),
      );
      await tester.pumpAndSettle();

      // Subject picker: a single subject is available, so tapping it already
      // satisfies "choose one subject per round" and enables the button.
      expect(find.text('Estado'), findsOneWidget);
      await tester.tap(find.text('Estado'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Começar (1/1)'));
      await tester.pumpAndSettle();

      // First card's question, answer hidden.
      expect(find.text('Pergunta due-1'), findsOneWidget);
      expect(find.text('Resposta due-1'), findsNothing);

      await tester.tap(find.text('Mostrar resposta'));
      await tester.pumpAndSettle();

      expect(find.text('Resposta due-1'), findsOneWidget);

      // "Lembrei com esforço" == Rating.good, the client's own label.
      await tester.tap(find.text('Lembrei com esforço'));
      await tester.pumpAndSettle();

      // The round is not over (5-minute timer, not card count), so the
      // session moves straight to the second due card.
      expect(find.text('Pergunta due-2'), findsOneWidget);
    },
  );
}
