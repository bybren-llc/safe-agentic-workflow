---
type: script
title: "update-doc-references.sh"
description: "Rewrites links to documentation files that moved during the repository reorganization."
tags: [operations, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/update-doc-references.sh"
sources:
  - "scripts/update-doc-references.sh"
  - "docs/REPOSITORY-REORGANIZATION-PLAN.md"
verified_against: "fd0fc6a"
---

# update-doc-references.sh

**Edits files in place**, rewriting old documentation paths to their post-reorganization locations. It
is the second step of a one-time historical migration, not part of any routine workflow.

## Overview

Moving documentation breaks links; this script repairs them. It depends on
[reorganize-docs.sh](reorganize-docs.md) having already run, because it rewrites references *to* the new
layout rather than performing the moves itself. 177 lines under `set -e`, with **two** helpers.
`update_file_references()` carries 6 expressions for the `](FILE.md)` markdown-link form in
`README.md` and the onboarding docs; `update_agent_prompt_references()` carries 7 more for the
backtick-quoted `` `FILE.md` `` and bare list-item forms across `.claude/agents/` and both
`agent_providers/*/prompts/` trees, prefixing `../../` for the extra depth. Both copy the target to
`<file>.bak`, run one `sed -i.tmp`, drop the `.tmp`, then diff against the `.bak`. Because a suffix is
supplied that form is portable across GNU and BSD sed, unlike `apply-workflow.sh`. The repair is still
incomplete: [the follow-up pass](fix-remaining-doc-references.md) applies the backtick and bare-list
forms to the *non-prompt* file set this one leaves untouched.

## Inputs & Outputs

- **In** no flags — the path mapping is hardcoded; the one runtime input is the closing
  backup-cleanup answer read from stdin. Assumes the reorganization moves have already landed.
- **Out** rewritten links — the same 6 relocated docs in both helpers: `DATA_DICTIONARY.md`,
  `RLS_IMPLEMENTATION_GUIDE.md`, `RLS_POLICY_CATALOG.md`, `RLS_DATABASE_MIGRATION_SOP.md` to
  `docs/database/`; `SECURITY_FIRST_ARCHITECTURE.md` to `docs/security/`; `CI-CD-Pipeline-Guide.md`
  to `docs/ci-cd/`. An inline comment notes that `AGENTS.md` and `CLAUDE.md` stay in the root.
- **Out** a `.bak` per **changed** file — when `diff -q` shows no change the backup is deleted at
  once. The run then ends on a `Remove all backup files? (y/N)` prompt that, on `y`, runs
  `find . -name "*.bak" -delete` repo-wide, so it blocks on stdin and backups may not survive.
- **Exit** non-zero — on any command failure under `set -e`.
- **Note** re-running is safe: each pattern matches only the pre-move path, which no longer appears
  once rewritten, so a second pass finds nothing to change.

## Invoked By

- Manual, once, immediately after `scripts/reorganize-docs.sh`.
- Followed by [fix-remaining-doc-references.sh](fix-remaining-doc-references.md).

## Citations

- [Repository Reorganization Plan](../../../REPOSITORY-REORGANIZATION-PLAN.md) — the migration this
  script belongs to.
