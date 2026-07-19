---
type: command
title: "/check-docker-status"
description: "Deprecated alias that redirects to /remote-status for checking whether the remote Docker environment needs updating."
resource: ".claude/commands/check-docker-status.md"
tags: [commands, operations, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".claude/commands/README.md"
verified_against: "fd0fc6a"
---

# /check-docker-status

A tombstone, not a command. Operators reach for it from muscle memory left over from the naming
that preceded canonicalization, and what they get is a page telling them to run something else.

## Overview

One of five entries the commands README files under Deprecated Aliases, and one of the four that are
pure prose redirects, retired by the `-445` canonicalization on the `/remote-*` and `/local-*`
prefixes. The canonical replacement is [`/remote-status`](remote-status.md), which
performs the actual Docker environment comparison. This file carries no executable steps at all.

## Invocation

- `/check-docker-status` — no arguments; nothing to pass, since nothing runs.
- Claude-only: no Gemini counterpart exists, and none is wanted for a retired name.
- Precondition: none. Reading it is the entire operation.

## What It Does

- Nothing observable. The body is prose that instructs the reader to run `/remote-status`.
- The body states "This command calls /remote-status", but the file contains no invocation of any
  kind — it is documentation-only redirection, so treat the claim as drift, not behaviour.
- Its frontmatter description still advertises a Docker environment check while the body declares
  the command deprecated — a second, narrower instance of the same drift.
- Frontmatter declares `allowed-tools` of Read, Write, Edit, Bash, Grep and Glob for a command that
  runs none of them.

## Provider Parity

- Claude — present as a documentation-only alias file.
- Gemini — absent. Deprecated aliases were never ported to the Gemini surface.
- `.claude/commands/README.md` — classifies this file under "Deprecated Aliases" as a thin wrapper
  pointing at the canonical `/remote-*` command, which matches its own DEPRECATED banner.

The deprecation lives only in the body prose; no `status: deprecated` marker appears in the
command's own frontmatter, so tooling that reads frontmatter alone will not see it.

## Citations

- [Commands README](../../../.claude/commands/README.md) — the alias-versus-canonical catalogue.
