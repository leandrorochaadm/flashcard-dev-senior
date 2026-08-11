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

# `--pwa-strategy=none`: Flutter's own service worker is deprecated as of 3.44
# — it unregisters itself on activate and caches nothing. Offline is a product
# requirement here, so `web/sw.js` takes over, registered from index.html.
flutter build web --release \
  --pwa-strategy=none \
  --dart-define=APP_VERSION="$APP_VERSION" \
  --dart-define=BUILD_NUMBER="$BUILD_NUMBER" \
  --dart-define=COMMIT_HASH="$COMMIT_HASH"

# Stamps the build into the cache name, so a new build opens a new cache and
# drops the previous one whole — never a new main.dart.js against a stale
# asset manifest. A temp file plus mv, because `sed -i` differs between BSD
# and GNU and this repo is written on macOS and built on ubuntu-latest.
sed "s/{{BUILD_ID}}/$APP_VERSION+$BUILD_NUMBER.$COMMIT_HASH/" \
  build/web/sw.js > build/web/sw.js.tmp
mv build/web/sw.js.tmp build/web/sw.js

grep -q "{{BUILD_ID}}" build/web/sw.js && {
  echo "ERROR: sw.js still carries the {{BUILD_ID}} placeholder." >&2
  exit 1
}

echo "Service worker cache: flashcards-$APP_VERSION+$BUILD_NUMBER.$COMMIT_HASH"
