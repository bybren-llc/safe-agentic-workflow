---
type: sop
title: "Agent Workflow SOP v1.4"
description: "SSoT stub: authoritative procedure for the four agent invocation methods plus the vNext contract, gates, and role collapsing."
resource: "docs/sop/AGENT_WORKFLOW_SOP.md"
tags: [ssot-stub, workflow, process, gates, orchestration]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
verified_against: "fd0fc6a"
---

# Agent Workflow SOP v1.4

## Overview

576 lines, and the document that `README.md`, `AGENTS.md`, and `CONTRIBUTING.md` all defer to for
"complete details" — which makes it the tiebreaker whenever their shorter tables disagree. It is
authoritative for the four invocation methods (direct specialist, TDM orchestration,
ARCHitect-in-CLI orchestration, and System Architect review for complex code), the workflow
selection guide, the quality gates attached to each method, the escalation paths, and the success
metrics. It also restates the vNext contract: exit states, the stop-the-line gate, QAS as gate
owner, RTE as PR shepherd, three-stage PR review, and role-collapsing guidelines. It carries its
own Version History section, which makes it the version anchor for the contract as a whole.

## When It Applies

- When choosing how to invoke agents for a task — the selection guide is the entry point, not the
  method sections.
- When a shorter table in `AGENTS.md` or `CONTRIBUTING.md` conflicts with anything here.
- When a gate outcome or escalation path is disputed mid-workflow.
- When establishing which contract version a piece of work was executed under.
- It does NOT govern how an individual agent is configured — that is
  [Agent Configuration SOP](agent-configuration-sop.md) — and it does not replace the PR-time
  judgment checklist, which is [Pre-PR Validation Checklist](pre-pr-validation-checklist.md).

## Affected Concepts

- [vNext Workflow Contract](../../methodology/vnext-workflow-contract.md) — this SOP is its
  version anchor; the contract's canonical diagrams live in `README.md`.
- [Exit States](../../methodology/exit-states.md) and
  [Stop-the-Line Gate](../../methodology/stop-the-line-gate.md) — restated here authoritatively
  where other documents only summarize them.
- [Role Collapsing](../../methodology/role-collapsing.md) — the guidelines constraining when one
  agent may hold two roles.
- [Three-Stage PR Review](../../methodology/three-stage-pr-review.md) — the review shape this SOP
  requires of the RTE as PR shepherd.
- [TDM Agent Assignment Matrix](../workflow/tdm-agent-assignment-matrix.md) and
  [ARCHitect-in-CLI Role](../workflow/architect-in-cli-role.md) — the two orchestration methods,
  each obliged to follow the gates defined here.

## Citations

- [AGENT_WORKFLOW_SOP.md](../../../sop/AGENT_WORKFLOW_SOP.md) — the authoritative procedure;
  Version 1.4, last updated 2025-12-23, ticket refs {{TICKET_PREFIX}}-497 and -499.
