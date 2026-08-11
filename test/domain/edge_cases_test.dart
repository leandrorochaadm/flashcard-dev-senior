import 'package:flashcard_dev_senior/domain/import/import_service.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/domain/mock_interview/mock_interview_service.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/domain_fakes.dart';

/// Edge cases the requirements describe as normal states of business: an empty
/// collection, a card with no date yet, a subject nobody answered.
void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 9);

  test('a mock score with nothing asked reports zero, never a division by zero',
      () {
    const score = MockInterviewScore(subject: 'Estado', asked: 0, recalled: 0);

    expect(score.accuracy, 0);
  });

  test('a subject with no cards reports zero ratios instead of NaN', () {
    const progress =
        SubjectProgress(subject: 'Estado', total: 0, ready: 0, firm: 0, stuck: 0);

    expect(progress.readyRatio, 0);
    expect(progress.firmRatio, 0);
  });

  test('an outcome counts what would be created plus what would be updated',
      () {
    const outcome = ImportOutcome(created: [], updated: []);

    expect(outcome.total, 0);
  });

  test('a card with no date yet is simply not due', () {
    final collection = FakeCollection([
      newCard('b', importedAt: importedAt, introducedAt: importedAt),
      newCard('a', importedAt: importedAt, introducedAt: importedAt),
      newCard('c',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(const Duration(hours: 1))),
    ]);

    final due = DueCardsPolicy(collection).dueNow(now);

    expect(due.map((card) => card.id), ['c']);
  });

  test('blank lines around a section are trimmed, inner ones preserved', () {
    const source = '''
---
id: est-001
assunto: Estado
dificuldade: básico

**Pergunta**


Primeira linha da pergunta?


**Resposta**

Primeiro parágrafo.

Segundo parágrafo.

''';

    final preview = const MarkdownParser().parse(source);

    final card = preview.valid.single;
    expect(card.question, 'Primeira linha da pergunta?');
    expect(card.answer, 'Primeiro parágrafo.\n\nSegundo parágrafo.');
  });

  test('a window with the target in the past clamps the days remaining to zero',
      () {
    final window = ScheduleWindow(
      startDate: DateTime(2026, 8, 10),
      targetDate: DateTime(2026, 9, 9),
    );

    expect(window.daysRemainingFrom(DateTime(2026, 10, 1)), 0);
    expect(window.daysRemainingFrom(DateTime(2026, 1, 1)), 30);
  });
}
