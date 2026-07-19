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

**Edits files in place**, rewriting old documentation paths to their post-reorganization locations.
About 5.9 KB of bash under `set -e`. It is the second step of a one-time historical migration, not
part of any routine workflow.

## Overview

Moving documentation breaks links; this script repairs them. It depends on
[reorganize-docs.sh](reorganize-docs.md) having already run, because it rewrites references *to* the
new layout rather than performing the moves itself. 177 lines under `set -e`. An
`update_file_references()` helper copies each target to `<file>.bak`, runs a single `sed -i.tmp`
carrying 6 `-e` expressions, removes the `.tmp`, then diffs against the `.bak` to report whether
anything actually changed. Because a suffix is supplied, `sed -i.tmp` is portable across GNU and BSD
sed — unlike `apply-workflow.sh` and `generalize-onboarding-docs.sh`. The repair is knowingly
incomplete: this pass handles **only** the `](FILE.md)` markdown-link form, leaving the
backtick-quoted and bare list forms to
[fix-remaining-doc-references.sh](fix-remaining-doc-references.md) — which is why one migration
needs two link-rewriting scripts.

## Inputs & Outputs

- **In** no flags — the old-to-new path mapping is hardcoded in the script body.
- **In** repository state — assumes the reorganization moves have already landed.
- **Out** rewritten links — exactly 6 forms: `](DATA_DICTIONARY.md)`,
  `](RLS_IMPLEMENTATION_GUIDE.md)`, `](RLS_POLICY_CATALOG.md)`, `](RLS_DATABASE_MIGRATION_SOP.md)`
  to `docs/database/`; `](SECURITY_FIRST_ARCHITECTURE.md)` to `docs/security/`; and
  `](CI-CD-Pipeline-Guide.md)` to `docs/ci-cd/`. An inline comment notes that `AGENTS.md` and
  `CLAUDE.md` stay in the root.
- **Out** a `.bak` per edited file, left behind for the operator to clean up.
- **Exit** non-zero — on any command failure under `set -e`.
- **Note** re-running is safe: each pattern matches only the pre-move path, which no longer appears
  once rewritten, so a second pass finds nothing to change.

## Invoked By

- Manual, once, immediately after `scripts/reorganize-docs.sh`.
- Followed by [fix-remaining-doc-references.sh](fix-remaining-doc-references.md).

## Citations

- [Repository Reorganization Plan](../../../REPOSITORY-REORGANIZATION-PLAN.md) — the migration this
  script belongs to.
