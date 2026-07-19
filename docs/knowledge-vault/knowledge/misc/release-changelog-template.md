---
type: guide
title: "Release Changelog Template (SSoT stub)"
description: "Pointer to the template governing when and how the release changelog is written."
tags: [ssot-stub, release, process]
timestamp: 2026-07-19
status: active
sources:
  - "docs/templates/RELEASE_CHANGELOG_TEMPLATE.md"
  - "HARNESS_CHANGELOG.yml"
verified_against: "fd0fc6a"
---

# Release Changelog Template (SSoT stub)

A map-card for `docs/templates/RELEASE_CHANGELOG_TEMPLATE.md`: 229 lines, the only file in
`docs/templates/`, opening not with a format spec but with "When to Update the Changelog." That
ordering is the document's thesis — timing is the part people get wrong, not layout.

## The three-authority problem

Changelog format is asserted in three places in this repo, and they are not cross-referenced:

| Authority | Form |
| --- | --- |
| `docs/templates/RELEASE_CHANGELOG_TEMPLATE.md` | Human-authored markdown template |
| `HARNESS_CHANGELOG.yml` | Schema described in embedded comments |
| `scripts/generate-changelog.sh` | The format actually emitted |

**UNKNOWN: whether this template's structure matches what `generate-changelog.sh` produces, or is
an independent human format that happens to coexist with it.** Unresolved at `fd0fc6a`. Until it
is settled, do not assume editing one propagates to the others. Where they disagree, the script's
output is what ships, so the script wins any tie in practice.

## Related

The generator has its own concept, [generate-changelog](../../operations/scripts/generate-changelog.md),
and the surrounding procedure is in [Release Process](../../operations/release/release-process.md)
and the [/release command](../../commands/release.md).

## Citations

- [RELEASE_CHANGELOG_TEMPLATE.md](../../../templates/RELEASE_CHANGELOG_TEMPLATE.md) — the template.
- `HARNESS_CHANGELOG.yml` — the machine-readable changelog (config file, carried in `sources`).
