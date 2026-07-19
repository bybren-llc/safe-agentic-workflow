---
type: script
title: "setup-template.sh"
description: "Interactive wizard that replaces template placeholders repo-wide when a new project is created from the template."
tags: [operations, onboarding, sync]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/setup-template.sh"
sources:
  - "scripts/setup-template.sh"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# setup-template.sh

**Rewrites files in place across the whole repository** with no backup — run once on a fresh clone
via `bash scripts/setup-template.sh`. 233 lines of bash under `set -euo pipefail`.

## Overview

**This script is the source of truth for token names.** `.harness-manifest.yml` and
`.harness-manifest.schema.json` both require identity keys to match the placeholder names here, and
the sync engine rebuilds its map from them — rename a token and fork sync silently breaks.

`REPLACEMENTS` is a `declare -a` of 30 `OLD|NEW` pairs applied longest and most specific first, so
`{{GITHUB_REPO_URL}}` is consumed before `{{GITHUB_ORG}}` and `{{AUTHOR_FIRST_NAME}}` before
`{{AUTHOR_NAME}}`; a pair is skipped when `OLD` equals `NEW`, and substitution is unanchored
`s|OLD|NEW|g`. 28 `read -rp` prompts feed them. Four values are derived, never prompted —
`GITHUB_REPO_URL`, `TICKET_PREFIX_LOWER`, `AUTHOR_INITIALS`, `HARNESS_VERSION` — exactly the four
absent from the manifest's 26 identity keys, which the schema confirms are computed automatically.
`_sed_inplace` picks GNU `sed -i` versus BSD `sed -i ''` via `sed --version | grep GNU`, the one
genuinely cross-platform script in this directory.

## Inputs & Outputs

- **In** 28 interactive prompts for identity values (**names only** recorded here), then
  `Proceed? (y/N)` — the sole confirmation gate; anything but `y`/`Y` prints `Aborted.`, **Exit** `1`.
- **Out** rewritten files, found by `find` over 17 name patterns (`*.md *.json *.yml *.yaml *.sh
  *.py *.txt *.toml *.bib *.cff *.mjs *.ts NOTICE LICENSE CODEOWNERS .env.template .gitignore`),
  excluding `*/.git/*` and `*/node_modules/*`, piped through `xargs -0 _sed_inplace`.
- **Out** a leftover report grepping surviving `{{[A-Z_]*}}` tokens, but over a **narrower** set
  (`*.md *.json *.yml *.yaml *.sh *.cff *.bib`) — the other 10 patterns are never re-scanned.
- **Caveat — secret in cleartext** it prompts for `DB_PASSWORD` with an unmasked `read -rp` and
  substitutes the value into tracked files via the `{{DB_PASSWORD}}` pair, committing it to git.
- **Caveat** no `--yes`/non-interactive mode and no dry-run, so it cannot run in CI; no backup is
  taken, so the only undo is git.

## Invoked By

- Manual, once per new project created from the template.
- Asserted to exist by [pre-release-check.sh](pre-release-check.md) section 3.

## Citations

- [Template Setup](../../knowledge/root-docs/template-setup.md) — the setup narrative for a new
  project. This repo is still in template state: its own sources carry unresolved `{{...}}` tokens.
