---
type: pattern
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the reusable approach and the problem it solves}}"
resource: "{{PATH}}"
tags: [{{TAGS}}, ssot-stub]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

**This is a map-card. The full pattern lives in the source-of-truth document cited below — do not
restate it here.** If you are restating more than a paragraph, stop and link. A stub that
duplicates its source becomes two things to maintain, and they will diverge.

## Overview

{{3-5 sentences: what the pattern is, when to reach for it, and when NOT to. Enough for a reader
to decide whether to open the full document — no more.}}

## Exemplars

{{2-5 bullets: real places in the codebase where this pattern is applied correctly, each with one
clause on what makes it a good example. Name code files as plain inline code; never link to them.
Code paths belong in `resource` and `sources`.}}

- `{{PATH}}` — {{why this is the reference implementation}}

## Citations

{{1-4 bullets. A stub type MUST carry an out-of-bundle citation to its source of truth — the
validator enforces this. Out-of-bundle links appear ONLY in this section. Relative markdown links
only: no wikilinks, no leading-slash paths, no repository-host URLs for files in this repo.}}

- [{{Pattern Document}}]({{PATH}}) — the authoritative definition
