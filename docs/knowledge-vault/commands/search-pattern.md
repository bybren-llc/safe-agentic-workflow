---
type: command
title: "/search-pattern"
description: "Codebase pattern search with optional file-type filter, categorising matches and outliers."
tags: [commands, operations, patterns]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/search-pattern.md"
sources:
  - ".gemini/commands/search-pattern.toml"
verified_against: "fd0fc6a"
---

# /search-pattern

Reached for before a refactor, or when you need to know how widely a convention is actually
followed. Read-only: it finds and categorises, it never edits.

## Overview

Four steps — parse arguments, execute the search, analyse the result set, categorise the hits. The
analysis reports total matches, files affected, common patterns and refactoring opportunities; the
categorisation sorts hits into usage patterns, contexts, variations and outliers. It serves the
[pattern discovery protocol](../methodology/pattern-discovery-protocol.md) as its search primitive.

## Invocation

- `/search-pattern <pattern>` — `$1` is a required regex.
- `/search-pattern <pattern> <file-type>` — `$2` is an optional filter: `ts`, `tsx`, `js` or `md`.
- `/search-pattern` on the Gemini surface, taking the whole argument string.

## What It Does

- On Claude it does not shell out. It specifies the built-in Grep tool by parameter table: pattern,
  type, `output_mode` of `files_with_matches` or `content`, `head_limit`, `-A`/`-B`/`-C` context, and
  multiline.
- On Gemini it shells out to `grep -r` with fixed `--include` flags, piped through `head -50`.
- Ships eight worked example searches — direct Prisma access, icon libraries, TODO/FIXME/HACK,
  deprecated markers, try/catch, `process.env.`, API route exports, and test declarations.
- Documents five use cases: pre-refactoring survey, pattern enforcement, dependency analysis,
  migration tracking, and documentation coverage.

## Provider Parity

The implementation difference is the headline fact, and it makes the Gemini form materially weaker.

- Gemini — the shelled `grep` hardcodes `--include` to `*.ts` and `*.tsx`, so the documented file-type
  argument is inert and `md` or `js` searches silently return nothing.
- Gemini — caps results at 50 lines with no way to raise it; Claude exposes `head_limit` as tunable.
- Gemini — drops the Advanced Patterns section (multiline, context flags, regex recipes) and the
  Integration with Refactoring section.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the conventions these searches are usually checking
  compliance against.
