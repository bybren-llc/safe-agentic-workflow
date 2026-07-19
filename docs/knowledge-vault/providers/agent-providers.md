---
type: architecture
title: "agent_providers Legacy Mirror"
description: "The pre-dotfile provider directory: an Augment starter kit plus a diverged, unsynced mirror of the Claude Code harness."
tags: [providers, sync, agents, ssot-stub]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
  - "agent_providers/claude_code/prompts"
  - "agent_providers/claude_code/permissions/settings.template.json"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# agent_providers Legacy Mirror

Two subtrees under one directory the sync engine does not know about. `augment/` is a real starter
kit for a second tool; `claude_code/` is a stale copy of `.claude/` that silently drops a gate.

## Overview

`augment/` holds a workflow guide, `instructions.md`, and six rule files — four of them 4-byte
`---` stubs. `claude_code/` holds three hooks, a permissions template, and eleven prompts whose
filenames match `.claude/agents/` exactly. It is a mirror, and it has diverged: ten of eleven
prompts now differ from their originals, only `bsa.md` still matching.

## Design

- `augment/` — starter kit, framed against the Claude "golden path"; `claude_code/` hooks are
  byte-identical to `.claude/hooks/`.
- `claude_code/prompts/be-developer.md` — the divergence that matters. `.claude/` sets `model: opus`;
  the mirror sets `model: sonnet` and drops 69 lines — the Precondition (Stop-the-Line Gate) section,
  the You Own / You Must / You Must NOT ownership model, Available Skills, and Exit Protocol — losing
  [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) authority without saying so.
- `claude_code/permissions/settings.template.json` — inverted against `.claude/`, neither a
  superset: 84 `permissions.allow` entries with an empty deny, embedding `DATABASE_URL`
  strings with `{{DB_USER}}` / `{{DB_PASSWORD}}` / `{{DB_NAME}}` tokens and permitting
  `prisma db push --force-reset`, which root `CLAUDE.md` forbids. `.claude/settings.template.json`
  leaves permissions a `_comment` placeholder but adds `teammateMode` and agent-teams env keys.
- Not synced — absent from the `sync_scope` list in `.harness-manifest.yml`.

**Doc drift.** Root `CLAUDE.md` lists `agent_providers/` as "Agent configurations" peer to
`.claude/`, a parity disk does not support. `USER-JOURNEY-VALIDATION-REPORT.md` flags the duplicate
agent files; `REORGANIZATION-EXECUTION-SUMMARY.md` says the prompts directory holds five, not 11.

**Open question.** Whether the tree is deprecated is unknown — no DEPRECATED marker, README, or ADR.

## Related Concepts

- [Claude Code Provider Surface](claude-code.md) — the live surface this tree mirrors.
- [Sync Scope](../sync/sync-scope.md) — the domain list that omits this directory.

## Citations

- [AUGMENT_WORKFLOW_GUIDE.md](../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) — setup.
- [CLAUDE.md](../../../CLAUDE.md) — the structure block claiming parity.
