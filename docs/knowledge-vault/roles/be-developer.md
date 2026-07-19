---
type: agent-role
title: "BE Developer - Backend Implementation"
description: "Implements API routes and server logic from existing patterns; stops if the ticket has no AC/DoD."
resource: ".claude/agents/be-developer.md"
tags: [methodology, agents, patterns, workflow, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/be-developer.toml"
  - "agent_providers/claude_code/prompts/be-developer.md"
verified_against: "fd0fc6a"
---

# BE Developer - Backend Implementation

An executor, not a designer. "Execute, don't discover" is the whole posture.

## Overview

The role turns an approved spec into server-side code by locating an existing pattern and
customising it — read spec, load pattern, copy the pattern code, customise per spec, validate.
It holds the full file-editing tool set but no Linear MCP tools, so it cannot post its own
evidence. The boundary that matters most is the precondition gate: a ticket with no Acceptance
Criteria or Definition of Done stops the role — "you are NOT responsible for inventing AC/DoD."

## Responsibilities

- Owns API routes and server-side logic derived from the BSA spec and a named pattern.
- Owns atomic commits in the form `feat(api): description [{{TICKET_PREFIX}}-XXX]`.
- Owns the validation loop, rerun until it is green: integration tests, type-check, lint.
- Does not create PRs — that is the RTE's work — and does not merge to `dev` or `master`.
- Does not invent acceptance criteria; missing AC is a stop condition, not an input to guess at.

## Skills & SOPs

- [pattern-discovery](../skills/pattern-discovery.md) — finding the pattern before writing code.
- [api-patterns](../skills/api-patterns.md) — route shape, validation, error handling.
- [rls-patterns](../skills/rls-patterns.md) — the context helpers server code must go through.
- [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) — the AC/DoD precondition it enforces.

## Handoffs

- **Receives from** [BSA](bsa.md) — a spec with testable AC/DoD and a referenced pattern; absent
  that, the role halts and returns the ticket.
- **Hands off to** [QAS](qas.md) — exit state `Ready for QAS`, commits pushed and validation
  green. Declaring the work "done" is explicitly forbidden; only QAS closes that judgement.
- **Escalates** spec or pattern gaps to [BSA](bsa.md), and delivery blockers to [TDM](tdm.md).

The provider mirror is stale: it drops the stop-the-line gate, the ownership model and the
auto-loaded skills block (~38 lines) plus the whole Exit Protocol — 69 lines missing in all — and
declares a smaller model, leaving no AC/DoD gate and no `Ready for QAS` exit state.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — exit states and chain of custody.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
