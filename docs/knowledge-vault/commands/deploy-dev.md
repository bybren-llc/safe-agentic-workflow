---
type: command
title: "/deploy-dev"
description: "Deprecated alias that redirects to /remote-deploy for deploying the latest Docker image to the remote dev machine."
resource: ".claude/commands/deploy-dev.md"
tags: [commands, operations, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".claude/commands/README.md"
verified_against: "fd0fc6a"
---

# /deploy-dev

The retired name for the remote dev deploy. An operator who types it is one rename behind; the page
they land on exists to point them at the canonical command rather than to ship anything.

## Overview

Retired by the `-445` canonicalization on the `/remote-*` and `/local-*` prefixes. The canonical
replacement is [`/remote-deploy`](remote-deploy.md). The file also lists its sibling canon commands
so an operator arriving here can find the whole remote lane in one place.

## Invocation

- `/deploy-dev` — no arguments; nothing is parsed and nothing is forwarded.
- Claude-only: no Gemini counterpart.
- Precondition: none, because no deployment is attempted.

## What It Does

- Nothing. The body is prose redirection with no executable steps.
- The body claims "This command calls /remote-deploy", but no invocation exists in the file — it
  instructs the reader; it does not act. Read the claim as drift.
- The frontmatter description advertises a deployment action the body never performs.
- Points onward to the canonical set: `/remote-deploy`, [`/remote-status`](remote-status.md),
  [`/remote-health`](remote-health.md), [`/remote-logs`](remote-logs.md), and
  [`/remote-rollback`](remote-rollback.md).
- Declares `allowed-tools` of Read, Write, Edit, Bash, Grep and Glob despite running nothing.

## Provider Parity

- Claude — present as a documentation-only alias file.
- Gemini — absent; deprecated aliases were not ported.
- `.claude/commands/README.md` — files it under "Deprecated Aliases" as a thin wrapper on the
  canonical `/remote-*` command, agreeing with the file's own DEPRECATED banner.

## Citations

- [Commands README](../../../.claude/commands/README.md) — the alias-versus-canonical catalogue.
