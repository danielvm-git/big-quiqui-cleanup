# Templates used by this game

Seven templates, all from build wave 1 of the QuiQui line. Each one is a TutoTOONS Builder template adapted to
our charter. Evidence: the scene-file pass over 13 Builder titles (1,801 scenes that use a template).
Raw counts: `specs/reference/tutotoons/builder-template-usage.json`.

Common to all: a miss returns the item, no timer ends a step, every valid touch gets a sound and a QuiQui reaction
in the same frame, and a hint (ghost hand) shows after a few seconds with no input.

## t20_drag_snap

| | |
|---|---|
| TutoTOONS | Template20. 147 scenes, in 13 of 13 titles |
| Gesture | Give to Receive |
| Params | `items`, `target`, `repeat` |
| Done when | every item has been delivered to the target |
| On miss | the item goes back to the tray with a soft sound |
| Here | put toys in the box, dishes on the rack |

## t23_erase

| | |
|---|---|
| TutoTOONS | Template23. 131 scenes, in 12 of 13 titles. An erase layer is present in every one |
| Gesture | Rub, clear mode |
| Params | `tool`, `layer`, `levels` |
| Done when | the cleared share of the layer reaches `threshold` (default proposed 0.9, tune by play) |
| On miss | not applicable, rubbing outside the layer does nothing |
| Here | wipe dust and stains, scrub the mirror |

## t21_touch_each

| | |
|---|---|
| TutoTOONS | Template21. 274 scenes, in 12 of 13 titles |
| Gesture | Tap, or a carried tool touched on each target |
| Params | `targets`, `mode` (`tap` or `tool`) |
| Done when | every target has been touched once |
| Rule | the TutoTOONS auto-end timer is dropped |
| Here | open curtains, switch lights, sweep each pile of leaves |

## t25_map

| | |
|---|---|
| TutoTOONS | Template25. 65 scenes, in 13 of 13 titles |
| Gesture | Tap on a door. Pan only if the map is wider than the screen |
| Params | `rooms` with their scene ids |
| State | a room shows a cloud while dirty and a sparkle when clean |
| Rule | a lock opens with play, never with payment |
| Here | the house map. It fits one screen, so Pan is not needed in S2 |

## t34_rub_reveal

| | |
|---|---|
| TutoTOONS | Template34. 121 scenes, in 12 of 13 titles |
| Gesture | Rub, reveal mode |
| Params | `tool`, `layers` |
| Done when | every layer has played its reveal |
| Here | before and after: rub to show the clean room |

## t32_reward

| | |
|---|---|
| TutoTOONS | Template32. 8 scenes, in 8 of 13 titles |
| Gesture | Tap to collect |
| Params | `coins`, `star`, `pose` |
| Done when | the reward is collected, then the save is written |
| Rule | the ad version (Template39, 54) does not exist here: the gift is free |

## t0_title

| | |
|---|---|
| TutoTOONS | Template0. 13 scenes, in 13 of 13 titles |
| Gesture | Tap the play button |
| Rule | a parent gate replaces the policy and subscription links. Its design is part of slice S4 |

## Not used here

`t22_play_beat`, `t3_skip_beat` and the other wave-1 and later templates belong to the other games.
Their evidence is weaker or they are not needed for tidying.
