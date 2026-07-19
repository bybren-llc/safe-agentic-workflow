---
type: guide
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: what a reader will be able to do after reading this}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
---

# {{Title}}

**The `guide` type is free-form: it declares no fixed sections, so the H2 structure is yours to
choose.** Guides are the learning door of the vault — narrative and navigational, where the other
types are reference cards. Everything below is guidance, not a required skeleton. Delete what does
not serve the reader.

Guides carry one privilege no other type has: **they may link outside the bundle anywhere in the
body**, because navigation is their job. Every other rule still holds — relative markdown links
only, no wikilinks, no leading-slash paths, no repository-host URLs for files in this repo, and
never a link to a concept ID that is absent from `manifest.json`.

## Shape that usually works

{{Open with 2-4 sentences naming the audience and the outcome. A reader must be able to tell in
ten seconds whether this guide is for them.}}

{{Then 3-7 H2 sections of 3-8 sentences or 4-8 bullets each. Order them by the reader's journey,
not by the system's structure.}}

{{Where you send the reader elsewhere, state WHY it comes at that point. "Read the security model
third" is a table of contents; "read it third because everything after it assumes it" is
onboarding. That clause is the teaching.}}

{{Close with a short list of next steps or related reading.}}

## Budgets and discipline

- **Length.** Guides may exceed the map-card budget in `vault-config.json`; the validator will
  warn, and for this type the warning is acceptable. Aim to stay under roughly 200 lines anyway.
- **Summarize, never duplicate.** If a procedure lives in a source-of-truth document, describe
  what it accomplishes and link it. If you are restating more than a paragraph, stop and link.
- **Code wins over docs.** Facts must be true of the system as it exists. A guide that describes
  the intended design rather than the built one is the most damaging file in the vault.
- **Freshness.** `timestamp` is the date the content was last verified against its sources — not
  the date the file was edited. A citation is not re-verification.
- No emoji. Environment variable names may appear; values never.

## Citations

{{Optional for this type, since guides may link inline. Include it when the guide rests on
specific source-of-truth documents worth naming as authorities.}}

- [{{Doc Title}}]({{PATH}}) — {{what it authoritatively covers}}
