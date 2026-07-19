---
type: process
title: "Workflow Changes v1.3 (SSoT stub)"
description: "Pointer to the v1.3 workflow change record and its version history."
tags: [methodology, workflow, process, ssot-stub]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/WORKFLOW_CHANGES_v1.3.md"
verified_against: "fd0fc6a"
---

# Workflow Changes v1.3 (SSoT stub)

The 397-line record of what changed in the SAFe workflow at v1.3, and the newest workflow version
documented in `docs/workflow/`. This is a version-scoped change record, distinct from the harness
release notes under `docs/releases/` — the workflow and the harness version independently.

## Overview

The document opens with Version History, which carries the bulk of its length, then a pattern
selection guide, quality gates by version, a migration path, success metrics, related
documentation, and references. Read it to answer "which workflow version am I running, and what
does that version require of me". Its filename, `WORKFLOW_CHANGES_v1.3.md`, uses a lowercase `v`
and a dot where its siblings in the directory use plain uppercase names — worth knowing when
searching for it.

## Flow

- **Establish the version in play.** Version History states what each workflow version introduced;
  everything downstream depends on knowing which one applies.
- **Select the pattern.** The Pattern Selection Guide maps the situation to the workflow pattern
  to run, rather than defaulting to the heaviest one.
- **Apply the gates for that version.** Quality Gates by Version is explicit that gates differ
  across versions; applying v1.1 gates to v1.3 work under-checks it.
- **Migrate forward if behind.** The Migration Path section covers moving up. Note the only
  standalone migration document in the directory is v1.0 to v1.1 — see
  [Workflow Migration Guide](workflow-migration-guide.md).
- **Measure.** Success Metrics defines what the version change was supposed to improve, which is
  the only way to tell whether adopting it helped.

## Roles Involved

- **[RTE](../../roles/rte.md)** — accountable for which workflow version the team runs and for
  the migration decision.
- **[TDM](../../roles/tdm.md)** — accountable for applying the correct pattern and version gates
  to each work item.
- **[QAS](../../roles/qas.md)** — accountable for validating work against the gates of the version
  actually in force.

## Citations

- [Workflow Changes v1.3](../../../workflow/WORKFLOW_CHANGES_v1.3.md) — the authoritative change
  record, version history, and per-version quality gates.
- [Workflow Comparison v1.0-v1.2](workflow-comparison.md) — the side-by-side that stops at v1.2.
