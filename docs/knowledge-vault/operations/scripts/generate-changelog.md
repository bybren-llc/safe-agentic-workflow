---
type: script
title: "generate-changelog.sh"
description: "Generates a structured changelog between two git refs, categorizing harness file changes for release notes."
tags: [operations, release, ci]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/generate-changelog.sh"
sources:
  - "scripts/generate-changelog.sh"
verified_against: "fd0fc6a"
---

# generate-changelog.sh

Reads git history between two refs and emits a categorized changelog of what changed inside the
`.claude/` harness. Read-only: it writes to stdout and makes no network calls.

## Overview

Harness release notes are a different problem from application ones: what matters is which harness
files appeared, changed, or broke compatibility, not which functions moved — so it sorts paths into
five buckets rather than listing raw commits. 601 lines of bash under `set -euo pipefail` across 15
functions. Pipeline: `parse_args`, `validate_ref` on both refs, `collect_changes`
(`git diff --name-status`), `classify_file` per path, `emit_yaml`/`emit_markdown`.

`classify_file` is first-match-wins, and rule one is an override: a rename (`R*`) or deletion (`D`)
is **always** `BREAKING`, outranking every path rule. Then `.claude/agents/*.md` and
`.claude/skills/*/SKILL.md` to `METHODOLOGY`; `.claude/commands/*.md` to `NEW_FILE` when added else
`UPDATED_FILE`; top-level `.claude/*.json` and `.claude/hooks/*` to `CONFIG`; top-level
`.claude/*.md` to `UPDATED_FILE`; other added files to `NEW_FILE`; default `UPDATED_FILE`.

## Inputs & Outputs

- **In** `--from <ref>` / `--to <ref>` — the git range; both default empty and both `die` if unset.
- **In** `--format` `yaml` (default) or `markdown`, anything else rejected; `--version` release
  label, derived from `--to` minus a leading `v` when omitted; `--summary` one-liner; `--help`.
- **Out** stdout — output matching the `HARNESS_CHANGELOG.yml` schema, with `SCHEMA_VERSION` pinned
  to `1.0.0` inside the script. ANSI colour is disabled when stdout is not a tty.
- **Out** categories — `NEW_FILE`, `UPDATED_FILE`, `METHODOLOGY`, `BREAKING`, `CONFIG`.
- **Caveat — classification is `.claude/`-only** every path rule is anchored to `^\.claude/`, yet
  `.gemini/`, `.codex/`, `.cursor/`, `.agents/` and `dark-factory/` are all legal sync domains.
  Changes there fall through to the `NEW_FILE`/`UPDATED_FILE` default and can never be tagged
  `METHODOLOGY` or `CONFIG` — a rewritten Gemini agent reads as an ordinary file edit.
- **Caveat** no test suite covers this script — there is no `tests/test-changelog*.sh`.

## Invoked By

- Intended for the release flow, consuming git history rather than the sync engine — see
  [Release Process](../release/release-process.md).
- **UNKNOWN**: no caller found in `scripts/` or `tests/`; whether any command, hook, or CI workflow
  invokes it, and whether a `HARNESS_CHANGELOG.yml` is ever committed here, is unresolved.

## Citations

- [Release Changelog Template](../../knowledge/misc/release-changelog-template.md) — the changelog
  shape this output is meant to populate.
