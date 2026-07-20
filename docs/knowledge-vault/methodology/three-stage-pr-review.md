---
type: process
title: "Three-Stage PR Review"
description: "PRs pass System Architect pattern review, then ARCHitect-in-CLI architecture review, then human HITL review which alone may merge."
tags: [methodology, process, gates, workflow, ci]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CONTRIBUTING.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
  - "docs/sop/PRE_PR_VALIDATION_CHECKLIST.md"
  - "docs/workflow/ARCHITECT_IN_CLI_ROLE.md"
  - ".github/pull_request_template.md"
verified_against: "0c26121"
---

# Three-Stage PR Review

A pull request is reviewed three times by three different kinds of reviewer before anyone may merge
it: once for pattern compliance, once for architecture, once by a human. The rule that gives the
structure teeth is that Stage 1 explicitly must not skip to Stage 3.

## Overview

Review begins only after RTE posts `Ready for HITL Review`, which itself requires QAS to have
posted `Approved for RTE` — see [Exit States](exit-states.md). A separate pre-PR gate, owned by
ARCHitect-in-CLI, runs before the PR is opened at all. Merge strategy is fixed to rebase and
merge; squash and merge commits are both forbidden.

## Flow

- **Stage 1 — System Architect.** Pattern compliance, RLS enforcement, technical validation. Six
  checklist items: RLS context enforced with no direct Prisma calls; `withUserContext`,
  `withAdminContext`, or `withSystemContext` used; authentication checks present; pattern library
  followed; TypeScript types valid; error handling comprehensive. Exits at
  `Stage 1 Approved - Ready for ARCHitect`, and must not jump to Stage 3.
- **Stage 2 — ARCHitect-in-CLI.** Architecture, security, and cross-cutting concerns.
- **Stage 3 — HITL.** Final human review and sole merge authority. The action is MERGE.

Two caveats. The Stage 1 checklist is written against a Prisma, RLS, and TypeScript stack and does
not generalize to the template's other declared stacks — adopting teams must rewrite it. And
CONTRIBUTING.md requires at least one reviewer approval auto-assigned through CODEOWNERS, a GitHub
mechanism unrelated to the three stages; no source reconciles the two models, so expect both.

## Roles Involved

- **[System Architect](../roles/system-architect.md)** — Stage 1; owns pattern and RLS compliance.
- **ARCHitect-in-CLI** — Stage 2; also owns the pre-PR checklist preceding the sequence.
- **HITL (human)** — Stage 3; the only merge authority in the contract.
- **[RTE](../roles/rte.md)** — opens the PR and hands it into Stage 1 with evidence linked.

## Citations

- [PRE_PR_VALIDATION_CHECKLIST.md](../../sop/PRE_PR_VALIDATION_CHECKLIST.md) — the gate before Stage 1.
- [ARCHITECT_IN_CLI_ROLE.md](../../workflow/ARCHITECT_IN_CLI_ROLE.md) — Stage 2 scope and authority.
