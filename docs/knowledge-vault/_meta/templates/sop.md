---
type: sop
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the standard operating procedure and what it governs}}"
resource: "{{PATH}}"
tags: [{{TAGS}}, ssot-stub]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
---

# {{Title}}

**This is a map-card. The procedure itself lives in the source-of-truth document cited below — do
not copy the steps here.** Copied steps drift from the original, and the copy is always the one
someone follows.

## Overview

{{3-5 sentences: what the SOP governs, why it is mandatory rather than advisory, and what has gone
wrong when it was skipped. Name the enforcement mechanism if one exists.}}

## When It Applies

{{3-6 bullets: the concrete triggers that put you under this SOP, plus at least one boundary case
clarifying when it does NOT apply. Ambiguity about scope is how an SOP gets ignored.}}

## Affected Concepts

{{2-6 bullets: the concepts and artifact classes governed by this SOP, each with a clause on the
obligation it creates. Link only to concept IDs listed in manifest.json; name missing ones in
prose without a link.}}

- {{[Concept Title](../path/to/concept.md) — the obligation this SOP imposes}}

## Citations

{{1-4 bullets. A stub type MUST carry an out-of-bundle citation to its source of truth — the
validator enforces this. Out-of-bundle links appear ONLY in this section.}}

- [{{SOP Document}}]({{PATH}}) — the authoritative procedure
