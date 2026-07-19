---
type: environment
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: which environment this is and what it is for}}"
tags: [{{TAGS}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
sources:
  - "{{PATH}}"
verified_against: "{{GIT_SHA}}"
---

# {{Title}}

{{2-4 sentences: what this environment is, who uses it, and the one thing people most often get
wrong about it (for example, mistaking it for a mirror of production when it is not).}}

## Overview

{{3-5 sentences: the environment's purpose in the delivery flow and how it differs from its
neighbours — data realism, credentials, scale, and what guarantees it does NOT provide.}}

## Topology

{{4-8 bullets or a table: the services that make it up, how they are hosted, and how they connect.
Use a table when there are more than four services; tables need leading and trailing pipes.}}

| Service | Host / Port | Notes |
| --- | --- | --- |
| {{name}} | {{where it runs}} | {{version or constraint}} |

## Access & Deployment

{{4-8 bullets: how a person or agent reaches this environment, what credential or network access is
required, and how code arrives here (automatic on merge, manual promotion, image pull). State
whether deploys are automatic or manual — that distinction causes the most confusion. Names of
environment variables may appear; values never.}}

## Citations

{{1-5 bullets: runbooks, access procedures, and infrastructure configuration documents.
Out-of-bundle links appear ONLY in this section. Relative markdown links only — no leading-slash
paths, no repository-host URLs for files in this repo.}}

- [{{Doc Title}}]({{PATH}}) — {{what it authoritatively covers}}
