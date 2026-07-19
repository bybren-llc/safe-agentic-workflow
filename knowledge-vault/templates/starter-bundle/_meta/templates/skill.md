---
type: skill
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the capability this skill provides and when it fires}}"
resource: "{{PATH}}"
tags: [agents, {{TAGS}}, ssot-stub]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
---

# {{Title}}

**This is a map-card. The skill's procedure lives in the skill definition cited below — do not
restate its steps here.** The card makes the skill discoverable from the graph; the definition is
what actually runs.

## Overview

{{3-5 sentences: what the skill does, its invocation trigger, and its output. State any
precondition that must hold before it is safe to run.}}

## Routes To

{{2-6 bullets: what this skill delegates to or produces — sub-skills, scripts, or the artifacts it
writes. Name scripts and code files as plain inline code; never link to code files.}}

- `{{PATH}}` — {{what it does in this flow}}

## Used By Roles

{{2-5 bullets: the agent roles that invoke this skill and at which point in their work. Link only
to concept IDs listed in manifest.json; if a role concept does not exist yet, name it in prose
without a link and report it as a suggestion.}}

- {{[Role Title](../path/to/role.md) — when and why it invokes this}}

## Citations

{{1-4 bullets. A stub type MUST carry an out-of-bundle citation to its source of truth — the
validator enforces this. Out-of-bundle links appear ONLY in this section.}}

- [{{Skill Definition}}]({{PATH}}) — the authoritative procedure
