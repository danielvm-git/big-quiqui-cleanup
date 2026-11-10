# Backlog

Slices, in order. Each one ends with something that runs. Update the status as slices finish.

| Slice | Goal | Done when | Status |
|---|---|---|---|
| S0 | Skeleton and gates | The project boots, `Fsm` lives in the core, preflight passes, the core boundary check has a self-test | done |
| S1 | First loop: the living room | `SceneDef`, `StepDef`, the scene player, `t23_erase`, `t20_drag_snap`, reactions, hint and gentle miss. A child cleans the room unaided and asks to play again | done |
| S2 | The house | `t25_map` hub, `t21_touch_each`, the other four rooms as data, two dirt levels, the room meter | done |
| S3 | Reward and save | `t32_reward`, atomic save, stars and coins | done |
| S4 | Title and polish | `t0_title` with the parent gate, `t34_rub_reveal` for before and after, recorded voice, final art | code done (e04); recorded voice and final art still need people |
| S5 | Build and release | CI on the central workflow, iOS export, version ladder | |

## Planned ports from big-quiqui-v2

Only these, each with its slice. Anything else stays in v2.

| What | Slice | Notes |
|---|---|---|
| `Fsm`, `FsmProbe` | S0 | done, rewritten without the diary dependency |
| `TouchSim`, `TestReset` | S1 | test helpers |
| `GeometryOracle` | S2 | layout checks on 4:3 and 16:9 |
| `SaveFile`, `ProgressManager` | S3 | atomic save, new schema |
| Art: 5 room backgrounds, sponge, towel, trash bag, toys, foam, bubble, drop and sparkle effects, hero rig | S1 and S2 | copied once by script with English names |
| Audio: effects and the music tracks that fit | S1 and S2 | same script |

## Open questions

1. Does the central CI template (`danielvm-git/.github`, Godot workflow) support a library, and submodule checkout? Needed in S5 and before the core is extracted.
2. Dirt art: which stains and levels, and who draws them.
3. The threshold of `t23_erase`: proposed 0.9, to be tuned in S1.
4. Voice lines per room: who records them and when.
