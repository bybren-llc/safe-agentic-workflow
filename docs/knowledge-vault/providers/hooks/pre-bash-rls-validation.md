---
type: script
title: "Hook: pre-bash-rls-validation.sh"
description: "Inspects a bash command for Prisma/psql usage and warns when no RLS context helper is present; blocks nothing."
tags: [providers, hooks, security]
timestamp: 2026-07-19
status: active
domain: providers
resource: ".claude/hooks/pre-bash-rls-validation.sh"
sources:
  - ".claude/hooks/pre-bash-rls-validation.sh"
  - "agent_providers/claude_code/hooks/pre-bash-rls-validation.sh"
  - ".claude/hooks-config.json"
verified_against: "fd0fc6a"
---

# Hook: pre-bash-rls-validation.sh

Takes a bash command as a string, decides whether it touches the database, and prints a warning if
no Row Level Security context helper appears in it. It is advisory only: every path exits zero, so
it can slow nobody down and stop nothing. Nothing destructive happens either way.

## Overview

It backstops the RLS helper contract described in [RLS Patterns](../../skills/rls-patterns.md) —
the rule that database access goes through `withUserContext`, `withAdminContext`, or
`withSystemContext` rather than a bare client. It needs only `bash` and `grep`. It is
byte-identical to its mirror at `agent_providers/claude_code/hooks/pre-bash-rls-validation.sh`.

## Inputs & Outputs

- **In** `$1` — the bash command string, taken as a positional argument rather than from stdin JSON.
- **In** the match chain: if the command matches `npx prisma`, `psql`, or `DATABASE_URL`, it then
  looks for one of the three context helpers and allows; failing that it checks for
  `prisma migrate`, `prisma generate`, or `prisma studio` and allows those as schema operations.
- **Out** `stdout` — a WARNING naming the three helpers when a database command carries none.
- **Exit** `0` — on all four paths: helper found, schema operation, missing context, and
  non-database command.

## Invoked By

- Nothing. `.claude/hooks-config.json` declares no PreToolUse matcher for this file, and defines no
  Bash matcher that would pass `$1` in the first place. Dead code as committed.
- DOC DRIFT: the script header declares "Exit code 2: Block operation", but no `exit 2` exists
  anywhere in the file; the missing-context branch is annotated "Allow but warn".
- DOC DRIFT: it is the only mechanical check for the RLS rule that root `CLAUDE.md` states as
  mandatory ("Never use direct SQL or bypass RLS policies"), and it is structurally incapable of
  enforcing it.

## Citations

- [CLAUDE.md](../../../../CLAUDE.md) — the mandatory RLS helper rule this hook only warns about.
