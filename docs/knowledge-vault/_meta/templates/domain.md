---
type: domain
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: what this business domain covers and where its boundary falls}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: the domain in plain language — what capability it delivers and for whom. This is
the semantic axis: it re-groups artifacts by purpose, so a newcomer who asks "how does X work"
lands here rather than in a directory listing.}}

## Overview

{{3-5 sentences: the domain's responsibility and its boundary. State explicitly what is NOT in it
and which neighbouring domain owns that instead. Boundaries are the whole value of a domain card.}}

## Members

{{5-12 bullets: the concepts that constitute this domain, each with a short clause saying why it
belongs. Link only to concept IDs listed in manifest.json — if a member concept does not exist
yet, name it in prose without a link and report it as a suggestion. Never invent links.}}

- {{[Concept Title](../path/to/concept.md) — one clause on its role in this domain}}

## Key Flows

{{2-4 flows, each 1-3 lines: the end-to-end paths that cross this domain, written as a traced
sequence (entry point, to handler, to store). Name real artifacts. Prefer one fully-traced flow
over four vague ones.}}

## Citations

{{1-5 bullets: source-of-truth documents and external references. Out-of-bundle links appear ONLY
in this section — everywhere else, links must stay inside the bundle. Relative markdown links
only: no wikilinks, no leading-slash paths, no repository-host URLs for files in this repo.}}

- [{{Doc Title}}]({{PATH}}) — {{what it authoritatively covers}}
