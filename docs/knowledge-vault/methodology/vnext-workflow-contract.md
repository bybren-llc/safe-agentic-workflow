---
type: process
title: "vNext Workflow Contract"
description: "The v1.4 agent delivery contract: BSA spec, stop-the-line gate, implementers, QAS gate, RTE shepherd, three-stage review, HITL merge."
tags: [methodology, workflow, process, gates, agents]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CONTRIBUTING.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - "docs/workflow/WORKFLOW_MIGRATION_GUIDE.md"
  - "docs/workflow/WORKFLOW_COMPARISON.md"
  - "docs/workflow/ARCHITECT_IN_CLI_ROLE.md"
verified_against: "fd0fc6a"
---

# vNext Workflow Contract

The contract, at version 1.4, is the spine every other methodology concept hangs from: who may
touch what, in what order, and who is allowed to say a thing is done. It exists to stop the failure
where an agent writes code, reviews its own code, and merges it.

## Overview

Established by `{{TICKET_PREFIX}}-497` and amended by `-499` for role collapsing. Linear is the
declared system of record; evidence posts through the Linear MCP server's `create_comment`,
`update_issue`, and `list_comments`. The contract is documentation only — no script, hook, or CI
job enforces any exit state or gate. Two drift notes: README's Version History table ends at v1.3
while its header, CONTRIBUTING.md, AGENTS.md, and the SOP declare v1.4 (v1.4 is live), and its
"Source Document" link points into another repository, so that document is unverifiable here.

## Flow

- **Ticket.** The user or POPM creates the Linear issue.
- **Spec.** [BSA](../roles/bsa.md) defines acceptance criteria and Definition of Done, runs
  [Pattern Discovery](pattern-discovery-protocol.md), and writes the spec.
- **Gate.** The [Stop-the-Line Gate](stop-the-line-gate.md) refuses work whose ticket lacks AC/DoD.
- **Implement.** BE, FE, or Data-Engineer owns CODE and COMMITS, is denied PR and MERGE, and holds
  only Partial evidence ownership.
- **Validate.** [QAS](../roles/qas.md) owns EVIDENCE and GATE, denied code, commits, PR, and merge.
- **Shepherd.** [RTE](../roles/rte.md) owns PR alone; its commit rights cover metadata only.
- **Review and merge.** [Three-Stage PR Review](three-stage-pr-review.md), then HITL merge.

## Roles Involved

- **ARCHitect-in-CLI** — primary orchestrator, one of four invocation methods alongside direct
  specialist calls, TDM orchestration, and System Architect review.
- **[TDM](../roles/tdm.md)** — explicitly reactive (blockers, Linear, evidence), not the
  orchestrator. Work blocked more than four hours escalates to `@tdm`.
- **HITL (human)** — sole merge authority and the terminal state of the contract.

## Citations

- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the ownership matrix and invocations.
- [WORKFLOW_COMPARISON.md](../../workflow/WORKFLOW_COMPARISON.md) — how vNext differs from before.
