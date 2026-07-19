---
type: guide
title: "Augment Rule: Confluence Standards"
description: "Augment rule slot for documentation standards; the file on disk is an empty 4-byte stub."
tags: [providers, process, ssot-stub]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/confluence-standards.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
verified_against: "fd0fc6a"
---

# Augment Rule: Confluence Standards

A documentation-standards rule that documents nothing. The file is four bytes — a lone `---` with
no frontmatter body, no heading, and no content. It is listed as delivered and is not.

## What The Slot Was For

`AUGMENT_WORKFLOW_GUIDE.md` names its subject as *documentation standards* and counts it among the
rules adapted from the Claude prompts. Four of the six files in `agent_providers/augment/rules/`
are empty in exactly this way; only [Project Guidelines](project-guidelines.md) and
[Review Checklist](review-checklist.md) carry text.

## Where The Content Actually Lives

The same subject is covered with real content by the `confluence-docs` skill, which ships in
`.claude/skills/`, `.gemini/skills/`, and `.agents/skills/` and is mapped as
[Confluence Docs](../../skills/confluence-docs.md). That skill supplies ADR, runbook, and
architecture templates; the Augment slot supplies none of them. An Augment session therefore has
to reach the portable skills surface — [Portable .agents Skills Surface](../agents-portable.md) —
or go without.

## Why Nobody Notices

Nothing reads the file. `agent_providers/` is absent from the `sync_scope` list in
`.harness-manifest.yml`, so the emptiness is never surfaced by a sync or parity run; the wider
picture is in [agent_providers Legacy Mirror](../agent-providers.md).

**Doc drift.** The workflow guide lists this as an included pre-translated rule; the file has no
content.

## Citations

- [AUGMENT_WORKFLOW_GUIDE.md](../../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) —
  describes the intended contents of this rule.
