---
type: guide
title: "docs/patterns Redirect (SSoT stub)"
description: "Pointer to the stub that redirects docs/patterns to the active patterns_library directory."
tags: [ssot-stub, patterns]
timestamp: 2026-07-19
status: active
sources:
  - "docs/patterns/README.md"
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# docs/patterns Redirect (SSoT stub)

A map-card for `docs/patterns/README.md`: fourteen lines, the only file in its directory, and a
tombstone rather than documentation. Its value is negative — it tells you where patterns are not.

## What it says

The H1 is "Pattern Library Redirect" and the blockquote immediately below states that the active
pattern library has moved to `patterns_library/`, linked relatively. It names the pattern index
and the pattern-discovery skill as the two entry points, retains the directory for backward
compatibility, and instructs that no new patterns be added there.

## Why the card exists

An agent searching the docs tree for patterns will hit this directory first and, finding a README,
may reasonably stop. Knowing in advance that `docs/patterns/` holds no patterns saves the search.
This is consistent with [CLAUDE.md](../root-docs/claude-md.md), whose pattern discovery protocol
points at `patterns_library/` and never at `docs/patterns/`.

## Where the patterns actually are

The [Pattern Library](../../subsystems/pattern-library.md) concept covers the real directory, and
the [Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md) covers the
mandatory search-first step it supports. The
[pattern-discovery skill](../../skills/pattern-discovery.md) is the agent-facing door.

## Citations

- [docs/patterns/README.md](../../../patterns/README.md) — the redirect stub.
- `patterns_library/` — where the patterns live (directory, not linkable per the link rules).
