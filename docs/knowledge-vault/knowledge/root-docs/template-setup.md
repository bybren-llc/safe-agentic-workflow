---
type: guide
title: "TEMPLATE_SETUP.md"
description: "SSoT stub: authoritative placeholder inventory and post-setup checklist for customizing the template into a real project."
tags: [ssot-stub, onboarding, operations]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "TEMPLATE_SETUP.md"
verified_against: "fd0fc6a"
---

# TEMPLATE_SETUP.md

126 lines that turn the template into somebody's actual repository. It is the authoritative
inventory of every `{{PLACEHOLDER}}` token the harness ships with, and the checklist for
confirming they are gone.

## The Inventory

Two tables: 29 core placeholders in the first, 10 technology-stack placeholders in the second.
Key names only — the document records no values, and neither does this vault. If a `{{TOKEN}}`
turns up in agent output, a CI log, or a generated file, this is the list to check it against.

## How Substitution Happens

The entry point is `scripts/setup-template.sh`, which prompts for each value and substitutes it in
place; see [setup-template](../../operations/scripts/setup-template.md) for the script concept.
Manual find-and-replace is the documented alternative, which is what makes the inventory table
load-bearing rather than decorative.

## The Self-Deleting Document

The post-setup checklist ends by instructing you to delete `TEMPLATE_SETUP.md` itself. That makes
its absence in an adopting repository expected rather than a defect — do not file it as missing
documentation. It also means the placeholder inventory is only reliably available in the upstream
template, so audit against upstream if the local copy is already gone.

## Where It Hands Off

- [Getting Started](../guides/getting-started.md) — the next document once substitution completes.
- [Optional Features](../guides/optional-features.md) — for trimming surfaces you do not want.
- It also documents the optional Agent Teams and Dark Factory enablement paths, and the
  sync-script upgrade commands; see [Agent Teams Guide](../onboarding/agent-teams-guide.md) and
  [Dark Factory](../../subsystems/dark-factory.md) for those subsystems.

## When To Read It

Two moments, and they are the whole use case: when a `{{PLACEHOLDER}}` token shows up somewhere it
should not, and when auditing whether substitution ever completed across the tree.

## Citations

- [TEMPLATE_SETUP.md](../../../../TEMPLATE_SETUP.md) — the placeholder tables and post-setup
  checklist.
- [GETTING-STARTED.md](../../../guides/GETTING-STARTED.md) — the successor document.
- [OPTIONAL-FEATURES.md](../../../guides/OPTIONAL-FEATURES.md) — the trimming guide.
