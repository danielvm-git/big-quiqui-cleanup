# ADR-002: The core is a module with a hard boundary

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

Nine QuiQui games are planned. They need the same player, templates and test helpers. A shared library designed
before any game uses it tends to guess wrong. Two repositories from day one would slow the first game down.

## Decision

The core lives in `game/addons/quiqui_core/` inside this repository. Code there may use nothing outside the folder:
no `res://` path outside `addons/quiqui_core`, and no `/root/` autoload access. `scripts/check_core_boundary.sh`
enforces this in preflight and has a self-test that must fail on a planted violation.

When the second game (Care) starts, the folder is extracted to `big-quiqui-core` with `git subtree split`,
which keeps its history. Games then consume it as a git submodule pinned to a tag.

## Consequences

- Services the core needs from the game (save, audio, log) are passed in or exposed as signals, never reached by path.
- A template that only one game needs starts in that game and moves to the core when a second game needs it.
