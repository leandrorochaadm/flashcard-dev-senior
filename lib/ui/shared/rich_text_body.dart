import 'package:flutter/material.dart';

import 'code_block.dart';

/// Renders the answer of a card: plain paragraphs, with every ```dart fence
/// handed to [CodeBlock].
///
/// Splitting the text is presentation, not a business rule — the parser
/// already kept the answer byte for byte.
class RichTextBody extends StatelessWidget {
  const RichTextBody({required this.text, this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final segments = _split(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final segment in segments) ...[
          if (segment.isCode)
            CodeBlock(code: segment.text)
          else
            SelectableText(
              segment.text,
              style: style ?? Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _Segment {
  const _Segment(this.text, {required this.isCode});

  final String text;
  final bool isCode;
}

List<_Segment> _split(String text) {
  final segments = <_Segment>[];
  final current = <String>[];
  var insideFence = false;

  void flush({required bool isCode}) {
    final joined = current.join('\n').trim();
    current.clear();
    if (joined.isNotEmpty) segments.add(_Segment(joined, isCode: isCode));
  }

  for (final line in text.split('\n')) {
    if (line.trimLeft().startsWith('```')) {
      flush(isCode: insideFence);
      insideFence = !insideFence;
      continue;
    }
    current.add(line);
  }
  flush(isCode: insideFence);
  return segments;
}
