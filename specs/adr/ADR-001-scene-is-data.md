# ADR-001: A scene is data run by one player

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

TutoTOONS repeats one architecture in the games we studied: a generic player runs scenes described as data, and
a small set of numbered templates does the interaction. The evidence pass covered 13 Builder titles and 1,801 scenes.
`big-quiqui-v2` took the opposite route: 17 scenes, each with its own script and builder, which made every feel
change a rewrite.

## Decision

A scene is a `SceneDef` resource. One player scene loads it and runs its steps. No scene has its own script.
Interaction shapes live in the core as templates. A new room costs art plus a data file.

## Consequences

- The core must offer enough templates for every room. Missing shapes are built in the core, not in the scene.
- Scene tests check data and template behavior, not node trees.
- Only two `.tscn` files exist: `boot.tscn` and the player.
