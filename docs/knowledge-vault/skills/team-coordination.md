---
type: skill
title: "Skill: team-coordination"
description: "Agent Teams orchestration: team creation, messaging, shared task lists and gate enforcement via deps."
resource: ".claude/skills/team-coordination/SKILL.md"
tags: [skills, orchestration, agents, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/team-coordination/SKILL.md"
  - ".claude/agents/tdm.md"
verified_against: "fd0fc6a"
---

# Skill: team-coordination

How several agents work one problem at once: forming the team, passing messages, sharing a task
list, and using task dependencies to hold a quality gate shut.

## Overview

User-invocable only — `disable-model-invocation: true` with an `argument-hint` of
`[task-description]`, so it is absent from the runtime available-skills listing. Its `allowed-tools`
are `Read`, `Bash`, `Grep`, `Glob`, and `Task`: the only skill in the harness that is both
user-invocable-only and granted `Task`, which lets it spawn teammates rather than describe how to.

Ten H2s carry it, including Prerequisites, Agent Teams vs Subagents vs Background Agents, SAFe Team
Patterns, Quality Gate Hooks, Team Sizing Guidelines, and Known Limitations. The comparison section
decides whether the skill should run at all — most work does not need a team. The Claude description
names `TeamCreate`, `SendMessage` and a shared `TaskList`; the portable one genericizes them.

## Routes To

- `patterns_library/api/` and `patterns_library/ui/` — where delegated implementation work lands.
- `specs/` — the specs a formed team divides between its members.

The surfaces disagree on their authoritative reference. The Claude copy links three vendor
documentation routes — `docs/en/agent-teams`, `docs/en/hooks`, `docs/en/sub-agents` — which are
product docs, not repository files, and resolve to nothing on disk. The `.agents` copy replaces all
three with `docs/sop/AGENT_WORKFLOW_SOP.md`, which does exist; it is also the shorter (205 vs 232).

Related: [agent-coordination](agent-coordination.md),
[orchestration-patterns](orchestration-patterns.md), [Role Collapsing](../methodology/role-collapsing.md).

## Used By Roles

| Role | Why it loads this skill |
| --- | --- |
| [TDM](../roles/tdm.md) | forms and sizes the team, then enforces gates through task deps |

No other role definition names it, consistent with a user-invoked orchestration entry point rather
than a skill agents reach for on their own.

## Citations

- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the authoritative coordination procedure.
- [AGENT_TEAM_GUIDE.md](../../guides/AGENT_TEAM_GUIDE.md) — team formation and sizing background.
