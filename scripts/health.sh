#!/usr/bin/env bash
# Health check: does the game boot and does the living room load, with no engine errors?
#   bash scripts/health.sh
# Idempotent and read-only: it writes nothing but the engine's own import cache.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
GODOT="${GODOT:-godot}"
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

"$GODOT" --headless --path game --import > /dev/null 2>&1
"$GODOT" --headless --path game --quit-after 30 > "$OUT" 2>&1
code=$?
# "resources still in use at exit" is the engine's quit-time leak notice, not a runtime error.
if [ "$code" -ne 0 ] || grep -vE "still in use at exit" "$OUT" | grep -qE "SCRIPT ERROR|^ERROR:|scene_invalid"; then
	echo "UNHEALTHY: boot exit code $code"
	sed 's/^/  | /' "$OUT" | tail -20
	exit 1
fi
if ! grep -q '"message":"scene_loaded"' "$OUT"; then
	echo "UNHEALTHY: the living room did not report scene_loaded"
	exit 1
fi
echo "HEALTHY: boots, living room loaded"
grep '"message"' "$OUT" | head -3
