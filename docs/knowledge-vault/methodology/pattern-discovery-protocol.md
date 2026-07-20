---
type: process
title: "Pattern Discovery Protocol"
description: "Mandatory search of the patterns library, specs, codebase, and session history before writing any new implementation."
tags: [methodology, patterns, process, workflow, skills]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "AGENTS.md"
  - "CLAUDE.md"
  - "README.md"
  - "patterns_library/README.md"
  - ".claude/skills/pattern-discovery/SKILL.md"
  - ".claude/commands/search-pattern.md"
  - "docs/onboarding/ENGINEER-DAILY-WORKFLOW.md"
  - "docs/guides/AGENT_TEAM_GUIDE.md"
verified_against: "a79c2bd"
---

# Pattern Discovery Protocol

*Search First, Reuse Always, Create Only When Necessary.* Before any feature is implemented, the
agent searches what already exists and gets architectural sign-off — preventing the fifth
slightly-different implementation of the same webhook handler.

## Overview

Labelled MANDATORY, it runs at the start of implementation, before code. Two harness surfaces
reach it: the model-invoked [pattern-discovery skill](../skills/pattern-discovery.md) and
the user-invoked [/search-pattern](../commands/search-pattern.md) command. Enforcement stops there;
nothing rejects a commit that skipped it. The library holds 18 pattern files in seven categories.

## Flow

- **Search prior specifications.** AGENTS.md orders this first: look in `specs/` for a feature.
- **Search the pattern library.** CLAUDE.md orders this first instead; browse `patterns_library/`
  by category. See [Pattern Library](../subsystems/pattern-library.md).
- **Search the codebase and session history.** Prefer extending a shipped implementation; grep
  `~/.claude/todos/*.json`, a Claude-Code-only path with no Gemini, Codex, or Cursor equivalent.
- **Consult documentation.** Contribution rules, database docs, the security architecture.
- **Propose to the System Architect.** Approval comes *before* implementation — the gate without
  which the protocol is only a reading list.

Two discrepancies. AGENTS.md numbers its steps from zero, puts `specs/` first, and never names
`patterns_library/`, while CLAUDE.md puts the library first — both labelled MANDATORY. AGENTS.md
cites `docs/security/SECURITY_FIRST_ARCHITECTURE.md`, which exists; CONTRIBUTING.md cites it under
`docs/guides/`, which does not exist on disk.

## Roles Involved

- **Implementers (BE, FE, Data-Engineer)** — run the search and cite what they found or ruled out.
- **[BSA](../roles/bsa.md)** — performs discovery during spec authoring, ahead of implementation.
- **[System Architect](../roles/system-architect.md)** — approves the chosen pattern, or rejects.

## Citations

- [AGENTS.md](../../../AGENTS.md) — the numbered protocol as the agents receive it.
