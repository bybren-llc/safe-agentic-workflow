---
type: guide
title: "Whitepapers Index (SSoT stub)"
description: "Pointer to the index of the five Claude Code harness whitepapers."
tags: [methodology, ssot-stub, onboarding]
timestamp: 2026-07-19
status: active
sources:
  - "docs/whitepapers/README.md"
verified_against: "fd0fc6a"
---

# Whitepapers Index (SSoT stub)

The 93-line front door to `docs/whitepapers/`. It is a reading list, not an argument: one
Documents section naming five papers, followed by Quick Start, Related Documentation, and Origin.
This concept points at it and records where the index and the directory disagree.

## The five indexed documents

1. Claude Code Harness Modernization (Main Whitepaper)
2. Agent Perspective: Why This Harness Works
3. Knowledge Transfer Meta-Prompt
4. Iteration Patterns Comparative Analysis
5. Anthropic Research Alignment

## Doc drift: the index does not match the directory

Two mismatches, both worth knowing before you follow a link:

- Entry 1, *Claude Code Harness Modernization (Main Whitepaper)*, **has no file in
  `docs/whitepapers/`**. This is the same missing parent that
  `CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md` declares itself an addendum to, so two documents now
  point at a whitepaper that is not in the repository.
- `HARNESS-v2.5.0-KT.md` **exists on disk but appears in no index entry**, so a reader working
  from the index will miss it entirely.

The directory is the authority on what you can actually read; the index is the authority on what
was intended to exist. Neither has been reconciled.

## Where to start

The vault carries a map-card for each paper that is present:
[Agent Perspective](harness-agent-perspective.md),
[KT Meta-Prompt](harness-kt-meta-prompt.md),
[Harness v2.5.0 KT](harness-v2-5-0-kt.md),
[Iteration Patterns](iteration-patterns-comparative-analysis.md), and
[Anthropic Research Alignment](anthropic-research-alignment.md). Start with Agent Perspective if
you want the reasoning, Iteration Patterns if you want the tradeoffs.

## Citations

- [Whitepapers README](../../../whitepapers/README.md) — the index itself, including its Quick
  Start and Origin sections.
