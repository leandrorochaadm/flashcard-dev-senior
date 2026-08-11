import 'package:flashcard_dev_senior/domain/import/import_preview.dart';
import 'package:flashcard_dev_senior/domain/import/import_template.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

const parser = MarkdownParser();

String block(int index, {String difficulty = 'intermediário', String? id}) => '''
---
id: ${id ?? 'est-${index.toString().padLeft(3, '0')}'}
assunto: Gerenciamento de estado
dificuldade: $difficulty

**Pergunta**
Pergunta número $index?

**Resposta**
Resposta número $index.
''';

void main() {
  test('a well formed file with 20 cards gives 20 cards and no issues', () {
    final source = [for (var i = 1; i <= 20; i++) block(i)].join();

    final preview = parser.parse(source);

    expect(preview.valid.length, 20);
    expect(preview.invalid, isEmpty);
    expect(preview.valid.first.id, 'est-001');
    expect(preview.valid.first.subject, 'Gerenciamento de estado');
    expect(preview.valid.first.difficulty, Difficulty.intermediate);
  });

  // The whole promise of the preview: a broken block does not invalidate the
  // others, which a JSON file could never offer.
  test('a broken block 47 leaves 99 valid and 1 marked', () {
    final blocks = [for (var i = 1; i <= 100; i++) block(i)];
    blocks[46] = '''
---
id: est-047
dificuldade: intermediário

**Resposta**
Sobrou uma resposta sem pergunta e sem assunto.
''';

    final preview = parser.parse(blocks.join());

    expect(preview.valid.length, 99);
    expect(preview.invalid.length, 1);
    expect(preview.invalid.single.issues, contains(ImportIssue.missingSubject));
    expect(preview.invalid.single.issues, contains(ImportIssue.missingQuestion));
  });

  test('the three difficulty labels map onto the enum, accents or not', () {
    final preview = parser.parse([
      block(1, difficulty: 'básico'),
      block(2, difficulty: 'basico'),
      block(3, difficulty: 'INTERMEDIÁRIO'),
      block(4, difficulty: 'avançado'),
    ].join());

    expect(
      preview.valid.map((card) => card.difficulty),
      [
        Difficulty.basic,
        Difficulty.basic,
        Difficulty.intermediate,
        Difficulty.advanced,
      ],
    );
  });

  test('an unknown difficulty is marked instead of guessed', () {
    final preview = parser.parse(block(1, difficulty: 'muito difícil'));

    expect(preview.valid, isEmpty);
    expect(
      preview.invalid.single.issues,
      contains(ImportIssue.unknownDifficulty),
    );
  });

  test('a dart block keeps indentation, line breaks and long lines', () {
    const longLine =
        '    final resultado = algumaFuncaoBemLonga(primeiro, segundo, terceiro, quarto, quinto);';
    const source = '''
---
id: est-010
assunto: Widgets
dificuldade: avançado

**Pergunta**
Como fica esse código?

**Resposta**
Assim:

```dart
class Contador extends ChangeNotifier {
  int valor = 0;

$longLine
}
```
---
''';

    final preview = parser.parse(source);

    expect(preview.invalid, isEmpty);
    final answer = preview.valid.single.answer;
    expect(answer, contains('```dart'));
    expect(answer, contains(longLine));
    expect(answer, contains('  int valor = 0;'));
    expect(answer.split('\n').length, greaterThan(5));
  });

  test('a --- inside a code block does not split the card', () {
    const source = '''
---
id: est-011
assunto: Async
dificuldade: básico

**Pergunta**
E se o código tiver três traços?

**Resposta**
```dart
// ---
const separador = '---';
```
---
''';

    final preview = parser.parse(source);

    expect(preview.valid.length, 1);
    expect(preview.invalid, isEmpty);
    expect(preview.valid.single.answer, contains("const separador = '---';"));
  });

  test('a card without id parses, so the question text can match it later', () {
    const source = '''
---
assunto: Testes
dificuldade: básico

**Pergunta**
Qual a diferença entre teste de unidade e de widget?

**Resposta**
Um roda em Dart puro, o outro monta a árvore de widgets.
''';

    final preview = parser.parse(source);

    expect(preview.valid.single.id, isNull);
    expect(preview.valid.single.question,
        'Qual a diferença entre teste de unidade e de widget?');
  });

  test('the copy template parses with no issues in the preview', () {
    final preview = parser.parse(importTemplate);

    expect(preview.invalid, isEmpty);
    expect(preview.valid.length, 2);
    expect(preview.valid.map((card) => card.id), ['est-001', 'est-002']);
    expect(preview.valid.last.answer, contains('```dart'));
  });
}
