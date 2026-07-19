---
type: guide
title: "CI/CD Pipeline Guide (SSoT stub)"
description: "Pointer to the multi-team CI/CD pipeline guide covering branch protection and the rebase-first flow."
tags: [operations, ci, ssot-stub, workflow]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "docs/ci-cd/CI-CD-Pipeline-Guide.md"
verified_against: "fd0fc6a"
---

# CI/CD Pipeline Guide (SSoT stub)

A map-card for the harness's long-form account of how a pull request gets validated. Read the
source for the procedure; read this for the two places where it describes a pipeline the
repository does not have.

## What The Source Covers

The document is titled "{{PROJECT_NAME}}-app CI/CD Pipeline Guide" and ships with its template
tokens unsubstituted — `{{PROJECT_NAME}}`, `{{PRIMARY_DEV_BRANCH}}` and `{{TICKET_PREFIX}}` appear
literally. It runs Overview, Pipeline Architecture, then Workflow Stages, of which Stage 1 is
Structure Validation and Stage 2 is Rebase Status Check. Branch protection is configured by
hand through `gh api` with a `--field required_status_checks` payload near line 203, and a
loosened variant near line 396 for teams that need to relax the gate. Supporting artifacts are
named rather than reproduced: CODEOWNERS, the pull request template, and package scripts.

## Where It Diverges From The Repo

Its "Core Workflows" section names `.github/workflows/multi-team-collaboration.yml` and
`.github/workflows/branch-protection.yml`. Neither file exists. The four workflows actually
installed are [CI](../../operations/workflows/ci.md),
[Docker Build](../../operations/workflows/docker-build.md),
[PR Validation](../../operations/workflows/pr-validation.md) and
[Fork Sync Tests](../../operations/workflows/test-fork-sync.md). The multi-team pipeline the guide
describes does exist, but as an uninstalled template inside the
[project_workflow scaffold](../../operations/project-workflow.md), and GitHub never reads workflows
from there.

The second drift is a gate that is not a gate. The guide states that Stage 1 branch-name and
PR-title failures block a PR from progressing; the installed `pr-validation.yml` emits only
`::warning::` annotations for title and commit-message checks and performs no branch-name check at
all. Treat Stage 1 as advisory unless you install the scaffold pipeline, which does enforce the
branch-name regex.

## How To Read It

Take the architecture and the branch-protection commands as authoritative. Take the workflow
filenames and the blocking claims as aspirational, and check the installed workflow concepts above
before relying on a check to stop bad work.

## Citations

- [CI-CD-Pipeline-Guide.md](../../../ci-cd/CI-CD-Pipeline-Guide.md) — the authoritative pipeline
  document this card maps.
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — the branch and commit conventions it assumes.
