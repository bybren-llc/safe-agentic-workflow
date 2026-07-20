---
type: process
title: "Stop-the-Line Gate and Authority"
description: "Two distinct mechanisms share the name: the mandatory AC/DoD precondition gate, and every agent's Andon-cord authority to halt work."
tags: [methodology, gates, process, workflow, security]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CONTRIBUTING.md"
  - "docs/guides/ROUND-TABLE-PHILOSOPHY.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - ".claude/commands/start-work.md"
verified_against: "a79c2bd"
---

# Stop-the-Line Gate and Authority

Two different mechanisms travel under this one name, and conflating them causes real confusion. One
is a precondition gate implementation agents must clear before writing code. The other is a
standing authority any team member may exercise at any moment. Read them separately.

## Overview

The **gate** is a check on the ticket: does it carry acceptance criteria and a Definition of Done?
Yes proceeds; no is a FULL STOP routing back to BSA or POPM. Its owner is listed as *Implementer*
and it is marked blocking. The contract is explicit that the implementer is **not** responsible for
inventing missing AC or DoD — writing them itself would defeat the gate. The **authority** is the
Andon cord, borrowed from Toyota: every member, human or AI, may halt progress, which is what makes
[Round Table Philosophy](round-table-philosophy.md) more than manners.

## Flow

- **Check the ticket first.** If AC/DoD are absent, full stop and hand back to `@bsa`.
- **Pull the cord for any of five concerns.** Architectural integrity, security, maintainability,
  performance implications, or scalability. Nothing else is listed.
- **Justify it in four steps.** Explain the concern with specifics, propose an alternative,
  document it via an ADR or `#PATH_DECISION` tag, and comment on the Linear ticket.
- **Expect four more gates downstream.** Five blocking gates are named: Stop-the-Line
  (Implementer), QAS Gate, Stage 1 Review (System Architect), Stage 2 Review (ARCHitect-CLI), and
  HITL Merge — the last three covered by [Three-Stage PR Review](three-stage-pr-review.md).

Enforcement is prompt-level only: the gate text ships inside the
[/start-work](../commands/start-work.md) command, and no hook, script, or CI check verifies it.

## Roles Involved

- **Implementers (BE, FE, Data-Engineer)** — own the gate; must refuse work that fails it.
- **[BSA](../roles/bsa.md)** — receives the routed ticket and authors the missing AC/DoD.
- **Every role** — holds the authority; none may be overruled without a recorded decision. HITL
  is the final blocking gate and sole merge authority.

## Citations

- [ROUND-TABLE-PHILOSOPHY.md](../../guides/ROUND-TABLE-PHILOSOPHY.md) — the authority definition.
- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the mandatory gate steps and QAS gate
  owner role. The five-gate table itself lives in README's Gate Quick Reference, not the SOP.
