---
type: test-suite
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: which behaviour this suite holds to account}}"
tags: [{{TAGS}}, testing]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
resource: "{{PATH_TO_TEST_FILE}}"
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: the behaviour under test and why it is worth a suite. This is a STUB — the test
file is the source of truth; do not restate its assertions one by one.}}

## Overview

{{3-5 sentences: the surface under test, how the suite is run, and whether it gates CI or is
manual-only. A suite that runs in no workflow protects nothing — state that plainly if it is
the case.}}

## What It Proves

{{4-8 bullets: the guarantees a green run actually establishes, phrased as claims a reader can
rely on. This is the load-bearing section. Distinguish what is proven from what is merely
exercised, and name what a green run does NOT prove. A test that only ever passes proves
nothing — prefer assertions that are shown to FAIL when the rule is broken.}}

- {{Guarantee}} — {{one clause; note if proven by a deliberate-break assertion}}
- **Does not prove**: {{the adjacent thing a reader might wrongly assume}}

## Fixtures

{{2-5 bullets: the fixture data or scaffolding the suite depends on, and where it lives. Note any
fixture that is missing or stale, since a broken fixture is a silent gate failure.}}

- `{{path}}` — {{what it stands in for}}

## Citations

{{1-5 bullets: the test file, the workflow that runs it, and the specification it enforces.
Out-of-bundle links appear ONLY in this section.}}

- [{{Doc Title}}]({{PATH}}) — {{what it establishes}}
