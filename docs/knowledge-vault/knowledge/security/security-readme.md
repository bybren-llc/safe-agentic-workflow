---
type: guide
title: "Security Documentation Index (SSoT stub)"
description: "Pointer to the docs/security index."
tags: [ssot-stub, security, onboarding]
timestamp: 2026-07-19
status: active
sources:
  - "docs/security/README.md"
verified_against: "fd0fc6a"
---

# Security Documentation Index (SSoT stub)

A map-card for `docs/security/README.md`: 35 lines, the smallest index in the documentation tree,
carrying the H1 "Security Documentation" and a Documentation Files section.

## What it covers

`docs/security/` holds exactly two files — this index and
`SECURITY_FIRST_ARCHITECTURE.md`, mapped in the vault as
[Security-First Architecture](security-first-architecture.md). An index over one document is
thin by construction, so if you arrived here looking for the standards themselves, follow that
link and skip the index entirely.

## Where the rest of security lives

Most of this harness's security material is not in `docs/security/`, which is the useful thing to
know:

- Row Level Security: [RLS Implementation Guide](../database/rls-implementation-guide.md) and the
  [RLS Policy Catalog](../database/rls-policy-catalog.md).
- Vulnerability disclosure: [SECURITY.md](../root-docs/security.md) at the repository root.
- Agent-facing enforcement: the [security-audit skill](../../skills/security-audit.md) and the
  [pre-bash-rls-validation hook](../../providers/hooks/pre-bash-rls-validation.md).
- Code shapes: [input sanitization](../../patterns/input-sanitization.md) and
  [secrets management](../../patterns/secrets-management.md).

## Citations

- [docs/security/README.md](../../../security/README.md) — the index itself.
