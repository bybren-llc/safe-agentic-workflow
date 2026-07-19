---
type: command
title: "/dev-logs"
description: "Deprecated alias that redirects to /remote-logs for viewing remote dev container logs."
resource: ".claude/commands/dev-logs.md"
tags: [commands, operations, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".claude/commands/README.md"
verified_against: "fd0fc6a"
---

# /dev-logs

The retired name for remote container logs, and the most misleading of the four aliases: it still
advertises flags. Nothing is tailed, and the flags go nowhere.

## Overview

Retired by the `-445` canonicalization on the `/remote-*` and `/local-*` prefixes. The canonical
replacement is [`/remote-logs`](remote-logs.md), which actually streams the container logs. The
alias file is prose redirection with usage examples for the canonical form.

## Invocation

- `/dev-logs [--follow] [--tail N]` — an `argument-hint` is declared, but see below: the arguments
  are never parsed or forwarded.
- Claude-only: no Gemini counterpart.
- Examples in the body are written against the canonical name: `/remote-logs`,
  `/remote-logs --follow`, `/remote-logs --tail 500`.

## What It Does

- Nothing observable. The body is redirection prose with no executable steps.
- The body claims "This command calls /remote-logs" while containing no invocation of any kind.
- It is the only deprecated alias that still advertises an argument surface it does not implement —
  the declared `argument-hint` is drift, not a contract.
- Declares `allowed-tools` of Read, Write, Edit, Bash, Grep and Glob despite running nothing.

## Provider Parity

- Claude — present as a documentation-only alias file.
- Gemini — absent; deprecated aliases were not ported to that surface.
- `.claude/commands/README.md` — files it under "Deprecated Aliases" as a thin wrapper on the
  canonical `/remote-*` command, agreeing with the file's own DEPRECATED banner.

## Citations

- [Commands README](../../../.claude/commands/README.md) — the alias-versus-canonical catalogue.
