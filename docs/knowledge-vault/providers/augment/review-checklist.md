---
type: guide
title: "Augment Rule: Review Checklist"
description: "Populated Augment rule with seven review gates spanning pre-implementation through post-deployment."
tags: [providers, gates, testing, process]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/review-checklist.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
verified_against: "fd0fc6a"
---

# Augment Rule: Review Checklist

The second of the two populated rules under `agent_providers/augment/rules/` — 158 lines of plain
markdown with no YAML frontmatter, opening at `# Review Checklist`. It is the Augment path's
restatement of the harness quality gates, written as checklists rather than as agent prompts.

## The Seven Gates

Counted from the file's top-level headings: Purpose, then Pre-Implementation Review, Code Review
Checklist, Testing Review, Deployment Review, Documentation Review, Final Approval Checklist, and
Post-Deployment Review. Its stated scope is reviewing code changes, architectural decisions, and
project deliverables — so it spans further than a pull request, both earlier (before
implementation starts) and later (after deploy).

## What It Duplicates

The same gates are expressed three other ways in this repo, each maintained independently:

- `.cursor/rules/22-agent-qas.mdc` — the Cursor rule form, mapped under
  [Agent and Background Rules](../rules/agent-and-background.md).
- `.claude/agents/qas.md` — the QAS agent prompt, mapped as [QAS](../../roles/qas.md).
- The `review_stages`, `quality_gates`, and `gates` keys in `.claude/team-config.json`, which is
  the machine-readable form the Claude surface actually reads —
  [Claude Code Provider Surface](../claude-code.md).

Where the four disagree, the config keys and the agent prompt are what a running session obeys;
this checklist is prose that no tool loads. The canonical review flow is
[Three-Stage PR Review](../../methodology/three-stage-pr-review.md), and the enforced pre-PR gate
is [Pre-PR Validation Checklist](../../knowledge/sop/pre-pr-validation-checklist.md).

## Standing Of The File

Nothing references it from any code path, and `agent_providers/` is absent from the `sync_scope`
list in `.harness-manifest.yml` — so it is not regenerated from the QAS prompt and no parity check
compares the two. Treat divergence between this checklist and the Claude-side gates as expected
rather than as a bug, and prefer the Claude-side definition. See
[agent_providers Legacy Mirror](../agent-providers.md) for how the rest of that tree stands.

## Citations

- [Augment review-checklist.md](../../../../agent_providers/augment/rules/review-checklist.md) —
  the checklist itself.
- [AUGMENT_WORKFLOW_GUIDE.md](../../../../agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md) —
  places the rule in the Augment setup path.
