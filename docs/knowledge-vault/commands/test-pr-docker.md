---
type: command
title: "/test-pr-docker"
description: "Labels a PR with build-docker-image to trigger a CI build, then verifies the pr-N tagged image."
tags: [commands, operations, ci, testing]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/test-pr-docker.md"
sources:
  - ".gemini/commands/test-pr-docker.toml"
verified_against: "fd0fc6a"
---

# /test-pr-docker

For when reviewing the diff is not enough and you want the PR running as a real container. The
command itself builds nothing — it flips a label and lets CI do the work.

## Overview

Five steps: resolve the PR, add the trigger label, explain the build, verify the resulting image on
a Linux host, then remove the label. The label is the whole contract — adding `build-docker-image`
starts builds for that PR, removing it stops them. Builds take roughly 5-10 minutes and produce an
image tagged `pr-{number}`.

## Invocation

- `/test-pr-docker <PR-number>` — declared in the `argument-hint`; resolved via `gh pr view`.
- `/test-pr-docker` — falls back to finding the open PR for the current branch.
- `/test-pr-docker` on the Gemini surface, passing the argument string straight through.

## What It Does

- `gh pr edit {PR} --add-label 'build-docker-image'`, confirmed with `gh pr view {PR} --json labels`.
- Points at the PR checks and offers `gh pr view {PR} --web`.
- Verification path on a Linux machine uses the `./scripts/dev-docker.sh` helper: `pull-pr {PR}`,
  then export `{{PROJECT}}_IMAGE_TAG=pr-{PR}`, then `restart`, `status`, and a curl against the local
  health endpoint. That env var is documented as the replacement for hand-editing the compose file.
- `gh pr edit {PR} --remove-label 'build-docker-image'` to stop further builds.

Three drift notes. The cleanup step tells you to revert the compose file, a mechanism the
verification step explicitly moved away from in favour of the image-tag env var. The success
criteria claim hot-reload is verified, but no step exercises or checks it. And the Actions link is
missing its host, rendering as a scheme followed directly by the org path.

## Provider Parity

- Gemini — passes its argument straight into `gh pr edit` and `gh pr view` with no fallback for the
  no-argument case its own first step describes.
- Gemini — drops the compose-file alternative and the Customization Guide.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the label-triggered build workflow
  this command depends on.
