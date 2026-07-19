---
type: skill
title: "Skill: safe-workflow"
description: "Branch naming, SAFe commit format, rebase-first workflow and the pre-PR validation checklist."
resource: ".claude/skills/safe-workflow/SKILL.md"
tags: [skills, workflow, process, ci]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/safe-workflow/SKILL.md"
  - ".claude/skills/safe-workflow/README.md"
verified_against: "fd0fc6a"
---

# Skill: safe-workflow

The conventions layer every implementing role loads before touching git: how branches are named,
what a commit message must carry, and why history stays linear.

## Overview

Model-invoked only — the Claude copy declares `user-invocable: false` with `allowed-tools` limited
to `Read`, `Grep`, and `Glob`, so it informs behaviour but cannot act. It is the most widely
adopted skill in the harness: six of the eleven roles reference it by name.

The skill states its own authority boundary — it supplies execution steps while `CONTRIBUTING.md`
remains the northstar for conventions. Both are meant to be followed, and where they disagree the
contributing guide wins.

## Routes To

The skill carries no repository file paths in either surface copy. Its "Authoritative Reference"
heading names `CONTRIBUTING.md` in prose only, so the routing is by convention rather than by link
— a reader must know where to look. This is worth knowing before relying on it to navigate.

Related concepts: [Three-Stage PR Review](../methodology/three-stage-pr-review.md) and
[Exit States](../methodology/exit-states.md) describe what happens to a branch once it is pushed.

## Used By Roles

| Role | Why it loads this skill |
| --- | --- |
| [BE Developer](../roles/be-developer.md), [FE Developer](../roles/fe-developer.md) | branch and commit conventions before implementing |
| [Data Engineer](../roles/data-engineer.md) | same, plus migration commit scoping |
| [QAS](../roles/qas.md) | verifying history is clean before approving |
| [RTE](../roles/rte.md) | enforcing rebase-first at PR assembly |
| [System Architect](../roles/system-architect.md) | reviewing structural conformance |

The two surface copies diverge substantially: the portable `.agents` copy is roughly half the size
of the Claude copy, dropping the slash-command table, multi-team coordination, and customization
guidance, while adding an evidence template the Claude copy lacks. Neither is a strict subset of
the other, so which surface a reader loaded changes what they were told.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the authoritative git workflow and commit standard.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — where this skill sits in the delivery chain.
