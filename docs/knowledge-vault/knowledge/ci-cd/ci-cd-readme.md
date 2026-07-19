---
type: guide
title: "CI/CD Documentation Index (SSoT stub)"
description: "Pointer to the docs/ci-cd index listing the pipeline guide, related docs and CI/CD agent owners."
tags: [operations, ci, ssot-stub, onboarding]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "docs/ci-cd/README.md"
verified_against: "fd0fc6a"
---

# CI/CD Documentation Index (SSoT stub)

A 35-line index for the `docs/ci-cd/` directory. Worth knowing mostly for what it is not: a
catalogue of one document, plus a short list of operating rules that have quietly diverged from the
rest of the harness.

## What It Indexes

Exactly one document — the [CI/CD Pipeline Guide](ci-cd-pipeline-guide.md). Everything else on the
page is a cross-link outward: to `CONTRIBUTING.md` for the git workflow and to the security
architecture document for the controls CI is expected to uphold. If you arrived here looking for a
directory of pipeline docs, there is only the one.

## Who Owns CI/CD

The index assigns two roles by name. The [RTE](../../roles/rte.md) owns PR creation and CI
validation; the [TDM](../../roles/tdm.md) owns coordination and blocker resolution when a pipeline
run stalls. That split matters in practice: a red check is an RTE problem, a red check nobody is
picking up is a TDM problem.

## The Important Notes Block

Four rules, stated as non-negotiable: rebase onto the integration branch before opening a PR, run
the CI validation script locally first, push with `--force-with-lease` rather than `--force`, and
fill in `.github/pull_request_template.md`. All four match the harness's wider
[three-stage PR review](../../methodology/three-stage-pr-review.md) posture.

## One Caveat Before You Copy Commands

The block hardcodes `yarn ci:validate` and `git rebase origin/dev`, while `CLAUDE.md` and the
sibling pipeline guide both use the `{{CI_VALIDATE_COMMAND}}` and `{{PRIMARY_DEV_BRANCH}}`
placeholders. There is no root `package.json` defining a `ci:validate` script at this baseline, so
the literal command does not run as written. Substitute your project's real validation command and
integration branch; do not paste the line.

## Citations

- [CI/CD README](../../../ci-cd/README.md) — the index this card maps.
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — the git workflow it defers to.
- [SECURITY_FIRST_ARCHITECTURE.md](../../../security/SECURITY_FIRST_ARCHITECTURE.md) — the security
  controls it cross-links.
