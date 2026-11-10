#!/usr/bin/env bash
# The game version is the latest release tag (big-release creates v0.N.0, v0.N.M ...). project.godot keeps 0.0.0.
#   bash scripts/version.sh              prints the version without the "v", or 0.0.0 when there is no tag
#   bash scripts/version.sh --self-test
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# "v1.2.3" -> "1.2.3"; anything that is not x.y.z (with an optional v) -> 0.0.0
normalize() {
	local tag="${1#v}"
	if printf '%s' "$tag" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
		printf '%s\n' "$tag"
	else
		printf '0.0.0\n'
	fi
}

if [ "${1:-}" = "--self-test" ]; then
	fail=0
	check() {
		local got
		got="$(normalize "$1")"
		if [ "$got" = "$2" ]; then echo "  PASS '$1' -> $2"; else echo "  FAIL '$1' -> $got (want $2)"; fail=1; fi
	}
	check "v0.4.0" "0.4.0"
	check "v1.0.0" "1.0.0"
	check "0.4.1" "0.4.1"
	check "" "0.0.0"
	check "none" "0.0.0"
	check "v1.2" "0.0.0"
	check "v1.2.3-rc1" "0.0.0"
	exit "$fail"
fi

# The highest clean vX.Y.Z tag reachable from HEAD (pre-release tags such as v1.2.3-rc1 are skipped).
tag="$(git -C "$ROOT" tag --merged HEAD --list 'v[0-9]*' --sort=-v:refname 2>/dev/null \
	| grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1 || true)"
normalize "$tag"
