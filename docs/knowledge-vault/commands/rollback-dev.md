---
type: command
title: "/rollback-dev"
description: "Pre-rename rollback for the dev machine: superseded in naming by /remote-rollback, still executable."
tags: [commands, operations, release]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/rollback-dev.md"
sources:
  - ".claude/commands/README.md"
verified_against: "fd0fc6a"
---

# /rollback-dev

The odd one out of the five pre-rename command names: four siblings became thin deprecated wrappers,
this one kept a full 272-line executable procedure and no deprecation banner.

## Overview

Step for step it mirrors [`/remote-rollback`](remote-rollback.md): assess, list candidates, choose,
pull, back up and rewrite the compose file, restart, verify, act on outcome, report, restore. The
difference is parameterization, not intent — the two files are divergent forks of one procedure.

## Invocation

- `/rollback-dev` — offers the last five images and asks for confirmation.
- `/rollback-dev <commit-sha>` — declared in the `argument-hint`; used directly.
- Claude-only. There is no Gemini counterpart.

## What It Does

- Reads the running revision from the dev app container and curls health on port 3000.
- Lists `docker images` for the dev registry path and `git log origin/dev -10 --oneline`.
- Pulls the chosen `dev-{sha}` tag.
- **Mutates remote state**: copies `docker-compose.dev.yml` to a timestamped backup, then `sed -i`
  rewrites `:latest` to the pinned tag in place. That backup is the only safety net.
- Restarts via `./scripts/dev-docker.sh restart`, tails 50 lines, verifies containers, health and
  revision, then files a Linear ticket labelled `bug` and `deployment-rollback` and notifies Slack.

Doc drift, three ways. It hardcodes port 3000, the compose filename, the helper script path and the
`/dev` registry segment, all of which `/remote-rollback` parameterizes. Its verification steps cite
the very ticket that deprecated its four siblings, yet it was never deprecated itself. And its
restore step hands off to [`/remote-deploy`](remote-deploy.md), not to `/remote-rollback`.

The command README lists `/rollback-dev` under Deprecated Aliases, describing that table's entries as
thin wrappers pointing at canonical `/remote-*` commands and mapping this one to `/remote-rollback`.
The file itself is no wrapper. Open question: is it meant to be deprecated? No marker either way.

## Provider Parity

- Gemini — absent. No `.gemini` counterpart exists for this name.
- Claude — the only surface, and the only one of the five listed aliases that is not a wrapper.

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the image tagging scheme it pins to.
