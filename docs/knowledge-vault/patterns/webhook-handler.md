---
type: pattern
title: "Webhook Handler Pattern"
description: "Signature-verified webhook endpoint writing under withSystemContext for Stripe, Clerk, and third parties."
resource: "patterns_library/api/webhook-handler.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Webhook Handler Pattern

The shape for an endpoint whose caller is a machine: verify the signature against the bytes that
were actually signed, then write under a system RLS context because there is no user to attribute.

## Overview

The ordering is the whole pattern. The handler reads the raw body with `req.text()` and the
signature header via `headers()` from `next/headers` **before** anything parses the payload, so
verification runs against unparsed bytes rather than a re-serialized object — the classic way
signature checks are silently defeated. Only after verification does it decode and dispatch,
writing through `withSystemContext`. Reach for it for Stripe, Clerk, and any third-party callback.
Do not reach for it for user-initiated routes, which belong to the
[user context pattern](user-context-api.md); a system context is not a shortcut around RLS.

Its 318-line file follows the library's fixed order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/api/webhook-handler.md` — the reference implementation itself, carried in
  `resource`; no second in-repo instance exists to compare it against.

Discovery is the intended route in: `CLAUDE.md` names this file directly in its payments notes,
the [pattern-discovery](../skills/pattern-discovery.md) skill points at `patterns_library/`, and
the [stripe-patterns](../skills/stripe-patterns.md) skill arrives at the same place from the
payments side. The library README indexes it under `api`.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, so correctness rests on review alone — which matters more here than elsewhere,
since a signature check that looks right and is wrong fails silently.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol and the payments notes.
