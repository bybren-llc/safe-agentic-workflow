---
type: guide
title: "Augment Rule: Linear API SOP"
description: "Augment rule slot for Linear integration guidelines; the file on disk is an empty 4-byte stub."
tags: [providers, process, ssot-stub]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/linear-api-sop.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
  - "agent_providers/augment/instructions.md"
verified_against: "fd0fc6a"
---

# Augment Rule: Linear API SOP

The Augment rules directory promises a Linear procedure and delivers an empty file: four bytes,
one `---` line, no frontmatter body, no heading, no steps. This matters more than the other empty
stubs, because Linear evidence is a delivery gate in this harness, not a nicety.

## What The Slot Was For

`AUGMENT_WORKFLOW_GUIDE.md` describes the file as *Linear integration guidelines*, one of the
rules adapted from the Claude prompts. Four of the six rule files are empty stubs; only
[Project Guidelines](project-guidelines.md) and [Review Checklist](review-checklist.md) are
populated.

## Where The Content Actually Lives

Two places, neither of them here. The `linear-sop` skill — mapped as
[Linear SOP](../../skills/linear-sop.md) and present in `.claude/skills/`, `.gemini/skills/`, and
`.agents/skills/` — carries the actual procedure and the evidence templates. Within the Augment
tree itself, `agent_providers/augment/instructions.md` covers evidence-attachment expectations
under its Communication Protocols and Success Criteria sections, so an Augment agent that reads
the instructions file is not entirely unguided. The obligation those documents encode is
[Evidence-Based Delivery](../../methodology/evidence-based-delivery.md).

## Why Nobody Notices

No code path references the rule, and `agent_providers/` is absent from the `sync_scope` list in
`.harness-manifest.yml`, so no sync or parity check ever compares it to the skill that holds the
real procedure. See [agent_providers Legacy Mirror](../agent-providers.md).

**Doc drift.** The workflow guide lists this as an included pre-translated rule; the file has no
content.

## Citations

- [AUGMENT_WORKFLOW_GUIDE.md](../../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) —
  describes the intended contents of this rule.
- [Augment instructions.md](../../../../agent_providers/augment/instructions.md) — the evidence
  expectations that survive in the Augment tree.
