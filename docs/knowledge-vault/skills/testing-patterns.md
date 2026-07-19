---
type: skill
title: "Skill: testing-patterns"
description: "Unit, integration and E2E test conventions, fixtures, RLS-aware testing and evidence templates."
resource: ".claude/skills/testing-patterns/SKILL.md"
tags: [skills, testing, patterns]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/testing-patterns/SKILL.md"
  - "patterns_library/testing"
verified_against: "fd0fc6a"
---

# Skill: testing-patterns

Test conventions across unit, integration and end-to-end, plus fixtures, RLS-aware assertions, and
the evidence a ticket needs before it can close.

## Overview

Model-invocable, with `allowed-tools` of `Read`, `Bash`, `Grep`, `Glob`; no `user-invocable` key is
declared. The `Bash` grant lets it run the suites it describes rather than only cite them. It fires
when writing tests, setting up fixtures, or validating that policies are actually enforced.

This is the widest divergence in its group: the Claude copy is 273 lines against the portable
copy's 94, a 66 percent shrink across 283 diff lines. The `.agents` copy deletes four whole
sections — Configuration Files, RLS-Aware Testing, Common Patterns, Pre-Push Validation. A reader
on that surface was never told how to test row-level security, which the harness treats as
mandatory.

## Routes To

- `patterns_library/testing/` — the test conventions the skill claims to route to.
- The unit, integration and E2E suite commands, run through the skill's `Bash` grant.

The description says it "routes to existing test conventions", but the Claude copy contains zero
`patterns_library/` paths; only the `.agents` copy links `patterns_library/testing/`, which does
exist. On the Claude surface the routing claim is unbacked. That copy also hardcodes a Yarn, Jest
and Playwright command block with no tokens, where `.agents` uses `{{TEST_UNIT_COMMAND}}` and peers.

Related: [API Integration Test](../patterns/api-integration-test.md),
[E2E User Flow](../patterns/e2e-user-flow.md), [rls-patterns](rls-patterns.md),
[Evidence-Based Delivery](../methodology/evidence-based-delivery.md).

## Used By Roles

No role definition under `.claude/agents/` names this skill — not even `qas.md`, whose entire remit
is validating acceptance criteria. [QAS](../roles/qas.md) is the obvious consumer and the binding is
simply absent from the harness configuration, leaving model invocation as the only path in.

## Citations

- [PRE_PR_VALIDATION_CHECKLIST.md](../../sop/PRE_PR_VALIDATION_CHECKLIST.md) — where evidence is required.
- [AGENT_WORKFLOW_SOP.md](../../sop/AGENT_WORKFLOW_SOP.md) — the validation stage this skill serves.
