---
type: agent-role
title: "FE Developer - Frontend Implementation"
description: "Implements UI components and pages from patterns; stops if the ticket has no AC/DoD."
resource: ".claude/agents/fe-developer.md"
tags: [methodology, agents, patterns, workflow, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/fe-developer.toml"
  - "agent_providers/claude_code/prompts/fe-developer.md"
verified_against: "fd0fc6a"
---

# FE Developer - Frontend Implementation

The backend developer's mirror image, distinguished by one thing: it must show its work visually.

## Overview

The role implements UI components, pages, and client logic from patterns in the library's UI
category, following the same read-spec, load-pattern, customise, validate loop as its backend
counterpart. It carries the identical stop-the-line precondition: no Acceptance Criteria or
Definition of Done means stop and route back, never improvise. Two things separate it from the
backend role — its validation loop ends in a build rather than integration tests, and its handoff
is incomplete without visual evidence.

## Responsibilities

- Owns UI components, pages, and client-side logic derived from a named pattern.
- Owns atomic commits in the form `feat(ui): description [{{TICKET_PREFIX}}-XXX]`.
- Owns visual evidence: screenshots or Playwright output, including a light and dark mode check.
- Does not create PRs or merge to `dev` or `master`.
- Does not invent acceptance criteria; a ticket without them is a stop condition.

## Skills & SOPs

- [frontend-patterns](../skills/frontend-patterns.md) — component, page, and auth-flow shapes.
- [pattern-discovery](../skills/pattern-discovery.md) — finding the pattern before writing code.
- [testing-patterns](../skills/testing-patterns.md) — the evidence its handoff requires.
- [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) — the AC/DoD precondition.

## Handoffs

- **Receives from** [BSA](bsa.md) — a spec with testable AC/DoD and a referenced UI pattern.
- **Hands off to** [QAS](qas.md) — exit state `Ready for QAS`, with lint, type-check, and build
  green and visual evidence attached. Reporting the work as "done" is explicitly forbidden.
- **Escalates** spec gaps to BSA and delivery blockers to [TDM](tdm.md).

The provider mirror is stale: it drops the stop-the-line gate and ownership model (~38 lines) and
declares a smaller model, so the provider variant of this role has no AC/DoD gate.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — exit states and chain of custody.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
