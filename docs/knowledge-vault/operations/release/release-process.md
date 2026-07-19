---
type: process
title: "Harness Release Changelog Process"
description: "How harness releases are described: generate-changelog.sh diffs two refs into the HARNESS_CHANGELOG.yml schema."
tags: [operations, release, process]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "scripts/generate-changelog.sh"
  - "HARNESS_CHANGELOG.yml"
  - "docs/templates/RELEASE_CHANGELOG_TEMPLATE.md"
  - "docs/releases/v2.6.0-STRUCTURED-CHANGELOG.md"
  - "docs/releases/v2.9.0-STRUCTURED-CHANGELOG.md"
verified_against: "fd0fc6a"
---

# Harness Release Changelog Process

Release description here is mechanical, not editorial:
[generate-changelog.sh](../scripts/generate-changelog.md) diffs two git refs into a fixed schema,
so forks can tell a breaking harness change from a cosmetic one without reading the diff.

## Overview

The process runs on demand at release time, driven by a human invoking the script with `--from` and
`--to` refs. Its entire data source is one command: `git diff --name-status -M` scoped to
`.claude/`. Nothing outside `.claude/` is ever categorized, so a release changing only scripts,
docs or workflows produces an empty changelog. Output goes to stdout as YAML or Markdown; the
script never opens or edits `HARNESS_CHANGELOG.yml`. Enforcement is convention plus a checklist.

## Flow

- **Choose the ref span.** `--from` and `--to` are required; `validate_ref` rejects bad refs.
- **Collect the diff.** `collect_changes` reads the name-status diff restricted to `.claude/`.
- **Classify each path.** `classify_file` and `status_to_change_type` assign NEW_FILE,
  UPDATED_FILE, METHODOLOGY, BREAKING or CONFIG; `is_breaking` overrides renames and deletions to
  BREAKING, the gate that stops a silent incompatibility shipping as a routine update.
- **Emit.** `emit_yaml` or `emit_markdown` writes to stdout per `--format`; `info`, `warn` and
  `die` go to stderr so the payload stays pipeable.
- **Paste and enrich by hand.** The v2.6.0 changelog states outright that it was generated
  retroactively and then manually enriched.

## Roles Involved

- **Release owner** — runs the script and pastes the output into the release document.
- **RTE** — accountable for the release artifacts named in the
  [Pre-Release Checklist](pre-release-checklist.md), including this changelog item.
- **Tech Writer** — enriches the mechanical output into user-facing release notes.

Two discrepancies. `HARNESS_CHANGELOG.yml` claims it is "consumed by `sync-claude-harness.sh` for
automated categorization"; no such consumer exists in the repo. And its `releases:` list is empty
while v2.6.0 and v2.9.0 shipped standalone changelog documents — the file is docs, not a ledger.

## Citations

- [Release Changelog Template](../../../templates/RELEASE_CHANGELOG_TEMPLATE.md) — target shape.
- [v2.9.0 Structured Changelog](../../../releases/v2.9.0-STRUCTURED-CHANGELOG.md) — a real output.
