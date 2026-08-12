// Tidies the ```dart blocks of the deck files in `temp/card/`.
//
// Same formatter the app runs at import time, so a file that passes here needs
// no fixing on the way in — and `test/deck_files_test.dart` checks exactly that.
// Run it after regenerating a deck file with an AI:
//
//     dart run tool/format_deck.dart            # rewrites the files
//     dart run tool/format_deck.dart --check    # reports, changes nothing
//
// A block that does not parse is never rewritten: it is reported and left
// alone, because a broken snippet is for a person to read and fix, not for a
// tool to guess at.
import 'dart:io';

import 'package:flashcard_dev_senior/domain/import/dart_code_formatter.dart';

const _deckPath = 'temp/card';

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  final directory = Directory(_deckPath);
  if (!directory.existsSync()) {
    stderr.writeln('No $_deckPath/ in this checkout — nothing to do.');
    return;
  }

  final formatter = DartCodeFormatter();
  final files =
      directory
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.md') && !file.path.endsWith('README.md'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  var changed = 0;
  var broken = 0;

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final source = file.readAsStringSync();
    final result = formatter.formatFences(source);

    if (!result.ok) {
      broken++;
      stdout.writeln('$name: a ```dart block does not parse — left untouched');
    }
    if (result.answer == source) continue;

    changed++;
    if (checkOnly) {
      stdout.writeln('$name: would be reformatted');
    } else {
      file.writeAsStringSync(result.answer);
      stdout.writeln('$name: reformatted');
    }
  }

  stdout.writeln(
    '${files.length} files, $changed to rewrite, $broken with broken code.',
  );
  // Non-zero on either count, so `--check` can gate a commit hook.
  if ((checkOnly && changed > 0) || broken > 0) exitCode = 1;
}
