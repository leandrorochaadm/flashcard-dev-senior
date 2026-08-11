import 'package:flashcard_dev_senior/domain/import/import_service.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

const parser = MarkdownParser();

String card({
  String? id,
  String question = 'Qual a diferença entre setState e um notifier?',
  String answer = 'setState reconstrói o widget inteiro.',
  String subject = 'Gerenciamento de estado',
}) =>
    '''
---
${id == null ? '' : 'id: $id'}
assunto: $subject
dificuldade: intermediário

**Pergunta**
$question

**Resposta**
$answer
''';

void main() {
  final now = DateTime(2026, 8, 11, 9);
  final window = ScheduleWindow.forFirstOpening(now);

  ({ImportService service, FakeCollection collection}) build() {
    final collection = FakeCollection();
    final intake = ContentIntakePolicy(
      FakeWindow(window),
      collection,
      FakeHistory(),
      DueCardsPolicy(collection),
    );
    return (service: ImportService(collection, intake), collection: collection);
  }

  test('new cards enter unreleased, with a first review date already set', () {
    final built = build();

    final outcome =
        built.service.resolve(parser.parse(card(id: 'est-001')), now);

    expect(outcome.created.length, 1);
    expect(outcome.updated, isEmpty);
    final created = outcome.created.single;
    expect(created.id, 'est-001');
    expect(created.importedAt, now);
    expect(created.introducedAt, isNull, reason: 'importing is not releasing');
    expect(created.dueAt, isNotNull);
    expect(created.state, CardState.newCard);
  });

  test('re-importing the same id updates the answer and keeps the history', () {
    final built = build();
    final first = built.service.resolve(parser.parse(card(id: 'est-001')), now);
    // The card has been studied since.
    final studied = first.created.single.copyWith(
      introducedAt: now,
      stability: 12,
      reps: 5,
      lapses: 2,
      dueAt: now.add(const Duration(days: 3)),
    );
    built.collection.save(studied);

    final again = built.service.resolve(
      parser.parse(card(id: 'est-001', answer: 'Resposta corrigida.')),
      now.add(const Duration(days: 4)),
    );

    expect(again.created, isEmpty, reason: 'it must not duplicate');
    final updated = again.updated.single;
    expect(updated.answer, 'Resposta corrigida.');
    expect(updated.stability, 12);
    expect(updated.reps, 5);
    expect(updated.lapses, 2);
    expect(updated.dueAt, studied.dueAt);
    expect(updated.introducedAt, now);
  });

  test('without an id, an identical question is recognized by its text', () {
    final built = build();
    final first = built.service.resolve(parser.parse(card()), now);
    built.collection.save(first.created.single.copyWith(stability: 9));

    final again = built.service.resolve(parser.parse(card()), now);

    expect(again.created, isEmpty);
    expect(again.updated.single.stability, 9);
  });

  test('without an id, an edited question enters as new — documented, not a bug',
      () {
    final built = build();
    final first = built.service.resolve(parser.parse(card()), now);
    built.collection.save(first.created.single);

    final again = built.service.resolve(
      parser.parse(card(question: 'Qual a diferença entre setState e notifier?')),
      now,
    );

    expect(again.created.length, 1);
    expect(again.updated, isEmpty);
  });

  test('a block of 100 does not all get the same first review date — it is '
      'spread over the days of the initial load', () {
    final built = build();
    final source = [
      for (var i = 1; i <= 100; i++)
        card(id: 'est-$i', question: 'Pergunta $i?'),
    ].join();

    final outcome = built.service.resolve(parser.parse(source), now);

    expect(outcome.created.length, 100);
    expect(
      outcome.created.map((card) => card.dueAt).toSet().length,
      greaterThan(1),
      reason: 'H5 is checked right here, on the import screen',
    );
  });
}
