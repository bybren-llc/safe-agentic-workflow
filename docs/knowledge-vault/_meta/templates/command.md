---
type: command
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: what invoking this command accomplishes}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
resource: "{{PATH_TO_COMMAND_FILE}}"
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: when an operator reaches for this command and what state they are in. This is a
STUB — the command file itself is the source of truth; do not restate its body.}}

## Overview

{{3-5 sentences: the job the command does and the workflow step it belongs to. Name the preceding
and following commands if it sits in a chain.}}

## Invocation

{{2-4 bullets: how it is called, any arguments, and the preconditions that must hold. Record
argument NAMES; never record secret or environment VALUES.}}

- `{{/command-name <args>}}` — {{when to use this form}}

## What It Does

{{3-6 bullets: the observable effects in order — files touched, checks run, external calls made,
exit states. Describe what the command file ACTUALLY does, not what its name suggests. If the
documentation and the command body disagree, the body wins and you note the discrepancy in one
sentence.}}

- {{Effect}} — {{one clause}}

## Provider Parity

{{2-5 bullets: which provider surfaces carry an equivalent, and where behaviour diverges. If this
command is provider-only, say so and say why. "Parity assumed" is not an acceptable entry.}}

- {{Provider}} — {{mirrored / absent / diverges in <specific way>}}

## Citations

{{1-5 bullets: the command file and the workflow document that governs it. Out-of-bundle links
appear ONLY in this section.}}

- [{{Doc Title}}]({{PATH}}) — {{what it establishes}}
