---
type: guide
title: "Augment Rule: Coding Standards"
description: "Augment rule slot for code quality and style guidelines; the file on disk is an empty 4-byte stub."
tags: [providers, patterns, ssot-stub]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/coding-standards.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
verified_against: "fd0fc6a"
---

# Augment Rule: Coding Standards

An advertised Augment rule that contains nothing. The file is four bytes: one `---` line, no
frontmatter body, no heading, no prose. An Augment agent loading this rules directory picks up
zero code-quality guidance from it.

## What The Slot Was For

`AUGMENT_WORKFLOW_GUIDE.md` describes the file as *code quality and style guidelines* and counts
it among the rules "adapted from the Claude prompts." It is one of four empty stubs out of the six
files in `agent_providers/augment/rules/`; only [Project Guidelines](project-guidelines.md) and
[Review Checklist](review-checklist.md) are populated.

## Where The Content Actually Lives

Code-quality expectations for this harness are carried by root `CLAUDE.md`, mapped as
[CLAUDE.md](../../knowledge/root-docs/claude-md.md), and by the pattern library that the
[Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md) makes mandatory
before implementation. Style enforcement is real elsewhere — see
[Linting](../../subsystems/linting.md) — and none of it reaches this file.

## Why Nobody Notices

No code path references the rule. `agent_providers/` does not appear in the `sync_scope` list of
`.harness-manifest.yml`, so nothing regenerates or diffs it; see
[agent_providers Legacy Mirror](../agent-providers.md).

**Doc drift.** The workflow guide lists this as an included, pre-translated rule while the file
carries no content.

**Open question.** Which Claude prompt this was meant to be translated from is unknown — the guide
says the rules are adapted from the Claude prompts but names no source file.

## Citations

- [AUGMENT_WORKFLOW_GUIDE.md](../../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) —
  describes the intended contents of this rule.
