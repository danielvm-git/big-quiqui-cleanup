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

bash "$ROOT/scripts/check_export.sh" || exit 1
"$GODOT" --version >/dev/null 2>&1 || { echo "godot not found"; exit 3; }

BACKUP="$(mktemp)"
cp "$PRESETS" "$BACKUP"
trap 'cp "$BACKUP" "$PRESETS"; rm -f "$BACKUP"' EXIT
sed -e "s/^application\/version=.*/application\/version=\"$VERSION\"/" \
	-e "s/^application\/short_version=.*/application\/short_version=\"$VERSION\"/" \
	-e "s/^application\/app_store_team_id=.*/application\/app_store_team_id=\"$TEAM\"/" \
	"$BACKUP" > "$PRESETS"

rm -rf "$OUT"
mkdir -p "$OUT"
"$GODOT" --headless --path "$ROOT/game" --import > /dev/null 2>&1
LOG="$(mktemp)"
"$GODOT" --headless --path "$ROOT/game" --export-release iOS "$OUT/QuiQuiCleanup.ipa" > "$LOG" 2>&1
if grep -q "export_templates\|No export template\|templates" "$LOG" && [ ! -d "$OUT/QuiQuiCleanup.xcodeproj" ]; then
	echo "missing export templates for this Godot version (install them from the editor)"
	exit 3
fi
if [ ! -d "$OUT/QuiQuiCleanup.xcodeproj" ]; then
	echo "EXPORT FAILED"; tail -15 "$LOG"; exit 1
fi
if strings "$OUT/QuiQuiCleanup.pck" | grep -qE "addons/gut|res://tests/"; then
	echo "EXPORT FAILED: tests or the test framework leaked into the game"; exit 1
fi
echo "EXPORTED: build/ios/QuiQuiCleanup.xcodeproj (version $VERSION)"
