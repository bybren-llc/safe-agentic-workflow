---
type: process
title: "Exit States and Handoff Statements"
description: "Each agent role terminates with an explicit named exit state plus a handoff statement, forming the chain of custody between roles."
tags: [methodology, workflow, process, agents, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CONTRIBUTING.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - "docs/onboarding/ENGINEER-DAILY-WORKFLOW.md"
  - "docs/onboarding/QAS-DAILY-WORKFLOW.md"
verified_against: "fd0fc6a"
---

# Exit States and Handoff Statements

No agent finishes by going quiet. Each role terminates in a named exit state and emits a handoff
statement to the next role, so custody is explicitly transferred rather than assumed. It prevents
the silent drop — work that stalls because nobody knows it is theirs.

## Overview

Exit states run alongside the Linear swimlane (Backlog, Ready, In Progress, Testing, Ready for
Review, Done) and are declared once a role's own gate has passed. They are prose contract only: no
validator, hook, or Linear automation checks that a handoff string was emitted. The states belong
to the [vNext Workflow Contract](vnext-workflow-contract.md) and are duplicated verbatim across
five files with no single source of truth marked — a standing drift risk.

## Flow

- **Implementers exit to QAS.** BE-Developer, FE-Developer, and Data-Engineer all end at
  `Ready for QAS`, with a handoff naming the ticket, confirming validation passes and AC/DoD met.
- **QAS exits to RTE.** `Approved for RTE`, carrying the evidence block described in
  [Evidence-Based Delivery](evidence-based-delivery.md).
- **RTE exits to the human.** `Ready for HITL Review`, once the PR exists and CI is green.
- **The review stages exit in turn.** System Architect at `Stage 1 Approved - Ready for
  ARCHitect`, then ARCHitect-CLI at `Stage 2 Approved - Ready for HITL`.
- **HITL terminates the chain.** `MERGED` — the only terminal state, and the only merge authority.

The ARCHitect-CLI row appears only in README Appendix A.1; the four other copies omit it, so the
canonical set is ambiguous between seven and eight states. Appendix A.1 is the fuller listing.

## Roles Involved

- **Implementers (BE, FE, Data-Engineer)** — own the first handoff; must not self-certify past it.
- **[QAS](../roles/qas.md)** — owns the quality gate and the evidence attached to its exit state.
- **[RTE](../roles/rte.md)** — owns PR creation and the handoff into human review.
- **[System Architect](../roles/system-architect.md)** — owns the Stage 1 exit state; HITL alone
  owns MERGED, and no agent may issue it.

## Citations

- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the standard operating procedure copy.
- [README.md](../../../README.md) — Appendix A.1, the eight-row listing.
