---
type: agent-role
title: "System Architect - Pattern and Architecture Gate"
description: "Owns the pattern library, Stage 1 PR review, ADRs, and schema-change approval; can block work."
resource: ".claude/agents/system-architect.md"
tags: [methodology, agents, gates, patterns, security, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/system-architect.toml"
  - "agent_providers/claude_code/prompts/system-architect.md"
verified_against: "fd0fc6a"
---

# System Architect - Pattern and Architecture Gate

The first of two review stages, and the custodian of everything the other roles copy from.

## Overview

The role validates patterns, makes architectural decisions, and prevents conflicting approaches
from entering the codebase — the largest role definition in the team by some margin. It holds full
file-editing tools but no Linear MCP grant, so it reviews and authors rather than administers
tickets. Every PR passes its Stage 1 review before an ARCHitect-in-CLI Stage 2 review, and it may
block progression until violations are fixed.

## Responsibilities

- Owns the pattern library and whether a proposed new pattern is warranted.
- Owns Stage 1 PR review against a fixed checklist: RLS context enforced with no direct ORM calls,
  auth present, types valid, error handling, no conflicting patterns, SOLID, performance.
- Owns architecture decision records, the integration map, governance and ownership docs, the
  disaster recovery playbook, and approval of production migration plans.
- Does not merge PRs, skip pattern validation on trivial-looking changes, or approve work
  containing RLS violations.

## Skills & SOPs

- [pattern-discovery](../skills/pattern-discovery.md) — the search protocol it polices.
- [rls-patterns](../skills/rls-patterns.md) — the enforcement it checks for at review.
- [Three-Stage PR Review](../methodology/three-stage-pr-review.md) — where Stage 1 sits.

## Handoffs

- **Receives from** [BSA](bsa.md), [RTE](rte.md), and [TDM](tdm.md) as review or escalation.
- **Hands off to** the [ARCHitect-in-CLI](../knowledge/workflow/architect-in-cli-role.md) —
  exit state `Stage 1 Approved - Ready for ARCHitect`.
- **Approves** schema changes with the ARCHitect before [Data Engineer](data-engineer.md) migrates.

The provider mirror is stale: it drops the declared skills block, the Ownership Model, the output
location, the mandatory reading checklist and the whole Exit Protocol, so the exit state above does
not exist on that surface at all. It is one of only two roles whose provider copy does not also
downgrade the model.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — PR conventions and review expectations.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
