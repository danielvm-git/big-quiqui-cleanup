# ADR-004: The charter

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

The audience is 4 to 7 years old and cannot read. The product is a promise to parents: ad-free and offline.
Several TutoTOONS templates carry lives, timers, ads and screen shake. We copy their shapes, not those parts.

## Decision

1. No network call, no ads, no telemetry, no store, no account.
2. No text during play. Every prompt is a picture plus a voice or a sound.
3. No punishment: no lives, no game over, no timer that ends a step. A miss returns the item.
4. Every valid touch gets a sound and a reaction in the same frame.
5. A hint (ghost hand) appears after a few seconds with no input.

Templates adapted from TutoTOONS drop `DecreaseLife`, `TimeOut`, `AddAutoEndTimer`, `ShowAd` and screen shake.

## Consequences

Each template spec states which part of the original it drops. A step ends on the child's effort, never on a clock.
