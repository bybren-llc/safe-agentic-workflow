---
type: guide
title: "Harness Agent Perspective (SSoT stub)"
description: "Pointer to the addendum whitepaper arguing why the harness works from the agent's point of view."
tags: [methodology, ssot-stub, agents]
timestamp: 2026-07-19
status: active
sources:
  - "docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md"
verified_against: "fd0fc6a"
---

# Harness Agent Perspective (SSoT stub)

A 293-line essay written from the agent's side of the table: not what the harness asks agents to
do, but why an agent working inside it performs better than one working without it. This concept
is a pointer. The argument lives in the source and is not restated here.

## What the source covers

Titled *Agent Perspective: Why This Harness Works*, it moves through the harness as an expertise
system — progressive disclosure of context, pattern-first development as a real constraint rather
than a slogan, process offered as a service instead of control, and documentation treated as a
product whose consumer is an agent. It closes with the reasoning behind key design decisions and
the practical implications for anyone operating the team.

## Read it when

- You are onboarding to the harness and the *rules* make sense but the *reasons* do not.
- You are deciding whether to keep, cut, or generalize a harness mechanism, and want the argument
  for what it buys the agent before you remove it.
- You have already read [Round Table Philosophy](../../methodology/round-table-philosophy.md);
  the whitepaper's Round Table section is a restatement of that model from the agent's view, so
  the philosophy concept is the better first door.

## Known gap

The document declares itself *An Addendum to the Claude Code Harness Modernization Whitepaper*,
and that parent whitepaper is not present in `docs/whitepapers/`. The directory holds six files —
`ANTHROPIC-RESEARCH-ALIGNMENT.md`, `CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md`,
`CLAUDE-CODE-HARNESS-KT-META-PROMPT.md`, `HARNESS-v2.5.0-KT.md`,
`ITERATION-PATTERNS-COMPARATIVE-ANALYSIS.md`, and `README.md`. Read this as a standalone essay;
the context it assumes is unavailable in the repository. The same missing parent is recorded in
[Whitepapers Index](whitepapers-readme.md).

## Citations

- [Agent Perspective: Why This Harness Works](../../../whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md)
  — the full addendum, and the authority for everything summarized above.
- [Whitepapers Index](whitepapers-readme.md) — the other four harness whitepapers and how they
  relate.
