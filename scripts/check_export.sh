#!/usr/bin/env bash
# Export hygiene: nothing secret and nothing risky in the iOS export preset or the repository.
#   bash scripts/check_export.sh [preset-file]    default: game/export_presets.cfg
#   bash scripts/check_export.sh --self-test      plants each violation and expects a failure
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLACEHOLDER_TEAM="0000000000"

# Prints one line per violation in the preset file given as $1. Spaces around "=" are ignored.
violations() {
	local file="$1"
	[ -s "$file" ] || { echo "no preset file at $file"; return; }
	local norm
	norm="$(sed 's/^[[:space:]]*//; s/[[:space:]]*=[[:space:]]*/=/' "$file")"
	printf '%s\n' "$norm" | grep -q '^platform="iOS"' || echo "no iOS preset"
	printf '%s\n' "$norm" | grep -iE '(team_id|development_team)=' | grep -v -e '=""$' -e "=\"$PLACEHOLDER_TEAM\"\$" \
		| grep -q . && echo "a real Apple team id is committed"
	printf '%s\n' "$norm" | grep -iE '(provisioning_profile|code_sign_identity|signing_identity|certificate)[a-z_]*="[^"]+"' \
		| grep -q . && echo "a provisioning profile or signing identity is committed"
	printf '%s\n' "$norm" | grep -qE '^(capabilities|entitlements)/[a-z_]+=true' && echo "a capability or entitlement is on"
	printf '%s\n' "$norm" | grep -qE '^application/bundle_identifier="[a-z0-9]+(\.[a-z0-9-]+)+"$' \
		|| echo "the bundle id is missing or malformed"
	printf '%s\n' "$norm" | grep -q '^exclude_filter=.*tests/\*' || echo "tests are not excluded from the export"
	printf '%s\n' "$norm" | grep -q '^exclude_filter=.*addons/gut' || echo "the test framework is not excluded from the export"
	local versions
	versions="$(printf '%s\n' "$norm" | grep -E '^application/(short_)?version=')"
	[ -n "$versions" ] || echo "the version keys are missing"
	printf '%s\n' "$versions" | grep -v '="0\.0\.0"$' | grep -q . && echo "a version is baked in (the tag is the version)"
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
application/provisioning_profile_specifier_debug="1234-abcd"'
	plant "signing identity" '$a\
application/code_sign_identity_release="iPhone Distribution"'
	plant "team id with spaces" '$a\
application/app_store_team_id = "ABCDE12345"'
	plant "development team" '$a\
DEVELOPMENT_TEAM="ABCDE12345"'
	plant "entitlement" '$a\
entitlements/push_notifications=true'
	plant "wifi capability" 's/^capabilities\/access_wifi=false/capabilities\/access_wifi=true/'
	plant "bad bundle id" 's/^application\/bundle_identifier=.*/application\/bundle_identifier="Quiqui"/'
	plant "underscore bundle id" 's/^application\/bundle_identifier=.*/application\/bundle_identifier="com.a.b_c!"/'
	plant "tests not excluded" 's/tests\/\*, //'
	plant "version baked in" 's/^application\/version=.*/application\/version="1.0.0"/'
	exit "$status"
fi

file="${1:-$ROOT/game/export_presets.cfg}"
out="$(violations "$file")"
secrets="$(git -C "$ROOT" ls-files | grep -iE '\.(p12|pfx|cer|pem|key|mobileprovision|provisionprofile|p8|keystore|jks|certSigningRequest|mobileconfig)$|(^|/)\.env$|\.keychain' || true)"
if [ -n "$secrets" ]; then out="${out:+$out
}signing material is tracked: $secrets"; fi
if [ -n "$out" ]; then
	echo "$out" | sed 's/^/  FAIL export: /'
	exit 1
fi
echo "  PASS export preset is clean (no signing data, no network, tests excluded)"
