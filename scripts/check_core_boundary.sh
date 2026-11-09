#!/usr/bin/env bash
# Core boundary (ADR-002): code under game/addons/quiqui_core may depend on nothing outside it.
#   R1  no res:// path outside res://addons/quiqui_core/
#   R2  no /root/ access (no reaching autoloads by path)
# Usage: bash scripts/check_core_boundary.sh             check the real core
#        bash scripts/check_core_boundary.sh --self-test prove the check fails on a planted violation
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

violations() {
	local core="$1"
	grep -rnE --include='*.gd' --include='*.tscn' --include='*.tres' 'res://' "$core" 2>/dev/null \
		| grep -v 'res://addons/quiqui_core/' || true
	grep -rnE --include='*.gd' '/root/' "$core" 2>/dev/null || true
}

if [ "${1:-}" = "--self-test" ]; then
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' EXIT
	mkdir -p "$tmp/core"
	printf 'extends Node\nvar x = preload("res://scripts/game_thing.gd")\n' > "$tmp/core/bad_path.gd"
	printf 'extends Node\nfunc f():\n\treturn get_node("/root/Log")\n' > "$tmp/core/bad_root.gd"
	printf 'extends Node\nvar x = preload("res://addons/quiqui_core/core/fsm.gd")\n' > "$tmp/core/ok.gd"
	found="$(violations "$tmp/core")"
	count="$(printf '%s\n' "$found" | grep -c . || true)"
	if [ "$count" -ne 2 ]; then
		echo "core boundary self-test FAILED: expected 2 violations, found $count"
		printf '%s\n' "$found"
		exit 1
	fi
	echo "core boundary self-test ok: the planted violations were caught and the clean file was not"
	exit 0
fi

CORE="$ROOT/game/addons/quiqui_core"
if [ ! -d "$CORE" ]; then
	echo "core boundary: $CORE does not exist"
	exit 1
fi
found="$(violations "$CORE")"
if [ -n "$found" ]; then
	echo "core boundary violated (ADR-002):"
	printf '%s\n' "$found"
	exit 1
fi
echo "core boundary ok"
