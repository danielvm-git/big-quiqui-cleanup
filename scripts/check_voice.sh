#!/usr/bin/env bash
# Lists voice keys the scenes use that have no recording in the locale folder (ADR-003).
#   bash scripts/check_voice.sh [--strict] [locale]     default locale: pt_BR
# Without --strict a missing file is a NOTE (no recordings exist yet). With --strict it fails.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STRICT=0
if [ "${1:-}" = "--strict" ]; then STRICT=1; shift; fi
LOCALE="${1:-pt_BR}"
DIR="$ROOT/game/assets/audio/voice/$LOCALE"
if [ ! -d "$DIR" ] && [ -d "$ROOT/game/assets/audio/voice" ]; then
	echo "  FAIL voice: no folder for locale '$LOCALE'"
	exit 2
fi
missing=0
keys="$(grep -h -A1 -E '^(intro_voice = |kind = "voice")' "$ROOT"/game/data/scenes/*.tres \
	| grep -oE '"vo\.[A-Za-z0-9_.-]+"' | tr -d '"' | sort -u)"
for key in $keys; do
	file="$(echo "${key#vo.}" | tr '.' '_').ogg"
	if [ ! -f "$DIR/$file" ]; then
		echo "  missing: $key -> voice/$LOCALE/$file"
		missing=$((missing + 1))
	fi
done
total="$(echo "$keys" | grep -c . || true)"
if [ "$missing" -eq 0 ]; then
	echo "  PASS voice: all $total lines recorded for $LOCALE"
elif [ "$STRICT" -eq 1 ]; then
	echo "  FAIL voice: $missing of $total lines missing for $LOCALE"
	exit 1
else
	echo "  NOTE voice: $missing of $total lines missing for $LOCALE (use --strict to fail)"
fi
