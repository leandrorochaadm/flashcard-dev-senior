import 'package:dart_style/dart_style.dart';

/// The single door to `package:dart_style` — nothing else imports it.
///
/// The answers are written by an AI, and the mistake it makes inside a code
/// block is almost always shape: broken indentation, a line too long for a
/// phone, a missing brace. Formatting at import time means the card is fixed
/// once, at the door, instead of being read wrong every session for 30 days.
///
/// **This validates syntax, not meaning.** The formatter parses; it does not
/// resolve names against the SDK, so a snippet calling `notifyListners()` with
/// a typo formats happily. Real analysis needs a resolved context — an SDK and
/// a package config on disk — which does not exist in a browser. Catching the
/// typo is not on the table; catching a missing brace is, and that is the
/// error worth catching.
///
/// A snippet on a card is a FRAGMENT, not a library: it has no imports, and it
/// is often a bare run of statements. The formatter only parses whole
/// compilation units, so a fragment is retried inside a wrapper before being
/// called broken — otherwise perfectly good teaching code would be rejected.
final class DartCodeFormatter {
  DartCodeFormatter([DartFormatter? formatter])
    : _formatter =
          formatter ??
          DartFormatter(
            languageVersion: DartFormatter.latestLanguageVersion,
            pageWidth: cardPageWidth,
          );

  /// Narrower than the 80 columns Dart usually wants, and the same 76 the deck
  /// files are written to. The snippet is read on a phone, where [CodeBlock]
  /// scrolls sideways rather than wrapping — every column past the screen is a
  /// column someone has to drag to. One number, used by the app and by the
  /// authoring tool alike, so a card is never reformatted back and forth.
  static const cardPageWidth = 76;

  final DartFormatter _formatter;

  /// The fence that opens a Dart block, and the one that closes any block.
  static final _fence = RegExp(r'^\s*```(\w*)\s*$');

  /// Formats every ```dart block of [markdown] — the answer of a card, its
  /// question, or a whole deck file.
  ///
  /// Returns the rewritten text and whether every block parsed. A block that
  /// does not parse is left exactly as it came — it is still worth reading —
  /// and `ok` comes back false so the preview can mark the card. Blocks in
  /// another language are never touched.
  ({String answer, bool ok}) formatFences(String markdown) {
    final out = <String>[];
    final block = <String>[];
    var ok = true;
    String? language;

    for (final line in markdown.split('\n')) {
      final fence = _fence.firstMatch(line);
      if (fence == null) {
        (language == null ? out : block).add(line);
        continue;
      }
      if (language == null) {
        language = fence.group(1)!;
        out.add(line);
        continue;
      }
      // Closing fence: flush what the block collected.
      if (language == 'dart') {
        final formatted = format(block.join('\n'));
        if (formatted == null) {
          ok = false;
          out.addAll(block);
        } else {
          out.addAll(formatted.split('\n'));
        }
      } else {
        out.addAll(block);
      }
      out.add(line);
      block.clear();
      language = null;
    }
    // An unterminated fence: whatever it holds is not a block we can trust.
    out.addAll(block);
    return (answer: out.join('\n'), ok: ok);
  }

  /// Formats one snippet, or null when it does not parse in any shape.
  ///
  /// The attempts, in order, are the five shapes a card snippet takes: a whole
  /// file, a run of statements, the inside of a class, a bare expression and an
  /// elision. The first three are rewritten; the last two are only checked,
  /// because peeling their wrapper back off cannot be done without risking the
  /// code. Every shape past the first exists because a real card used it.
  String? format(String snippet) {
    final source = snippet.trim();
    if (source.isEmpty) return null;

    final direct = _tryFormat(source);
    if (direct != null) return direct.trimRight();

    for (final wrapper in const [_statements, _classBody]) {
      final formatted = _tryFormat(wrapper.open + source + wrapper.close);
      if (formatted != null) return _unwrap(formatted, wrapper);
    }

    // Last shape, and the only one that is checked without being rewritten: a
    // bare expression, which is how a widget tree is shown on a card —
    // `Column(children: [...])` with no semicolon and no statement around it.
    // Unwrapping it is not safe: the formatter folds the assignment and the
    // first line of the expression together, so peeling the wrapper back off
    // would eat code. Parsing proves the snippet is sound, and sound is what
    // the preview needs to know; the card keeps the text it shipped with.
    if (_tryFormat('var _e =\n$source\n;\n') != null) return source;

    // Elision, the last shape and a deliberate one: a card writes `{ … }` to
    // say "the body is not the point here". It is not Dart and never will be,
    // so it is checked with the ellipsis swapped for a comment — valid
    // wherever the character is used — and, like an expression, kept as it is.
    //
    // The stand-in must NOT contain the ellipsis itself: substituting it into
    // its own replacement makes each pass produce another one to substitute,
    // and the recursion never reaches the bottom.
    if (source.contains(_ellipsis)) {
      final filled = source.replaceAll(_ellipsis, '/* elided */');
      if (format(filled) != null) return source;
    }
    return null;
  }

  /// The single character, not three dots: `...` is real Dart (spread) and
  /// must keep failing when it is written where no spread belongs.
  static const _ellipsis = '…';

  String? _tryFormat(String source) {
    try {
      return _formatter.format(source);
    } on FormatterException {
      return null;
    }
  }

  /// Drops the wrapper the snippet was formatted inside and pulls the body
  /// back to column zero, so the card keeps the fragment it shipped with.
  String _unwrap(String formatted, _Wrapper wrapper) {
    final lines = formatted.trimRight().split('\n');
    final body = lines.sublist(wrapper.openLines, lines.length - 1);
    return body
        .map((line) => line.startsWith('  ') ? line.substring(2) : line)
        .join('\n')
        .trimRight();
  }
}

/// A shape a fragment is retried inside of, and how much of it to peel back.
final class _Wrapper {
  const _Wrapper(this.open, this.close, this.openLines);

  final String open;
  final String close;

  /// Lines the wrapper adds above the snippet, dropped when unwrapping.
  final int openLines;
}

const _statements = _Wrapper('void _f() {\n', '\n}\n', 1);
const _classBody = _Wrapper('class _C {\n', '\n}\n', 1);
