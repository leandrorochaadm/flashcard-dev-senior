#!/usr/bin/env sh
# Brave as the browser for `flutter test --platform chrome`.
#
# Brave is Chromium, so the test runner drives it fine — but out of the box it
# spends the first run on onboarding, Rewards and its own updater, none of
# which the runner knows to dismiss. On a throwaway profile that is enough to
# leave the run hanging.
#
# Point the tool at this wrapper instead of at the binary:
#
#   export CHROME_EXECUTABLE="$PWD/tool/brave_for_tests.sh"
#   flutter test --platform chrome --tags=chrome-only
exec "/Volumes/Dock/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  --no-first-run \
  --no-default-browser-check \
  --disable-sync \
  --disable-background-networking \
  --disable-component-update \
  --disable-brave-update \
  --disable-extensions \
  --disable-features=BraveRewards,BraveWallet,BraveVPN,BraveNews,Translate \
  "$@"
