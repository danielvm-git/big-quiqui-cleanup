#!/usr/bin/env bash
# Export hygiene: nothing secret and nothing risky in the iOS export preset or the repository.
#   bash scripts/check_export.sh [preset-file]    default: game/export_presets.cfg
#   bash scripts/check_export.sh --self-test      plants each violation and expects a failure
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLACEHOLDER_TEAM="0000000000"

# Prints one line per violation in the preset file given as $1.
violations() {
	local file="$1"
	[ -s "$file" ] || { echo "no preset file at $file"; return; }
	grep -q '^platform="iOS"' "$file" || echo "no iOS preset"
	local team
	team="$(sed -n 's/^application\/app_store_team_id="\(.*\)"/\1/p' "$file")"
	if [ -n "$team" ] && [ "$team" != "$PLACEHOLDER_TEAM" ]; then echo "a real Apple team id is committed"; fi
	grep -qE '^(provisioning_profile_uuid_|code_sign_identity_|application/provisioning_profile)[a-z_]*="[^"]+"' "$file" \
		&& echo "a provisioning profile or signing identity is committed"
	grep -qE '^capabilities/(access_wifi|push_notifications)=true' "$file" && echo "a network capability is on"
	grep -qE '^application/bundle_identifier="[a-z0-9]+(\.[a-z0-9_-]+)+"' "$file" || echo "the bundle id is missing or malformed"
	grep -q '^exclude_filter=.*tests/\*' "$file" || echo "tests are not excluded from the export"
	grep -q '^exclude_filter=.*addons/gut' "$file" || echo "the test framework is not excluded from the export"
	grep -E '^application/(short_)?version=' "$file" | grep -qv '"0\.0\.0"' && echo "a version is baked in (the tag is the version)"
	return 0
}

if [ "${1:-}" = "--self-test" ]; then
	good="$ROOT/game/export_presets.cfg"
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	status=0
	[ -z "$(violations "$good")" ] && echo "  PASS the real preset is clean" || { echo "  FAIL the real preset is not clean"; status=1; }
	plant() { # description, sed expression
		sed "$2" "$good" > "$tmp"
		if [ -n "$(violations "$tmp")" ]; then echo "  PASS planted: $1"; else echo "  FAIL not caught: $1"; status=1; fi
	}
	plant "real team id" 's/^application\/app_store_team_id=.*/application\/app_store_team_id="ABCDE12345"/'
	plant "provisioning profile" '$a\
provisioning_profile_uuid_release="1234-abcd"'
	plant "wifi capability" 's/^capabilities\/access_wifi=false/capabilities\/access_wifi=true/'
	plant "bad bundle id" 's/^application\/bundle_identifier=.*/application\/bundle_identifier="Quiqui"/'
	plant "tests not excluded" 's/tests\/\*, //'
	plant "version baked in" 's/^application\/version=.*/application\/version="1.0.0"/'
	exit "$status"
fi

file="${1:-$ROOT/game/export_presets.cfg}"
out="$(violations "$file")"
secrets="$(git -C "$ROOT" ls-files | grep -iE '\.(p12|cer|mobileprovision|p8|keystore|jks)$' || true)"
if [ -n "$secrets" ]; then out="${out:+$out
}signing material is tracked: $secrets"; fi
if [ -n "$out" ]; then
	echo "$out" | sed 's/^/  FAIL export: /'
	exit 1
fi
echo "  PASS export preset is clean (no signing data, no network, tests excluded)"
