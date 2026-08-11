import 'package:flashcard_dev_senior/ui/dashboard/widgets/idle_time_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

void main() {
  Widget host() => MaterialApp(
        home: Scaffold(
          body: IdleTimePanel(
            onImportMore: () {},
            onMockInterview: () {},
            onWeakSubjects: () {},
          ),
        ),
      );

  // Three buttons sharing one row fitted at 800x600, the `WidgetTester`
  // default, and broke every label across three lines on a real phone
  // ("Importa / r mais / pergunt / as"). Nothing threw — it just looked
  // broken, which is why the size has to be part of the test.
  //
  // What is asserted is the structural property that fixes it: each button
  // gets the full width of the panel. Counting rendered lines would measure
  // the test font, whose glyphs are square and far wider than any real one,
  // so it would fail on labels that read perfectly in a browser.
  for (final size in const [ScreenSize.phone, ScreenSize.smallPhone]) {
    testWidgets('each way out gets the full width at ${size.width.toInt()}pt',
        (tester) async {
      useScreenSize(tester, size: size);
      await tester.pumpWidget(host());

      final panel = tester.getSize(find.byType(IdleTimePanel)).width;
      // `FilledButton.tonal` builds a `FilledButton`, so the tonal one and the
      // filled one share a type; the label is what tells them apart.
      const buttons = <String, Type>{
        'Importar mais perguntas': FilledButton,
        'Fazer um simulado': FilledButton,
        'Ver os assuntos fracos': OutlinedButton,
      };
      for (final MapEntry(key: label, value: type) in buttons.entries) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(type),
        );
        expect(button, findsOneWidget, reason: label);
        // Was panel/3 before the fix, which is what cramped the labels.
        expect(tester.getSize(button).width, greaterThan(panel * 0.7),
            reason: '$label is sharing its row again');
      }
      expect(tester.takeException(), isNull);
    });
  }
}
