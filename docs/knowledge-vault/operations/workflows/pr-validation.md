---
type: integration
title: "PR Validation Workflow (pr-validation.yml)"
description: "Checks PR rebase status, commit message format, PR title and Linear ticket reference."
resource: ".github/workflows/pr-validation.yml"
tags: [operations, ci, gates, workflow, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".github/workflows/pr-validation.yml"
  - "CONTRIBUTING.md"
verified_against: "fd0fc6a"
---

# PR Validation Workflow (pr-validation.yml)

The workflow named `PR Validation` enforces the conventions in `CONTRIBUTING.md` at PR time. Exactly
one of its four checks can fail a run — the rebase check. The other three are advisory annotations,
which makes this workflow far weaker than it reads.

## Overview

One job, `validate-pr`, `ubuntu-latest`, four shell `run` steps, no actions beyond checkout. Triggered
by `pull_request` types `opened`, `synchronize`, `reopened`, `edited` with no `paths:` filter, so it
runs on every PR. `fetch-depth: 0` serves the rebase and commit checks; title and ticket read the payload.

## Touchpoints

| Touchpoint | Direction | Artifact |
| --- | --- | --- |
| Rebase check against the base ref | inbound | `git fetch` + `git merge-base` |
| Commit message format check | inbound | `git log --format=%s base..HEAD` |
| PR title check | inbound | workflow context |
| Linear ticket reference in PR body | inbound | `env: PR_BODY` |

## Configuration

- `TICKET_PREFIX` — the only configuration key, an unsubstituted template placeholder. Until it is
  substituted the regexes match the literal string `{{TICKET_PREFIX}}`, so every real commit warns.
- No secrets and no external services are used.

## Failure Modes & Health

- **The only hard gate**: step 1 compares `rev-parse origin/<base>` to `merge-base HEAD
  origin/<base>` and, on mismatch, emits `::error::` and exits 1 — the PR must be rebased.
- Step 2 pipes commit subjects into a `while read` subshell and `grep -qE` for a conventional-commit
  prefix plus `[{{TICKET_PREFIX}}-N]`, allowlisting `^Merge` and `^` plus the generated-by marker.
  It emits `::warning::` only, and because the loop runs in a pipeline subshell no exit status could
  escape it regardless.
- Steps 3 and 4 (PR title, Linear ticket reference) emit `::warning::` only.
- **DOC DRIFT**: the CI/CD guide's Stage 1 says branch-name and PR-title violations "block PR
  progression". The implementation only warns, and there is no branch-name check here at all.

## Citations

- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — the commit, branch, and rebase conventions.
- [CI/CD Pipeline Guide](../../../ci-cd/CI-CD-Pipeline-Guide.md) — the stage description that drifts.
