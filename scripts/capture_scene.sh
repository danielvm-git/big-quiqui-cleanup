#!/usr/bin/env bash
# In-engine screenshots of a scene. Read the PNGs: a green suite does not prove the screen is right.
#   bash scripts/capture_scene.sh living_room
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${QQ_CAPTURE_DIR:-/tmp/qq_capture}"
mkdir -p "$OUT"
"${GODOT:-godot}" --path "$ROOT/game" --resolution 1280x720 -s res://tools/capture_scene.gd -- "${1:-living_room}" "$OUT/${1:-living_room}"
ls -1 "$OUT"/"${1:-living_room}"_*.png
