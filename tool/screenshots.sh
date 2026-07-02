#!/usr/bin/env bash
# Capture store screenshots with the integration_test harness (the single
# source of the shot list — integration_test/screenshots_test.dart) and file
# them into the fastlane layouts that `fastlane android listing` /
# `fastlane ios screenshots` upload.
#
#   tool/screenshots.sh android [en de fr it]   # any host with flutter+adb
#   tool/screenshots.sh ios     [en de fr it]   # macOS with a simulator
#
# Android: uses the first `adb devices` device — the canonical capture target
# is the emulator (Linux: launch it from the HOST, the script runs inside the
# distrobox; Mac: any AVD). Override with DEVICE=<id>.
# iOS: uses the booted simulator, else boots the newest iPhone "Pro Max"
# (6.9" — the layout deliver maps to). Override with DEVICE=<udid>.
set -euo pipefail

PLATFORM=${1:?usage: tool/screenshots.sh <android|ios> [locales...]}
shift || true
LOCALES=("$@")
[ ${#LOCALES[@]} -gt 0 ] || LOCALES=(en de fr it)

cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo "✗ flutter not on PATH (Linux: run inside the flutter distrobox)"; exit 1; }

case "$PLATFORM" in
  android)
    DEVICE=${DEVICE:-$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')}
    [ -n "${DEVICE:-}" ] || { echo "✗ no adb device — start the emulator first"; exit 1; }
    ;;
  ios)
    command -v xcrun >/dev/null || { echo "✗ ios capture needs macOS"; exit 1; }
    DEVICE=${DEVICE:-$(xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1)}
    if [ -z "${DEVICE:-}" ]; then
      DEVICE=$(xcrun simctl list devices available | grep -E 'iPhone .* Pro Max' \
        | tail -1 | grep -oE '[0-9A-F-]{36}')
      [ -n "$DEVICE" ] || { echo "✗ no iPhone Pro Max simulator available"; exit 1; }
      echo "→ booting simulator $DEVICE"
      xcrun simctl boot "$DEVICE"
      xcrun simctl bootstatus "$DEVICE" -b
    fi
    ;;
  *) echo "✗ unknown platform '$PLATFORM' (android|ios)"; exit 1 ;;
esac
echo "✓ target: $DEVICE"

for L in "${LOCALES[@]}"; do
  echo "=== capture $L ==="
  rm -rf "screenshots/$L"
  # Fresh app container per locale so the seeded fixture doesn't accumulate.
  case "$PLATFORM" in
    android) adb -s "$DEVICE" uninstall ch.knabberfuchs.app >/dev/null 2>&1 || true ;;
    ios)     xcrun simctl uninstall "$DEVICE" ch.knabberfuchs.app 2>/dev/null || true ;;
  esac
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshots_test.dart \
    --dart-define=LOCALE="$L" \
    -d "$DEVICE"
  ls "screenshots/$L"/*.png >/dev/null 2>&1 || { echo "✗ no screenshots produced for $L"; exit 1; }

  case "$PLATFORM" in
    android)
      case "$L" in en) D=en-US;; de) D=de-DE;; fr) D=fr-FR;; it) D=it-IT;; *) D=$L;; esac
      DEST="fastlane/metadata/android/$D/images/phoneScreenshots"
      mkdir -p "$DEST"
      rm -f "$DEST"/*.png
      cp "screenshots/$L"/*.png "$DEST/"   # NN_name.png — supply orders by name
      ;;
    ios)
      case "$L" in en) D=en-US;; de) D=de-DE;; fr) D=fr-FR;; it) D=it;; *) D=$L;; esac
      DEST="fastlane/screenshots/$D"
      mkdir -p "$DEST"
      rm -f "$DEST"/iphone69_*.png
      for F in "screenshots/$L"/*.png; do
        cp "$F" "$DEST/iphone69_$(basename "$F")"  # prefix orders the 6.9" slot
      done
      ;;
  esac
  echo "✓ $L → $DEST ($(ls "$DEST" | wc -l | tr -d ' ') files)"
done

echo "done — review the PNGs, then upload with:"
case "$PLATFORM" in
  android) echo "  fastlane android listing" ;;
  ios)     echo "  fastlane ios screenshots" ;;
esac
