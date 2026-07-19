---
type: command
title: "/pre-pr"
description: "Mandatory pre-PR gate: CI suite, markdown lint, clean tree, rebase onto dev, commit-format audit."
tags: [commands, operations, gates, ci, workflow]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/pre-pr.md"
sources:
  - ".claude/commands/pre-pr.md"
  - ".gemini/commands/workflow/pre-pr.toml"
verified_against: "fd0fc6a"
---

# /pre-pr

The last gate before a pull request exists. Run when work is believed done and the operator is about
to push — four of its seven steps can hard-stop the run.

## Overview

Runs the CI suite, fixes and re-checks markdown lint, demands a clean tree, rebases onto `dev`, and
audits every commit message for the SAFe format. It follows [`/end-work`](end-work.md) and ends in
`git push --force-with-lease` plus `gh pr create`, citing `CONTRIBUTING.md` as mandatory authority.

## Invocation

- `/pre-pr` — no arguments; operates on the current branch. `/workflow:pre-pr` on Gemini.
- Precondition: a feature branch with commits ahead of `origin/dev`.

## What It Does

- Runs `yarn ci:validate` — **BLOCKER**.
- Runs `yarn lint:md:fix`, then `yarn lint:md` to confirm — the one non-blocking step of the four.
- Requires a clean `git status`, allowing no uncommitted changes into the PR — **BLOCKER**.
- Runs `git fetch origin && git rebase origin/dev` — **BLOCKER**.
- Audits the dev-to-HEAD log against `type(scope): description [PREFIX-XXX]` — **BLOCKER**.
- Walks a doc-update checklist, confirms the six PR-template sections, reports PASS/WARNING/BLOCKER.

Two drifts: the Workflow section says "execute steps 1-6 in order" while the checklist defines
seven; and `ci:validate` is described here with format checking, which [`/local-sync`](local-sync.md) omits.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | rebases onto `origin/dev` and blocks on failure |
| Gemini | targets `origin/main`; never runs `git rebase` |
| Gemini | runs `git log HEAD..origin/main` and merely advises rebasing |
| Gemini | appends `\|\| echo ... completed` to `ci:validate` and both `lint:md` calls |

That last wrapper defeats the BLOCKER semantics the same file asserts — on Gemini it cannot fail.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the authority the command defers to.
- [Pre-PR Validation Checklist](../../sop/PRE_PR_VALIDATION_CHECKLIST.md) — the checklist in full.
