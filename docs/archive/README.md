# Archived Documentation

This directory preserves documents that are no longer actively used but retain
historical or reference value for the project.

## Purpose

- **Institutional knowledge** -- Decisions, rationale, and one-time deliverables
  that informed the current state of the repository remain accessible.
- **Audit trail** -- Superseded documents stay available for traceability
  without cluttering the active documentation tree.
- **Safe removal** -- Moving files here instead of deleting them prevents
  accidental loss while keeping active docs clean.

## When to Archive

Move a document here when it meets **any** of these criteria:

| Criteria | Example |
|---|---|
| Project-internal doc that does not belong in the template | A validation report created for a specific sprint |
| Superseded by a newer version | An old README replaced by the current one |
| Completed one-time deliverable | A migration change log after the migration shipped |
| No longer accurate but historically valuable | An early architecture proposal that was later revised |

## Archival Workflow

Follow these steps every time you archive a document.

### 1. Move the file with `git mv`

Use `git mv` so the full commit history travels with the file.

```bash
git mv docs/onboarding/OLD-GUIDE.md docs/archive/OLD-GUIDE.md
```

Never use a plain `mv` followed by `git add`; that breaks history continuity.

### 2. Update references

Search the repository for any links or mentions of the old path and update or
remove them.

```bash
grep -r "OLD-GUIDE.md" docs/ CLAUDE.md AGENTS.md CONTRIBUTING.md README.md
```

### 3. Record the archival in this README

Add an entry under **Current Archive Contents** below with:

- File name (linked)
- One-line description
- Reason it was archived

### 4. Verify no broken links remain

```bash
grep -r "OLD-GUIDE.md" . --include="*.md" | grep -v docs/archive/
```

If the command returns no output, no stale references remain.

### 5. Commit

```bash
git add docs/archive/ && git commit -m "docs(archive): archive OLD-GUIDE.md -- superseded by NEW-GUIDE.md"
```

## Current Archive Contents

| File | Description | Reason Archived |
|---|---|---|
| [README-TEMPLATE.md](./README-TEMPLATE.md) | Original README template used during repository setup. | Superseded -- `README.md` is complete and maintained directly. |
| [GENERALIZATION-CHANGES.md](./GENERALIZATION-CHANGES.md) | Change log tracking the generalization of onboarding docs for broader adoption. | Completed deliverable -- all generalization work has been applied. |
| [SOCIAL-MEDIA-SETUP.md](./SOCIAL-MEDIA-SETUP.md) | Guide for configuring GitHub social preview cards and sharing metadata. | Project-internal -- setup instructions specific to the original project, not the template. |
| [USER-JOURNEY-VALIDATION-REPORT.md](./USER-JOURNEY-VALIDATION-REPORT.md) | Validation report assessing the new-user journey through repository documentation (2025-10-08). | Completed deliverable -- findings were addressed; report preserved for reference. |

## What NOT to Archive

Some files should be **deleted entirely** rather than archived:

- **Temporary or scratch files** -- `.bak`, `.tmp`, editor swap files.
- **Generated output** -- Build artifacts, compiled assets, coverage reports.
- **Sensitive data** -- Credentials, tokens, `.env` files with real values.
  Delete immediately and rotate any exposed secrets.
- **Duplicate copies** -- Exact duplicates with no unique content.
- **Empty placeholders** -- Stub files that were never filled in.

When in doubt, prefer archiving over deleting. It is easier to remove an
archived file later than to recover a deleted one.

---

**Do not use archived files for current development.** They may contain outdated
information, old paths, or references to infrastructure that no longer exists.
