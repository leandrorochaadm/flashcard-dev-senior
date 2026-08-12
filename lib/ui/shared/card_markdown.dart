import 'package:flutter/material.dart';

import 'code_block.dart';

/// Renders the answer of a card as Markdown: headings, lists, quotes, rules
/// and inline emphasis, with every ```fence handed to [CodeBlock].
///
/// The parser is hand-rolled, like the Dart highlighter next door: a Markdown
/// package would pull a full CommonMark implementation into the first offline
/// load, which risk 7 of the handoff calls out.
///
/// Formatting the answer is presentation, not a business rule — the import
/// parser already kept the answer byte for byte.
class CardMarkdown extends StatelessWidget {
  const CardMarkdown({required this.text, this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) ...[
          _BlockView(block: block, style: style),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------- block model

enum _BlockKind { paragraph, heading, bullet, numbered, quote, code, rule }

final class _Block {
  const _Block(
    this.kind,
    this.text, {
    this.level = 0,
    this.marker = '',
    this.language = '',
  });

  final _BlockKind kind;
  final String text;

  /// The word after the opening fence of a code block, e.g. `dart` or `sql`.
  final String language;

  /// Heading level 1..6, or the nesting depth of a list item (0 = top).
  /// Unused by the other kinds.
  final int level;

  /// The bullet or number printed in the gutter of a list item.
  final String marker;
}

/// The gutter marker of a nested bullet, cycling by depth so a sub-item is
/// told apart from its parent even before the indentation is noticed.
const _bullets = ['•', '◦', '▪'];

/// The nesting depth of a list item, from the indentation of its line.
///
/// Two spaces make a level and a tab counts as two spaces, which covers what
/// both an AI and a person write. Capped at 3 so a pasted answer with wild
/// indentation cannot push the text off a phone screen.
int _depthOf(String line) {
  var columns = 0;
  for (final char in line.split('')) {
    if (char == ' ') {
      columns++;
    } else if (char == '\t') {
      columns += 2;
    } else {
      break;
    }
  }
  return (columns ~/ 2).clamp(0, 3);
}

/// Splits the source into blocks. Fences win over everything: a `# ` inside a
/// code block is code, not a heading.
///
/// A single line break inside a paragraph, a quote or a list item is a SPACE,
/// not a break — the CommonMark rule, and the one that matters most here: the
/// answers arrive hard-wrapped at whatever width the AI or the editor used,
/// and honoring those breaks would shred every paragraph into short ragged
/// lines on a phone. The text reaches the renderer as one run and wraps to the
/// width of the screen. A deliberate break is still available, written the
/// Markdown way: two trailing spaces, or a trailing backslash.
///
/// A code block never passes through that join: its lines survive byte for
/// byte, because [CodeBlock] scrolls sideways instead of wrapping.
List<_Block> _parseBlocks(String text) {
  final blocks = <_Block>[];
  var insideFence = false;
  var language = '';

  /// The lines of the block being read, and the shape to close them into. A
  /// null shape means a plain paragraph.
  var pending = <String>[];
  _Block? shape;

  void flush() {
    final lines = pending;
    final open = shape;
    pending = [];
    shape = null;

    final kind = open?.kind ?? _BlockKind.paragraph;
    final joined = kind == _BlockKind.code
        ? lines.join('\n').trim()
        : _joinSoftBreaks(lines);
    if (joined.isEmpty) return;

    blocks.add(
      _Block(
        kind,
        joined,
        level: open?.level ?? 0,
        marker: open?.marker ?? '',
        language: kind == _BlockKind.code ? language : '',
      ),
    );
  }

  /// Closes whatever is open and starts a block of [next], whose first line of
  /// text is [firstLine].
  void open(_Block next, String firstLine) {
    flush();
    shape = next;
    pending.add(firstLine);
  }

  /// One counter per nesting depth, so a nested ordered list starts at its own
  /// number and the outer one resumes where it stopped.
  final ordinals = <int, int>{};

  /// Drops the counters of every level deeper than [depth]: coming back out of
  /// a nested list and into it again restarts the inner numbering.
  void dropDeeperThan(int depth) {
    ordinals.removeWhere((level, _) => level > depth);
  }

  for (final line in text.split('\n')) {
    final fence = line.trimLeft();
    if (fence.startsWith('```')) {
      if (insideFence) {
        flush();
        language = '';
      } else {
        flush();
        // The info string of the opening fence; CommonMark only guarantees
        // the first word means the language.
        language = fence.substring(3).trim().split(RegExp(r'\s')).first;
        shape = const _Block(_BlockKind.code, '');
      }
      insideFence = !insideFence;
      continue;
    }
    if (insideFence) {
      pending.add(line);
      continue;
    }

    final trimmed = line.trim();
    final depth = _depthOf(line);

    if (trimmed.isEmpty) {
      flush();
      ordinals.clear();
      continue;
    }

    final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
    if (heading != null) {
      flush();
      ordinals.clear();
      blocks.add(
        _Block(
          _BlockKind.heading,
          heading.group(2)!.trim(),
          level: heading.group(1)!.length,
        ),
      );
      continue;
    }

    if (RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(trimmed)) {
      flush();
      ordinals.clear();
      blocks.add(const _Block(_BlockKind.rule, ''));
      continue;
    }

    final bullet = RegExp(r'^[-*+]\s+(.*)$').firstMatch(trimmed);
    if (bullet != null) {
      dropDeeperThan(depth);
      open(
        _Block(
          _BlockKind.bullet,
          '',
          level: depth,
          marker: _bullets[depth % _bullets.length],
        ),
        bullet.group(1)!,
      );
      continue;
    }

    final numbered = RegExp(r'^(\d+)[.)]\s+(.*)$').firstMatch(trimmed);
    if (numbered != null) {
      dropDeeperThan(depth);
      // Counts from the first item's own number, so the common `1. 1. 1.`
      // source still prints 1, 2, 3 — at each depth independently.
      final ordinal = ordinals.containsKey(depth)
          ? ordinals[depth]! + 1
          : int.parse(numbered.group(1)!);
      ordinals[depth] = ordinal;
      open(
        _Block(_BlockKind.numbered, '', level: depth, marker: '$ordinal.'),
        numbered.group(2)!,
      );
      continue;
    }

    final quote = RegExp(r'^>\s?(.*)$').firstMatch(trimmed);
    if (quote != null) {
      // A run of `>` lines is ONE quote, so it wraps like a paragraph.
      if (shape?.kind == _BlockKind.quote) {
        pending.add(quote.group(1)!);
      } else {
        ordinals.clear();
        open(const _Block(_BlockKind.quote, ''), quote.group(1)!);
      }
      continue;
    }

    // Anything else continues what is open: the wrapped tail of a list item
    // or a quote, or simply the next line of a paragraph.
    pending.add(line);
  }

  // An unterminated fence leaves `insideFence` true; the rest of the answer is
  // still code, and `flush` already knows how to close it.
  flush();
  return blocks;
}

/// Joins the lines of one block, turning a soft break into a space.
///
/// A line ending in two spaces or in a backslash is a HARD break and keeps its
/// newline — that is how Markdown asks for one, and an answer that lays out
/// steps without bullets depends on it.
String _joinSoftBreaks(List<String> lines) {
  final buffer = StringBuffer();
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final backslash = line.endsWith(r'\');
    final hard = backslash || line.endsWith('  ');
    buffer.write(
      (backslash ? line.substring(0, line.length - 1) : line).trim(),
    );
    if (index == lines.length - 1) break;
    buffer.write(hard ? '\n' : ' ');
  }
  return buffer.toString().trim();
}

// ----------------------------------------------------------------- block view

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.style});

  final _Block block;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyLarge ?? const TextStyle();

    switch (block.kind) {
      case _BlockKind.code:
        return CodeBlock(code: block.text, language: block.language);

      case _BlockKind.rule:
        return const Divider(thickness: 1);

      case _BlockKind.heading:
        // All six levels are distinct, so a `####` never looks like the
        // `###` above it. The ceiling is modest: the answer shares the screen
        // with the question, and an `#` at 2x would outshout the card itself.
        final scale = switch (block.level) {
          1 => 1.55,
          2 => 1.35,
          3 => 1.2,
          4 => 1.1,
          5 => 1.0,
          _ => 0.92,
        };
        return _inline(
          context,
          block.text,
          base.copyWith(
            fontSize: (base.fontSize ?? 16) * scale,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        );

      case _BlockKind.quote:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 3),
            ),
          ),
          child: _inline(
            context,
            block.text,
            base.copyWith(
              fontStyle: FontStyle.italic,
              color: base.color?.withValues(alpha: 0.85),
            ),
          ),
        );

      case _BlockKind.bullet:
      case _BlockKind.numbered:
        return Padding(
          // The nesting of the item, 20 points per level.
          padding: EdgeInsets.only(left: 4 + block.level * 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(block.marker, style: base),
              ),
              Expanded(child: _inline(context, block.text, base)),
            ],
          ),
        );

      case _BlockKind.paragraph:
        return _inline(context, block.text, base);
    }
  }

  Widget _inline(BuildContext context, String text, TextStyle base) {
    return SelectableText.rich(
      TextSpan(children: _parseInline(text, base, Theme.of(context))),
      style: base,
    );
  }
}

// ---------------------------------------------------------------- inline pass

/// Handles `code`, **bold**, *italic*, ~~strike~~ and [text](url). The link is
/// styled but not tappable: the app is offline-first and has no browser hop.
List<InlineSpan> _parseInline(String text, TextStyle base, ThemeData theme) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();

  void flush() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString()));
    plain.clear();
  }

  void emit(String content, TextStyle style) {
    flush();
    spans.add(
      TextSpan(children: _parseInline(content, style, theme), style: style),
    );
  }

  var index = 0;
  while (index < text.length) {
    final rest = text.substring(index);

    final code = RegExp(r'^`([^`]+)`').firstMatch(rest);
    if (code != null) {
      flush();
      spans.add(
        TextSpan(
          text: code.group(1),
          style: base.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
            fontSize: (base.fontSize ?? 16) * 0.92,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      );
      index += code.group(0)!.length;
      continue;
    }

    final link = RegExp(r'^\[([^\]]+)\]\(([^)]*)\)').firstMatch(rest);
    if (link != null) {
      flush();
      spans.add(
        TextSpan(
          text: link.group(1),
          style: base.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      );
      index += link.group(0)!.length;
      continue;
    }

    final bold = RegExp(r'^(\*\*|__)(.+?)\1', dotAll: true).firstMatch(rest);
    if (bold != null && _emphasizes(bold, text, index)) {
      emit(bold.group(2)!, base.copyWith(fontWeight: FontWeight.w700));
      index += bold.group(0)!.length;
      continue;
    }

    final strike = RegExp(r'^~~(.+?)~~', dotAll: true).firstMatch(rest);
    if (strike != null) {
      emit(
        strike.group(1)!,
        base.copyWith(decoration: TextDecoration.lineThrough),
      );
      index += strike.group(0)!.length;
      continue;
    }

    // Single delimiter last, so `**` is never read as two italics.
    final italic = RegExp(r'^(\*|_)(?!\1)(.+?)\1', dotAll: true)
        .firstMatch(rest);
    if (italic != null && _emphasizes(italic, text, index)) {
      emit(italic.group(2)!, base.copyWith(fontStyle: FontStyle.italic));
      index += italic.group(0)!.length;
      continue;
    }

    plain.write(text[index]);
    index++;
  }

  flush();
  return spans;
}

final _word = RegExp(r'[A-Za-z0-9]');

/// Whether an underscore-delimited [match] is emphasis or just punctuation
/// inside a word. Asterisks always emphasize.
///
/// CommonMark's intraword rule, and here it is not a nicety: the answers are
/// full of `snake_case` identifiers and file names, and without this
/// `list_of_names` renders as "list*of*names" in italics.
bool _emphasizes(RegExpMatch match, String text, int index) {
  if (!match.group(1)!.startsWith('_')) return true;
  final before = index == 0 ? '' : text[index - 1];
  final afterAt = index + match.group(0)!.length;
  final after = afterAt >= text.length ? '' : text[afterAt];
  return !_word.hasMatch(before) && !_word.hasMatch(after);
}
