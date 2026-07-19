---
type: process
title: "TDM Agent Assignment Matrix (SSoT stub)"
description: "Pointer to the TDM matrix mapping work types to agent roles and specializations."
tags: [methodology, workflow, process, ssot-stub, agents, orchestration]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md"
verified_against: "fd0fc6a"
---

# TDM Agent Assignment Matrix (SSoT stub)

The 405-line source is the single source of truth for which agent takes which work item. It exists
to stop assignment becoming a matter of whoever is convenient — the wrong specialist on a story is
the failure it prevents. This concept is a map-card; the matrix itself stays in the source.

## Overview

The document opens with Agent Roster and Specializations, then mandatory System Architect review
triggers, an assignment decision tree, the vNext contract exit states, common assignment patterns,
quality gates, escalation paths, success metrics, and version history. It is also surfaced to
agents through the [agent-coordination skill](../../skills/agent-coordination.md), which is the
practical entry point during a session. Enforcement is by convention and review; no hook checks an
assignment against the matrix. Several headings carry unsubstituted `{{TICKET_PREFIX}}`
placeholders.

## Flow

- **Classify the work item.** Identify the type of work before naming an owner; the decision tree
  keys off work type, not availability.
- **Match to a specialization.** The agent roster maps each role to what it is competent to accept.
- **Check the mandatory review triggers.** Certain work types require System Architect review
  before implementation. The source marks these MANDATORY; they are not discretionary.
- **Assign and hand off.** The receiving role owns the item from that point.
- **Report an exit state.** Work terminates in one of the vNext contract exit states rather than
  trailing off — see [Exit States](../../methodology/exit-states.md).
- **Escalate on block.** The escalation paths section defines where a blocked item goes rather
  than who to ask.

## Roles Involved

- **[TDM](../../roles/tdm.md)** — owns the assignment decision and the escalation when work blocks.
- **[System Architect](../../roles/system-architect.md)** — accountable for the mandatory review
  on triggered work types, before implementation begins.
- **Receiving specialist role** — accountable for the item once assigned, including reporting its
  exit state.

## Citations

- [TDM Agent Assignment Matrix](../../../workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md) — the
  authoritative roster, decision tree, and review triggers.
- [vNext Workflow Contract](../../methodology/vnext-workflow-contract.md) — the contract whose
  exit states the matrix reports against.
