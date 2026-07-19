---
type: skill
title: "Skill: api-patterns"
description: "API route patterns: RLS context wrappers, Zod validation, standard responses and error handling."
resource: ".claude/skills/api-patterns/SKILL.md"
tags: [skills, methodology, patterns, security]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/api-patterns/SKILL.md"
  - ".agents/skills/api-patterns/SKILL.md"
  - ".claude/skills/api-patterns/README.md"
  - "patterns_library/api/webhook-handler.md"
verified_against: "fd0fc6a"
---

# Skill: api-patterns

The route-authoring card: which RLS context wrapper to reach for, where validation belongs, and what
shape a response and an error take before an endpoint is done.

## Overview

Model-invoked only — the Claude copy sets `user-invocable: false` with `allowed-tools` of `Read`,
`Grep`, and `Glob`. Ten H2 sections carry it, opening with "Authoritative References (MUST READ)" and
including stop-the-line conditions, a route checklist, response patterns, and a route template. Its job
is routing, not teaching: the substance lives in `patterns_library/api/`.

## Routes To

- `patterns_library/api/user-context-api.md` — the default caller-scoped route shape.
- `patterns_library/api/admin-context-api.md` — the elevated-context variant and its guardrails.
- `patterns_library/api/zod-validation-api.md` — request validation at the boundary.
- `patterns_library/api/webhook-handler.md` — inbound third-party calls and idempotency.
- `patterns_library/api/bonus-content-delivery.md` — referenced but ABSENT; treat as broken.

Related concepts: [user-context-api](../patterns/user-context-api.md),
[admin-context-api](../patterns/admin-context-api.md), [webhook-handler](../patterns/webhook-handler.md),
[zod-validation-api](../patterns/zod-validation-api.md), and sibling [rls-patterns](rls-patterns.md).

## Used By Roles

- No `.claude/agents/*.md` file names this skill, so no role loads it on definition — it is reached by
  model judgement while a route is written.
- Its natural consumers, [BE Developer](../roles/be-developer.md) and
  [Security Engineer](../roles/security-engineer.md), do not declare it.

The surfaces diverge on concreteness. The `.agents` copy (215 lines against 225) drops `user-invocable`
and `allowed-tools`, says "validation" where Claude says "Zod", and swaps hardcoded imports for
`{{AUTH_IMPORT}}`, `{{AUTH_PROVIDER}}`, `{{DB_IMPORT}}`, and `{{RLS_IMPORT}}` — the Claude copy carries
no placeholders at all.

## Citations

- [api-patterns SKILL.md](../../../.claude/skills/api-patterns/SKILL.md) — the authoritative procedure.
- [webhook-handler pattern](../../../patterns_library/api/webhook-handler.md) — the one route verified present.
