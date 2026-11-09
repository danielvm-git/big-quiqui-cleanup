# QuiQui Cleanup: agent rules

Read first: `specs/VISION.md`, `specs/ARCHITECTURE.md`, `specs/BACKLOG.md`. Work on one slice at a time.

## Purpose

A child tidies a messy house, room by room. Every gesture gets an instant answer. No text, no timers, no ads.
This game also builds the shared core of the QuiQui line (`game/addons/quiqui_core`).

## Commands

| Action | Command |
|---|---|
| All gates | `bash scripts/preflight.sh` |
| Fast gates (pre-commit) | `bash scripts/preflight.sh --fast` |
| Run | `godot --path game` |
| Tests only | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gexit` |

Godot 4.7, GDScript, GUT 9.6 (vendored, never edit `game/addons/gut`), gdtoolkit for lint and format.

## Rules

1. **A scene is data.** One player scene runs `SceneDef` resources. No per-scene scripts (ADR-001).
2. **The core never depends on the game.** Nothing under `game/addons/quiqui_core` may use a `res://` path outside itself or `/root/` autoloads. `scripts/check_core_boundary.sh` enforces it (ADR-002).
3. **English ids everywhere.** Code, files, data keys, scene ids. Voice is referenced by key (ADR-003).
4. **Charter.** Offline, no ads, no telemetry, no text during play, no punishment, no timer that ends a step (ADR-004).
5. **Every state machine is an `Fsm` table.** No clusters of boolean flags.
6. **Strict typing** on every variable, parameter and return value.
7. **Touch input** must ignore synthesized mouse events (`event is InputEventMouse and event.device == -1`).
8. **Port from `big-quiqui-v2` only with a spec line and a test** (ADR-005). Never copy a file because it exists.
9. **Size bars:** 300 lines per file, 20 lines per function.

## Never

- Network calls, ads, telemetry, accounts, a store.
- Pure black (`#000000`) outlines in art.
- Editing vendored code (`game/addons/gut`).
- Committing secrets or signing material.
- Declaring a slice done without showing the gate output.

## Commits

Conventional Commits, subject at most 72 characters, no AI attribution lines. Hooks:
`git config core.hooksPath .githooks` (done by `scripts/setup.sh`). Work on a branch, never directly on `main`.
