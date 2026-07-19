---
type: integration
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: which external system this integrates and what it does for us}}"
resource: "{{PATH}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: what the external system is, what capability it provides, and what breaks without
it. Use neutral naming — "the auth provider", "the primary datastore" — unless the vendor name is
itself the fact.}}

## Overview

{{3-5 sentences: the shape of the integration — direction of calls, whether it is synchronous or
event-driven, and which parts of the system depend on it.}}

## Touchpoints

{{4-8 bullets or a table: every place the codebase meets this system — client wrappers, webhook
receivers, scheduled syncs. Name real files as plain inline code; never link to code files. Code
paths belong in `resource` and `sources`.}}

| Touchpoint | Direction | Artifact |
| --- | --- | --- |
| {{what it does}} | {{inbound / outbound}} | `{{PATH}}` |

## Configuration

{{3-6 bullets: the environment variables, feature flags, and setup steps required. Names only —
never values, never secrets. Note which are required versus optional and what degrades if absent.}}

## Failure Modes & Health

{{3-6 bullets: how this integration fails, how the failure surfaces, and what the system does
about it (retry, queue, degrade, hard-fail). Include the health check or signal to watch. Describe
the behaviour that exists, not the behaviour that ought to exist.}}

## Citations

{{1-5 bullets: source-of-truth docs and vendor documentation. Out-of-bundle links appear ONLY in
this section. External web URLs are permitted here and nowhere else.}}

- [{{Doc Title}}]({{PATH}}) — {{what it authoritatively covers}}
