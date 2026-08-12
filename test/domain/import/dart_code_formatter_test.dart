import 'package:flashcard_dev_senior/domain/import/dart_code_formatter.dart';
import 'package:flashcard_dev_senior/domain/import/import_preview.dart';
import 'package:flashcard_dev_senior/domain/import/import_template.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flutter_test/flutter_test.dart';

final formatter = DartCodeFormatter();

String fenced(String code) => '''
Explicação antes.

```dart
$code
```
''';

void main() {
  group('what a card snippet is allowed to be', () {
    test('a whole file formats', () {
      final out = formatter.format('class A{int x=1;void inc(){x++;}}');

      expect(out, contains('class A {'));
      expect(out, contains('  int x = 1;'));
    });

    // The point of formatting at the door: an AI hard-wraps and indents by
    // whatever it felt like, and the card is read on a phone.
    test('bad indentation is fixed', () {
      final out = formatter.format('class A{\n        int x=1;\n int y  =2;}');

      expect(out, 'class A {\n  int x = 1;\n  int y = 2;\n}');
    });

    // A snippet has no imports and never will: it is a fragment on a flashcard,
    // not a library. The formatter parses, it does not resolve names.
    test('undefined names are none of the formatter business', () {
      final out = formatter.format(
        'class C extends ChangeNotifier{void f(){notifyListeners();}}',
      );

      expect(out, isNotNull);
      expect(out, contains('extends ChangeNotifier'));
    });

    test('a bare run of statements formats, wrapped and unwrapped again', () {
      final out = formatter.format('final a=1;\nprint(  a );');

      // Comes back at column zero: the wrapper must not leak its indentation.
      expect(out, 'final a = 1;\nprint(a);');
    });

    test('the inside of a class formats', () {
      final out = formatter.format('int x=1;\nvoid inc(){x++;}');

      expect(out, isNotNull);
      expect(out, startsWith('int x = 1;'));
    });

    // How a widget tree is shown on a card: no semicolon, no statement around
    // it. Found in the real deck, where it was being called broken.
    test('a bare expression is accepted, and kept exactly as it is', () {
      const tree = 'SingleChildScrollView(\n  child: Column(\n'
          '    children: [Expanded(child: Text(\'a\'))],\n  ),\n)';

      expect(formatter.format(tree), tree);
    });

    test('a missing brace is not formattable in any shape', () {
      expect(formatter.format('class A { void f() { ;'), isNull);
    });

    test('an empty snippet is not code', () {
      expect(formatter.format('   \n  '), isNull);
    });

    // Elision is a teaching device, not sloppiness: `{ … }` says "the body is
    // not the point". A real card in the deck writes exactly this.
    test('the ellipsis character stands in for elided code', () {
      const source = "if (json case {'id': final int id}) { … }";

      // Accepted, and handed back untouched — it is not Dart to reformat.
      expect(formatter.format(source), source);
    });

    test('an ellipsis inside a class body is accepted too', () {
      const source = 'class A {\n  void f() { … }\n}';

      expect(formatter.format(source), source);
    });

    // `...` is real Dart. Accepting it as elision would hide a spread written
    // where no spread belongs, which is the kind of error worth catching.
    test('three ASCII dots are not elision and still fail', () {
      expect(formatter.format('if (a) { ... }'), isNull);
    });

    test('an ellipsis does not rescue code that is broken anyway', () {
      expect(formatter.format('class A { void f() { … '), isNull);
    });

    // The whole reason the width is 76 and not 80: CodeBlock scrolls sideways
    // on a phone, so every extra column is a column someone has to drag to.
    test('a long line is wrapped to the width a phone can show', () {
      const source =
          'final resultado = umaFuncaoBemLonga(primeiro, segundo, terceiro, '
          'quarto, quinto, sexto);';
      expect(source.length, greaterThan(DartCodeFormatter.cardPageWidth));

      final out = formatter.format(source)!;

      expect(out.split('\n').length, greaterThan(1));
      for (final line in out.split('\n')) {
        expect(line.length, lessThanOrEqualTo(DartCodeFormatter.cardPageWidth));
      }
    });

    test('an already tidy snippet comes back identical', () {
      const source = 'class A {\n  int x = 1;\n}';

      expect(formatter.format(source), source);
    });
  });

  group('walking the fences of an answer', () {
    test('a dart block is rewritten and the prose is left alone', () {
      final result = formatter.formatFences(fenced('var   x=1;'));

      expect(result.ok, isTrue);
      expect(result.answer, contains('Explicação antes.'));
      expect(result.answer, contains('var x = 1;'));
    });

    test('a block in another language is never touched', () {
      const source = '```sql\nselect    *   from x;\n```';

      final result = formatter.formatFences(source);

      expect(result.ok, isTrue);
      expect(result.answer, contains('select    *   from x;'));
    });

    test('a broken block is reported and left exactly as it came', () {
      final result = formatter.formatFences(fenced('class A { void f() { ;'));

      expect(result.ok, isFalse);
      // The text is still worth reading, so nothing is thrown away.
      expect(result.answer, contains('class A { void f() { ;'));
    });

    test('an answer with no code at all is unchanged and fine', () {
      const source = 'Uma resposta sem código nenhum.';

      final result = formatter.formatFences(source);

      expect(result.ok, isTrue);
      expect(result.answer, source);
    });

    test('every dart block of an answer is formatted, not just the first', () {
      final result = formatter.formatFences(
        '${fenced('var   a=1;')}\nEntre um e outro.\n${fenced('var   b=2;')}',
      );

      expect(result.ok, isTrue);
      expect(result.answer, contains('var a = 1;'));
      expect(result.answer, contains('var b = 2;'));
      expect(result.answer, contains('Entre um e outro.'));
    });

    test('one broken block among good ones marks the whole answer', () {
      final result = formatter.formatFences(
        '${fenced('var   a=1;')}\n${fenced('class A { void f() { ;')}',
      );

      expect(result.ok, isFalse);
      // The good one is still tidied: the mark is about the card, not a veto.
      expect(result.answer, contains('var a = 1;'));
    });

    test('an indented fence is still a fence', () {
      final result = formatter.formatFences('  ```dart\n  var   x=1;\n  ```');

      expect(result.ok, isTrue);
      expect(result.answer, contains('var x = 1;'));
    });

    // Half a block is not a block: rewriting it could truncate the answer, so
    // the lines come back exactly as they arrived.
    test('an unterminated fence keeps every line it holds', () {
      const source = '```dart\nvar   x=1;\nsem fechar';

      final result = formatter.formatFences(source);

      expect(result.ok, isTrue);
      expect(result.answer, source);
    });

    test('a fence with no language is left alone', () {
      const source = '```\nvar   x=1;\n```';

      expect(formatter.formatFences(source).answer, source);
    });

    test('formatting is idempotent', () {
      final once = formatter.formatFences(fenced('var   x=1;')).answer;

      expect(formatter.formatFences(once).answer, once);
    });
  });

  group('what the parser does with it', () {
    String card(String code) =>
        '''
---
id: est-001
assunto: Estado
dificuldade: básico

**Pergunta**
E o código?

**Resposta**
${fenced(code)}
---
''';

    test('the bare parser still hands the answer back byte for byte', () {
      // The contract every other test of the parser relies on.
      const bare = MarkdownParser();

      final preview = bare.parse(card('var   x=1;'));

      expect(preview.valid.single.answer, contains('var   x=1;'));
    });

    test('the app parser tidies the block on the way in', () {
      final preview = MarkdownParser(formatter).parse(card('var   x=1;'));

      expect(preview.invalid, isEmpty);
      expect(preview.valid.single.answer, contains('var x = 1;'));
    });

    test('a card whose code does not parse is marked, not imported', () {
      final preview = MarkdownParser(
        formatter,
      ).parse(card('class A { void f() { ;'));

      expect(preview.valid, isEmpty);
      expect(
        preview.invalid.single.issues,
        contains(ImportIssue.unparsableDartCode),
      );
    });

    // A broken block 47 must not take the other 99 down with it — the whole
    // promise of the `---` format, now with one more way to be broken.
    test('the other cards of the file still import', () {
      final source = card('var x = 1;').replaceAll('est-001', 'est-002') +
          card('class A { void f() { ;');

      final preview = MarkdownParser(formatter).parse(source);

      expect(preview.valid.single.id, 'est-002');
      expect(preview.invalid, hasLength(1));
    });

    String cardAsking(String code) =>
        '''
---
id: est-003
assunto: Estado
dificuldade: básico

**Pergunta**
${fenced(code)}
Qual a ordem dos prints?

**Resposta**
Primeiro a, depois b.
---
''';

    // "What does this code do?" — a card whose only code is on the front.
    // It went unchecked until a real deck file turned it up.
    test('code on the question is checked as well', () {
      final preview =
          MarkdownParser(formatter).parse(cardAsking('class A { void f() { ;'));

      expect(preview.valid, isEmpty);
      expect(
        preview.invalid.single.issues,
        contains(ImportIssue.unparsableDartCode),
      );
    });

    // The question is the fallback key ImportService matches an existing card
    // by. Tidying it would change that key and quietly cost the study history
    // of every card imported before this check existed.
    test('the question is never rewritten, however untidy its code', () {
      final preview = MarkdownParser(formatter).parse(cardAsking('var   x=1;'));

      expect(preview.invalid, isEmpty);
      expect(preview.valid.single.question, contains('var   x=1;'));
    });

    test('a card with no code at all is untouched by any of this', () {
      const source = '''
---
id: est-004
assunto: Comportamental
dificuldade: básico

**Pergunta**
Qual sua pretensão salarial?

**Resposta**
Uma faixa, com a razão dela.
---
''';

      final withFormatter = MarkdownParser(formatter).parse(source);
      final withoutFormatter = const MarkdownParser().parse(source);

      expect(withFormatter.valid.single.answer,
          withoutFormatter.valid.single.answer);
    });

    // The formatting must not fire for a block already headed to the invalid
    // list — and, more importantly, must not mask why it got there.
    test('a block missing its subject is marked for that, not for the code',
        () {
      const source = '''
---
id: est-005
dificuldade: básico

**Pergunta**
E aqui?

**Resposta**
```dart
class A { void f() { ;
```
---
''';

      final preview = MarkdownParser(formatter).parse(source);

      expect(
        preview.invalid.single.issues,
        containsAll([ImportIssue.missingSubject, ImportIssue.unparsableDartCode]),
      );
    });
  });

  // The template is what the AI is told to imitate. If its own snippet does
  // not survive the check the app runs, every card it inspires fails too.
  group('the copy template survives its own rule', () {
    test('its dart block parses and is already formatted', () {
      final answer =
          MarkdownParser(formatter).parse(importTemplate).valid.last.answer;
      final bare = const MarkdownParser().parse(importTemplate).valid.last;

      // Formatted output equals what the template ships: no reformatting.
      expect(answer, bare.answer);
    });

    test('the whole template text has no broken block anywhere', () {
      expect(formatter.formatFences(importTemplate).ok, isTrue);
    });
  });
}
