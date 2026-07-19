---
type: skill
title: "Skill: release-patterns"
description: "PR creation, pre-PR validation, CI status checks, merge strategy and the QAS pre-merge gate."
resource: ".claude/skills/release-patterns/SKILL.md"
tags: [skills, release, ci, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/release-patterns/SKILL.md"
  - ".claude/skills/release-patterns/README.md"
verified_against: "fd0fc6a"
---

# Skill: release-patterns

The checklist a branch clears before it becomes a pull request, and again before it merges.

## Overview

User-invocable only: `disable-model-invocation: true` with an `argument-hint` of `[ticket-id]`, so
it never appears in the runtime available-skills listing and a human must call it by name. Its
`allowed-tools` are `Read`, `Bash`, `Grep`, `Glob` — the `Bash` grant is what lets it run the
validation command rather than only describe it.

Six shared H2s carry the procedure: Stop-the-Line Conditions, Pre-PR Checklist (MANDATORY),
CI/CD Validation Command, PR Creation Template, Merge Strategy, QAS Gate (MANDATORY). Two of the
six are marked mandatory — the skill is a gate, not advice.

The portable `.agents` copy is the longer of the two (180 lines against 139), adding a Release
Workflow section with Changes, Breaking Changes and Migration Steps subsections plus a
`{{VERSION}}` token the Claude copy lacks. It keeps `{{LINEAR_WORKSPACE}}` despite being neutral.

## Routes To

- The CI validation command, invoked through the skill's `Bash` grant before any PR is opened.

The two surfaces disagree on where the CI/CD guide lives: the Claude copy links
`docs/CI-CD-Pipeline-Guide.md`, which does not exist, while the `.agents` copy links
`docs/ci-cd/CI-CD-Pipeline-Guide.md`, which does and matches `CLAUDE.md`. Claude is the broken one.

Related: [Three-Stage PR Review](../methodology/three-stage-pr-review.md),
[Stop-the-Line Gate](../methodology/stop-the-line-gate.md).

## Used By Roles

| Role | Why it loads this skill |
| --- | --- |
| [RTE](../roles/rte.md) | named directly in the role definition; assembles and merges the PR |
| [QAS](../roles/qas.md) | owns the mandatory pre-merge gate this skill enforces |

Only the RTE definition names it; QAS appears as the gate's owner inside the skill text.

## Citations

- [CI-CD-Pipeline-Guide.md](../../ci-cd/CI-CD-Pipeline-Guide.md) — the authoritative pipeline reference.
- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — merge strategy and branch protection rules.
