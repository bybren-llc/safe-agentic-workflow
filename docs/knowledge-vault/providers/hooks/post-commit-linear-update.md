---
type: script
title: "Hook: post-commit-linear-update.sh"
description: "Extracts a Linear ticket ID from the latest commit message and prints a suggested Linear comment; never calls Linear."
tags: [providers, hooks, workflow]
timestamp: 2026-07-20
status: active
domain: providers
resource: ".claude/hooks/post-commit-linear-update.sh"
sources:
  - ".claude/hooks/post-commit-linear-update.sh"
  - "agent_providers/claude_code/hooks/post-commit-linear-update.sh"
  - ".claude/hooks-config.json"
  - ".claude/README.md"
verified_against: "0c26121"
---

# Hook: post-commit-linear-update.sh

Reads the most recent commit, looks for a Linear ticket ID in its subject, and prints a suggested
MCP call for a human or TDM agent to run. It writes nothing and calls no API, so running it is
entirely safe and entirely inert. The name promises an update the body does not perform.

## Overview

It exists to close the loop between a commit and its Linear ticket without granting a hook network
access — the automation stops at a suggestion. It needs only `bash` and `git`; there is no Linear
client dependency because no Linear call is made. It is byte-identical to its mirror at
`agent_providers/claude_code/hooks/post-commit-linear-update.sh`.

## Inputs & Outputs

- **In** `git log -1 --format=%H` and `--format=%s` — the hash and subject of the latest commit.
- **In** the subject is grepped for `{{TICKET_PREFIX}}-[0-9]+`. That is the literal placeholder
  token, not a substituted prefix, so the pattern matches nothing until token substitution runs.
- **Out** `stdout` — a suggested `mcp__{{MCP_LINEAR_SERVER}}__create_comment` invocation.
- **Out** nothing else: no file written, no network request, no Linear mutation.
- **Exit** `0` — on success, on no ticket found, and on a missing commit hash alike. Nothing in the
  script can fail a commit.

## Invoked By

- Nothing. `.claude/hooks-config.json` has no matcher that runs this file; it is dead code as
  committed.
- DOC DRIFT: `.claude/README.md` lists it under wired hook scripts "actively wired via
  hooks-config.json". The `Bash.*git\s+commit` matcher there runs an inline echo about commit
  format and never invokes this script.
- DOC DRIFT: the script header comment says "Auto-updates Linear ticket with commit hash" while its
  own trailing comment concedes the "actual Linear update done by TDM agent".

## Citations

- [.claude README](../../../../.claude/README.md) — the hook inventory, including the wiring claim
  this concept contradicts.
