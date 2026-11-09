# quiqui_core

The shared core of the QuiQui games. Today it holds `core/fsm.gd`. The scene player, primitives and templates
arrive with slice S1 onward (see `specs/BACKLOG.md`).

**Boundary (ADR-002):** nothing in this folder may use a `res://` path outside `res://addons/quiqui_core/`
or reach an autoload through `/root/`. `scripts/check_core_boundary.sh` fails the preflight if it does.
