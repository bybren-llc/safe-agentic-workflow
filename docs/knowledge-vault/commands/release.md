---
type: command
title: "/release"
description: "Six-phase version release: validate, merge PRs, bump version, tag, sync branches, clean up."
tags: [commands, operations, release, ci, gates]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/release.md"
sources:
  - ".claude/commands/release.md"
  - ".gemini/commands/workflow/release.toml"
verified_against: "fd0fc6a"
---

# /release

The largest command in the harness and the only one that mutates remote state irreversibly. Reached
when open PRs are green and a version is ready to cut. No phase may be skipped.

## Overview

Six phases in order: pre-flight validation, PR merges, version-reference bump, tag and GitHub
Release, branch sync, cleanup. It assumes [`/pre-pr`](pre-pr.md) passed on every PR it merges.

## Invocation

- `/release <version>` — for example `v2.7.0`; an `argument-hint` is declared.
- `/release` — derives the last tag from `git tag -l 'v*'`, bumps the minor or asks.
- `/workflow:release` on Gemini. Placeholders in play: main branch, ticket prefix, org and repo.

## What It Does

- **Phase 1** — blocks unless the tree is clean, on the main branch and fully pushed; then checks
  every open PR's `mergeStateStatus` and `statusCheckRollup`.
- **Phase 2** — `gh pr merge --squash` in dependency order, rebasing dependents and waiting for CI.
- **Phase 3** — greps version references in `README.md`, `CLAUDE.md` and `CONTRIBUTING.md`, updating
  active ones only — never changelogs or KT docs — then commits and pushes.
- **Phase 4** — groups `git log $LAST_TAG..HEAD` by type, tags, publishes via `gh release create`.
- **Phase 5** — pushes the main branch onto the secondary branch, verifying both directions empty.
- **Phase 6** — deletes merged remote branches via `gh api -X DELETE`, prunes, runs `git gc`.

Phase 6 is destructive with **no confirmation gate** in the source: remote refs are deleted and
garbage collection forced without asking. The Phase 3 commit template hardcodes a
`Co-Authored-By: Claude Opus 4.6` trailer that will drift as models change.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | all six phases issue real `gh` and `git` commands |
| Gemini | prose summary only; the sole executable block is the `git tag` listing |
| Gemini | retains double-brace placeholders, unlike every other Gemini command file |

## Citations

- [Pre-Release Checklist](../../release/PRE-RELEASE-CHECKLIST.md) — the gate before Phase 1.
- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the checks Phase 1 inspects.
