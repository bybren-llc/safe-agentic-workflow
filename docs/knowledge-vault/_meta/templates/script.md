---
type: script
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: what this script does and to what}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
resource: "{{PATH_TO_SCRIPT}}"
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: what the script automates and the consequence of running it. Flag destructive or
irreversible behaviour in the first sentence. This is a STUB — the script is the source of truth;
do not restate its body.}}

## Overview

{{3-5 sentences: the problem it solves and where it sits in the toolchain. Name the shell or
runtime it needs and any hard dependency, since a missing dependency is the most common failure.}}

## Inputs & Outputs

{{4-8 bullets: flags and positional arguments in, files and exit codes out. Record argument and
environment variable NAMES; never record their VALUES, including defaults that look harmless. State
exit codes explicitly — a script whose failure mode is undocumented cannot be gated on.}}

- **In** `{{--flag}}` — {{what it controls}}
- **Out** `{{path or stream}}` — {{what is written}}
- **Exit** `{{code}}` — {{what it signals}}

## Invoked By

{{2-5 bullets: the call graph — which commands, workflows, hooks, or other scripts run this, and
whether invocation is manual or automated. Name the caller ACTUALLY observed in the repo, not the
one that logically should call it. If nothing calls it, say so plainly: an uninvoked script is a
finding worth recording.}}

- `{{caller}}` — {{manual / automated, and when}}

## Citations

{{1-5 bullets: the script file, the workflow that runs it, and any operational document.
Out-of-bundle links appear ONLY in this section.}}

- [{{Doc Title}}]({{PATH}}) — {{what it establishes}}
