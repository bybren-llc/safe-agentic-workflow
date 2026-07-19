---
type: domain
title: "Operations Domain"
description: "Running the harness day to day: four CI workflows, the release gate, maintenance scripts, commands."
tags: [operations, ci, release, commands, onboarding]
timestamp: 2026-07-19
status: active
domain: operations
verified_against: "fd0fc6a"
---

# Operations Domain

What actually executes — and where the gap between claimed gates and real ones is widest.

## Overview

Owns the four GitHub workflows, ten maintenance scripts, the release gate, and the 35 command cards.
Its subject is *enforcement*: methodology declares gates, this domain says which fire. It does not
own provider surfaces ([Providers](providers.md)) or the sync tests ([Sync](sync.md)) it runs.

## Members

Automation that runs on push:

- [ci.yml](../operations/workflows/ci.md) — unparseable as shipped, so it never runs at all.
- [pr-validation.yml](../operations/workflows/pr-validation.md) — only its rebase check can fail.
- [test-fork-sync.yml](../operations/workflows/test-fork-sync.md) — the only asserting workflow.
- [docker-build.yml](../operations/workflows/docker-build.md) — opt-in for PRs via label.
- [project_workflow scaffold](../operations/project-workflow.md) — inert; GitHub reads only the root.

Scripts, the release gate, and the commands an operator types:

- [setup-template](../operations/scripts/setup-template.md) — replaces 30 placeholder tokens.
- [pre-release-check](../operations/scripts/pre-release-check.md) — runs every test suite; the only
  automation that blocks on one failing.
- [generate-changelog](../operations/scripts/generate-changelog.md) — classifies `.claude/` only.
- [Release Process](../operations/release/release-process.md) — the human half of shipping.
- [/start-work](../commands/start-work.md) and [/release](../commands/release.md) head 35 such cards.

## Key Flows

**A working day.** [/start-work](../commands/start-work.md) states the stop-the-line gate,
[/pre-pr](../commands/pre-pr.md) validates locally, and `pr-validation.yml` then fails the PR only
for being behind base.

**A release.** The [checklist](../operations/release/pre-release-checklist.md) is worked by hand, then
[pre-release-check](../operations/scripts/pre-release-check.md) re-runs the verifiable parts,
including all nine sync suites, exiting 1 on failure. Only then is a tag cut.

**What truly gates.** A PR touching only `.claude/` or `docs/` fires no asserting workflow: `ci.yml`
cannot load, `docker-build.yml` needs a label, `test-fork-sync.yml` needs a path match — the real
gates are the review chain in [Methodology](methodology.md) and the release script.

## Citations

- [CI-CD-Pipeline-Guide.md](../../ci-cd/CI-CD-Pipeline-Guide.md) — names two nonexistent workflows.
- [PRE-RELEASE-CHECKLIST.md](../../release/PRE-RELEASE-CHECKLIST.md) — the mandatory manual gate.
