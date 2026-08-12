import 'package:flashcard_dev_senior/ui/session/widgets/round_break_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

/// The turn of the round says the same thing in two situations that feel very
/// different: the five minutes ran out, or the user chose to stop. Only the
/// wording separates them — nothing about the scoring changes — which is
/// exactly the kind of condition a refactor inverts without breaking anything
/// else.
void main() {
  Widget host({
    required bool endedEarly,
    String? next,
    int remainingDueCards = 0,
    VoidCallback? onEndSession,
    VoidCallback? onExtend,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: RoundBreakScreen(
            finished: 'Estado',
            next: next,
            remainingDueCards: remainingDueCards,
            endedEarly: endedEarly,
            onContinue: () {},
            onExtend: onExtend ?? () {},
            onEndSession: onEndSession ?? () {},
          ),
        ),
      );

  testWidgets('the clock running out is the plain end of the round',
      (tester) async {
    useScreenSize(tester);
    await tester.pumpWidget(host(endedEarly: false, next: 'Widgets'));

    expect(find.text('Fim do round'), findsOneWidget);
    expect(find.text('Round encerrado'), findsNothing);
    expect(find.text('Tudo o que você respondeu foi salvo.'), findsNothing);
  });

  testWidgets('stopping on purpose is confirmed, not scolded', (tester) async {
    useScreenSize(tester);
    await tester.pumpWidget(host(endedEarly: true, next: 'Widgets'));

    expect(find.text('Round encerrado'), findsOneWidget);
    expect(find.text('Fim do round'), findsNothing);
    expect(find.text('Tudo o que você respondeu foi salvo.'), findsOneWidget);
  });

  testWidgets('leaving the session is offered while rounds remain',
      (tester) async {
    useScreenSize(tester);
    var asked = 0;
    await tester.pumpWidget(
      host(endedEarly: true, next: 'Widgets', onEndSession: () => asked++),
    );

    await tester.tap(find.text('Encerrar a sessão'));
    await tester.pump();

    expect(asked, 1);
  });

  testWidgets('the last round has no session left to leave', (tester) async {
    useScreenSize(tester);
    await tester.pumpWidget(host(endedEarly: false));

    // "Ver o resultado" already is the way out — a second button would only
    // ask the same question twice.
    expect(find.text('Encerrar a sessão'), findsNothing);
    expect(find.text('Ver o resultado'), findsOneWidget);
  });

  testWidgets('cards still due offer another round on the same subject',
      (tester) async {
    useScreenSize(tester);
    var extended = 0;
    await tester.pumpWidget(
      host(
        endedEarly: true,
        next: 'Widgets',
        remainingDueCards: 3,
        onExtend: () => extended++,
      ),
    );

    expect(find.text('Ainda restam 3 cartões vencidos em Estado.'),
        findsOneWidget);
    await tester.tap(find.text('Estender o round de Estado'));
    await tester.pump();

    expect(extended, 1);
  });
}
