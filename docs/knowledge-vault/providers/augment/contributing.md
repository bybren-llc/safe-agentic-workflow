---
type: guide
title: "Augment Rule: CONTRIBUTING"
description: "Augment rule slot for git workflow and contribution standards; the file on disk is an empty 4-byte stub."
tags: [providers, workflow, ssot-stub]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/CONTRIBUTING.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
verified_against: "fd0fc6a"
---

# Augment Rule: CONTRIBUTING

A named slot in the Augment rules directory that carries no rule. The file is four bytes — a
single `---` line, an empty YAML document separator, with no frontmatter body, no heading, and no
content. This card exists so the gap is visible rather than inferred.

## What The Slot Was For

`AUGMENT_WORKFLOW_GUIDE.md` lists this file under "pre-translated rules and guidelines adapted
from the Claude prompts" and describes its subject as *git workflow and contribution standards*.
It is one of four empty stubs among the six files in `agent_providers/augment/rules/` — the others
being coding standards, Confluence standards, and the Linear API SOP. Only
[Project Guidelines](project-guidelines.md) and [Review Checklist](review-checklist.md) carry
content.

## Where The Content Actually Lives

Nothing is lost by the emptiness, only misdirected. The git workflow and contribution standards
this slot advertises are held by repo-root `CONTRIBUTING.md` — mapped in the vault as
[Contributing](../../knowledge/root-docs/contributing.md) — and restated for Cursor in
`.cursor/rules/01-git-workflow.mdc`, covered by [Cursor Provider Surface](../cursor.md). An
Augment session reading only this rules directory gets neither.

## Why Nobody Notices

The file is referenced by no code path. `agent_providers/` is absent from the `sync_scope` list in
`.harness-manifest.yml`, so no sync engine regenerates it, no parity check compares it against a
source, and no validator complains that a rule file has no rule. See
[agent_providers Legacy Mirror](../agent-providers.md) for the wider state of that tree.

**Doc drift.** The workflow guide presents this rule as included and pre-translated; on disk it has
no content, so the guide overstates what an Augment user receives.

**Open question.** Whether the 4-byte stub is a deliberate placeholder or a truncation is unknown
— no ticket, comment, or TODO on disk explains it.

## Citations

- [AUGMENT_WORKFLOW_GUIDE.md](../../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) —
  lists this rule as included.
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — the real git workflow and commit standards.
