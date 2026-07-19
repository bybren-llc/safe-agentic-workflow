---
type: command
title: "/local-deploy"
description: "Deploys the latest registry Docker image to the local Docker daemon in dev or staging mode."
tags: [commands, operations, ci]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/local-deploy.md"
sources:
  - ".claude/commands/local-deploy.md"
  - ".gemini/commands/local/deploy.toml"
verified_against: "fd0fc6a"
---

# /local-deploy

Pulls the current registry image onto the local Docker daemon so a change can be exercised in a
container. Reached when the operator wants the built artifact, not the source tree, in front them.

## Overview

Seven ordered steps: parse flags, report pre-deploy state, optionally trigger and wait on a CI
build, deploy, verify health, tail logs, print a report. Container work is delegated to
`./scripts/dev-docker.sh` — this is an orchestration wrapper, not a deployer.

## Invocation

- `/local-deploy` — dev mode against the local dev stack; `--staging` targets the staging stack.
- `/local-deploy --rebuild` — triggers the CI image build first and blocks until it completes.
- `/local:deploy` on the Gemini surface.

## What It Does

- Parses flags into `MODE` and `REBUILD` shell variables.
- Reports pre-deploy state: `docker ps`, an image-revision `docker inspect`, and `origin/dev`'s tip.
- On `--rebuild`, runs `gh workflow run`, polls every 30s, exits 1 on a non-success conclusion.
- Deploys via `./scripts/dev-docker.sh deploy` for staging, or `pull` then `restart` for dev.
- Verifies with `docker ps` and a `curl` against `/api/health` on port 3000 (dev) or 3001 (staging).
- Tails 50 log lines and prints a deployment report.
- Documents failure modes — bad workflow, build, pull, ports, health — each with a diagnostic.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | targets `origin/dev` and the "Build and Push Dev Docker Image" workflow |
| Gemini | targets `origin/main` and "Build and Push Docker Image" — different branch and workflow |
| Gemini | drops the `--both` mode, port tables, mode-switching section and report template |

Two drifts sit inside the Claude file. Its Deployment Modes table documents a `--both` flag the
step-1 parser never reads, so `--both` falls through to dev mode. Its Related Commands list names
three absent files — `/local-health`, `/local-logs`, `/local-restart`; a fourth, `/local-rollback`,
is offered only in the failure-handling prose, hedged with "(when available)".

## Citations

- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the image build and registry flow.
