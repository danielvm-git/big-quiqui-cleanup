#!/usr/bin/env bash
# Preflight: every gate, one entry point.
#   bash scripts/preflight.sh          all gates, including the tests
#   bash scripts/preflight.sh --fast   static gates only (used by the pre-commit hook)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
FAST=0
[ "${1:-}" = "--fast" ] && FAST=1
FAILED=0
GODOT="${GODOT:-godot}"

stage() { printf '\n== %s\n' "$1"; }
pass() { printf '  PASS %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; FAILED=1; }
run() {
	local label="$1"
	shift
	if "$@" > /tmp/qq_preflight.out 2>&1; then
		pass "$label"
	else
		fail "$label"
		sed 's/^/    | /' /tmp/qq_preflight.out | tail -25
	fi
}

stage "L0 lint and format"
run "gdlint game/" gdlint game/
run "gdformat --check game/" gdformat --check game/

stage "L0a engine import"
run "project imported" "$GODOT" --headless --path game --import

stage "L0b strict typing"
run "type gate" "$GODOT" --headless --path game -s res://tools/type_gate.gd

stage "L1 tests (GUT)"
if [ "$FAST" -eq 1 ]; then
	printf '  NOTE skipped by --fast\n'
else
	"$GODOT" --headless --path game -s addons/gut/gut_cmdln.gd -gexit > /tmp/qq_gut.out 2>&1
	code=$?
	# GUT exits 0 when it finds no tests, so the output is checked too.
	if [ "$code" -ne 0 ]; then
		fail "GUT exit code $code"
		tail -40 /tmp/qq_gut.out | sed 's/^/    | /'
	elif grep -q "Nothing was run" /tmp/qq_gut.out || ! grep -q "Passing Tests" /tmp/qq_gut.out; then
		fail "GUT ran no tests"
		tail -20 /tmp/qq_gut.out | sed 's/^/    | /'
	else
		pass "GUT: $(grep -E 'Passing Tests' /tmp/qq_gut.out | tail -1 | tr -s ' ')"
	fi
fi

stage "L2 core boundary (ADR-002)"
run "core boundary" bash scripts/check_core_boundary.sh
run "core boundary self-test" bash scripts/check_core_boundary.sh --self-test

stage "L3 specs"
for f in VISION ARCHITECTURE TEMPLATES BACKLOG; do
	[ -s "specs/$f.md" ] && pass "specs/$f.md" || fail "specs/$f.md is missing or empty"
done
for f in specs/adr/ADR-*.md; do
	grep -q '^- \*\*Status:\*\*' "$f" && pass "$(basename "$f") has a status" || fail "$f has no Status line"
done

stage "L3b voice lines"
bash scripts/check_voice.sh

stage "L4 traceability"
run "trace stories (strict)" bash scripts/trace_stories.sh --strict

printf '\n'
if [ "$FAILED" -eq 0 ]; then
	printf 'GATES GREEN%s\n' "$([ "$FAST" -eq 1 ] && echo ' (fast mode, tests skipped)')"
	exit 0
fi
printf 'GATES RED\n'
exit 1
