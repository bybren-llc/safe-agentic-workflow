---
type: adr
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the decision made, stated as an outcome}}"
resource: "{{PATH}}"
tags: [{{TAGS}}, ssot-stub]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
ticket: [{{TICKET_IDS}}]
docs:
  - "{{PATH}}"
---

# {{Title}}

**This is a map-card. The full architecture decision record lives in the document cited below —
do not restate its context, options, or consequences here.** The card exists so the decision is
discoverable from the graph; the record exists so it is understandable.

## Overview

{{2-4 sentences: the problem that forced a decision and the constraint that dominated it. Enough
context that a reader knows whether this decision affects them.}}

## Decision

{{2-4 sentences or 2-4 bullets: what was decided, stated in the active voice and the present
tense ("the system uses X"). Include the one alternative that was closest and the single reason it
lost. Record the status if the ADR has been superseded.}}

## Affected Concepts

{{2-6 bullets: the concepts this decision constrains, each with a clause on how. Link only to
concept IDs listed in manifest.json — if the concept does not exist yet, name it in prose without
a link and report it as a suggestion. Never invent links.}}

- {{[Concept Title](../path/to/concept.md) — what this decision imposes on it}}

## Citations

{{1-4 bullets. A stub type MUST carry an out-of-bundle citation to its source of truth — the
validator enforces this. Out-of-bundle links appear ONLY in this section.}}

- [{{ADR Document}}]({{PATH}}) — the full record
