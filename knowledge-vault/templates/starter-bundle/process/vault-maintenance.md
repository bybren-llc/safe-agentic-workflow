---
type: process
title: "Vault Maintenance"
description: "How this vault stays honest as the code moves: drift detection, targeted regeneration, and the record."
tags: [process, okf]
timestamp: 2026-07-19
status: active
domain: platform
---

# Vault Maintenance

## Overview

A knowledge base that is not maintained becomes confidently wrong, which is worse than absent.
This vault defends against that with a mechanism rather than a good intention: every concept
records the commit its claims were checked against, so staleness is a fact you can compute
instead of a feeling.

## Flow

- **Detect drift.** Read `baseline_sha` from `_meta/manifest.json` and diff it to HEAD across the
  watch-list of source paths. A concept is stale if and only if a changed path matches its
  `resource` or one of its `sources` — file-level truth, not a time-based guess.
- **Detect inventory change.** Re-enumerate the source globs and compare against the manifest.
  A new source with no concept gets one (manifest entry first). A deleted source gets
  `status: deprecated` — never a silent file deletion, because inbound links must be cleaned first.
- **Regenerate only what drifted.** Re-derive facts from the source files. Never patch prose
  without re-reading the code it describes.
- **Validate.** The validator exits 0 and markdown lint passes, or the change does not ship.
- **Record.** Prepend a dated entry to the log, then bump `baseline_sha` and `generated`.

## Roles Involved

- **Whoever merged the change** — responsible for noticing that a merge moved the territory.
- **The maintenance agent or author** — runs the sync and re-derives the affected concepts.
- **Reviewer** — confirms the claims were re-verified, not merely re-worded.

## Citations

- [Conventions](../_meta/CONVENTIONS.md) — the rules this process enforces

The full method lives in the harness at `knowledge-vault/docs/GUIDE.md`, and the first-build steps
at `knowledge-vault/docs/ADOPTION-PLAYBOOK.md`. Those are named rather than linked on purpose: this
bundle is meant to be **copied** to wherever your vault will live, and a relative link out of the
bundle would break the moment you move it. Cite paths that travel with the bundle; name the rest.
