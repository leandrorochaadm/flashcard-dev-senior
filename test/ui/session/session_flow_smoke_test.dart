@TestOn('browser')
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
import '../../support/screen_sizes.dart';

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
/// which compiles to JS.
///
/// In CI it is the `widget-tests-chrome` job of `.github/workflows/ci.yml`
/// that runs it, via `flutter test --platform chrome --tags=chrome-only`.
/// `@TestOn('browser')` makes a plain local `flutter test` skip this file
/// instead of failing to compile — the tag alone only helps whoever remembers
/// to pass `--exclude-tags`.
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
      // The study session ships on a phone. At the 800x600 default the four
      // rating buttons have room they do not have in production, so the test
      // would pass on a layout the user never sees.
      useScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(home: SessionView()),
      );
      await tester.pumpAndSettle();

      // Subject picker: a single subject is available, so tapping it already
      // satisfies "choose one subject per round" and enables the button.
      expect(find.text('Estado'), findsOneWidget);
      await tester.tap(find.text('Estado'));
      await tester.pump();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Começar · 1 assunto · 5 min'),
      );
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

  // The picker used to force exactly five subjects. It now accepts any number
  // from one up, so the two ends are what a regression would break: zero keeps
  // the button dead, and six — past the old ceiling — starts a six-round
  // session.
  testWidgets('any number of subjects can be picked, above five included',
      (tester) async {
    useScreenSize(tester);

    const extras = ['Widgets', 'Testes', 'Async', 'Plataforma', 'Build'];
    await getIt<CardRepository>().saveAll([
      for (final subject in extras)
        newCard(
          'due-$subject',
          subject: subject,
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(const Duration(hours: 1)),
        ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: SessionView()));
    await tester.pumpAndSettle();

    // Nothing picked: no round to run, so the button stays dead.
    final startButton = find.widgetWithText(FilledButton, 'Começar');
    expect(tester.widget<FilledButton>(startButton).onPressed, isNull);

    for (final subject in ['Estado', ...extras]) {
      await tester.tap(find.text(subject));
      await tester.pump();
    }

    // Six subjects — one past the old fixed five — and the session length
    // follows the list instead of a constant.
    await tester.tap(
      find.widgetWithText(FilledButton, 'Começar · 6 assuntos · 30 min'),
    );
    await tester.pumpAndSettle();

    // The clock counts the rounds this session actually has, not five.
    expect(find.text('Round 1/6'), findsOneWidget);
  });

  // The four labels are the client's own words and cannot be shortened, so the
  // narrowest phone is where they either fit or overflow. A `RenderFlex`
  // overflow fails the test on its own — `tester.takeException` is here to say
  // so out loud instead of leaving a red stripe in a screenshot nobody takes.
  testWidgets('the rating buttons survive the narrowest phone', (tester) async {
    useScreenSize(tester, size: ScreenSize.smallPhone);

    await tester.pumpWidget(const MaterialApp(home: SessionView()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Estado'));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Começar · 1 assunto · 5 min'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mostrar resposta'));
    await tester.pumpAndSettle();

    for (final label in const [
      'Errei',
      'Lembrei só uma parte',
      'Lembrei com esforço',
      'Sabia de cor',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(tester.takeException(), isNull);
  });
}
