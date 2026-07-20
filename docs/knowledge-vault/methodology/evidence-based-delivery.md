---
type: guide
title: "Evidence-Based Delivery"
description: "Nothing advances on assertion: every deliverable carries verifiable evidence attached to the tracker before human review."
tags: [methodology, process, workflow, testing, gates]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "docs/guides/ROUND-TABLE-PHILOSOPHY.md"
  - "README.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "docs/guides/AGENT_TEAM_GUIDE.md"
  - "docs/onboarding/QAS-DAILY-WORKFLOW.md"
  - "docs/sop/PRE_PR_VALIDATION_CHECKLIST.md"
verified_against: "0c26121"
---

# Evidence-Based Delivery

The rule the harness repeats more than any other: *all work requires verifiable evidence, no
"trust me, it works."* Every deliverable arrives with artifacts a reviewer can open, attached to
the Linear ticket, before a human is asked to look at it.

## The Eight Evidence Types

Four are required on every ticket: test results, a coverage report, the output of
`{{CI_VALIDATE_COMMAND}}`, and the session ID. Four are conditional: screenshots for UI work, RLS
audit results for database work, performance data when tagged for it, and a security scan for
anything carrying `#EXPORT_CRITICAL`. The canonical table lives in the Round Table document, also
the origin of [Round Table Philosophy](round-table-philosophy.md).

## How It Attaches

Evidence is posted as a comment on the Linear ticket through
`mcp__{{MCP_LINEAR_SERVER}}__create_comment`. Its concrete shape is the QAS Validation Report
template in [QAS Daily Workflow](../knowledge/onboarding/qas-daily-workflow.md) — that template is
what "evidence block" means, not a free-form note.

## Where It Sits in the Flow

The swimlane runs Backlog, Ready, In Progress, Testing, Ready for Review, Done. The gate sits
between Testing and Ready for Review: no ticket reaches Ready for Review without evidence.
Approval then runs — RTE creates the PR with evidence linked, CI passes, POPM reviews the PR
alongside the Linear evidence and the spec's acceptance criteria, and either approves or requests
changes; approval ends in rebase-and-merge. See [Three-Stage PR Review](three-stage-pr-review.md).

## Honest Limits

The gate is enforced by [QAS](../roles/qas.md) and by team culture; no hook, script, or CI job
checks that evidence was posted. The "session ID" type also depends on Claude Code session
identifiers and has no stated equivalent for the Gemini, Codex, or Cursor providers.

## Citations

- [ROUND-TABLE-PHILOSOPHY.md](../../guides/ROUND-TABLE-PHILOSOPHY.md) — the canonical evidence table.
- [PRE_PR_VALIDATION_CHECKLIST.md](../../sop/PRE_PR_VALIDATION_CHECKLIST.md) — the pre-PR evidence gate.
