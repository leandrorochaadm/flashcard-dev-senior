import 'package:flashcard_dev_senior/domain/stats/collection_overview.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/accuracy_vs_target_tile.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/due_today_tile.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/firm_today_tile.dart';
import 'package:flashcard_dev_senior/ui/dashboard/widgets/streak_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

/// The four compact tiles, two by two, on the floor of the layout.
///
/// This is the only layout risk of the redesign, so it is the only one that
/// gets a test instead of a checklist item: at 800x600 — the `WidgetTester`
/// default — a `RenderFlex overflowed` would simply not appear. The tiles are
/// public widgets precisely so this test can mount them without the whole
/// dashboard.
void main() {
  List<FirmedDay> series(List<int> values) => [
        for (var i = 0; i < values.length; i++)
          FirmedDay(day: DateTime(2026, 8, 14 + i), cards: values[i]),
      ];

  Widget strip({
    required int firmed,
    required List<int> values,
    required double average,
    required double? accuracy,
    required StudyStreak streak,
    required int dueCards,
    required int dueSubjects,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FirmTodayTile(
                          firmedToday: firmed,
                          series: series(values),
                          average: average,
                        ),
                      ),
                      Expanded(
                        child: AccuracyVsTargetTile(
                          accuracy: accuracy,
                          target: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: StreakTile(streak: streak)),
                      Expanded(
                        child: DueTodayTile(
                          cards: dueCards,
                          subjects: dueSubjects,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  testWidgets('the four compact tiles fit a small phone with long numbers',
      (tester) async {
    useScreenSize(tester, size: ScreenSize.smallPhone);

    await tester.pumpWidget(strip(
      firmed: 999,
      values: const [120, 340, 90, 780, 210, 640, 999],
      average: 454.0,
      accuracy: 1,
      streak: const StudyStreak(
        current: 99,
        longest: 128,
        daysStudiedLastSeven: 7,
        answeredToday: 432,
      ),
      dueCards: 999,
      dueSubjects: 12,
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('999'), findsNWidgets(2));
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('the four compact tiles fit a small phone with empty state',
      (tester) async {
    useScreenSize(tester, size: ScreenSize.smallPhone);

    await tester.pumpWidget(strip(
      firmed: 0,
      values: const [0, 0, 0, 0, 0, 0, 0],
      average: 0,
      accuracy: null,
      streak: const StudyStreak(
        current: 0,
        longest: 0,
        daysStudiedLastSeven: 0,
        answeredToday: 0,
      ),
      dueCards: 0,
      dueSubjects: 0,
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Sem respostas de sessão ainda.'), findsOneWidget);
    expect(find.text('Você ainda não respondeu nada hoje.'), findsOneWidget);
    expect(find.text('Nada vencendo hoje.'), findsOneWidget);
  });

  testWidgets('the four compact tiles fit the default phone too', (tester) async {
    useScreenSize(tester);

    await tester.pumpWidget(strip(
      firmed: 3,
      values: const [1, 2, 4, 3, 5, 2, 3],
      average: 2.857,
      accuracy: 0.87,
      streak: const StudyStreak(
        current: 5,
        longest: 9,
        daysStudiedLastSeven: 6,
        answeredToday: 48,
      ),
      dueCards: 12,
      dueSubjects: 4,
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('acima da média dos últimos 7 dias'), findsOneWidget);
    expect(find.text('melhor 9 · 6 de 7 dias'), findsOneWidget);
  });
}
