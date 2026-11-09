# Architecture

## Layers

```
L4  Game        game/scripts, game/assets          hub, dirt layers, room meter, helpers
L3  Scene data  game/data/scenes/*.tres            one SceneDef per scene, no code
L2  Templates   addons/quiqui_core/templates       t20_drag_snap, t23_erase, ...
L1  Primitives  addons/quiqui_core/primitives      Give->Receive, Rub, Tap, Pan, Reactions, Hint layer
L0  Services    addons/quiqui_core/core            Fsm, ScenePlayer, StepRunner
```

L0 to L2 are the core. Each layer only uses the one below it. A template never knows which game it runs in.

## Rules

| # | Rule | Enforced by |
|---|---|---|
| R1 | A scene is a `SceneDef` resource run by the one player scene. No per-scene scripts. | review, ADR-001 |
| R2 | The core depends on nothing outside itself: no `res://` path outside `addons/quiqui_core`, no `/root/` access. | `scripts/check_core_boundary.sh` |
| R3 | Every state machine is an `Fsm` table. | review |
| R4 | Strict typing. | `game/tools/type_gate.gd` |
| R5 | Only two `.tscn` files exist: `boot.tscn` and the player. | review |
| R6 | Ids, files and data keys are English. | ADR-003 |
| R7 | Touch handlers drop synthesized mouse events (`device == -1`). | tests |
| R8 | A miss returns the item. No timer ends a step. | template tests |

## Data model (to be fixed in slice S1)

```
SceneDef   id, background, music, intro_voice, quiqui_pose, steps: Array[StepDef], reward, next
StepDef    template (id), params (Dictionary), on_hit: Array[Reaction], on_miss: Array[Reaction]
Reaction   kind (pose | sfx | voice | fx | swap | coins | wait), value
```

Both are typed `Resource` classes, editable in the inspector. Navigation is by scene id: the scene player loads
`data/scenes/<id>.tres`, runs its steps in order, then goes to `next`.

## The scene player

An `Fsm` with the states `LOAD, INTRO, STEP, STEP_DONE, OUTRO, EXIT`. In `STEP` the current template runs one
loop: hint, gesture, test, reaction. The Home button leaves from any state with no penalty. No step has a time limit.

## Folders

```
game/addons/quiqui_core/   the core (the only code another game can reuse)
game/addons/gut/           vendored test framework, never edited
game/scripts/              game code (L4)
game/data/scenes/          scene data (L3)
game/scenes/               boot.tscn and the player scene
game/tests/                unit and integration tests, helpers
game/tools/                type gate and other dev scripts
scripts/                   preflight and repository scripts
specs/                     this documentation
```

## Testing

GUT for unit and integration tests. Each template has a written rule, a unit test and one scene that uses it.
A gate that cannot fail is not a gate: the core boundary check has a self-test that must fail on a planted violation.

## Porting from big-quiqui-v2

A file is ported only when a spec line asks for it and a test covers it. The list of planned ports lives in
`specs/BACKLOG.md`. Anything not on that list stays in v2.
