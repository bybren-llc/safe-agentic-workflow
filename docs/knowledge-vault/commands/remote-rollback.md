---
type: command
title: "/remote-rollback"
description: "Rolls the remote environment back to a prior image by pinning the compose tag and verifying health."
tags: [commands, operations, release]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/remote-rollback.md"
sources:
  - ".gemini/commands/remote/rollback.toml"
verified_against: "fd0fc6a"
---

# /remote-rollback

The break-glass command. A deploy went bad, health is failing, and the fastest safe move is to pin
the remote environment to the previous image. It mutates remote state — read that section first.

## Overview

Ten ordered steps: assess current revision, list candidates, choose a target, pull it, back up and
rewrite the compose file, restart, verify, act on the outcome, report, and — on the Claude side
only — restore to `:latest`. It is the canonical target of the deprecated `/rollback-dev` alias, and
step 10 hands back to [`/remote-deploy`](remote-deploy.md).

## Invocation

- `/remote-rollback` — offers the last five images and defaults to the one before current.
- `/remote-rollback <commit-sha>` — uses the argument directly, skipping confirmation.
- `/remote:rollback` on the Gemini surface.

## What It Does

- Reads the current revision via `docker inspect`, with a staging-then-dev fallback chained on `||`,
  and curls the health endpoint.
- Lists candidates from `docker images {{REGISTRY}}/{{IMAGE_NAME}}` and
  `git log origin/{{MAIN_BRANCH}} -10 --oneline`.
- Pulls the target tag, falling back to a locally cached image if the registry has pruned it.
- **Mutates remote state**: copies `{{COMPOSE_FILE}}` to a timestamped `.backup`, then `sed -i`
  rewrites `:latest` to the pinned tag in place. That backup is the only safety net.
- Restarts through `{{DOCKER_SCRIPT}} restart`, tails 50 log lines, then verifies containers, health
  and revision.
- On success files a Linear ticket labelled `bug` and `deployment-rollback` and notifies Slack; on
  failure tries an older image, checks environment (database, Redis, config), then escalates.

## Provider Parity

- Gemini — omits step 10 (restore to latest) and the explicit `sed -i` command, saying only "update
  docker-compose file to use specific image tag".
- Gemini — drops the `bug` / `deployment-rollback` label instruction and the Error Handling section.
- Gemini — hardcodes `origin/main` where Claude parameterizes the main branch.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — image tagging scheme the pinned tag
  relies on.
