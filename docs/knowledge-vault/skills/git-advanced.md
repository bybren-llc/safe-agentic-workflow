---
type: skill
title: "Skill: git-advanced"
description: "Rebase, bisect, cherry-pick, conflict resolution and recovery commands with force-push safety rules."
resource: ".claude/skills/git-advanced/SKILL.md"
tags: [skills, workflow, operations]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/git-advanced/SKILL.md"
  - ".agents/skills/git-advanced/SKILL.md"
  - ".claude/skills/git-advanced/README.md"
verified_against: "fd0fc6a"
---

# Skill: git-advanced

The recovery card: what to do when a rebase stalls, a regression needs bisecting, or a branch has to be
pulled back from a bad push.

## Overview

Model-invocable, with no `user-invocable` key. Its `allowed-tools` are `Read`, `Bash`, and `Grep` —
note the absence of `Glob`, and the presence of `Bash`, which makes this one of the few skills in the
lane that can actually run the commands it describes. Ten H2 sections cover the standard rebase
workflow, bisect, cherry-pick, conflict resolution, recovery commands, and safety guidelines. It sits
downstream of [safe-workflow](safe-workflow.md), which sets the conventions this skill repairs
violations of.

## Routes To

- Nothing. Neither surface contains a single `patterns_library/`, `docs/`, or `scripts/` path — the
  guidance is self-contained git command text with no onward references.
- That self-containment is the fact worth carrying: this card is a leaf, and its "Related Resources"
  heading names sibling skills rather than files.

Related concepts: [safe-workflow](safe-workflow.md) owns branch and commit conventions;
[Three-Stage PR Review](../methodology/three-stage-pr-review.md) is where a rebased branch goes next.

## Used By Roles

- No file under `.claude/agents/` names this skill, so no role loads it on definition.
- Every implementing role is a plausible caller — [BE Developer](../roles/be-developer.md),
  [FE Developer](../roles/fe-developer.md), [RTE](../roles/rte.md) — but the wiring is by model
  judgement, not declaration.

The surfaces are close: `.agents` runs 285 lines to Claude's 290. It drops `allowed-tools`, adds a
`TEMPLATE` banner, renames the closing "Related Resources" heading to "Related Skills", and tokenizes
`{{CI_VALIDATE_COMMAND}}`, `{{MAIN_BRANCH}}`, and `{{TEST_UNIT_COMMAND}}` where the Claude copy
hardcodes the commands. Both use `{{TICKET_PREFIX}}`.

## Citations

- [git-advanced SKILL.md](../../../.claude/skills/git-advanced/SKILL.md) — the authoritative command reference.
- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the git workflow whose conventions these commands serve.
