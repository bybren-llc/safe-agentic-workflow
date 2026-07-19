---
type: guide
title: "Security-First Architecture (SSoT stub)"
description: "Pointer to the security-first architecture assessment and development standards."
tags: [ssot-stub, security, gates]
timestamp: 2026-07-19
status: active
sources:
  - "docs/security/SECURITY_FIRST_ARCHITECTURE.md"
verified_against: "fd0fc6a"
---

# Security-First Architecture (SSoT stub)

A map-card for `docs/security/SECURITY_FIRST_ARCHITECTURE.md`, 182 lines under the H1
"Security-First Architecture Assessment: {{PROJECT_NAME}} Development Standards." It is the
document other parts of the harness cite when they say "the security standards," so knowing its
status matters more than knowing its contents.

## Its status is unusual

The second line is a Confluence blockquote pointing at an external Atlassian wiki URL assembled
from the `{{ARCHITECT_GITHUB_HANDLE}}` and `{{PROJECT_NAME}}` placeholders. The in-repo file may
therefore be a mirror rather than the canonical text, and the canonical version may live off-repo
where this vault cannot verify it. Nothing reconciles the two. Read the in-repo copy as
authoritative only after confirming the wiki page does not supersede it.

## Who points here

[CLAUDE.md](../root-docs/claude-md.md) cites it from the authentication section as the pattern
authority alongside `patterns_library/`, and the CI/CD documentation cites it as well — see
[CI/CD Documentation Index](../ci-cd/ci-cd-readme.md). That makes it a shared upstream for two
otherwise unrelated areas, which is worth remembering when it changes.

## Related

The operational counterpart is the [security-audit skill](../../skills/security-audit.md); the
role that owns the standard is [Security Engineer](../../roles/security-engineer.md); the
directory it sits in is described by [Security Documentation Index](security-readme.md).

## Citations

- [SECURITY_FIRST_ARCHITECTURE.md](../../../security/SECURITY_FIRST_ARCHITECTURE.md) — the standard.
