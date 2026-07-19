---
type: skill
title: "Skill: security-audit"
description: "RLS validation, OWASP Top 10 checklist, credential scanning and pre-deployment security review."
resource: ".claude/skills/security-audit/SKILL.md"
tags: [skills, security, gates, operations]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/security-audit/SKILL.md"
  - "docs/security/SECURITY_FIRST_ARCHITECTURE.md"
verified_against: "fd0fc6a"
---

# Skill: security-audit

The sweep that runs before anything ships: policy coverage, the OWASP checklist, credential
scanning, and a written report.

## Overview

One of only two skills that run in a forked context (`context: fork`, `agent: Explore`), and the
only one combining a fork with a `Bash` grant — so it can execute scanning commands in isolation
without polluting the caller's window. Its `allowed-tools` are `Read`, `Bash`, `Grep`, `Glob`. It is
model-invocable; no `user-invocable` key is declared.

Ten H2s carry it, including Stop-the-Line Conditions, Security Audit Checklist, OWASP Top 10
Checklist, Pre-Deployment Security Review, and Security Audit Report Template. The report template
is the output artifact — the audit is not finished until it is written down. The `.agents` copy
(202 lines against 207) tokenizes the audit command as `{{SECURITY_AUDIT_COMMAND}}`.

## Routes To

- The RLS context helpers and policy catalog, re-validated as the first checklist item.
- A written security audit report, produced from the template the skill carries.

Both copies cite `docs/guides/SECURITY_FIRST_ARCHITECTURE.md`, which does not exist; the real path
is `docs/security/SECURITY_FIRST_ARCHITECTURE.md`, as used by `CLAUDE.md`. The drift is on both
surfaces, so it is a genuine broken reference rather than a divergence between folds.

Related: [rls-patterns](rls-patterns.md), [Stop-the-Line Gate](../methodology/stop-the-line-gate.md),
[Security-First Architecture](../knowledge/security/security-first-architecture.md),
[Secrets Management](../patterns/secrets-management.md).

## Used By Roles

| Role | Why it loads this skill |
| --- | --- |
| [Security Engineer](../roles/security-engineer.md) | owns the audit; the only role that names it |

Roles with adjacent stop-the-line authority — [System Architect](../roles/system-architect.md) and
[RTE](../roles/rte.md) — consume its report rather than invoking the skill themselves.

## Citations

- [SECURITY_FIRST_ARCHITECTURE.md](../../security/SECURITY_FIRST_ARCHITECTURE.md) — the authoritative posture.
- [RLS_POLICY_CATALOG.md](../../database/RLS_POLICY_CATALOG.md) — the protected-table inventory audited.
