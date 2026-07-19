---
type: guide
title: "QAS Daily Workflow"
description: "SSoT stub: authoritative day-to-day loop for the QAS gate owner, from the Testing swimlane through evidence posting and approval."
tags: [ssot-stub, onboarding, testing, gates, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/onboarding/QAS-DAILY-WORKFLOW.md"
verified_against: "fd0fc6a"
---

# QAS Daily Workflow

This is a map-card. `docs/onboarding/QAS-DAILY-WORKFLOW.md` is the source of truth: 417 lines, 12
H2 sections, scoped to the [Quality Assurance Specialist](../../roles/qas.md).

## The Premise It Opens With

> QAS is a gate owner in the vNext workflow contract. Nothing moves to RTE without your approval.

That sentence sets the register for everything after it. This is not a guide about running tests;
it is a guide about holding a gate, and the tests are the evidence.

## What It Is Authoritative For

The morning routine over the Testing swimlane, the test execution workflow, the acceptance-criteria
validation checklist, evidence gathering, the QAS Validation Report template, Linear MCP tool usage,
the `/end-work` checklist, and the scope of QAS gate authority. Its header names three auto-loading
skills — [testing-patterns](../../skills/testing-patterns.md),
[security-audit](../../skills/security-audit.md), and [linear-sop](../../skills/linear-sop.md) —
and it requires Linear workspace access with the `mcp__{{MCP_LINEAR_SERVER}}__*` tools available.

## Where Abstraction Becomes Format

[Evidence-Based Delivery](../../methodology/evidence-based-delivery.md) states what evidence a
transition requires; this guide is where that table becomes a concrete report format you can fill
in. If you have ever wondered what "Approved for RTE" must actually be backed by, the QAS Validation
Report template is the answer, and it is the reason to read this document even if you are not QAS.

## Next

- [Engineer Daily Workflow](engineer-daily-workflow.md) — the implementer loop that feeds this gate.
- [Exit States](../../methodology/exit-states.md) — the states this gate moves work between.
- [Stop-the-Line Gate](../../methodology/stop-the-line-gate.md) — the authority to refuse.

## Citations

- [QAS-DAILY-WORKFLOW.md](../../../onboarding/QAS-DAILY-WORKFLOW.md) — the full gate-owner loop.
