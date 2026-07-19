---
type: command
title: "/remote-status"
description: "Compares the SHA baked into the running remote container against the latest branch commit and CI."
tags: [commands, operations, ci]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/remote-status.md"
sources:
  - ".gemini/commands/remote/status.toml"
verified_against: "fd0fc6a"
---

# /remote-status

Answers one question before you deploy: is the running remote container the same commit as the
branch? Read-only throughout.

## Overview

Five steps — inspect the remote containers, fetch the local branch state and recent CI runs, compare
the two SHAs, render a status block, then branch guidance. It is the canonical target of the
deprecated `/check-docker-status` alias and the usual precursor to [`/remote-deploy`](remote-deploy.md).

## Invocation

- `/remote-status` — no arguments.
- `/remote:status` on the Gemini surface.
- Preconditions: SSH reachability, a `gh` session, and a fetchable `origin`.

## What It Does

- Runs `docker ps` for the dev and staging filters, greps `docker inspect` for
  `org.opencontainers.image.revision`, and reads `docker images {{REGISTRY}}:latest` CreatedAt.
- Runs `git fetch`, `git log -1 --format='%H %s'` on `{{MAIN_BRANCH}}`, and `gh run list --limit 3`.
- Compares SHAs: identical means up to date; different means an update is available and CI is checked.
- Emits guidance for four states: up to date, update with build complete, build in progress, failed.
- Failure routing: SSH failure points at VPN or the key at `{{SSH_KEY_PATH}}`; a missing container
  routes to [`/remote-deploy`](remote-deploy.md).

| Mode | Container | Port |
| --- | --- | --- |
| Dev | `{{PROJECT}}-dev` | 3000 |
| Staging | `{{PROJECT}}-staging` | 3001 |

Staging mode is recommended because it survives a `git pull` on the remote host. Doc drift: the
revision is read from a single `{{CONTAINER_NAME}}` though the preceding listing enumerates two
containers; which one supplies the SHA is unresolved in source.

## Provider Parity

- Gemini — hardcodes `origin/main` and the literal workflow name where Claude parameterizes both.
- Gemini — omits the `docker images ... CreatedAt` call and the Error Handling section.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the build workflow it inspects.
