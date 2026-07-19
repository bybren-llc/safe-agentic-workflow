---
type: guide
title: "Engineer Daily Workflow"
description: "SSoT stub: authoritative day-to-day loop for FE and BE developers from morning sync through pre-PR validation and end of day."
tags: [ssot-stub, onboarding, workflow, patterns]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/onboarding/ENGINEER-DAILY-WORKFLOW.md"
verified_against: "fd0fc6a"
---

# Engineer Daily Workflow

This is a map-card. `docs/onboarding/ENGINEER-DAILY-WORKFLOW.md` is the source of truth: 495 lines,
11 H2 sections, scoped to the [FE Developer](../../roles/fe-developer.md) and
[BE Developer](../../roles/be-developer.md) roles.

## What It Is Authoritative For

The daily sequence, command by command: start-of-day sync and review, the `/start-work` walkthrough,
the mandatory pattern discovery protocol as an implementer actually runs it, the implementation
workflow, the `/pre-pr` validation pass, and the end-of-day wrap-up. Its closing sections are Exit
States, Troubleshooting, and Success Validation. Its header names four skills as auto-loading:
[safe-workflow](../../skills/safe-workflow.md),
[pattern-discovery](../../skills/pattern-discovery.md),
[api-patterns](../../skills/api-patterns.md) for backend, and
[frontend-patterns](../../skills/frontend-patterns.md) for frontend.

## Role Contract Versus Daily Loop

The role concepts define what an implementer is accountable for; this guide defines what the hours
look like. Read it when you have already accepted the contract and need the loop. Its Exit States
section restates "Ready for QAS" from the
[vNext Workflow Contract](../../methodology/vnext-workflow-contract.md) rather than redefining it,
so the contract stays the single authority on what that state means.

## The Coverage Gap

The gate-role counterpart is [QAS Daily Workflow](qas-daily-workflow.md). Between them they cover
three roles. No equivalent daily guide exists for the other nine; those roles have a contract but
no clock, and an implementer stepping into one of them has to work from the role concept alone.

## Next

- [Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md) — the mandate this
  loop enforces daily.
- [/pre-pr](../../commands/pre-pr.md) and [/end-work](../../commands/end-work.md) — the two commands
  that close the day.

## Citations

- [ENGINEER-DAILY-WORKFLOW.md](../../../onboarding/ENGINEER-DAILY-WORKFLOW.md) — the full loop.
