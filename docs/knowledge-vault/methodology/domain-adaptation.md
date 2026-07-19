---
type: guide
title: "Domain Adaptation Beyond Software"
description: "Mapping harness roles, gates, and artifacts onto non-engineering teams such as marketing, research, legal, and operations."
tags: [methodology, process, onboarding, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "README.md"
  - "docs/guides/OPTIONAL-FEATURES.md"
  - "TEMPLATE_SETUP.md"
  - "docs/team/PLANNING-AGENT-META-PROMPT.md"
verified_against: "fd0fc6a"
---

# Domain Adaptation Beyond Software

The harness claims its patterns generalize past engineering — to Marketing, Research, Legal, and
Operations. Read this before promising a non-engineering team that the workflow will fit them,
because the claim is broader than the evidence behind it.

## What Is Actually Mapped

One README section, roughly twenty lines, carries the whole conceptual argument — two mapping
tables of four rows each, and nothing more. Marketing: BSA and specs become a Campaign Brief
Writer, Code Review becomes Asset Review, `/pre-pr` becomes `/pre-launch`, the Pattern Library
becomes Brand Guidelines. Research: User Stories become Research Questions, Test Cases become
Validation Criteria, CI/CD becomes a Peer Review Pipeline, Documentation becomes Literature Notes.
Legal and Operations are named as supported domains and receive no mapping table anywhere in the
repository. Treat them as aspiration, not guidance.

## Where the Mapping Stops Being Real

The renamed command in the Marketing row, `/pre-launch`, does not exist in the command set — only
[/pre-pr](../commands/pre-pr.md) ships. The analogy is illustrative, not an installed capability.
The README says as much twice, under *Known Limitations* and again under *Important Caveats*:
non-software adaptations are documented but not yet validated in production.

## The Half That Is Mechanical

Adaptation has a working half. The removal checklists in
[Optional Features](../knowledge/guides/optional-features.md) let a team strip the
software-specific integrations it will never use — Stripe, Confluence, RLS and PostgreSQL, Clerk —
leaving the role, gate, and evidence structure behind. That is a real, executable step, and it is
where a non-software adoption should begin.

## Open Questions

- No source defines how the eleven agent roles are renamed or re-scoped for a non-software domain.
  Only the four concept-level analogies above exist.
- No source states whether the QAS and Security Engineer independence gates described in
  [Role Collapsing and Independence Gates](role-collapsing.md) have non-software equivalents.

## Citations

- [README.md](../../../README.md) — the Domain Adaptation Guide section and its caveats.
- [TEMPLATE_SETUP.md](../../../TEMPLATE_SETUP.md) — placeholder substitution during adoption.
