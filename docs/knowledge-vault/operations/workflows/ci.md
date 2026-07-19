---
type: integration
title: "CI Workflow (ci.yml)"
description: "Template CI workflow running lint, type-check and test on push/PR to main and dev."
resource: ".github/workflows/ci.yml"
tags: [operations, ci, gates, workflow]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".github/workflows/ci.yml"
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# CI Workflow (ci.yml)

The GitHub Actions workflow named `CI`, intended to run lint, type-check, and test on every push and
pull request against `main` and `dev`. **As shipped it gates nothing**: the file is not valid YAML,
so GitHub Actions rejects it and it never runs. It becomes loadable only after
[setup-template.sh](../scripts/setup-template.md) substitutes its placeholders.

## Overview

One job, `validate`, on `ubuntu-latest`. A concurrency group keyed on
`github.workflow`-`github.ref` with `cancel-in-progress: true` supersedes older runs on the same
ref. A `build` job is present but fully commented out.

## Touchpoints

| Touchpoint | Direction | Artifact |
| --- | --- | --- |
| Trigger on push and pull_request to `main`, `dev` | inbound | `.github/workflows/ci.yml` |
| Checkout | outbound | `actions/checkout@v4` |
| Node toolchain and dependency cache | outbound | `actions/setup-node@v4` |
| Frozen-lockfile install, then lint, type-check, test | outbound | placeholder run commands |

## Configuration

- `NODE_VERSION` — feeds `node-version` on `setup-node`.
- `PACKAGE_MANAGER` — feeds the `cache` key and the install and script invocations.
- `LINT_COMMAND`, `TYPE_CHECK_COMMAND`, `TEST_COMMAND` — the three validation steps.
- All five are unsubstituted template placeholders at this baseline. Key names only.

## Failure Modes & Health

- **Hard failure, present today**: `yaml.safe_load` fails with `expected <block end>, but found
  <scalar>` at line 39 col 34, because an unquoted `{{PACKAGE_MANAGER}}` inside a `run:` value
  parses as a YAML flow mapping. The workflow never runs and cannot block a PR.
- No health signal exists while the file is unparseable; the absence of a check is silent. Once
  substituted, a failing lint, type-check, or test step fails the `validate` job.
- **DOC DRIFT**: the CI/CD guide names `multi-team-collaboration.yml` and `branch-protection.yml` as
  the core workflows; neither exists. The four real files are `ci.yml`, `docker-build.yml`,
  `pr-validation.yml`, `test-fork-sync.yml`.

## Citations

- [CI/CD Pipeline Guide](../../../ci-cd/CI-CD-Pipeline-Guide.md) — the pipeline description drifted.
