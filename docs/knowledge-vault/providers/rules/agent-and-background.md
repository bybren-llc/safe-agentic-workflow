---
type: guide
title: "Cursor Rules: Agent & Background Family (20-31)"
description: "Six manual Cursor rules: four SAFe agent personas plus background-agent and MCP integration guidance."
tags: [providers, agents, orchestration, security]
timestamp: 2026-07-20
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
verified_against: "c4f9d6d"
---

# Cursor Rules: Agent & Background Family (20-31)

Six rules, all `alwaysApply: false` with no globs, all reached by `@rule-name`. The README splits
them into "Agent-Role Rules" (20-23) and "Advanced Features" (30-31) over one contiguous block of
[Cursor surface](../cursor.md) numbering.

## The four personas are pointers, not definitions

Each role rule summarizes and delegates to a file in `.claude/agents/`: 20 (72 lines) to
`system-architect.md`, 21 (73) to `be-developer.md`, 22 (84) to `qas.md`, 23 (84) to
`security-engineer.md`. Vault: [System Architect](../../roles/system-architect.md), [QAS](../../roles/qas.md),
[BE Developer](../../roles/be-developer.md), [Security Engineer](../../roles/security-engineer.md).

All four targets exist, so the thin-pointer pattern holds — and Cursor's personas break the moment
the Claude surface is removed. Coverage is 4 of 11 roles: BSA, FE Developer, Data Engineer, Data
Provisioning Engineer, RTE, TDM, and Tech Writer have no Cursor rule.

## 30 — background agents, the Cursor-only capability

`30-background-agents.mdc` (74 lines) describes agents in isolated Ubuntu VMs with internet access:
clone, branch, open PRs. The README grants no exemption — [Stop-the-Line](../../methodology/stop-the-line-gate.md),
QAS, and [three-stage review](../../methodology/three-stage-pr-review.md) all still apply, a human
still merges, and it runs one ticket per agent. `.codex/README.md` marks it N/A for Gemini and Codex.

## 31 — MCP integration, and where it disagrees with itself

`31-mcp-integration.mdc` (75 lines) points at `.cursor/mcp.json`, which the README calls
interchangeable across providers. Two contradictions before you copy its example:

- DOC DRIFT: 31 names the Linear package `@linear/mcp-server` where `.cursor/mcp.json` uses
  `@anthropic/linear-mcp-server`, so its example configures a server the repo does not.
- DOC DRIFT: 31 inlines `LINEAR_API_KEY = "your-api-key"` in `env`, against the rules README's
  "Never commit real API keys" — the shape it teaches is the one that leaks.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the family labels and gate claims.
- [.codex README](../../../../.codex/README.md) — the cross-provider capability comparison.
