---
type: skill
title: "Skill: linear-sop"
description: "Ticket SOP: MCP tool usage, program structure, evidence templates for dev/staging/done, status workflow."
resource: ".claude/skills/linear-sop/SKILL.md"
tags: [skills, process, workflow, operations]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/linear-sop/SKILL.md"
  - ".agents/skills/linear-sop/SKILL.md"
  - ".claude/skills/linear-sop/README.md"
  - "docs/sop/AGENT_WORKFLOW_SOP.md"
verified_against: "fd0fc6a"
---

# Skill: linear-sop

The ticket-hygiene card: how work is represented in the tracker, what evidence each status transition
owes, and how acceptance criteria are read back out.

## Overview

Model-invocable, with the narrowest tool grant in the lane: `Read` and `Grep` only, no `Bash`, no
`Glob`. Twelve H2 sections make it the longest-structured skill here, including an "Evidence Policy
(MUST)", evidence templates, acceptance-criteria parsing, the status workflow, UUID handling, and
common operations. It refers to configuration by key name — `{{MCP_LINEAR_SERVER}}`, `{{ORG_NAME}}`,
`{{PROJECT_TEAM_NAME}}`, `{{REPO_NAME}}`, `{{TICKET_PREFIX}}` — and never by value.

## Routes To

- `docs/sop/AGENT_WORKFLOW_SOP.md` — the delivery chain that says when each evidence template is due;
  present on disk.
- Its evidence templates are split by phase: dev, staging, and done, each with its own required
  attachments.

Related concepts: [Evidence-Based Delivery](../methodology/evidence-based-delivery.md) is the principle
this skill operationalises; [Exit States](../methodology/exit-states.md) defines the statuses it moves
tickets between.

## Used By Roles

- No `.claude/agents/*.md` file names this skill, so no role loads it on definition.
- Every role that files or closes a ticket is a caller in practice — [TDM](../roles/tdm.md),
  [BSA](../roles/bsa.md), and [QAS](../roles/qas.md) most of all — but none declares it.

The `.agents` copy (270 lines against 286) is a de-vendoring: it renames the "Linear MCP Tools" heading
to the provider-neutral "Ticket System Operations" and drops the `{{MCP_LINEAR_SERVER}}` token
entirely, so the portable surface names no MCP server at all. It adds `{{CI_VALIDATE_COMMAND}}`,
`{{STAGING_ENV_NAME}}`, and `{{STAGING_URL}}`, and drops `allowed-tools`. OPEN QUESTION: neither copy
asserts which workspace or team a ticket belongs to, so the correct target is carried outside the skill
and cannot be verified from it.

## Citations

- [linear-sop SKILL.md](../../../.claude/skills/linear-sop/SKILL.md) — the authoritative procedure.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — when each evidence phase is due.
