---
type: architecture
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the structural idea or cross-cutting view this concept explains}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: the architectural idea and why it exists. A reader who stops here should be able
to describe the shape of the system in one breath.}}

## Overview

{{3-5 sentences: the problem this structure solves and the constraints that forced it. Facts must
be true of the code as it exists — name the helper actually called, not the one the code should
call. When code contradicts documentation, the code wins and the discrepancy is noted here.}}

## Design

{{4-8 bullets or a short table: the components, their responsibilities, and how they interact.
Use a table only when it beats prose; tables need leading and trailing pipes with single-space
padding. Fenced blocks must declare a language. Environment variable names may appear; values
never.}}

| Component | Responsibility | Notes |
| --- | --- | --- |
| {{name}} | {{one clause}} | {{constraint or caveat}} |

## Related Concepts

{{3-6 bullets: neighbouring concepts and the nature of the relationship (depends on, constrains,
is implemented by). Link only to concept IDs listed in manifest.json; name missing ones in prose.}}

- {{[Concept Title](../path/to/concept.md) — how it relates}}

## Citations

{{1-5 bullets: the source-of-truth documents and any external references. Out-of-bundle links
appear ONLY in this section. Relative markdown links only.}}

- [{{Doc Title}}]({{PATH}}) — {{what it authoritatively covers}}
