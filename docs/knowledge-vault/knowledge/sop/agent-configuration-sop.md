---
type: sop
title: "Agent Configuration SOP"
description: "SSoT stub: authoritative procedure for agent YAML frontmatter, per-role tool restrictions, and model selection."
resource: "docs/sop/AGENT_CONFIGURATION_SOP.md"
tags: [ssot-stub, agents, process, security]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/sop/AGENT_CONFIGURATION_SOP.md"
verified_against: "fd0fc6a"
---

# Agent Configuration SOP

## Overview

381 lines governing every file under `.claude/agents/`: the mandatory YAML frontmatter contract,
the tool-restriction matrix per role, the model-selection criteria, and the procedures for adding
or modifying an agent. It is mandatory rather than advisory because tool restriction is the
mechanism `SECURITY.md` names as the harness's agent-boundary control — an agent granted tools
outside its matrix row is a boundary violation, not a configuration preference. Twelve H2 sections
cover Tool Restrictions by Agent Role, Model Selection Criteria, Tool Access Guidelines, Adding a
New Agent, Modifying Existing Agents, a Validation Checklist, and Troubleshooting. Enforcement is
the validation checklist and review, not an automated gate.

## When It Applies

- Before editing any agent `.md` file under `.claude/agents/` — including frontmatter-only edits.
- When adding a new role, and specifically when deciding which tools that role may hold.
- When changing an agent's model, which the selection criteria section governs.
- Whenever a change here must be mirrored into the other provider trees: `.codex/agents/*.toml`
  and `.cursor/rules/2x-agent-*.mdc`.
- It does NOT apply to the human-facing role descriptions in `AGENTS.md`, which document roles
  rather than configure them. The SOP is written Claude-Code-shaped and names no other provider,
  so the mirroring obligation above is carried by the provider concepts, not by this document.

## Affected Concepts

- [Claude Code](../../providers/claude-code.md) — owns the `.claude/agents/` tree this SOP
  configures; its layout is what the frontmatter contract binds to.
- [Codex](../../providers/codex.md) and [Cursor](../../providers/cursor.md) — must receive the
  mirrored change; parity is manual and this SOP does not describe it.
- [Agents Portable](../../providers/agents-portable.md) — the cross-provider role definitions that
  any frontmatter change has to stay consistent with.
- Every concept under `roles/` — for example [System Architect](../../roles/system-architect.md)
  and [QAS](../../roles/qas.md) — inherits its tool grant from the matrix in this SOP.
- [SECURITY.md](../root-docs/security.md) — depends on this SOP for the agent-boundary control it
  claims; a gap here is a reportable security issue there.

## Citations

- [AGENT_CONFIGURATION_SOP.md](../../../sop/AGENT_CONFIGURATION_SOP.md) — the authoritative
  procedure; header declares Version 1.0, last updated 2025-10-03.
