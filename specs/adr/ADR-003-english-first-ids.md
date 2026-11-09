# ADR-003: English-first ids, voice by key

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

The game shows no text during play, so the only things that change per language are the voice lines and a few words
in the parent area. Translating from an English base is easier.

## Decision

Code, file names, data keys and scene ids are English, in `snake_case`. Voice is referenced by key, for example
`vo.living_room.intro`, and the locale selects the file: `audio/voice/<locale>/living_room_intro.ogg`.
The first locale is `pt_BR`, recorded by the family. Parent-area text uses the engine translation tables with an
English base.

## Consequences

- Art and audio ported from `big-quiqui-v2` are renamed once, by script, when they are copied.
- A missing voice file for a locale is a gate failure, not a silent fallback.
