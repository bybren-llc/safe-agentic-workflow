---
type: agent-role
title: "TDM - Technical Delivery Manager"
description: "Orchestrates the agent team, manages blockers, maintains the Linear board, and routes escalations."
resource: ".claude/agents/tdm.md"
tags: [methodology, agents, orchestration, process, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/tdm.toml"
  - "agent_providers/claude_code/prompts/tdm.md"
verified_against: "fd0fc6a"
---

# TDM - Technical Delivery Manager

The router. It has no gate of its own — it decides who else's gate a problem belongs to.

## Overview

The role coordinates work across the agent team, resolves blockers, keeps the Linear board honest,
and ensures delivery to POPM is evidence-backed. Its Claude tool grant is deliberately narrow:
read and shell plus the Linear and Confluence MCP servers, with no file-editing tools at all.
Unlike QAS or the System Architect it holds no stop-the-line authority; when something cannot
proceed it escalates rather than blocks.

## Responsibilities

- Owns agent assignment and three coordination patterns: parallel development, sequential
  dependencies, blocker resolution.
- Owns the Linear board as the delivery record and the evidence rollup to POPM.
- Owns escalation routing: schema changes are mandatory ARCHitect escalations, with core
  architecture and security model changes, CI/CD failures, and CODEOWNERS conflicts. Unclear
  requirements, conflicting priorities, scope creep, and final approval go to POPM.
- Does not block work itself; it moves the decision to whoever owns it.

## Skills & SOPs

- [agent-coordination](../skills/agent-coordination.md) — the assignment matrix and blocker paths.
- [orchestration-patterns](../skills/orchestration-patterns.md) — multi-step and subagent work.
- [TDM Agent Assignment Matrix](../knowledge/workflow/tdm-agent-assignment-matrix.md) — who gets what.

## Handoffs

- **Receives from** POPM — priorities and scope.
- **Hands off to** every execution role as assignment, and to POPM as a delivery report.

The Claude definition additionally makes TDM the team lead for an experimental Agent Teams mode,
gated behind an environment key: it creates the team, spawns teammates, files tasks wired with
SAFe-gate dependencies, steers, and tears it down. The provider mirror omits that section and
downgrades the model. The Codex sandbox is broader than the Claude surface, permitting file
writes the Claude tool grant withholds.

## Citations

- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — escalation and evidence contract.
