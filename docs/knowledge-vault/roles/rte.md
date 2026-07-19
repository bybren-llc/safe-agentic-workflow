---
type: agent-role
title: "RTE - Release Train Engineer"
description: "Shepherds PRs from QAS approval through CI to HITL merge; never merges, never writes product code."
resource: ".claude/agents/rte.md"
tags: [methodology, agents, release, ci, gates, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/rte.toml"
  - "agent_providers/claude_code/prompts/rte.md"
verified_against: "fd0fc6a"
---

# RTE - Release Train Engineer

The last agent to touch a change before a human does. A PR shepherd, not a developer.

## Overview

The role separates *preparing* a release from *authorizing* one: RTE owns everything up to the
merge button and nothing past it. Its Claude surface grants `Read`, `Bash`, and `Grep` only — no
`Write` or `Edit` — so PRs are created through `gh` rather than by editing files, which stops the
shepherd becoming an implementer. Entry is gated: RTE may not begin until QAS sets `Approved for
RTE` and posts evidence.

## Responsibilities

- Create the PR from template, assemble other roles' evidence, maintain PR metadata.
- Monitor CI, routing structural failures to the System Architect and bugs back to their author.
- Enforce rebase-first history; merge commits are never created.
- Never merge, never implement product code, never approve its own work.

## Skills & SOPs

- [safe-workflow](../skills/safe-workflow.md) — branch, commit, and rebase sequence it enforces.
- [release-patterns](../skills/release-patterns.md) — PR construction and CI validation.
- [Three-Stage PR Review](../methodology/three-stage-pr-review.md) — the review chain.
- [Exit States](../methodology/exit-states.md) — the exit contract it must satisfy.

## Handoffs

| Direction | Counterpart | Condition |
| --- | --- | --- |
| In | [QAS](qas.md) | status `Approved for RTE`, evidence posted |
| Out | Human (HITL) | exit state `Ready for HITL Review` |
| Escalation | ARCHitect or [TDM](tdm.md) | blocked merge, unroutable CI failure |

The provider mirrors contradict the Claude surface on the defining rule. The `agent_providers/` copy
omits the QAS-gate prerequisite, replaces the HITL handoff with a "Merge Pull Request" step running
`gh pr merge --rebase --delete-branch`, and drops the `Ready for HITL Review` exit state — the
provider RTE merges, which Claude forbids. Codex likewise grants it `workspace-write`.

## Citations

- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — northstar for git workflow and PR conventions.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — exit states and chain of custody.
