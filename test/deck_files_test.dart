import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';

/// Parses every deck file in `temp/card/` with the production parser.
///
/// Regex checks pass on files the app would reject, so the only honest
/// verification is the parser that runs on import.
void main() {
  const parser = MarkdownParser();
  final deckDir = Directory('temp/card');
  // `temp/` is gitignored, so a clean clone has no deck to check.
  if (!deckDir.existsSync()) {
    test('deck files are absent in this checkout', () {}, skip: true);
    return;
  }
  final files = deckDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md') && !f.path.endsWith('README.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('deck files exist', () => expect(files, isNotEmpty));

  // The README claims importing the whole folder by mistake is harmless.
  // That claim is only true while the README yields no importable card.
  test('README yields no card when imported by mistake', () {
    final readme = File('temp/card/README.md');
    if (!readme.existsSync()) return;
    final preview = parser.parse(readme.readAsStringSync());
    expect(
      preview.valid,
      isEmpty,
      reason: preview.valid.map((c) => c.question).join(' | '),
    );
  });

  final seenIds = <String, String>{};
  final seenQuestions = <String, String>{};
  var total = 0;

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test('$name parses with no invalid block', () {
      final preview = parser.parse(file.readAsStringSync());
      expect(
        preview.invalid,
        isEmpty,
        reason: preview.invalid
            .map((b) => 'block ${b.blockIndex}: ${b.issues}')
            .join('\n'),
      );
      expect(preview.valid, isNotEmpty);
      total += preview.valid.length;

      for (final card in preview.valid) {
        final id = card.id;
        expect(id, isNotNull, reason: 'block ${card.blockIndex} has no id');
        expect(seenIds.containsKey(id), isFalse,
            reason: 'id $id also in ${seenIds[id]}');
        seenIds[id!] = name;
        final q = card.question.replaceAll(RegExp(r'\s+'), ' ').trim();
        expect(seenQuestions.containsKey(q), isFalse,
            reason: 'question repeated: $id and ${seenQuestions[q]}');
        seenQuestions[q] = id;
      }
    });
  }

  tearDownAll(() {
    expect(total, greaterThan(0));
    expect(seenIds, hasLength(total));
  });
}
