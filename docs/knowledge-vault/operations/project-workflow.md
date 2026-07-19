---
type: guide
title: "project_workflow Scaffold"
description: "Drop-in CI/CD scaffold: CONTRIBUTING, CODEOWNERS, PR template, multi-team pipeline and a setup script."
tags: [operations, ci, workflow, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "project_workflow/CONTRIBUTING.md"
  - "project_workflow/scripts/setup-ci-cd.sh"
  - "project_workflow/.github/CODEOWNERS"
  - "project_workflow/.github/pull_request_template.md"
  - "project_workflow/.github/workflows/main.yml"
verified_against: "fd0fc6a"
---

# project_workflow Scaffold

A five-file drop-in kit for standing up multi-team CI/CD in a downstream repository. Nothing in it
is active here: GitHub only reads workflows from the repo-root `.github/workflows/`, so the
pipeline in this directory never runs. Treat it as source material, not configuration.

## What Is In The Box

Exactly five files: `CONTRIBUTING.md`, `scripts/setup-ci-cd.sh`, `.github/CODEOWNERS`,
`.github/pull_request_template.md`, and `.github/workflows/main.yml`. The workflow is named
"Multi-Team Collaboration Pipeline" and triggers on pull requests to the primary dev branch
(`opened`, `synchronize`, `reopened`, `ready_for_review`), on pushes to the same branch, and on
`workflow_dispatch`. It declares the env key names `NODE_VERSION` and `YARN_CACHE_FOLDER`. Its
`validate-structure` job outputs `branch-valid` and `linear-ticket`, validating the branch against
`^__TICKET_PREFIX__-[0-9]+-[a-z0-9-]+$` and exiting nonzero on mismatch — so this scaffold gates on
branch name, where the installed [PR Validation workflow](workflows/pr-validation.md) does not.

## What The Setup Script Actually Does

`setup-ci-cd.sh` is easy to misread as an installer. It copies nothing. It checks that `gh` is
installed and authenticated (exit 1 otherwise), reads the repo owner and name via
`gh repo view --json`, manages secrets through `gh secret list`, and PUTs branch-protection rules
via `gh api`, degrading to a warning without admin access. It then merely verifies that `main.yml`,
`CODEOWNERS` and the PR template exist in the current working directory, printing any that are
missing, and finally runs `yarn ci:validate` if a `package.json` is present.

## Two Defects Worth Knowing

`main.yml` line 20 uses `if: github.event_name == "pull_request"`. GitHub Actions expressions
require single-quoted strings, so this condition is a syntax error as written. Separately, the
directory uses `__TICKET_PREFIX__` and `__PRIMARY_DEV_BRANCH__` double-underscore tokens rather
than the mustache tokens [setup-template.sh](scripts/setup-template.md) substitutes, and
`setup-ci-cd.sh` performs no substitution of its own, so the tokens survive untouched. The
scaffold's own `CONTRIBUTING.md` mixes all three dialects in one file.

Open question: nothing in the repo references this directory, so which script or documented step is
meant to copy it into a fork and resolve its tokens is UNKNOWN.

## Citations

- [project_workflow CONTRIBUTING.md](../../../project_workflow/CONTRIBUTING.md) — its own guide.
