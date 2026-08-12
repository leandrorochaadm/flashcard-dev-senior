@TestOn('vm')
library;

// The mirror image of the `chrome-only` suites: this one reads the deck from
// disk, so it belongs to the VM and must not be loaded by the Chrome job —
// `--tags=chrome-only` filters which tests RUN, not which files are compiled.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_dev_senior/domain/import/dart_code_formatter.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';

/// Parses every deck file in `temp/card/` with the production parser.
///
/// Regex checks pass on files the app would reject, so the only honest
/// verification is the parser that runs on import.
///
/// The formatter is wired in for the same reason: the app imports with it, so
/// checking without it would bless a deck the app then marks. It is what makes
/// a ```dart block with broken syntax fail here, before the card is studied.
void main() {
  final parser = MarkdownParser(DartCodeFormatter());
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

  // The parser accepts any Markdown as an answer, so it happily blessed 36
  // cards whose ```dart block sat at the end of `##### Uso real` with no
  // label of its own. Only a structural check catches that: the five-section
  // shape of `import_template.dart` is a deck rule, not a parser rule.
  const sections = ['##### Por quê', '##### Alternativa', '##### Uso real'];

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test('$name follows the five-section answer format', () {
      final preview = parser.parse(file.readAsStringSync());
      for (final card in preview.valid) {
        final answer = card.answer;
        final where = '${card.id} in $name';

        var cursor = -1;
        for (final section in sections) {
          final at = answer.indexOf(section);
          expect(at, greaterThan(-1), reason: '$where has no "$section"');
          expect(at, greaterThan(cursor), reason: '$where has $section early');
          cursor = at;
        }
        // The first section carries no label on purpose: the reader flipped
        // the card for the answer, so the answer owns the first line.
        expect(
          answer.trimLeft().startsWith('#####'),
          isFalse,
          reason: '$where labels its opening section',
        );
        for (final section in sections) {
          expect(
            RegExp('^${RegExp.escape(section)}\$', multiLine: true)
                .allMatches(answer)
                .length,
            1,
            reason: '$where repeats "$section"',
          );
        }
        // Every fenced block belongs under `##### Código`. The renderer gives
        // 22px before a heading and 4px after, so an unlabelled block reads
        // as the tail of the previous sentence instead of its own section.
        final codeAt = answer.indexOf('##### Código');
        final fence = RegExp(r'^```\w', multiLine: true).firstMatch(answer);
        if (fence != null) {
          expect(codeAt, greaterThan(-1), reason: '$where has code, no label');
          expect(
            fence.start,
            greaterThan(codeAt),
            reason: '$where has a code block before "##### Código"',
          );
        }
        if (codeAt > -1) {
          expect(cursor, lessThan(codeAt), reason: '$where puts Código early');
        }
      }
    });
  }

  // Checked against the pub.dev API by hand on 12/08/2026; refresh it the
  // same way. The list lives here rather than in a live query because the CI
  // must not depend on the network to tell a good deck from a bad one.
  //
  // Naming one of these is not the offence — saying it is dead IS the senior
  // answer, and `test-005` does exactly that. Recommending one without the
  // warning is the offence, so the check is for the warning nearby.
  const abandoned = {
    'golden_toolkit': 'descontinuado em 2023; use matchesGoldenFile/alchemist',
    'built_collection': 'parado desde 2021; use package:collection',
    'hive': 'abandonado pelo autor; Drift para projeto novo, hive_ce p/ migrar',
    'isar': 'abandonado pelo autor; Drift para projeto novo',
  };
  const warnings = ['descontinuad', 'abandonad', 'sem mantenedor', 'parado'];

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test('$name flags every abandoned package it names', () {
      final text = file.readAsStringSync();
      for (final entry in abandoned.entries) {
        for (final hit in RegExp('`${entry.key}`').allMatches(text)) {
          // The warning has to sit close enough that the reader sees it in
          // the same breath as the package name.
          final from = (hit.start - 400).clamp(0, text.length);
          final to = (hit.end + 400).clamp(0, text.length);
          final around = text.substring(from, to).toLowerCase();
          expect(
            warnings.any(around.contains),
            isTrue,
            reason: '$name names ${entry.key} with no warning: ${entry.value}',
          );
        }
      }
    });
  }

  tearDownAll(() {
    expect(total, greaterThan(0));
    expect(seenIds, hasLength(total));
  });
}
