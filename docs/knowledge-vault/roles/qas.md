---
type: agent-role
title: "QAS - Quality Assurance Specialist"
description: "Independent quality gate with iteration authority; verifies AC/DoD and cannot modify product code."
resource: ".claude/agents/qas.md"
tags: [methodology, agents, gates, testing, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/qas.toml"
  - "agent_providers/claude_code/prompts/qas.md"
verified_against: "fd0fc6a"
---

# QAS - Quality Assurance Specialist

"You are a GATE, not just a report producer. Work does not proceed without your approval."

## Overview

The role independently verifies all implementation work before it can reach the release path. Its
independence is structural: it holds `Read`, `Bash`, and `Grep` with no write tools, and its Codex
sandbox is read-only, so it physically cannot fix what it finds. Its three narrowly scoped Linear
tools are enough to post evidence and nothing more. It is one of two roles the collapsing rules
forbid folding into another agent — the [Security Engineer](security-engineer.md) is the other.

## Responsibilities

- Owns verification of every acceptance criterion and Definition of Done item.
- Owns iteration authority: work bounces back to its implementer, with specific issues named, as
  often as needed. Documentation gaps route to the Tech Writer instead.
- Owns the QA artefacts under `docs/agent-outputs/qa-validations/` and the Linear evidence.
- Does not modify product code, skip AC verification, or approve substandard work.

## Skills & SOPs

- [testing-patterns](../skills/testing-patterns.md) — fixtures and the checks it runs.
- [Role Collapsing](../methodology/role-collapsing.md) — why this role is never collapsed.
- [Evidence-Based Delivery](../methodology/evidence-based-delivery.md) — the governing principle.

## Handoffs

- **Receives from** [BE](be-developer.md), [FE](fe-developer.md), [DE](data-engineer.md), and
  [DPE](data-provisioning-eng.md) at exit state `Ready for QAS`.
- **Hands off to** [RTE](rte.md) — exit state `Approved for RTE`, requiring unit and integration
  tests, type-check, and lint green, every AC verified, and evidence posted to Linear.
- **Routes** pattern violations to [System Architect](system-architect.md), spec issues to
  [BSA](bsa.md), blockers to [TDM](tdm.md).

The provider mirror is barely a mirror: it drops the Ownership Model, the iteration authority, the
Linear evidence mandate and the entire Exit Protocol, and grants no Linear tools — so the provider
QAS has neither an evidence obligation nor an `Approved for RTE` exit state to reach.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — exit states and chain of custody.
- [AGENTS.md](../../../AGENTS.md) — role roster and the non-collapsible rule.
