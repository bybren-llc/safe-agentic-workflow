---
type: guide
title: "Harness Modernization KT Meta-Prompt (SSoT stub)"
description: "Pointer to the knowledge-transfer meta-prompt for handing harness modernization to another ARCHitect."
tags: [methodology, ssot-stub, onboarding, orchestration]
timestamp: 2026-07-19
status: active
sources:
  - "docs/whitepapers/CLAUDE-CODE-HARNESS-KT-META-PROMPT.md"
verified_against: "fd0fc6a"
---

# Harness Modernization KT Meta-Prompt (SSoT stub)

A 501-line prompt, not an essay: it is written to be handed to the ARCHitect of another
repository so that agent can carry the harness modernization forward. This concept is a pointer;
the prompt itself is the deliverable and is not restated here.

## What the source covers

The document is addressed *For the ARCHitect of {{PROJECT_REPO}}* and runs as a working brief —
an executive summary of what changed, the source documents to read first, a component extraction
checklist with skeleton shapes for skills and agent roles, a generalization guide for stripping
project-specific detail, ordered implementation steps, the key insights to preserve through the
port, ticket and PR references, and a quick reference of file locations.

## Read it when

- You are porting this harness into a different repository and want the extraction order someone
  already paid for, rather than rediscovering it.
- You are writing a knowledge-transfer prompt of your own and want a worked example of the shape:
  read first, extract, generalize, implement, preserve.
- You need the rationale behind a harness component before deciding whether to carry it across.

## Template placeholders are unsubstituted

The file ships with `{{TICKET_PREFIX}}` and `{{PROJECT_REPO}}` left in place — as this repository
is a template, that is expected. It matters in one spot: the H1 reads *Harness Modernization
{{TICKET_PREFIX}}-444*, so the ticket the prompt is scoped to is **not resolvable as written**.
Substitute your own prefix before using the document, and treat the referenced ticket as
unidentified until you do.

## Citations

- [Knowledge Transfer Meta-Prompt](../../../whitepapers/CLAUDE-CODE-HARNESS-KT-META-PROMPT.md) —
  the full prompt and the authority for the extraction and generalization procedure.
- [Whitepapers Index](whitepapers-readme.md) — where this sits among the harness whitepapers.
