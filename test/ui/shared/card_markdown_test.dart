import 'package:flashcard_dev_senior/domain/import/import_preview.dart';
import 'package:flashcard_dev_senior/domain/import/import_template.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/ui/shared/code_block.dart';
import 'package:flashcard_dev_senior/ui/shared/card_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

void main() {
  Future<void> render(WidgetTester tester, String text) async {
    useScreenSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CardMarkdown(text: text))),
      ),
    );
  }

  /// The style the renderer resolved for a run of text inside a rich span,
  /// with the styles of the enclosing spans merged in the way painting does.
  TextStyle styleOf(WidgetTester tester, String needle) {
    TextStyle? search(InlineSpan span, TextStyle inherited) {
      if (span is! TextSpan) return null;
      final style = span.style == null ? inherited : inherited.merge(span.style);
      if (span.text == needle) return style;
      for (final child in span.children ?? const <InlineSpan>[]) {
        final found = search(child, style);
        if (found != null) return found;
      }
      return null;
    }

    for (final widget in tester.allWidgets.whereType<SelectableText>()) {
      final span = widget.textSpan;
      if (span == null) continue;
      final found = search(span, widget.style ?? const TextStyle());
      if (found != null) return found;
    }
    fail('no span carrying "$needle" was rendered');
  }

  testWidgets('a heading renders bigger and bolder than a paragraph', (
    tester,
  ) async {
    await render(tester, '# Isolates\n\nTexto normal.');

    final heading = styleOf(tester, 'Isolates');
    expect(heading.fontWeight, FontWeight.w700);
    expect(heading.fontSize, greaterThan(styleOf(tester, 'Texto normal.').fontSize!));
  });

  testWidgets('bold, italic and strikethrough are applied', (tester) async {
    await render(tester, 'a **forte** e *fraca* e ~~riscada~~');

    expect(styleOf(tester, 'forte').fontWeight, FontWeight.w700);
    expect(styleOf(tester, 'fraca').fontStyle, FontStyle.italic);
    expect(styleOf(tester, 'riscada').decoration, TextDecoration.lineThrough);
  });

  testWidgets('inline code is monospaced without becoming a code block', (
    tester,
  ) async {
    await render(tester, 'chame `Isolate.run` aqui');

    expect(styleOf(tester, 'Isolate.run').fontFamily, 'monospace');
    expect(find.byType(CodeBlock), findsNothing);
  });

  testWidgets('a fenced block still goes to CodeBlock, unformatted', (
    tester,
  ) async {
    await render(tester, 'antes\n\n```dart\n// **nao** e negrito\nvar x = 1;\n```\n\ndepois');

    final block = tester.widget<CodeBlock>(find.byType(CodeBlock));
    expect(block.code, '// **nao** e negrito\nvar x = 1;');
  });

  testWidgets('the language of the fence reaches the code block', (
    tester,
  ) async {
    await render(tester, '```dart\nvar x = 1;\n```');

    expect(tester.widget<CodeBlock>(find.byType(CodeBlock)).language, 'dart');
  });

  testWidgets('a bare fence carries no language', (tester) async {
    await render(tester, '```\nvar x = 1;\n```');

    expect(tester.widget<CodeBlock>(find.byType(CodeBlock)).language, '');
  });

  testWidgets('lists print their gutter marker and number in order', (
    tester,
  ) async {
    await render(tester, '- um\n- dois\n\n1. primeiro\n1. segundo');

    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
  });

  testWidgets('a quote keeps its text and drops the marker', (tester) async {
    await render(tester, '> cuidado com o teto');

    expect(styleOf(tester, 'cuidado com o teto').fontStyle, FontStyle.italic);
  });

  testWidgets('the six heading levels all get their own size', (tester) async {
    await render(
      tester,
      '# um\n\n## dois\n\n### tres\n\n#### quatro\n\n##### cinco\n\n###### seis',
    );

    final sizes = [
      for (final text in ['um', 'dois', 'tres', 'quatro', 'cinco', 'seis'])
        styleOf(tester, text).fontSize!,
    ];
    expect(sizes, orderedEquals(sizes.toList()..sort((a, b) => b.compareTo(a))));
    expect(sizes.toSet(), hasLength(6));
  });

  testWidgets('an indented item nests instead of flattening', (tester) async {
    await render(tester, '- pai\n  - filho\n    - neto');

    // A distinct marker per depth, and a wider left padding each level down.
    expect(find.text('•'), findsOneWidget);
    expect(find.text('◦'), findsOneWidget);
    expect(find.text('▪'), findsOneWidget);

    double indentOf(String marker) => tester.getTopLeft(find.text(marker)).dx;
    expect(indentOf('◦'), greaterThan(indentOf('•')));
    expect(indentOf('▪'), greaterThan(indentOf('◦')));
  });

  testWidgets('a nested ordered list counts on its own', (tester) async {
    await render(tester, '1. um\n  1. a\n  1. b\n1. dois');

    expect(find.text('1.'), findsNWidgets(2)); // the outer 1 and the inner 1
    expect(find.text('2.'), findsNWidgets(2)); // the inner b and the outer 2
  });

  testWidgets('an underscore inside a word is not emphasis', (tester) async {
    await render(tester, 'o arquivo list_of_names.dart e o _campo_ dele');

    // Untouched: no span was cut around the identifier's underscores.
    expect(styleOf(tester, 'o arquivo list_of_names.dart e o ').fontStyle,
        isNot(FontStyle.italic));
    expect(styleOf(tester, 'campo').fontStyle, FontStyle.italic);
  });

  group('line breaks of the imported file', () {
    testWidgets('a hard-wrapped paragraph becomes one run of text', (
      tester,
    ) async {
      // How an answer arrives: wrapped at the width of whoever wrote it.
      await render(tester, 'uma resposta longa\nquebrada no arquivo\nem tres linhas');

      expect(
        find.text('uma resposta longa quebrada no arquivo em tres linhas'),
        findsOneWidget,
      );
    });

    testWidgets('a blank line still separates paragraphs', (tester) async {
      await render(tester, 'primeiro\n\nsegundo');

      expect(find.text('primeiro'), findsOneWidget);
      expect(find.text('segundo'), findsOneWidget);
    });

    testWidgets('two trailing spaces force a break', (tester) async {
      await render(tester, 'passo um  \npasso dois');

      expect(find.text('passo um\npasso dois'), findsOneWidget);
    });

    testWidgets('the wrapped tail of a list item rejoins the item', (
      tester,
    ) async {
      await render(tester, '- um item que\n  continua na linha seguinte\n- outro');

      expect(find.text('um item que continua na linha seguinte'), findsOneWidget);
      expect(find.text('•'), findsNWidgets(2));
    });

    testWidgets('a run of quote lines is a single quote', (tester) async {
      await render(tester, '> uma citacao\n> que continua');

      expect(find.text('uma citacao que continua'), findsOneWidget);
    });

    testWidgets('code keeps every line break it was imported with', (
      tester,
    ) async {
      await render(tester, '```dart\nvar a = 1;\nvar b = 2;\n```');

      expect(
        tester.widget<CodeBlock>(find.byType(CodeBlock)).code,
        'var a = 1;\nvar b = 2;',
      );
    });
  });

  testWidgets('plain text is left untouched', (tester) async {
    await render(tester, 'uma resposta sem marcacao nenhuma');

    expect(find.text('uma resposta sem marcacao nenhuma'), findsOneWidget);
  });

  // The gap is what groups a label with its text. Uniform spacing would leave
  // every heading floating between two sections, belonging to neither.
  group('spacing between blocks', () {
    /// The vertical gap the renderer left between the two runs of text.
    double gapBetween(WidgetTester tester, String above, String below) =>
        tester.getTopLeft(find.textContaining(below)).dy -
        tester.getBottomLeft(find.textContaining(above)).dy;

    testWidgets('two paragraphs get the ordinary gap', (tester) async {
      await render(tester, 'primeiro\n\nsegundo');

      expect(gapBetween(tester, 'primeiro', 'segundo'), 12);
    });

    testWidgets('a heading takes more air above than it leaves below', (
      tester,
    ) async {
      await render(tester, 'antes\n\n##### Rotulo\n\ndepois');

      final above = gapBetween(tester, 'antes', 'Rotulo');
      final below = gapBetween(tester, 'Rotulo', 'depois');
      expect(above, greaterThan(below));
      expect(below, lessThan(12));
    });

    testWidgets('the first block is flush with the top, with no gap', (
      tester,
    ) async {
      await render(tester, 'primeiro\n\nsegundo');

      final top = tester.getTopLeft(find.byType(CardMarkdown)).dy;
      expect(tester.getTopLeft(find.textContaining('primeiro')).dy, top);
    });

    testWidgets('a heading opening the answer still starts flush', (
      tester,
    ) async {
      await render(tester, '##### Rotulo\n\ntexto');

      final top = tester.getTopLeft(find.byType(CardMarkdown)).dy;
      expect(tester.getTopLeft(find.text('Rotulo')).dy, top);
    });

    testWidgets('a code block right after a label hugs it too', (tester) async {
      await render(tester, '##### Código\n\n```dart\nvar x = 1;\n```');

      final gap = tester.getTopLeft(find.byType(CodeBlock)).dy -
          tester.getBottomLeft(find.text('Código')).dy;
      expect(gap, lessThan(12));
    });
  });

  // The template is what the AI is told to imitate, so whatever it demonstrates
  // is what every future card looks like on screen. These check the
  // demonstration itself, instead of trusting that it reads well.
  group('the copy template renders', () {
    ParsedCard exampleWithCode() =>
        const MarkdownParser().parse(importTemplate).valid.last;

    testWidgets('every section label comes out as a heading of its own', (
      tester,
    ) async {
      await render(tester, exampleWithCode().answer);

      for (final label in ['Por quê', 'Alternativa', 'Uso real', 'Código']) {
        expect(styleOf(tester, label).fontWeight, FontWeight.w700,
            reason: 'the label "$label"');
      }
    });

    testWidgets('a label hugs its own text and keeps away from the one above', (
      tester,
    ) async {
      await render(tester, exampleWithCode().answer);

      // What the eye uses to group a label with what it labels: the space
      // above a heading has to beat the space below it. A uniform gap would
      // leave every label floating between two sections, part of neither.
      final label = find.text('Alternativa');
      final above = find.textContaining('já implementa a lista de ouvintes');
      final own = find.textContaining('entrega o mesmo comportamento');

      final gapAbove =
          tester.getTopLeft(label).dy - tester.getBottomLeft(above).dy;
      final gapBelow =
          tester.getTopLeft(own).dy - tester.getBottomLeft(label).dy;
      expect(gapAbove, greaterThan(gapBelow * 2));
    });

    testWidgets('the dart section becomes a code block, not a paragraph', (
      tester,
    ) async {
      await render(tester, exampleWithCode().answer);

      final block = tester.widget<CodeBlock>(find.byType(CodeBlock));
      expect(block.language, 'dart');
      expect(block.code, contains('notifyListeners();'));
      // No rule anywhere: the template teaches `***` but never uses it, and a
      // `---` would have been eaten by the import parser long before here.
      expect(find.byType(Divider), findsNothing);
    });
  });
}
