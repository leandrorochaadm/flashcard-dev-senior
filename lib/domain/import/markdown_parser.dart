import '../models/enums.dart';
import 'import_preview.dart';

/// Reads the labeled-Markdown format described in the requirements.
///
/// Cards are separated by a line containing only `---`. Each block is parsed
/// independently on purpose: a broken block number 47 shows up marked in the
/// preview while the other 99 import normally.
final class MarkdownParser {
  const MarkdownParser();

  static const _questionMarker = 'pergunta';
  static const _answerMarker = 'resposta';

  ImportPreview parse(String source) {
    final valid = <ParsedCard>[];
    final invalid = <InvalidBlock>[];

    final blocks = splitBlocks(source);
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.trim().isEmpty) continue;
      final issues = <ImportIssue>[];
      final parsed = _parseBlock(block, i, issues);
      if (parsed != null) {
        valid.add(parsed);
      } else {
        invalid.add(
          InvalidBlock(blockIndex: i, rawText: block.trim(), issues: issues),
        );
      }
    }
    return ImportPreview(valid: valid, invalid: invalid);
  }

  /// Splits on `---` lines, ignoring separators inside fenced code blocks —
  /// a Dart snippet is allowed to contain anything.
  List<String> splitBlocks(String source) {
    final blocks = <String>[];
    final current = <String>[];
    var insideFence = false;

    for (final line in source.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('```')) insideFence = !insideFence;

      if (!insideFence && trimmed == '---') {
        blocks.add(current.join('\n'));
        current.clear();
        continue;
      }
      current.add(line);
    }
    blocks.add(current.join('\n'));
    return blocks;
  }

  ParsedCard? _parseBlock(String block, int index, List<ImportIssue> issues) {
    final lines = block.split('\n');

    String? id;
    String? subject;
    String? difficultyLabel;
    final question = <String>[];
    final answer = <String>[];

    // null = still reading the labeled header.
    List<String>? section;
    var insideFence = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('```')) insideFence = !insideFence;

      if (!insideFence) {
        final marker = _sectionMarker(trimmed);
        if (marker == _questionMarker) {
          section = question;
          continue;
        }
        if (marker == _answerMarker) {
          section = answer;
          continue;
        }
        if (section == null) {
          final label = _labeledLine(trimmed);
          if (label != null) {
            switch (label.key) {
              case 'id':
                id = label.value;
              case 'assunto':
                subject = label.value;
              case 'dificuldade':
                difficultyLabel = label.value;
            }
            continue;
          }
          // Anything else before the first marker is decoration; skip it.
          continue;
        }
      }
      section?.add(line);
    }

    final difficulty = _difficultyFrom(difficultyLabel);
    if (subject == null || subject.isEmpty) issues.add(ImportIssue.missingSubject);
    if (difficulty == null) issues.add(ImportIssue.unknownDifficulty);
    if (_join(question).isEmpty) issues.add(ImportIssue.missingQuestion);
    if (_join(answer).isEmpty) issues.add(ImportIssue.missingAnswer);
    if (issues.isNotEmpty) return null;

    return ParsedCard(
      id: (id == null || id.isEmpty) ? null : id,
      question: _join(question),
      answer: _join(answer),
      subject: subject!,
      difficulty: difficulty!,
      blockIndex: index,
    );
  }

  /// `**Pergunta**`, `**Resposta**`, with or without the bold markers.
  String? _sectionMarker(String trimmed) {
    final bare = trimmed.replaceAll('*', '').replaceAll('#', '').trim();
    final normalized = _withoutAccents(bare.toLowerCase());
    if (normalized == _questionMarker || normalized == _answerMarker) {
      return normalized;
    }
    return null;
  }

  ({String key, String value})? _labeledLine(String trimmed) {
    final colon = trimmed.indexOf(':');
    if (colon <= 0) return null;
    final key = _withoutAccents(trimmed.substring(0, colon).trim().toLowerCase());
    if (key.contains(' ')) return null;
    return (key: key, value: trimmed.substring(colon + 1).trim());
  }

  /// Keeps indentation and line breaks byte for byte — only the blank lines
  /// around the section are dropped.
  String _join(List<String> lines) {
    var start = 0;
    var end = lines.length;
    while (start < end && lines[start].trim().isEmpty) {
      start++;
    }
    while (end > start && lines[end - 1].trim().isEmpty) {
      end--;
    }
    return lines.sublist(start, end).join('\n');
  }

  Difficulty? _difficultyFrom(String? label) {
    if (label == null) return null;
    return switch (_withoutAccents(label.trim().toLowerCase())) {
      'basico' => Difficulty.basic,
      'intermediario' => Difficulty.intermediate,
      'avancado' => Difficulty.advanced,
      _ => null,
    };
  }

  static const _accented = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  static const _plain = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  String _withoutAccents(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final at = _accented.indexOf(char);
      buffer.write(at == -1 ? char : _plain[at]);
    }
    return buffer.toString();
  }
}
