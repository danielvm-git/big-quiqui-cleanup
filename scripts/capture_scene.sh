#!/usr/bin/env bash
# In-engine screenshots of the whole house. Read the PNGs: a green suite does not prove the screen is right.
#   bash scripts/capture_scene.sh house_map          (the argument names the output prefix)
#   QQ_SIZE=1536x2048 bash scripts/capture_scene.sh house_map
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${QQ_CAPTURE_DIR:-/tmp/qq_capture}"
NAME="${1:-house_map}"
mkdir -p "$OUT"
"${GODOT:-godot}" --path "$ROOT/game" --resolution "${QQ_SIZE:-1280x720}" -s res://tools/capture_scene.gd -- "$OUT/$NAME"
ls -1 "$OUT/${NAME}"_*.png
