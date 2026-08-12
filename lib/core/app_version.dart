/// Version, build number and commit of the running bundle.
///
/// The version and the build number are the two halves of `version:` in
/// `pubspec.yaml` (`1.0.0+1`), kept in sync by hand — reading the pubspec at
/// runtime would mean shipping it as an asset, and the app has to open with no
/// network at all.
///
/// The commit hash comes in at build time:
///
/// ```sh
/// flutter build web --release \
///   --dart-define=COMMIT_HASH=$(git rev-parse --short HEAD)
/// ```
abstract final class AppVersion {
  /// `version:` of pubspec.yaml, before the `+`.
  static const name = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// `version:` of pubspec.yaml, after the `+`.
  static const build = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '5',
  );

  /// Short hash of the commit the bundle was built from. Empty when the app
  /// runs straight from `flutter run`, with no define.
  static const commit = String.fromEnvironment('COMMIT_HASH');

  static String get full => '$name+$build';

  static String get commitOrUnknown => commit.isEmpty ? 'não informado' : commit;
}
