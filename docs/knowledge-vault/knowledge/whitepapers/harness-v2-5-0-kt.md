---
type: guide
title: "Harness v2.5.0 Knowledge Transfer (SSoT stub)"
description: "Pointer to the v2.5.0 knowledge-transfer note on Skills 2.0 and Agent Teams."
tags: [methodology, ssot-stub, skills, release]
timestamp: 2026-07-19
status: active
sources:
  - "docs/whitepapers/HARNESS-v2.5.0-KT.md"
  - "docs/releases/v2.5.0-UPGRADE.md"
verified_against: "fd0fc6a"
---

# Harness v2.5.0 Knowledge Transfer (SSoT stub)

At 155 lines this is the shortest of the harness whitepapers, and the only one pinned to a single
release. Titled *KT: Harness v2.5.0 --- Skills 2.0 + Agent Teams*, it hands over what was decided
and what bit during that upgrade. This concept is a pointer; the detail stays in the source.

## What the source covers

It opens with a Summary, then context, the key decisions made, implementation details, gotchas
and lessons learned, verification commands, related tickets, and future work. The gotchas section
is the part with the longest shelf life — decisions age out, the reasons a change was hard do
not.

## Two documents, one scope

`docs/releases/v2.5.0-UPGRADE.md` covers the same Skills 2.0 and Agent Teams scope from the
upgrade angle: what an operator must do to move a repository onto the release. The whitepaper
covers why it was built that way. If you are upgrading, read the release note first and treat
this as the rationale behind it; the two overlap and neither supersedes the other.

## Version-pinned, so expect staleness

Every claim here is scoped to v2.5.0 and goes stale on any release past it. Later upgrade notes
live alongside it under `docs/releases/`, and
[Version Upgrade Notes](../../operations/release/version-upgrade-notes.md) is the concept that
tracks them. Check the current harness version before acting on anything in this document.

## Citations

- [KT: Harness v2.5.0](../../../whitepapers/HARNESS-v2.5.0-KT.md) — the knowledge-transfer note
  itself, authoritative for the v2.5.0 decisions and gotchas.
- [v2.5.0 Upgrade](../../../releases/v2.5.0-UPGRADE.md) — the operator-facing upgrade procedure
  for the same scope.
- [Whitepapers Index](whitepapers-readme.md) — note that this file is absent from that index.
