---
type: command
title: "/quick-fix"
description: "Fast-track bug-fix workflow with reduced validation, a minimal PR template and explicit scope limits."
tags: [commands, operations, workflow, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/quick-fix.md"
sources:
  - ".claude/commands/quick-fix.md"
  - ".gemini/commands/workflow/quick-fix.toml"
verified_against: "fd0fc6a"
---

# /quick-fix

The escape hatch from the ticket workflow, for a critical bug that cannot wait. Its value is less the
speed than the scope gate deciding whether the shortcut is legitimate.

## Overview

Five steps replacing the [`/start-work`](start-work.md) → [`/pre-pr`](pre-pr.md) chain: verify the
ticket and branch, edit and commit, run a trimmed validation set, rebase and open an abbreviated PR,
then notify. Post-merge follow-ups — full suite, docs, prod check, ticket close — are deferred.

## Invocation

- `/quick-fix <ticket-number>` — an `argument-hint` is declared; with no argument it asks.
- `/workflow:quick-fix` on the Gemini surface, taking `{{args}}`.
- The branch name interpolates `$1` raw, so a full ticket ID yields a doubled prefix — unguarded.

## What It Does

- Fetches the issue via Linear MCP `get_issue`, confirms it is a bug, cuts a `-fix-` branch.
- Guides a minimal edit, `git add .`, commits as `fix(scope): ...`, then runs only `yarn type-check`,
  `yarn lint` and `yarn test:unit`.
- Rebases onto `origin/dev`, pushes with `--force-with-lease`, opens the abbreviated PR, then
  notifies reviewers, Linear, and Slack when urgent.

**Scope gate**: permitted for critical blocking bugs under 50 lines with no architectural change and
adequate coverage. Forbidden for new features, large refactors, breaking changes and dependency
upgrades. Integration, E2E and build checks are the casualties; commit format, branch naming, Linear
reference, type-check and ESLint stay non-negotiable.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | rebases onto `origin/dev`; verifies the ticket through the Linear MCP |
| Gemini | rebases onto `origin/main` — a real branch divergence |
| Gemini | no Linear MCP; step 1 degrades to prose "verify it is a bug fix via Linear" |
| Gemini | appends `\|\| echo ... completed` to the three checks, so validation can never fail |

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — commit format and branch naming, both retained here.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the full workflow this path abbreviates.
