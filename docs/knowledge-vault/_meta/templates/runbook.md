---
type: runbook
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: the operational situation this runbook covers}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: the situation, its blast radius, and how urgent it is. Someone reading this at
3am should know within ten seconds whether they are in the right document.}}

## Overview

{{3-5 sentences: what goes wrong, why, and what a good outcome looks like. Name the signals that
indicate you are in this scenario.}}

## When To Use

{{3-6 bullets: the concrete triggers — alerts, symptoms, error signatures — plus at least one
"do NOT use this when" clause pointing to the correct alternative.}}

## Procedure Map

{{4-8 bullets: the ordered phases of the response, each one clause. This is a MAP, not the full
procedure: if the step-by-step commands live in an operational document, summarize the phases here
and cite that document. If you are restating more than a paragraph, stop and link.}}

- {{Phase 1 — one clause on what it accomplishes}}

## Citations

{{1-5 bullets: the authoritative procedure document, dashboards, and escalation contacts by role
(never by personal name). Out-of-bundle links appear ONLY in this section.}}

- [{{Doc Title}}]({{PATH}}) — {{the full step-by-step procedure}}
