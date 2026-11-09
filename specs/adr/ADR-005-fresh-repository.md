# ADR-005: A fresh repository, ports only with a spec and a test

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

`big-quiqui-v2` is green and unplayable. Its restart onto the player model was being done as a refactor, with the old
scenes kept alive during a rename, a migration and a removal commit. That made the work slow and hard to follow.

## Decision

Start a new repository per game, each with its own specs. `big-quiqui-v2` is frozen as a reference: its e12 and e13
work is the prototype of the player and the templates.

A file moves from v2 into a new repository only when a spec line asks for it and a test covers it. The planned ports
are listed in `specs/BACKLOG.md`. Everything else stays in v2.

## Consequences

- No history of v2 is carried over, only the code that earns its place.
- The first slice must prove the player on one room before anything else is built.
