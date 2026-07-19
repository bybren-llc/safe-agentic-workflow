---
type: sop
title: "Pre-PR Validation Checklist"
description: "SSoT stub: authoritative blocking checklist an orchestrator completes before opening any PR, with sign-off attached to the ticket."
resource: "docs/sop/PRE_PR_VALIDATION_CHECKLIST.md"
tags: [ssot-stub, gates, process, ci, testing]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/sop/PRE_PR_VALIDATION_CHECKLIST.md"
verified_against: "fd0fc6a"
---

# Pre-PR Validation Checklist

## Overview

276 lines the ARCHitect-in-CLI must complete before creating a PR for any investigation or
implementation. Its usage rules are blocking, not advisory: complete ALL sections; if ANY item
fails, do not create the PR; a System Architect review trigger blocks the PR until approval; and
the completed checklist is attached to the Linear ticket as sign-off. Twelve H2 sections cover How
to Use This Checklist, Documentation Completeness, Code Review Requirements, Security Validation,
Test Coverage, Linear Ticket Completeness, Workflow Compliance, Code Quality, Documentation
Quality, Sign-Off, an Example {{TICKET_PREFIX}}-321 Failure Analysis, and Related Documentation.
The worked post-mortem of that real failure is why the rules read as absolutes.

## When It Applies

- Immediately before opening a PR for an investigation or an implementation.
- Retrospectively, when diagnosing why a PR should not have been opened.
- Whenever a System Architect review trigger fires — the PR stays closed until approval lands.
- It is distinct from the `/pre-pr` command, which runs the mechanical validation. This checklist
  covers the judgment items a script cannot assert.
- It does NOT replace the CI pipeline or review stages that follow PR creation; it is the gate in
  front of them.

## Affected Concepts

- [pre-pr](../../commands/pre-pr.md) — the mechanical counterpart; running it satisfies part of
  this checklist but never all of it.
- [ARCHitect-in-CLI Role](../workflow/architect-in-cli-role.md) — the role that owns completion
  and sign-off.
- [System Architect](../../roles/system-architect.md) — holds the review trigger that blocks the
  PR outright.
- [Evidence-Based Delivery](../../methodology/evidence-based-delivery.md) — the attach-to-ticket
  obligation the sign-off section creates.
- [Three-Stage PR Review](../../methodology/three-stage-pr-review.md) — the process this gate
  guards the entrance to.
- [CONTRIBUTING.md](../root-docs/contributing.md) — its seven-step workflow assumes this
  checklist has already passed.

## Citations

- [PRE_PR_VALIDATION_CHECKLIST.md](../../../sop/PRE_PR_VALIDATION_CHECKLIST.md) — the
  authoritative checklist; Version 1.0, last updated 2025-10-06.
