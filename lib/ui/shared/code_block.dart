import 'package:flutter/material.dart';

/// A ```dart block, as requirement 3 demands it: monospaced, indentation and
/// line breaks preserved, colors by token type, a highlighted background and
/// its OWN horizontal scroll — a long line scrolls sideways instead of
/// wrapping or blowing past the screen.
///
/// The highlighter is hand-rolled for Dart only. A full highlight package
/// would register dozens of languages and weigh on the first offline load,
/// which risk 7 of the handoff calls out.
class CodeBlock extends StatelessWidget {
  const CodeBlock({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = _Palette(dark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        // Horizontal scroll wraps the code block only, never the whole card.
        scrollDirection: Axis.horizontal,
        child: SelectionArea(
          child: RichText(
            softWrap: false,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
                fontSize: 13,
                height: 1.45,
                color: palette.plain,
              ),
              children: _highlight(code, palette),
            ),
          ),
        ),
      ),
    );
  }
}

const _keywords = {
  'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
  'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do',
  'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external',
  'factory', 'false', 'final', 'finally', 'for', 'get', 'if', 'implements',
  'import', 'in', 'interface', 'is', 'late', 'library', 'mixin', 'new', 'null',
  'on', 'operator', 'part', 'required', 'rethrow', 'return', 'sealed', 'set',
  'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', 'try',
  'typedef', 'var', 'void', 'when', 'while', 'with', 'yield',
};

const _types = {
  'bool', 'double', 'int', 'num', 'String', 'List', 'Map', 'Set', 'Future',
  'Stream', 'Duration', 'DateTime', 'Object', 'Widget', 'BuildContext',
  'StatelessWidget', 'StatefulWidget', 'ChangeNotifier', 'ValueNotifier',
};

final class _Palette {
  _Palette(this.dark);

  final bool dark;

  Color get background => dark ? const Color(0xFF1E1E24) : const Color(0xFFF6F7F9);
  Color get border => dark ? const Color(0xFF34343E) : const Color(0xFFE0E3E8);
  Color get plain => dark ? const Color(0xFFE6E6EB) : const Color(0xFF23252B);
  Color get keyword => dark ? const Color(0xFF9D8DF1) : const Color(0xFF6F42C1);
  Color get type => dark ? const Color(0xFF6FC0E8) : const Color(0xFF0B6FA4);
  Color get string => dark ? const Color(0xFF9CD67F) : const Color(0xFF1A7F37);
  Color get comment => dark ? const Color(0xFF7C8391) : const Color(0xFF6A737D);
  Color get number => dark ? const Color(0xFFE0A15C) : const Color(0xFFB35A00);
}

/// Tokenizes just enough Dart to color keywords, types, strings, comments and
/// numbers. Every character of the source is emitted, so indentation and line
/// breaks survive byte for byte.
List<TextSpan> _highlight(String code, _Palette palette) {
  final spans = <TextSpan>[];
  final buffer = StringBuffer();

  void flushPlain() {
    if (buffer.isEmpty) return;
    spans.add(TextSpan(text: buffer.toString()));
    buffer.clear();
  }

  void emit(String text, Color color) {
    flushPlain();
    spans.add(TextSpan(text: text, style: TextStyle(color: color)));
  }

  var index = 0;
  while (index < code.length) {
    final rest = code.substring(index);

    if (rest.startsWith('//')) {
      final end = rest.indexOf('\n');
      final comment = end == -1 ? rest : rest.substring(0, end);
      emit(comment, palette.comment);
      index += comment.length;
      continue;
    }

    final char = code[index];
    if (char == "'" || char == '"') {
      final closing = code.indexOf(char, index + 1);
      final literal = closing == -1
          ? rest
          : code.substring(index, closing + 1);
      emit(literal, palette.string);
      index += literal.length;
      continue;
    }

    final wordMatch = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*').firstMatch(rest);
    if (wordMatch != null) {
      final word = wordMatch.group(0)!;
      if (_keywords.contains(word)) {
        emit(word, palette.keyword);
      } else if (_types.contains(word)) {
        emit(word, palette.type);
      } else {
        buffer.write(word);
      }
      index += word.length;
      continue;
    }

    final numberMatch = RegExp(r'^\d+(\.\d+)?').firstMatch(rest);
    if (numberMatch != null) {
      final number = numberMatch.group(0)!;
      emit(number, palette.number);
      index += number.length;
      continue;
    }

    buffer.write(char);
    index++;
  }
  flushPlain();
  return spans;
}
