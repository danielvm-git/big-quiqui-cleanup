#!/usr/bin/env bash
# Exports the iOS Xcode project (unsigned) to build/ios with the release tag as the version.
#   bash scripts/export_ios.sh
# The Apple team id comes from QQ_APPLE_TEAM_ID when set (never committed); otherwise a placeholder
# is used and the project still opens in Xcode, where the owner picks the team.
# Needs the Godot 4.7 export templates installed. Exit 3 when they are missing.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
PRESETS="$ROOT/game/export_presets.cfg"
OUT="$ROOT/build/ios"
VERSION="$(bash "$ROOT/scripts/version.sh")"
TEAM="${QQ_APPLE_TEAM_ID:-0000000000}"

[[ "$TEAM" =~ ^[A-Z0-9]{10}$ ]] || { echo "QQ_APPLE_TEAM_ID must be 10 letters or digits"; exit 2; }
bash "$ROOT/scripts/check_export.sh" || exit 1
BUILD="$VERSION.$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null || echo 0)"
"$GODOT" --version >/dev/null 2>&1 || { echo "godot not found"; exit 3; }

BACKUP="$(mktemp)"
cp "$PRESETS" "$BACKUP"
LOG="$(mktemp)"
restore() { cp "$BACKUP" "$PRESETS"; rm -f "$BACKUP" "$LOG"; }
trap restore EXIT
trap 'exit 130' INT TERM
# application/version is the build number (App Store Connect needs a rising one), short_version the release.
sed -e "s/^application\/version=.*/application\/version=\"$BUILD\"/" \
	-e "s/^application\/short_version=.*/application\/short_version=\"$VERSION\"/" \
	-e "s/^application\/app_store_team_id=.*/application\/app_store_team_id=\"$TEAM\"/" \
	"$BACKUP" > "$PRESETS"

rm -rf "$OUT"
mkdir -p "$OUT"
"$GODOT" --headless --path "$ROOT/game" --import > /dev/null 2>&1
"$GODOT" --headless --path "$ROOT/game" --export-release iOS "$OUT/QuiQuiCleanup.ipa" > "$LOG" 2>&1
code=$?
if grep -qiE "no export template|export templates? .*(not|missing)|templates.*not found" "$LOG"; then
	echo "missing export templates for this Godot version (install them from the editor)"
	exit 3
fi
if [ "$code" -ne 0 ] || [ ! -d "$OUT/QuiQuiCleanup.xcodeproj" ] || [ ! -s "$OUT/QuiQuiCleanup.pck" ]; then
	echo "EXPORT FAILED (exit $code)"; tail -15 "$LOG"; exit 1
fi
if grep -aqE "addons/gut|res://tests/|res://tools/" "$OUT/QuiQuiCleanup.pck"; then
	echo "EXPORT FAILED: tests, tools or the test framework leaked into the game"; exit 1
fi
echo "EXPORTED: build/ios/QuiQuiCleanup.xcodeproj (version $VERSION, build $BUILD)"
