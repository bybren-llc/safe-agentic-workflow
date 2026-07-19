---
type: command
title: "/remote-logs"
description: "Fetches, filters and analyses remote container logs over SSH in tail, follow and search modes."
tags: [commands, operations, testing]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/remote-logs.md"
sources:
  - ".gemini/commands/remote/logs.toml"
verified_against: "fd0fc6a"
---

# /remote-logs

The follow-up to a bad [`/remote-health`](remote-health.md) score: pull the actual log lines off the
remote host, filter them, and say what they mean. Read-only throughout.

## Overview

Six ordered steps — select a mode, fetch, pattern-filter, render per-container analysis, optionally
stream, optionally grep. Fetching goes through the `./scripts/dev-docker.sh` helper's `logs`
subcommand for all services, or plain `docker logs <container>` for one. It is the canonical target
of the deprecated `/dev-logs` alias.

## Invocation

- `/remote-logs` — defaults to the last 100 lines across all services.
- `/remote-logs --follow` (or `-f`) — streams via the helper's `--follow`.
- `/remote-logs --tail N` — declared in the `argument-hint`; see the drift note below.
- `/remote:logs` on the Gemini surface.

## What It Does

- Runs the fetch over SSH inside `{{PROJECT_PATH}}`, either through `./scripts/dev-docker.sh logs`
  or per-container `docker logs`.
- Filters three pattern classes: errors (ERROR, FATAL, Exception, stack traces), warnings (WARN,
  deprecated), and success markers (started, listening, ready, connected, successful).
- Addresses six containers across two stacks — app, database and Redis in both dev and staging —
  with `app|next`, `postgres|db` and `redis` aliases resolving to the right one.
- Offers three output modes: Compact (default, filtered), Full (raw), and Service-Specific.
- Failure routing: SSH failure suggests `ping`, `tailscale status` and a manual SSH line; a missing
  container routes to [`/remote-health`](remote-health.md) then [`/remote-deploy`](remote-deploy.md);
  permission denied suggests checking docker group membership.

Doc drift: the all-services fetch hardcodes `--tail 100` and never substitutes the parsed `N`, so
`/remote-logs --tail 500` still asks the helper for 100 lines.

## Provider Parity

- Gemini — collapses the six dev/staging containers into three generic container placeholders.
- Gemini — drops the Output Options section and the service-alias mapping.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the deployment surface whose
  containers these logs come from.
