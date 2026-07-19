---
type: sop
title: "Pre-Release Checklist"
description: "Mandatory manual gate completed before any release tag is created."
resource: "docs/release/PRE-RELEASE-CHECKLIST.md"
tags: [operations, release, gates, process, ssot-stub]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "docs/release/PRE-RELEASE-CHECKLIST.md"
verified_against: "fd0fc6a"
---

# Pre-Release Checklist

**A map-card. The checklist lives in the document cited below — do not copy the items here.**

## Overview

The document declares itself MANDATORY: no release proceeds until every item resolves. It opens
with a release information block (version, release branch `main`, previous version, Linear epic and
stories, release owner, date) and then runs eight numbered sections — Code Quality Gates,
Documentation Completeness, Third-Party Integration Verification, SAFe Workflow Gates, Template
Compatibility, Backward Compatibility, Release Artifacts, Post-Release Verification. Enforcement is
a human ticking boxes; no hook, script, or workflow in the repository reads this file.

## When It Applies

- Before creating any release tag or GitHub Release from `main`.
- Section 7 governs the tagging act itself: `git tag -a`, `git push origin main --tags`, and the
  GitHub Release.
- Section 8 runs after the tag exists, verifying via `gh release view` and requiring
  `git branch --list 'SAW-*'` to come back empty.
- Section 3 applies whenever a provider integration changed: vendor docs must be re-checked for
  Claude Code, Codex CLI, Cursor and Gemini, and fabricated config formats are forbidden.
- It does not apply to ordinary feature merges into the integration branch — that path is governed
  by the pre-PR validation checklist, not this one.

## Affected Concepts

- [Harness Release Changelog Process](release-process.md) — section 2 requires
  `HARNESS_CHANGELOG.yml` be updated or regenerated for the release.
- [Fork Sync Tests](../workflows/test-fork-sync.md) — section 1 names all eight suites by filename
  with expected pass counts; CI runs only six of them, omitting `test-patch-generation.sh` and
  `test-manifest-init.sh`, so two named suites are not CI-verified.
- [QAS](../../roles/qas.md) and [Security Engineer](../../roles/security-engineer.md) — section 4
  lists their gates as non-collapsible, alongside System Architect Stage 1 of the
  [three-stage PR review](../../methodology/three-stage-pr-review.md).
- Section 1 also gates on `bash -n` over `scripts/sync-claude-harness.sh`, a grep for conflict
  markers, and `shellcheck scripts/*.sh`.

Standing gap: section 2's changelog requirement has never been satisfied — `HARNESS_CHANGELOG.yml`
still carries an empty `releases:` list.

## Citations

- [PRE-RELEASE-CHECKLIST.md](../../../release/PRE-RELEASE-CHECKLIST.md) — the procedure itself.
