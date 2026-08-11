import 'dart:io';

import 'package:flashcard_dev_senior/core/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

/// The About screen has to name the exact bundle that is running, so the two
/// halves of `version:` in pubspec.yaml and the constants the screen reads must
/// never drift apart.
void main() {
  test('the version and build number match pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final line = pubspec.firstWhere((line) => line.startsWith('version:'));
    final value = line.split(':')[1].trim();
    final parts = value.split('+');

    expect(AppVersion.name, parts.first,
        reason: 'pubspec says $value; update lib/core/app_version.dart');
    expect(AppVersion.build, parts.last,
        reason: 'pubspec says $value; update lib/core/app_version.dart');
    expect(AppVersion.full, value);
  });

  test('with no build define the commit reads as unknown, never as empty', () {
    expect(AppVersion.commitOrUnknown, isNotEmpty);
  });
}
