---
type: skill
title: "Skill: agent-coordination"
description: "Agent assignment matrix, blocker escalation, pre-implementation gate and TDM role boundaries."
resource: ".claude/skills/agent-coordination/SKILL.md"
tags: [skills, methodology, agents, process, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/agent-coordination/SKILL.md"
  - ".agents/skills/agent-coordination/SKILL.md"
  - ".claude/skills/agent-coordination/README.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - "docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md"
verified_against: "fd0fc6a"
---

# Skill: agent-coordination

The dispatch layer: which specialist takes a piece of work, what stops the line, and how a blocker
travels upward instead of sitting in a branch.

## Overview

Model-invocable — the Claude copy declares no `disable-model-invocation` key, and its `allowed-tools`
are limited to `Read`, `Grep`, and `Glob`, so it advises but never acts. Nine H2 sections carry the
procedure: a mandatory assignment matrix, stop-the-line conditions, a pre-implementation gate, an
evidence-attachment step, and an explicit statement of TDM boundaries. Nothing here is executable —
the skill is instruction text with no scripts, so following it is a discipline, not an automation.

## Routes To

- `docs/sop/AGENT_WORKFLOW_SOP.md` — the delivery chain this coordination sits inside; present on disk.
- `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md` — the authoritative role-to-work mapping; present on disk.
- Both routes are named in prose rather than resolved by the harness, so a reader must navigate manually.

Related concepts: [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) formalises the halt
conditions, and [Evidence-Based Delivery](../methodology/evidence-based-delivery.md) the attachment step.

## Used By Roles

- No file under `.claude/agents/` names this skill, so no role loads it automatically — it is reached
  by model judgement or by a human pointing at it.
- [TDM](../roles/tdm.md) is its subject rather than its declared consumer: the skill defines where TDM
  authority ends, but does not appear in the TDM agent definition.

The two surfaces diverge in framing more than in substance. The portable `.agents` copy (168 lines
against 179) drops `allowed-tools`, adds "Do NOT use for direct implementation work" to its
description, wears a `TEMPLATE` banner with `{{PLACEHOLDER}}` and `{{CI_VALIDATE_COMMAND}}` tokens, and
renames "Updating Linear with evidence" to the neutral "Updating ticket system with evidence". Only the
Claude surface ships a `README.md`; `.agents` carries empty `assets/`, `references/`, and `scripts/`.

## Citations

- [agent-coordination SKILL.md](../../../.claude/skills/agent-coordination/SKILL.md) — the authoritative procedure.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the delivery chain this skill coordinates.
- [TDM Agent Assignment Matrix](../../workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md) — the role-to-work mapping.
