---
type: command
title: "/audit-deps"
description: "Dependency audit command running yarn audit, bundle analyzer, depcheck and yarn outdated, then writing a report and Linear tickets."
resource: ".claude/commands/audit-deps.md"
tags: [commands, operations, ci, security]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".gemini/commands/audit-deps.toml"
verified_against: "fd0fc6a"
---

# /audit-deps

Reached for when the dependency tree has drifted — vulnerabilities, dead packages, or a bundle that
grew without anyone noticing. It is a survey command: it gathers, writes a dated report, and files
the follow-up work rather than fixing anything itself.

## Overview

Six read-only inspections feed one report file, which then becomes Linear issues. It sits outside
the ticketed flow — nothing precedes or follows it in a chain — and is the security- and
size-facing counterpart to the routine validation commands. Its output is evidence, not a change.

## Invocation

- `/audit-deps` — no arguments and no `argument-hint` declared; the command takes the repo as it is.
- Preconditions: a yarn project with `node_modules` present, `npx` available, and the Linear MCP
  server configured for the final step.
- `ANALYZE` is set as a build-flag env key name for the bundle-analyzer pass.

## What It Does

- Runs `yarn audit` for advisories, then `ANALYZE=true yarn build` for a bundle breakdown.
- Runs `npx depcheck` for unused dependencies and `yarn outdated` for version lag.
- Greps `*.ts` / `*.tsx` for `from.*icons` imports and sorts unique, surfacing icon-library sprawl.
- Sizes the installed tree with `du -sh node_modules/* | sort -hr | head -20`.
- Writes `docs/agent-outputs/technical-docs/dependency-audit-report-{date}.md`.
- Creates Linear issues from the findings via the Linear MCP `create_issue` tool.

## Provider Parity

- Claude — the full six steps plus the report and the Linear ticket creation.
- Gemini (`.gemini/commands/audit-deps.toml`) — mirrors steps 1-6 and the report template, but
  omits Linear ticket creation and the Customization Guide entirely.
- Gemini — wraps each command in `!{...}` shell substitution with `|| echo` fallbacks, so no step
  can fail the run; the Claude version applies no such error suppression.
- Gemini — truncates the icon grep with `head -10`; Claude leaves it unlimited.

Open question: the Claude command specifies no failure handling, so whether it aborts or continues
when `yarn audit` exits non-zero is UNKNOWN from the source.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the validation conventions this audit supplements.
- [Commands README](../../../.claude/commands/README.md) — where the command sits in the catalogue.
