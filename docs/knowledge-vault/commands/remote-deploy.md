---
type: command
title: "/remote-deploy"
description: "One SSH call runs the remote deploy script, then health and container revision are verified."
tags: [commands, operations, ci]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/remote-deploy.md"
sources:
  - ".gemini/commands/remote/deploy.toml"
verified_against: "fd0fc6a"
---

# /remote-deploy

Reached for when a merged commit needs to be running on the remote host. The command is thin: it
delegates the deploy itself to a remote script and spends its own effort on verification.

## Overview

One SSH invocation runs `{{DEPLOY_SCRIPT}}` inside `{{PROJECT_PATH}}` on `{{REMOTE_HOST}}`. The four
deploy sub-steps the file describes — pull image, start the staging compose without source mounts,
wait for the health check, report the revision — are asserted as things the script "should handle",
not steps the command performs. Expected duration is 2-5 minutes. It is the canonical target of the
deprecated `/deploy-dev` alias, and `/remote-status` is the natural precursor.

## Invocation

- `/remote-deploy` — no arguments; the target host and script come from placeholders.
- `/remote:deploy` on the Gemini surface.
- Preconditions: SSH reachability with the key at `{{SSH_KEY_PATH}}`, and a valid registry session.

## What It Does

- Runs `ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}}` with a single `cd && deploy` payload.
- Verifies HTTP health via `curl` against `{{STAGING_PORT}}`, piped through `jq`.
- Verifies the container with `ssh 'docker ps --filter name={{CONTAINER_NAME}}'`.
- Success criteria: container healthy, health endpoint returns 200, image revision matches the
  latest commit.
- Failure routing: pull failed points at expired registry auth (`docker login {{REGISTRY}}`) or a
  full disk (`df -h`); health-check failure routes to logs, database checks, then
  [`/remote-rollback`](remote-rollback.md).

Open question: `{{DEPLOY_SCRIPT}}` has no in-repo referent, so the real deploy sequence cannot be
verified from this repository — the four sub-steps above are the command's claim, not observed
behaviour.

## Provider Parity

- Gemini — near-identical procedure, using single-brace `{PLACEHOLDER}` form and `/remote:`
  namespaced cross-references.
- Gemini — drops the Customization Guide table and the boxed customization banner comments.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the build and publish pipeline that
  produces the image this command deploys.
