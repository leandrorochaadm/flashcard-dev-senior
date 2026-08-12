import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/idle_time_panel.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/subject_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

/// The two halves of the "Ver os assuntos fracos" fix.
///
/// Mounting the whole dashboard would take half a dozen repository fakes, and
/// no new fake was invented for this: what is asserted here is the button's
/// outcome on one side and the opening mechanism on the other. The wiring
/// between them is covered by review.
void main() {
  SubjectProgress progress(String subject, {required int ready}) =>
      SubjectProgress(
        subject: subject,
        total: 10,
        ready: ready,
        firm: ready,
        stuck: 0,
        dueToday: 2,
        neverAnswered: 1,
        nextDueAt: DateTime(2026, 8, 21),
        averageTime: const Duration(seconds: 30),
      );

  Widget host(Widget child) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  testWidgets('the weak subjects button is disabled when there is no weakest '
      'subject', (tester) async {
    useScreenSize(tester);
    var tapped = 0;

    await tester.pumpWidget(host(
      IdleTimePanel(
        onImportMore: () {},
        onMockInterview: () {},
        // What `ProgressStats.weakestSubject` returns on a collection with
        // nothing released.
        onWeakSubjects: null,
      ),
    ));

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Ver os assuntos fracos'),
        matching: find.byType(OutlinedButton),
      ),
    );

    expect(button.onPressed, isNull, reason: 'the tap used to be swallowed');
    expect(
      find.text('Nenhum assunto liberado ainda — não há mapa para mostrar.'),
      findsOneWidget,
    );
    expect(find.textContaining('escolha um dos dois'), findsOneWidget);
    expect(tapped, 0);
  });

  testWidgets('with a weakest subject the button is enabled and reports the tap',
      (tester) async {
    useScreenSize(tester);
    var tapped = 0;

    await tester.pumpWidget(host(
      IdleTimePanel(
        onImportMore: () {},
        onMockInterview: () {},
        onWeakSubjects: () => tapped++,
      ),
    ));

    await tester.tap(find.text('Ver os assuntos fracos'));
    await tester.pump();

    expect(tapped, 1);
    expect(find.textContaining('escolha um dos três'), findsOneWidget);
  });

  testWidgets('expanding a subject through its controller opens the tile',
      (tester) async {
    useScreenSize(tester);
    final controllers = <String, ExpansibleController>{};
    ExpansibleController controllerFor(String subject) =>
        controllers.putIfAbsent(subject, ExpansibleController.new);

    await tester.pumpWidget(host(
      SubjectMap(
        subjects: [progress('Estado', ready: 2), progress('Widgets', ready: 9)],
        controllerOf: controllerFor,
        onSubjectTap: (_) {},
      ),
    ));

    expect(find.text('Nunca respondidos'), findsNothing);

    // This is the correction `initiallyExpanded` could not deliver: the tile is
    // already mounted, and only the controller reopens it.
    controllerFor('Estado').expand();
    await tester.pumpAndSettle();

    expect(find.text('Nunca respondidos'), findsOneWidget);
    expect(find.text('Abrir o assunto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
