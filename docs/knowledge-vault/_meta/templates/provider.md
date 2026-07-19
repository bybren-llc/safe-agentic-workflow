---
type: provider
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: which agent tool this surface configures and what it drives}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: providers
resource: "{{PATH_TO_SURFACE_ROOT}}"
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: which tool reads this surface, what it is authoritative for, and whether it is a
primary or mirrored surface. A reader should know within ten seconds whether editing here affects
their tool.}}

## Overview

{{3-5 sentences: the configuration dialect this surface speaks — file formats, activation model
(always-on, glob-attached, model-invoked, manual), and what the tool ignores. Name what breaks if
the surface is absent.}}

## Surface Layout

{{4-8 bullets: the directories and files that make up the surface, each one clause on what it
holds. This is a MAP, not a file listing — group by purpose, not alphabetically. Counts stated here
must be re-countable from disk.}}

- `{{path/}}` — {{what lives here and why}}

## Capabilities Exposed

{{3-6 bullets: what this surface can actually do that others cannot, and what it deliberately does
not carry. Name the capability, not the file.}}

- {{Capability}} — {{one clause; note if it is unique to this provider}}

## Sync & Parity

{{3-6 bullets: how this surface stays in step with the other provider surfaces — which artifacts
are mirrored, which are provider-only by design, and how drift is detected. Parity is the thing
that actually breaks, so be specific about the mirroring contract rather than asserting "in sync".}}

- {{Artifact class}} — {{mirrored from / provider-only, and the reason}}

## Citations

{{1-5 bullets: the surface's own README, the sync manifest, and the parity documentation.
Out-of-bundle links appear ONLY in this section.}}

- [{{Doc Title}}]({{PATH}}) — {{what it establishes}}
