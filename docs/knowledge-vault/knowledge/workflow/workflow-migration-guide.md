---
type: process
title: "Workflow Migration Guide v1.0 to v1.1 (SSoT stub)"
description: "Pointer to the migration guide for moving a team from workflow v1.0 to v1.1."
tags: [methodology, workflow, process, ssot-stub, onboarding]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/WORKFLOW_MIGRATION_GUIDE.md"
verified_against: "fd0fc6a"
---

# Workflow Migration Guide v1.0 to v1.1 (SSoT stub)

The 398-line guide for moving a team from workflow v1.0 to v1.1 — written for the engineer being
migrated, not the person deciding to migrate. It opens with a TL;DR quick summary so a reader can
tell in a minute what changes for them.

## Overview

After the TL;DR it covers what you need to know, a step-by-step adoption sequence with shell
checks, a reference guide, a transition period framed as roughly two weeks, common issues and
solutions, tracked metrics, contacts, additional resources, and a quick start checklist. It is
enforced by convention and review only. Its examples carry unsubstituted `{{TICKET_PREFIX}}` and
`{{MCP_LINEAR_SERVER}}` placeholders, so substitute your own before copying a command.

## Flow

- **Read the TL;DR.** It is the decision point on whether the rest of the document applies to you.
- **Run the readiness checks.** The adoption section checks branch naming against the ticket
  convention, sync state against the main branch, Linear ticket status, and a clean working tree
  before anything else changes.
- **Adopt the v1.1 practices.** Step-by-step, including atomic commits and the System Architect
  review on the pull request.
- **Pass the TDM pre-implementation gate.** The guide carries this gate explicitly; it is the stop
  that keeps unready work out of v1.1 flow.
- **Work through the transition period.** Roughly two weeks of both-versions tolerance, with the
  common-issues section as the debugging surface.
- **Confirm against the quick start checklist.** The closing checklist is the completion test.

## Roles Involved

- **[TDM](../../roles/tdm.md)** — owns the pre-implementation gate and the transition period.
- **[System Architect](../../roles/system-architect.md)** — accountable for the pull request review
  the migration introduces.
- **Migrating engineer role** — accountable for the readiness checks and the closing checklist.

## Citations

- [Workflow Migration Guide](../../../workflow/WORKFLOW_MIGRATION_GUIDE.md) — the authoritative
  step-by-step procedure, gates, and troubleshooting.
- [Workflow Changes v1.3](workflow-changes-v1-3.md) — later versions exist; no v1.1 to v1.2 or
  v1.2 to v1.3 migration document is present in `docs/workflow/`, so those hops are undocumented.
