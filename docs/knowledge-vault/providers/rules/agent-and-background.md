---
type: guide
title: "Cursor Rules: Agent & Background Family (20-31)"
description: "Six manual Cursor rules: four SAFe agent personas plus background-agent and MCP integration guidance."
tags: [providers, agents, orchestration, security]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - ".cursor/rules/20-agent-architect.mdc"
  - ".cursor/rules/21-agent-backend.mdc"
  - ".cursor/rules/22-agent-qas.mdc"
  - ".cursor/rules/23-agent-security.mdc"
  - ".cursor/rules/30-background-agents.mdc"
  - ".cursor/rules/31-mcp-integration.mdc"
  - ".cursor/rules/README.md"
  - ".cursor/mcp.json"
verified_against: "fd0fc6a"
---

# Cursor Rules: Agent & Background Family (20-31)

Six rules, all `alwaysApply: false` with no globs, all reached by `@rule-name`. The README splits
them into "Agent-Role Rules" (20-23) and "Advanced Features" (30-31) over one contiguous block of
[Cursor surface](../cursor.md) numbering.

## The four personas are pointers, not definitions

Each role rule is a summary delegating to a Claude agent file: 20 (72 lines) to
`.claude/agents/system-architect.md`, 21 (73) to `.claude/agents/be-developer.md`, 22 (84) to
`.claude/agents/qas.md`, 23 (84) to `.claude/agents/security-engineer.md`. Vault concepts:
[System Architect](../../roles/system-architect.md), [BE Developer](../../roles/be-developer.md),
[QAS](../../roles/qas.md), [Security Engineer](../../roles/security-engineer.md).

All four targets exist on disk, so the thin-pointer pattern holds — and Cursor's personas break the
moment the Claude surface is removed. Coverage is partial: 4 of 11 roles, with BSA, FE Developer,
Data Engineer, Data Provisioning Engineer, RTE, TDM, and Tech Writer absent.

## 30 — background agents, the Cursor-only capability

`30-background-agents.mdc` (74 lines) describes agents in isolated Ubuntu VMs with internet access:
clone from GitHub, branch, open PRs. The README is explicit that this buys no exemption — such work
still passes the same gate chain ([Stop-the-Line](../../methodology/stop-the-line-gate.md), QAS,
[three-stage review](../../methodology/three-stage-pr-review.md)), still needs a human to merge, and
runs one ticket per agent. `.codex/README.md` marks it N/A for Gemini and Codex.

## 31 — MCP integration, and where it disagrees with itself

`31-mcp-integration.mdc` (75 lines) points at `.cursor/mcp.json`, which the README says is
interchangeable across providers. Two contradictions before you copy its example:

- DOC DRIFT: 31 names the Linear package `@linear/mcp-server` where `.cursor/mcp.json` uses
  `@anthropic/linear-mcp-server`, and inlines a placeholder key in `env` against README advice.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the family labels and gate claims.
- [.codex README](../../../../.codex/README.md) — the cross-provider capability comparison.
