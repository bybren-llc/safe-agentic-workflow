---
type: script
title: "fix-remaining-doc-references.sh"
description: "Cleanup pass fixing documentation references missed by the main reorganization update script."
tags: [operations, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/fix-remaining-doc-references.sh"
sources:
  - "scripts/fix-remaining-doc-references.sh"
verified_against: "fd0fc6a"
---

# fix-remaining-doc-references.sh

Rewrites documentation references in place across eight named files, so run it on a clean working
tree where the edits can be reviewed as a diff.

## Overview

The third and final stage of a one-time documentation reorganization:
[reorganize-docs.sh](reorganize-docs.md) moved the files,
[update-doc-references.sh](update-doc-references.md) rewrote the bulk of the links, and this pass
catches what that missed. At 84 lines it is the smallest script in `scripts/`, bash under `set -e`.

It targets the same 6 relocated documents as its predecessor, but in three syntactic forms rather
than one — `](FILE.md)`, backtick-quoted `` `FILE.md` ``, and `- FILE.md` list items — which is 18
`sed -e` expressions in a single pass. It copies each file to `<file>.bak` first, uses the portable
`sed -i.tmp` form, and removes the `.tmp` afterwards.

## Inputs & Outputs

- **In** — no flags or arguments. The target list is a hardcoded `FILES` array, not discovered.
- **In** — the eight paths: `AGENTS.md`, `CONTRIBUTING.md`, `docs/onboarding/DAY-1-CHECKLIST.md`,
  `META-PROMPTS-FOR-USERS.md` and `USER-JOURNEY-VALIDATION-REPORT.md` in the same directory, a
  fourth onboarding path built from the `{{TICKET_PREFIX}}` placeholder,
  `docs/team/PLANNING-AGENT-META-PROMPT.md`, and `patterns_library/database/rls-migration.md`.
- **Out** — the listed files, edited in place.
- **Exit** `0` — including when every target is absent, since each entry is guarded by
  `if [ -f "$file" ]` and missing paths are skipped silently.

The placeholder sits inside a **filename**, and `scripts/setup-template.sh` substitutes file
*contents* but never renames files — so that entry does not resolve merely because setup ran. It
matches only in a fork whose docs were renamed by hand; otherwise the `-f` guard skips it.

## Invoked By

- Nothing. No workflow, hook, command, or other script references it — it was run by hand as part
  of the reorganization sequence and has no ongoing caller.
- Conceptually follows [update-doc-references.sh](update-doc-references.md), but that ordering is
  documented rather than enforced.

## Citations

- [AGENTS.md](../../../../AGENTS.md) — one of the eight files it edits.
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — another, and the record of the doc conventions
  the reorganization aligned to.
