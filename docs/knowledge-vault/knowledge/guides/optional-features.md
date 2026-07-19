---
type: guide
title: "Optional Features Removal Guide"
description: "SSoT stub: authoritative removal checklists for shipped integrations a project does not need, with post-removal verification."
tags: [ssot-stub, onboarding, operations, patterns]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "docs/guides/OPTIONAL-FEATURES.md"
verified_against: "fd0fc6a"
---

# Optional Features Removal Guide

A pointer card. At 704 lines this is the longest guide in `docs/guides/`, and it answers exactly
one question: which files do I delete when an integration the template ships does not apply to my
project. Subtraction, not configuration.

## What It Is Authoritative For

Six removal checklists, each naming concrete paths:

| Feature | Removed when |
| --- | --- |
| Stripe / payment patterns | The project takes no payments |
| Confluence integration | Docs do not live in Confluence |
| RLS / PostgreSQL patterns | No Postgres, or no row-level security |
| Clerk / auth patterns | Auth is handled elsewhere or absent |
| Agent Teams (experimental) | Single-agent operation is enough |
| Dark Factory (tmux agent teams) | No long-running remote agent sessions |

Plus a Verification After Removal section and a Summary.

## The Trap It Exists To Prevent

The checklists deliberately name **both** copies of the same hook script — the one under
`.claude/hooks/` and its mirror under `agent_providers/claude_code/hooks/`. Removal that touches
only the active tree leaves the mirrored provider tree to resurrect the feature on the next sync.
If you remember one thing from this guide, remember that it is two trees.

## When To Read It

Its stated timing is after `scripts/setup-template.sh` and before the first real commit, and the
[Template Setup](../root-docs/template-setup.md) post-setup checklist points here. Read it again
whenever a non-software domain adopts the harness and the SWE-specific integrations need
stripping — see [Domain Adaptation](../../methodology/domain-adaptation.md).

## Citations

- [OPTIONAL-FEATURES.md](../../../guides/OPTIONAL-FEATURES.md) — the authoritative checklists.
- [TEMPLATE_SETUP.md](../../../../TEMPLATE_SETUP.md) — the checklist that routes here.
