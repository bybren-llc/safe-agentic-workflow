---
type: guide
title: "Cursor Rules: Core Family (00-02)"
description: "The three always-apply Cursor rules covering SAFe principles, git workflow, and mandatory pattern discovery."
tags: [providers, methodology, workflow, patterns]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - ".cursor/rules/00-core-principles.mdc"
  - ".cursor/rules/01-git-workflow.mdc"
  - ".cursor/rules/02-pattern-discovery.mdc"
  - ".cursor/rules/README.md"
verified_against: "fd0fc6a"
---

# Cursor Rules: Core Family (00-02)

If you work in Cursor on this harness, these three rules are already in your context whether you
asked or not. They are the only rules in the [Cursor surface](../cursor.md) carrying
`alwaysApply: true` with no globs — the baseline every Cursor conversation starts from.

## The three members

- `00-core-principles.mdc` (84 lines) — SAFe methodology, the
  [Round Table Philosophy](../../methodology/round-table-philosophy.md) trio of equal voice, mutual
  respect, and shared responsibility, search-first-reuse-always,
  [evidence-based delivery](../../methodology/evidence-based-delivery.md), and the 11 agent roles.
- `01-git-workflow.mdc` (92) — branch naming, commit format, rebase-first, PR process.
- `02-pattern-discovery.mdc` (84) — declares pattern discovery MANDATORY before implementing
  anything: search `patterns_library/`, then `specs/`, then the codebase.

## Why always-on, and what that costs

Fifteen of the surface's 18 rules set `alwaysApply: false`; only these three take permanent
residence. That is a deliberate budget. Everything here is either a rule you would violate silently
without knowing it (commit format, branch names) or one whose whole value is firing before you type
— which is why [Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md) lives
here rather than behind a manual invocation. A discovery protocol you must remember to invoke has
already failed.

## Where they hand off

`01-git-workflow.mdc` is the default destination for single-ticket work: the methodology rule
`03-safe-ai-dlc.mdc` explicitly redirects there when work does not span multiple issues. See
[Methodology Family](methodology.md) for that boundary. Per the README's DRY design principle,
these rules reference their sources — [CLAUDE.md](../../../../CLAUDE.md),
[AGENTS.md](../../../../AGENTS.md), `patterns_library/` — instead of restating them.

## What they cannot do

Nothing here executes. `.mdc` rules are context injection: no exit codes, no gate, no failure mode.
A rule declaring pattern discovery mandatory is addressed to a reader, not a check. For enforcement
you would want a hook or a CI job, and for pattern discovery this repo has neither.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the rule index and numbering scheme.
