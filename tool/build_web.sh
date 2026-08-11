#!/usr/bin/env sh
# Release build with the version stamped into the About screen.
#
# The version and the build number come from `version:` in pubspec.yaml, and
# the commit from git — so the running bundle can always be named exactly,
# which matters in a PWA where the browser may keep an older cache around.
set -eu
cd "$(dirname "$0")/.."

VERSION_LINE=$(grep '^version:' pubspec.yaml | cut -d: -f2 | tr -d ' ')
APP_VERSION=${VERSION_LINE%%+*}
BUILD_NUMBER=${VERSION_LINE##*+}
COMMIT_HASH=$(git rev-parse --short HEAD)

echo "Flashcards $APP_VERSION+$BUILD_NUMBER (commit $COMMIT_HASH)"

flutter build web --release \
  --dart-define=APP_VERSION="$APP_VERSION" \
  --dart-define=BUILD_NUMBER="$BUILD_NUMBER" \
  --dart-define=COMMIT_HASH="$COMMIT_HASH"
