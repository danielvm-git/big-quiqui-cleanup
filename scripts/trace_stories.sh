#!/usr/bin/env bash
# Traceability: every story marked done has a test file tagged "# story: <id>".
#   bash scripts/trace_stories.sh --strict   also fails on a tagged test whose story is not listed
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1
FAILED=0
STATUS=specs/execution-status.yaml
[ -s "$STATUS" ] || { echo "  FAIL $STATUS missing"; exit 1; }

for id in $(grep -oE '^  e[0-9]+s[0-9]+:' "$STATUS" | tr -d ' :'); do
	state=$(grep -E "^  $id:" "$STATUS" | awk '{print $2}')
	if [ "$state" = "done" ]; then
		if grep -rlq "^# story: .*\b$id\b" game/tests; then
			echo "  PASS $id traced"
		else
			echo "  FAIL $id is done but no test carries '# story: $id'"
			FAILED=1
		fi
	fi
done
if [ "$STRICT" -eq 1 ]; then
	for id in $(grep -rhoE '^# story: .*' game/tests | grep -oE 'e[0-9]+s[0-9]+' | sort -u); do
		grep -qE "^  $id:" "$STATUS" || { echo "  FAIL test tags unknown story $id"; FAILED=1; }
	done
fi
[ "$FAILED" -eq 0 ] && echo "TRACE OK" || echo "TRACE FAILED"
exit "$FAILED"
