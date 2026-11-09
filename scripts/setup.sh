#!/usr/bin/env bash
# First-time setup: development tools and the commit hooks.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v godot > /dev/null || { echo "godot 4.7 is not on PATH"; exit 1; }
python3 -m pip install --quiet -r requirements-dev.txt
git config core.hooksPath .githooks
echo "setup done: gdtoolkit installed, hooks enabled. Run: bash scripts/preflight.sh"
