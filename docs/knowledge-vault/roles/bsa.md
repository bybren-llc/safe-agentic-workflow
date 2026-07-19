---
type: agent-role
title: "BSA - Business Systems Analyst"
description: "Decomposes requirements into SAFe stories with testable acceptance criteria and pattern references."
resource: ".claude/agents/bsa.md"
tags: [methodology, agents, process, workflow, patterns]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/bsa.toml"
  - "agent_providers/claude_code/prompts/bsa.md"
verified_against: "fd0fc6a"
---

# BSA - Business Systems Analyst

The upstream author of everything the execution roles refuse to invent.

## Overview

The role decomposes a business need into the SAFe hierarchy — Epic, Feature, Story, Enabler — and
writes the spec that execution agents consume. It runs in two modes: Planning Mode and Spec
Creation Mode, each starting from its own template. Its Claude surface is unusually broad: full
file editing plus the whole Linear MCP wildcard. Pattern discovery is mandatory and blocking — it
may not proceed until a pattern is found or a new one proposed to the System Architect.

## Responsibilities

- Owns requirement decomposition and the resulting spec, including testing strategy.
- Owns acceptance criteria and Definition of Done, which execution roles treat as a precondition
  rather than something to author themselves.
- Owns Linear ticket creation, but only after System Architect approval of the approach.
- Does not implement; the spec is the deliverable, not the code.
- Does not invent patterns unilaterally — new patterns are proposed, not assumed.

## Skills & SOPs

- [spec-creation](../skills/spec-creation.md) — spec structure, AC, and demo scripts.
- [pattern-discovery](../skills/pattern-discovery.md) — the mandatory pre-spec search.
- [Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md) — the blocking rule.

## Handoffs

- **Receives from** POPM — a business need or Linear ticket, with priority set.
- **Hands off to** the execution roles — a spec carrying AC/DoD and a named pattern, validated
  with the markdown linter, after System Architect sign-off on the architectural approach.
- **Escalates** architectural implications to [System Architect](system-architect.md).

Escalation routing for unclear business requirements disagrees across surfaces: the Codex
definition routes to POPM, the authoritative Claude definition routes to [TDM](tdm.md). BSA is
also the only role whose Claude and provider copies are byte-identical; the other ten diverge.
Whether its markdown-lint command exists here is open — `CLAUDE.md` commands are placeholders.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — handoff contract and exit states.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
