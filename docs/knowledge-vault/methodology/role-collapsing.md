---
type: process
title: "Role Collapsing and Independence Gates"
description: "Which agent roles may be merged into the implementer for small work, and which are independence gates that never collapse."
tags: [methodology, process, agents, gates, workflow]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CONTRIBUTING.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - "docs/workflow/ARCHITECT_IN_CLI_ROLE.md"
verified_against: "a79c2bd"
---

# Role Collapsing and Independence Gates

Eleven roles is a lot of ceremony for a two-line fix. Role collapsing names which roles the
implementer may absorb when work is small, and — more importantly — which may never be absorbed,
because their whole value is that someone other than the author performed them.

## Overview

Introduced by `{{TICKET_PREFIX}}-499` as an amendment to the
[vNext Workflow Contract](vnext-workflow-contract.md). Exactly one role is collapsible: RTE. Two
are permanently not: QAS and Security Engineer. The stated invariant is blunt — *quality gates are
immutable; QAS and SecEng cannot be collapsed.* Enforcement is prose across four documents;
nothing in the agent definitions or any script detects or refuses a self-review.

## Flow

- **Judge the work.** Collapse RTE when the PR is simple, the work is single-agent, or fast
  iteration matters more than separation of duties.
- **Collapse RTE into the implementer.** PR creation and CI shepherding move to BE-Developer,
  FE-Developer, or Data-Engineer; the [RTE](../roles/rte.md) role still describes what must happen.
- **Run the collapsed flow.** Implementer, QAS, implementer handles the PR, HITL merge.
- **Never collapse QAS.** Always spawn a subagent; never self-review. Stated rationale:
  self-review bias and quality enforcement.
- **Never collapse Security Engineer.** Never self-audit. Stated rationale: security blindness and
  conflict of interest.

Open question: no source states whether System Architect's Stage 1 review may collapse into
ARCHitect-CLI's Stage 2 when one actor holds both. The lists cover only RTE, QAS, and Security
Engineer, leaving the stages of [Three-Stage PR Review](three-stage-pr-review.md) unaddressed.

## Roles Involved

- **Implementers (BE, FE, Data-Engineer)** — may absorb RTE duties, and own the PR when they do.
- **[QAS](../roles/qas.md)** — an independence gate; must be a separate actor from the author.
- **[Security Engineer](../roles/security-engineer.md)** — an independence gate; never self-audits.
- **[RTE](../roles/rte.md)** — the only collapsible role in the contract.

## Citations

- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the collapsible and gate listings.
- [ARCHITECT_IN_CLI_ROLE.md](../../workflow/ARCHITECT_IN_CLI_ROLE.md) — orchestration around gates.
