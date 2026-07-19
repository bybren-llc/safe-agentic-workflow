---
type: skill
title: "Skill: stripe-patterns"
description: "Stripe checkout, webhook and subscription patterns with test-mode safety rules and evidence templates."
resource: ".claude/skills/stripe-patterns/SKILL.md"
tags: [skills, patterns, security]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/stripe-patterns/SKILL.md"
  - ".claude/skills/stripe-patterns/README.md"
verified_against: "fd0fc6a"
---

# Skill: stripe-patterns

Payment integration guidance: checkout sessions, webhook handling, subscription state, and the
test-mode rules that keep an agent from touching live money.

## Overview

Model-invoked only — `user-invocable: false`, `allowed-tools` limited to `Read`, `Grep`, `Glob`. It
fires when a role is implementing a payment flow, a webhook, or subscription logic. Seven H2s carry
it: Purpose, When This Skill Applies, Canonical Code References, Critical Rules (which contains the
Test Mode Safety Checklist), Common Patterns, Evidence Template, Authoritative References.

The safety checklist is the load-bearing part; everything else is routing. This is the only skill in
its group whose canonical references point exclusively at application source files rather than the
pattern library — it routes to no `docs/` or `patterns_library/` path in either copy, so a reader
without the application already open gets no usable destination.

## Routes To

- `lib/stripe-config.ts` — the `createStripeClient` factory the Claude copy names.
- `app/api/payments/create-checkout-session/route.ts` and `app/api/payments/webhook/route.ts`.
- `utils/data/payments/`, `utils/data/subscriptions/`, `utils/data/invoices/` — helper directories.

Those are template-project paths; none was verified to exist in this repository. The `.agents` copy
is the longer of the two (176 lines against 164), adds a Local Testing section the Claude copy
lacks, and replaces every concrete path with tokens such as `{{CHECKOUT_ROUTE_PATH}}` and
`{{STRIPE_CONFIG_PATH}}`, plus the `{{APP_URL_ENV}}` and `{{DEV_PORT}}` environment key names.

Related: [Webhook Handler](../patterns/webhook-handler.md),
[Zod Validation API](../patterns/zod-validation-api.md),
[Secrets Management](../patterns/secrets-management.md).

## Used By Roles

No role definition under `.claude/agents/` references this skill by name, so it has no standing
binding and is reachable only by model invocation from context. Its natural caller is the
[BE Developer](../roles/be-developer.md), who owns API routes and webhook handlers, but that is an
inference from subject matter rather than declared wiring.

## Citations

- [CLAUDE.md](../../../CLAUDE.md) — the Payments section naming the provider and idempotency rule.
- [patterns_library/api/webhook-handler.md](../../../patterns_library/api/webhook-handler.md) — webhook shape.
