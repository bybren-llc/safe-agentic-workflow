---
type: domain
title: "Methodology Domain"
description: "The SAFe plus AI-DLC method: eleven roles, five blocking gates, and evidence as the currency of progress."
tags: [methodology, workflow, gates, process, agents]
timestamp: 2026-07-20
status: active
domain: methodology
verified_against: "a79c2bd"
---

# Methodology Domain

How work is supposed to move: who touches what, which gates clear it, and what proof it carries.

## Overview

Owns role boundaries, handoff states, gates, evidence, and cadence — all of it prose contract that
no shipped validator enforces, the most important fact about the domain. It stops at mechanism: how a
prompt reaches Claude versus Codex belongs to [Providers](providers.md); what CI asserts belongs to
[Operations](operations.md); the pattern library it says to search, to [Subsystems](subsystems.md).

## Members

- [vNext Workflow Contract](../methodology/vnext-workflow-contract.md) — the v1.4 spine and its
  CODE/COMMITS/PR/MERGE/EVIDENCE/GATE matrix.
- [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) — one name, two mechanisms: an AC/DoD
  precondition and an Andon-cord authority every agent holds.
- [Exit States](../methodology/exit-states.md) — handoff strings; 7 or 8 rows, sources disagree.
- [Three-Stage PR Review](../methodology/three-stage-pr-review.md) plus
  [Evidence-Based Delivery](../methodology/evidence-based-delivery.md) — the chain and its evidence.
- [Role Collapsing](../methodology/role-collapsing.md) — RTE may collapse; QAS and SecEng never do.

Framing: [SAFe x AI-DLC](../methodology/safe-ai-dlc.md) (a per-program opt-in; where adopted the
Bolt supplants the sprint, gates unchanged), [Round Table](../methodology/round-table-philosophy.md),
[Three-Layer Architecture](../methodology/three-layer-architecture.md), and
[Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md), whose two orderings
disagree on what to search first. Every `roles/` and `skills/` card is a member too; the gate
carriers are [BSA](../roles/bsa.md), [QAS](../roles/qas.md) and [RTE](../roles/rte.md).

## Key Flows

**Ticket to merge.** [BSA](../roles/bsa.md) writes AC/DoD into a spec; an implementer checks the
[Stop-the-Line Gate](../methodology/stop-the-line-gate.md), halting if AC/DoD is missing, else emits
`Ready for QAS`. [QAS](../roles/qas.md) posts evidence and sets `Approved for RTE`;
[RTE](../roles/rte.md) opens the PR; the [three stages](../methodology/three-stage-pr-review.md) run.

**A halt.** An agent hitting one of the five authority categories states the concern, proposes an
alternative, tags `#PATH_DECISION`, comments on the ticket. No tooling participates.

**Bolt cadence.** Inside a program that adopts the [SAFe x AI-DLC](../methodology/safe-ai-dlc.md)
fusion, the sprint gives way to a Bolt that exits on evidence, not a date. Adopting it is a
per-program choice — the standard sprint path stays valid — and gates are unmoved either way.

## Citations

- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — v1.4, version anchor for the contract.
- [SAFE-AI-DLC-METHODOLOGY.md](../../guides/SAFE-AI-DLC-METHODOLOGY.md) — the Bolt cadence.
