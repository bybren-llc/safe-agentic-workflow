---
type: process
title: "ARCHitect-in-CLI Role (SSoT stub)"
description: "Pointer to the role definition for the ARCHitect-in-CLI, the technical authority in the workflow."
tags: [methodology, workflow, process, ssot-stub, agents]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/ARCHITECT_IN_CLI_ROLE.md"
verified_against: "fd0fc6a"
---

# ARCHitect-in-CLI Role (SSoT stub)

The 514-line source is the single source of truth for the ARCHitect-in-CLI: the agent holding
technical authority over a working session, including the authority to halt it. This concept is a
map-card. Where an operating rule is disputed, the source document decides, not this page.

## Overview

The document opens with Role Definition and runs through core responsibilities, when to invoke the
System Architect, workflow patterns, orchestration best practices, quality gates, a retrospective,
success metrics, role-collapsing authority, related documentation, and version history. It defines
authority and scope in prose; nothing in the harness mechanically enforces it. Two sections carry
unsubstituted `{{TICKET_PREFIX}}` placeholders in their headings, so the retrospective and
role-collapsing tickets are not resolvable as written.

## Flow

- **Hold the session.** The ARCHitect-in-CLI owns technical direction for the work in front of it
  and is accountable for the decisions taken there, not merely consulted on them.
- **Escalate on trigger.** The source lists the conditions under which the System Architect must be
  invoked; those are triggers, not judgement calls.
- **Apply the workflow pattern.** Work follows one of the documented orchestration patterns rather
  than an improvised sequence.
- **Stop the line.** The gate: architectural or security risk halts work rather than filing a
  follow-up. See [Stop-the-Line Gate](../../methodology/stop-the-line-gate.md).
- **Pass the quality gates.** The document's Quality Gates section states what must hold before
  work proceeds out of the session.
- **Collapse roles where warranted.** Authority to run several roles in one agent is granted here;
  [Role Collapsing](../../methodology/role-collapsing.md) covers the mechanism.

## Roles Involved

- **ARCHitect-in-CLI** — owns technical direction and the halt decision for the session.
- **[System Architect](../../roles/system-architect.md)** — the escalation target on the documented
  triggers; owns the architectural call the ARCHitect defers.
- **[TDM](../../roles/tdm.md)** — owns assignment of work into the session; see
  [TDM Agent Assignment Matrix](tdm-agent-assignment-matrix.md).

## Citations

- [ARCHitect-in-CLI Role Documentation](../../../workflow/ARCHITECT_IN_CLI_ROLE.md) — the
  authoritative statement of the role's authority, responsibilities, and stop-the-line scope.
