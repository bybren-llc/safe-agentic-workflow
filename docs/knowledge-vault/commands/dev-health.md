---
type: command
title: "/dev-health"
description: "Deprecated alias that redirects to /remote-health for the remote dev environment health dashboard."
resource: ".claude/commands/dev-health.md"
tags: [commands, operations, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".claude/commands/README.md"
verified_against: "fd0fc6a"
---

# /dev-health

The retired name for the remote health dashboard. Nothing is polled and no dashboard is rendered;
the file exists so the old name resolves to a signpost instead of a missing-command error.

## Overview

Retired by the `-445` canonicalization on the `/remote-*` and `/local-*` prefixes. The canonical
replacement is [`/remote-health`](remote-health.md), which performs the actual health check. This
file carries prose only.

## Invocation

- `/dev-health` — no arguments.
- Claude-only: no Gemini counterpart.
- Precondition: none; no environment is contacted.

## What It Does

- Nothing observable. The body is redirection prose with no executable steps.
- The body claims "This command calls /remote-health" while containing no invocation — drift
  between the stated behaviour and the file's actual content.
- The frontmatter description advertises a health check the file does not perform.
- Lists the related canon commands: `/remote-health`, [`/remote-status`](remote-status.md),
  [`/remote-deploy`](remote-deploy.md), and [`/remote-logs`](remote-logs.md).
- Declares `allowed-tools` of Read, Write, Edit, Bash, Grep and Glob despite running nothing.

## Provider Parity

- Claude — present as a documentation-only alias file.
- Gemini — absent; deprecated aliases were not ported to that surface.
- `.claude/commands/README.md` — files it under "Deprecated Aliases" as a thin wrapper on the
  canonical `/remote-*` command, agreeing with the file's own DEPRECATED banner.

## Citations

- [Commands README](../../../.claude/commands/README.md) — the alias-versus-canonical catalogue.
