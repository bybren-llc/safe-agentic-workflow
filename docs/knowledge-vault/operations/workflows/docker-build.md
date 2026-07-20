---
type: integration
title: "Docker Build Workflow (docker-build.yml)"
description: "Builds and pushes a container image on push to main/dev or on a labeled PR."
resource: ".github/workflows/docker-build.yml"
tags: [operations, ci, workflow]
timestamp: 2026-07-20
status: active
domain: operations
sources:
  - ".github/workflows/docker-build.yml"
  - "scripts/setup-template.sh"
verified_against: "0c26121"
---

# Docker Build Workflow (docker-build.yml)

The workflow named `Docker Build` publishes a container image to a registry using the GitHub
Actions Docker toolchain. It is valid YAML and does run, but for pull requests it is **opt-in**:
an unlabeled PR never triggers it, so by default it gates nothing.

## Overview

A single `build` job, guarded by `if:` — the event is a push, or it is a pull request whose labels
contain `build-docker-image`. Permissions are `contents: read` and `packages: write`. Layer caching
uses the GitHub Actions cache backend (`type=gha`, `mode=max`) in both directions.

## Touchpoints

| Touchpoint | Direction | Artifact |
| --- | --- | --- |
| Trigger on push to `main`/`dev`, PR `types: [labeled]` | inbound | `.github/workflows/docker-build.yml` |
| Checkout and buildx setup | outbound | `actions/checkout@v4`, `docker/setup-buildx-action@v3` |
| Registry login as `github.actor` | outbound | `docker/login-action@v3` |
| Tag computation | outbound | `docker/metadata-action@v5` |
| Build and push with GHA cache | outbound | `docker/build-push-action@v5`, `push: true` |

## Configuration

- `REGISTRY`, `IMAGE_NAME` — workflow-level `env` keys, both unsubstituted template placeholders at
  this baseline. Key names only.
- `secrets.GITHUB_TOKEN` — supplied as the registry password.
- Tag rules: `type=ref` for PRs with prefix `pr-`; `type=ref` for branches; `type=raw` `latest`
  enabled only when `github.ref` is `refs/heads/main`; `type=sha` with prefix `sha-`.

## Failure Modes & Health

- Unsubstituted `REGISTRY` / `IMAGE_NAME` make both the login and the push fail.
- There is no `Dockerfile` at the repository root at this baseline, so the build step has nothing to
  build.
- A build failure fails the check — but only on runs that were triggered at all.
- **DOC DRIFT**: the final step is echo-only and prints a pull command using `github.sha` as the
  tag, while `metadata-action` emits sha tags with the `sha-` prefix. The printed command therefore
  references a tag that was never pushed.

## Citations

- [CI/CD Pipeline Guide](../../../ci-cd/CI-CD-Pipeline-Guide.md) — repository pipeline overview.
