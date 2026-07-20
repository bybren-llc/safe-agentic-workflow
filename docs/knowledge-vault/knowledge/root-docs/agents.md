---
type: guide
title: "AGENTS.md"
description: "SSoT stub: the agent-team quick reference, and the file Codex CLI reads natively as its instruction surface."
tags: [ssot-stub, agents, workflow, providers]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "AGENTS.md"
verified_against: "0c26121"
---

# AGENTS.md

This is a map-card. `AGENTS.md` at the repository root is the source of truth: 449 lines serving
two audiences at once — a human quick reference, and the file `.codex/` consumes natively, since
the README describes [Codex CLI](../../providers/codex.md) as the provider that "reads AGENTS.md".
That dual purpose is why edits here have a blast radius beyond documentation.

## What It Is Authoritative For

The when-to-use-which-agent table, with success criteria and primary tools per role; the
auto-loaded skills trigger table; success validation commands per discipline; the pattern discovery
protocol as agents run it; invocation examples in both direct-mention and Task-tool form; and the
agent file index. It also restates exit states, the gate table, and role collapsing, deferring to
[Exit States](../../methodology/exit-states.md) and
[Role Collapsing](../../methodology/role-collapsing.md) as the authorities on those.

Read it when deciding which role to invoke and how, or when checking which skill fires on which
trigger. `SECURITY.md` lists "Agent definitions in AGENTS.md" as in scope for security reporting,
so it is a file with a disclosure path attached.

## Two Documented Drifts

DOC DRIFT: its auto-loaded skills table lists 11 skills while `.claude/skills/` holds 20. The
directory is the real inventory; the table is stale and undercounts by nine.

DOC DRIFT: its pattern discovery protocol starts at `specs/` and never names `patterns_library/`,
which contradicts the ordering [CLAUDE.md](claude-md.md) gives for the same protocol that both
files mark MANDATORY. Neither document is verifiable as the intended order from its own text; see
[Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md) for the reconciliation
and treat the divergence as unresolved until it is.

## Next

- [CLAUDE.md](claude-md.md) — the Claude Code counterpart, auto-loaded rather than read.
- [Round Table Philosophy](../../methodology/round-table-philosophy.md) — the model the roster
  assumes.

## Citations

- [AGENTS.md](../../../../AGENTS.md) — the full agent quick reference.
