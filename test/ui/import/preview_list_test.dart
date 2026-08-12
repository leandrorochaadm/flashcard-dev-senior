@TestOn('browser')
@Tags(['chrome-only'])
library;

// Reaches `dart:js_interop` through the import feature, which pulls the file
// picker in. Same reason as the other browser-only suites: the annotation is
// what lets a plain `flutter test` stay clean instead of failing to compile.
import 'package:flashcard_dev_senior/domain/import/import_preview.dart';
import 'package:flashcard_dev_senior/ui/import/widgets/preview_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Exhaustiveness itself is the analyzer's job — a missing case is a compile
  // error. What it cannot check is that the words are true.
  test('the dart issue is worded as syntax, not compilation', () {
    // The formatter parses; it never resolves names against the SDK, which a
    // browser has no way to do. Saying "não compila" would oversell the check.
    final label = issueLabel(ImportIssue.unparsableDartCode);

    expect(label, contains('sintaxe'));
    expect(label, isNot(contains('compila')));
  });

  test('every issue reads as a reason a person can act on', () {
    for (final issue in ImportIssue.values) {
      expect(issueLabel(issue), isNotEmpty, reason: issue.name);
    }
  });
}
