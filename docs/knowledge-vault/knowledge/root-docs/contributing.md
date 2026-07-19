---
type: guide
title: "CONTRIBUTING.md"
description: "SSoT stub: authoritative git workflow, branch and commit format, PR process, and CI expectations for humans and agents alike."
tags: [ssot-stub, workflow, ci, process, release]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "CONTRIBUTING.md"
verified_against: "fd0fc6a"
---

# CONTRIBUTING.md

The 639-line contract for getting a change from a branch into the trunk. Both `CLAUDE.md` and
`AGENTS.md` mark it a MANDATORY READ — meaning read it before your first commit, branch, or PR.

## What It Is Authoritative For

Branch naming (`{{TICKET_PREFIX}}-{number}-{description}`), the SAFe commit format
`type(scope): description [{{TICKET_PREFIX}}-XXX]` and its eight allowed types, the rebase-first
workflow, the seven-step process from ticket to merge, the PR template requirements, the six CI
pipeline stages, and "Rebase and merge" as the only permitted merge strategy. It also carries RLS
development guidance and troubleshooting recipes that appear nowhere else.

It restates — rather than owns — the [exit states](../../methodology/exit-states.md), the gate
table, and [role collapsing](../../methodology/role-collapsing.md). Where its shorter tables
disagree with [Agent Workflow SOP v1.4](../sop/agent-workflow-sop.md), the SOP wins.

## Known Drift

Three clusters, all live as of `fd0fc6a`:

- It cites `docs/guides/SECURITY_FIRST_ARCHITECTURE.md`; the file is really at
  [docs/security/SECURITY_FIRST_ARCHITECTURE.md](../../../security/SECURITY_FIRST_ARCHITECTURE.md).
- Seven further cited paths do not exist on disk: `docs/technical-improvements/` (cited three
  times as the ticket roadmap), `docs/contracts/REDIS_IMPLEMENTATION_CONTRACT.md`,
  `docs/CI-CD-Pipeline-Guide.md`, `docs/ci-cd-implementation-checklist.md`,
  `docs/guides/RLS_TROUBLESHOOTING.md`, `scripts/setup-ci-cd.sh` (a required setup step), and
  `docs/{{PROJECT_NAME}}-Multi-Team-Git-Workflow-Guide.md`.
- Its workflow branches from and rebases onto `dev`, while `.claude/hooks-config.json` blocks
  pushes to and compares against `main`. The hook is the enforced behaviour; the prose is not, and
  this is the drift that bites — the others fail loudly as dead links, this one as a rejected push.

## Where To Go Next

- [Agent Workflow SOP v1.4](../sop/agent-workflow-sop.md) — how to invoke agents for the work the
  branch will contain; read before you start, not after.
- [Pre-PR Validation Checklist](../sop/pre-pr-validation-checklist.md) — the judgment items these
  mechanical steps do not cover.
- [Three-Stage PR Review](../../methodology/three-stage-pr-review.md) — what happens once the PR
  is open.

## Citations

- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — the full workflow; footer declares Version 2.1,
  last updated 2025-12-23.
