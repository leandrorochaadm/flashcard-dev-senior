import 'package:flashcard_dev_senior/ui/shared/code_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/screen_sizes.dart';

void main() {
  Future<void> render(
    WidgetTester tester,
    String code, {
    String language = '',
  }) async {
    useScreenSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CodeBlock(code: code, language: language)),
      ),
    );
  }

  /// The colored runs of the block, in order, as (text, color) pairs. A run
  /// with no color of its own is plain code.
  List<(String, Color?)> runs(WidgetTester tester) {
    final rich = tester.widget<RichText>(find.byType(RichText).first);
    final result = <(String, Color?)>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) {
        result.add((span.text!, span.style?.color));
      }
      return true;
    });
    return result;
  }

  Color? colorOf(WidgetTester tester, String text) {
    for (final run in runs(tester)) {
      if (run.$1 == text) return run.$2;
    }
    return null;
  }

  group('highlighting is limited to Dart', () {
    testWidgets('dart is colored', (tester) async {
      await render(tester, 'final x = 1;', language: 'dart');

      expect(colorOf(tester, 'final'), isNotNull);
    });

    testWidgets('a bare fence is treated as dart', (tester) async {
      await render(tester, 'final x = 1;');

      expect(colorOf(tester, 'final'), isNotNull);
    });

    testWidgets('another language renders plain, byte for byte', (
      tester,
    ) async {
      const sql = 'SELECT final FROM cards -- not a comment in SQL';
      await render(tester, sql, language: 'sql');

      expect(runs(tester), [(sql, null)]);
    });

    testWidgets('the language is matched case-insensitively', (tester) async {
      await render(tester, 'final x = 1;', language: 'Dart');

      expect(colorOf(tester, 'final'), isNotNull);
    });
  });

  group('string literals', () {
    testWidgets('an escaped quote does not close the literal', (tester) async {
      await render(tester, "var s = 'it\\'s here'; final y = 1;");

      expect(colorOf(tester, "'it\\'s here'"), isNotNull);
      // The code after the literal is scanned as code again, not as string.
      expect(colorOf(tester, 'final'), isNot(colorOf(tester, "'it\\'s here'")));
    });

    testWidgets('a raw string keeps the backslash literal', (tester) async {
      await render(tester, "var s = r'a\\'; final y = 1;");

      expect(colorOf(tester, "r'a\\'"), isNull); // the r is a plain word
      expect(colorOf(tester, "'a\\'"), isNotNull);
      expect(colorOf(tester, 'final'), isNotNull);
    });

    testWidgets('an unterminated literal stops at the end of the line', (
      tester,
    ) async {
      await render(tester, "var s = 'oops\nfinal y = 1;");

      expect(colorOf(tester, "'oops"), isNotNull);
      expect(colorOf(tester, 'final'), isNotNull);
    });

    testWidgets('a triple-quoted literal spans lines', (tester) async {
      await render(tester, "var s = '''a\nb''';\nfinal y = 1;");

      expect(colorOf(tester, "'''a\nb'''"), isNotNull);
      expect(colorOf(tester, 'final'), isNotNull);
    });
  });
}
