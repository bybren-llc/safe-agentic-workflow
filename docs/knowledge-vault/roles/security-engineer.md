---
type: agent-role
title: "Security Engineer - RLS and Compliance"
description: "Read-only auditor for RLS, vulnerabilities, and compliance, with authority to block deployment."
resource: ".claude/agents/security-engineer.md"
tags: [methodology, agents, security, gates, testing]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/security-engineer.toml"
  - "agent_providers/claude_code/prompts/security-engineer.md"
verified_against: "fd0fc6a"
---

# Security Engineer - RLS and Compliance

An auditor that can stop a deployment but cannot write a line of the fix.

## Overview

The role validates row-level security enforcement, scans for vulnerabilities, and audits
compliance against the security patterns. It is read-only by construction, with a read-only Codex
sandbox — one of only two roles configured that way, the other being QAS. Its authority is
negative rather than productive: it blocks, it does not build. Its declared principles are
Security First, Defense in Depth, and Zero Trust.

## Responsibilities

- Owns RLS policy validation for new tables and the audit of access paths for user isolation.
- Owns vulnerability and dependency scanning, plus secret-exposure checks across the codebase.
- Owns compliance review and the mandatory security review of production migration plans.
- Does not create new security patterns; the definition assigns that to BSA or the ARCHitect.

## Skills & SOPs

- [security-audit](../skills/security-audit.md) — the audit procedure and OWASP checks.
- [rls-patterns](../skills/rls-patterns.md) — the context helpers every data path must use.
- [Stop-the-Line Gate](../methodology/stop-the-line-gate.md) — the shared blocking contract.

## Handoffs

- **Blocks deployment** on a critical or high vulnerability, unenforced RLS, missing auth on a
  protected route, or a secret in code.
- **Escalates to ARCHitect as CRITICAL** for a vulnerability, an RLS policy change, a security
  model change, or a dependency zero-day.
- The definition declares no exit state, so its clearance is not represented in the workflow's
  state machine the way `Approved for RTE` is.

Two gaps are worth flagging. Its validation command pipes an RLS validation SQL script into a
containerised database, but that script is absent from this template repo. And the two copies of
the role name that command's container and database through different placeholder variables, so
substitution renders different identifiers depending on which file is used.

## Citations

- [RLS Policy Catalog](../../database/RLS_POLICY_CATALOG.md) — the per-table policy expectations.
- [Security-First Architecture](../../security/SECURITY_FIRST_ARCHITECTURE.md) — governing model.
