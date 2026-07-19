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

The role separates *preparing* a release from *authorizing* one. RTE owns everything up to the
merge button and nothing past it. Its Claude surface grants `Read`, `Bash`, and `Grep` only — no
`Write` or `Edit` — so PRs are created through `gh` rather than by editing files, which
structurally stops the shepherd becoming an implementer. Entry is gated: RTE may not begin until
QAS sets `Approved for RTE` and posts evidence.

## Responsibilities

- Create the PR from template, assemble other roles' evidence, maintain PR metadata.
- Monitor CI and route failures: structural issues to the System Architect, implementation bugs
  back to the engineer who wrote them.
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

The provider mirrors disagree with the authoritative Claude surface: the `agent_providers/` copy
omits the QAS-gate prerequisite, and the Codex mirror grants `workspace-write` where Claude grants
no write tools.

## Citations

- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — northstar for git workflow and PR conventions.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — exit states and chain of custody.
