# QuiQui Cleanup

Game 1 of the QuiQui line. A child (ages 4 to 7) tidies a messy house, room by room, and watches it sparkle.
Ad-free, offline, no reading needed, voice recorded by the family.

**Status:** skeleton (slice S0). The project boots and all gates pass. It is not playable yet.

## Why this repository exists

`big-quiqui-v2` grew by refactoring and became hard to follow. This repository starts clean, with its own specs
and one rule: nothing is ported from v2 unless a spec line asks for it and a test covers it.
Cleanup is the simplest of the nine planned games, so it builds the shared core (`addons/quiqui_core`) with the least risk.

## Commands

| Action | Command |
|---|---|
| All gates (lint, format, typing, tests, core boundary, specs) | `bash scripts/preflight.sh` |
| Fast gates for the pre-commit hook (no tests) | `bash scripts/preflight.sh --fast` |
| Run the game | `godot --path game` |
| Run the tests only | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gexit` |
| First-time setup | `bash scripts/setup.sh` |

Needs Godot 4.7 and `gdtoolkit` (`pip install -r requirements-dev.txt`).

## Where things are

| Path | What |
|---|---|
| `specs/VISION.md` | What the game is and is not |
| `specs/ARCHITECTURE.md` | Layers, rules, data model |
| `specs/TEMPLATES.md` | The seven templates this game uses |
| `specs/BACKLOG.md` | Slices S0 to S5, each ends playable |
| `specs/adr/` | Decisions, one file each |
| `specs/product/` | The plan for this game and for the whole line |
| `specs/reference/tutotoons/` | The reverse-engineering evidence behind the design |
| `game/addons/quiqui_core/` | The core: no code here may depend on the game |
| `game/` | The Godot project |
