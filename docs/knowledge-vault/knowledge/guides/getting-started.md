---
type: guide
title: "Getting Started"
description: "SSoT stub: authoritative end-to-end path from first clone through first agent session, first PR, and optional advanced features."
tags: [ssot-stub, onboarding, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/guides/GETTING-STARTED.md"
verified_against: "fd0fc6a"
---

# Getting Started

A pointer card. `docs/guides/GETTING-STARTED.md` is 326 lines in eight numbered sections and is
the canonical ordering of adoption steps. Everything else in the onboarding cluster is either a
shorter form of it or a specialisation of one of its branches.

## What It Is Authoritative For

The ordered walkthrough, end to end:

1. Choosing an adoption path — new repo from the GitHub template, or an existing repo.
2. Configuring the harness.
3. Verifying the setup.
4. The first agent session.
5. The first pull request.
6. Optional advanced features: Agent Teams, then Dark Factory.

The ordering is the content. Later steps assume the earlier ones, which is why the guide is
numbered rather than a menu.

## When To Read It

Read it when onboarding a brand-new adopter who has not yet run `scripts/setup-template.sh`, or
whenever you need to confirm the canonical order of setup steps rather than reconstruct it.

## Neighbours And Boundaries

- [Template Setup](../root-docs/template-setup.md) hands off here once placeholders are replaced.
- [Day 1 Checklist](../onboarding/day-1-checklist.md) is the checklist form of the same ground —
  same steps, tick-box shape, for someone who has already read the narrative.
- It is **not** authoritative for existing-repo adoption specifics. That branch resolves to the
  [Workspace Adoption Guide](workspace-adoption-guide.md), which is where a repo with code
  already in it should go after step 1.
- The optional features at the end have their own homes:
  [Agent Teams](../onboarding/agent-teams-guide.md) and [Dark Factory](../../subsystems/dark-factory.md).

## Citations

- [GETTING-STARTED.md](../../../guides/GETTING-STARTED.md) — the authoritative walkthrough.
- [TEMPLATE_SETUP.md](../../../../TEMPLATE_SETUP.md) — the step that precedes it.
- [DAY-1-CHECKLIST.md](../../../onboarding/DAY-1-CHECKLIST.md) — the checklist form.
