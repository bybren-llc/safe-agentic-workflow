---
type: skill
title: "Skill: orchestration-patterns"
description: "Agent-loop orchestration for long-running work: evidence-based delivery, QAS pre-merge gate, escalation."
resource: ".claude/skills/orchestration-patterns/SKILL.md"
tags: [skills, orchestration, gates, agents]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/orchestration-patterns/SKILL.md"
  - ".agents/skills/orchestration-patterns/SKILL.md"
  - ".claude/skills/orchestration-patterns/README.md"
verified_against: "fd0fc6a"
---

# Skill: orchestration-patterns

The long-run card: how multi-step work is checkpointed, when a subagent is spawned, and what must be
proven before a merge is allowed.

## Overview

Model-invocable, and the only skill in this lane granted `Task` — alongside `Read`, `Bash`, `Grep`, and
`Glob` — which means it can spawn subagents rather than merely advise about them. It implements what it
calls Simon Willison's agent loop. Nine H2 sections cover evidence-based delivery, a QAS pre-merge
gate, escalation patterns, long-running task checkpoints, a worked orchestration example, and
anti-patterns to avoid. Its QA evidence is written to `docs/agent-outputs/qa-validations/`.

## Routes To

- `docs/agent-outputs/qa-validations/` — where the QAS gate's evidence lands.
- `docs/sop/AGENT_WORKFLOW_SOP.md` — routed to by the `.agents` copy ONLY; the Claude copy lacks this
  reference, so the portable surface is better connected here than the vendor one.

Related concepts: [Evidence-Based Delivery](../methodology/evidence-based-delivery.md) is the principle
it implements, [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) the escalation it triggers,
and [team-coordination](team-coordination.md) the sibling it cross-references for multi-agent teams.

## Used By Roles

- No `.claude/agents/*.md` file names this skill, so no role loads it on definition — notable for a
  skill holding the only subagent-spawning grant in the lane.
- [TDM](../roles/tdm.md) and [RTE](../roles/rte.md) are its natural operators; neither declares it.
- [QAS](../roles/qas.md) is the gate this skill blocks on rather than a caller of it.

The `.agents` copy (219 lines against 232) reorders rather than only trims: "Anti-Patterns to Avoid"
moves ahead of "Authoritative References", the reverse of the Claude ordering. It drops the
`{{PROJECT_REPO}}` token and `allowed-tools`, and adds `{{CI_VALIDATE_COMMAND}}`. The reordering matters
because a reader who stops early on one surface meets the warnings, and on the other meets the links.

## Citations

- [orchestration-patterns SKILL.md](../../../.claude/skills/orchestration-patterns/SKILL.md) — the authoritative loop.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the delivery chain the portable copy routes to.
