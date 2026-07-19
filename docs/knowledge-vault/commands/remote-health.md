---
type: command
title: "/remote-health"
description: "Read-only eight-step remote health sweep over SSH, ending in a scored dashboard."
tags: [commands, operations, testing]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/remote-health.md"
sources:
  - ".gemini/commands/remote/health.toml"
verified_against: "fd0fc6a"
---

# /remote-health

The read-only sweep you run when the remote host feels wrong but you do not know which layer is at
fault. It ends in a scored dashboard rather than a yes/no.

## Overview

Eight ordered steps, none of which mutate anything: container state, host resources, HTTP health,
Postgres, Redis, recent errors, image revision, then the dashboard. It is the canonical target of the
deprecated `/dev-health` alias and the usual first stop before [`/remote-logs`](remote-logs.md) or
[`/remote-rollback`](remote-rollback.md).

## Invocation

- `/remote-health` — no arguments.
- `/remote:health` on the Gemini surface.
- Precondition: SSH access to `{{REMOTE_HOST}}` using the key at `{{SSH_KEY_PATH}}`.

## What It Does

- `docker ps --filter name={{PROJECT}}` plus `docker inspect --format State.Health.Status`.
- `docker stats --no-stream`, `df -h /`, and `docker system df` for resource pressure.
- `curl -s -w` against `{{APP_PORT}}` capturing both `http_code` and `time_total`.
- `pg_isready -U {{DB_USER}}` in `{{DB_CONTAINER}}`; `redis-cli ping` in `{{REDIS_CONTAINER}}`.
- `docker logs --since 5m` grepped for error, fatal and exception, tailed to 10 lines; then
  `docker inspect` for `org.opencontainers.image.revision`.

The health score is a six-criterion additive rubric summing to 100: containers running (+30), health
checks passing (+20), resource usage under 80% (+15), no recent errors (+15), response time under
500 ms (+10), database and Redis responding (+10). Bands: 90-100 Excellent, 70-89 Good, 50-69
Degraded, 0-49 Critical.

Critical alerts fire on a stopped container, a down health endpoint, an unreachable database, or
disk above 90%. Warnings fire on response over 1 s, memory over 80%, or an error spike in 5 minutes.

## Provider Parity

- Gemini — keeps the identical scoring rubric but omits `docker system df` from the resource step.
- Gemini — drops the Alert Conditions section entirely.
- Gemini — greps with `grep -iE 'error|fatal|exception'` where Claude uses an escaped alternation.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — where the revision it reads is set.
