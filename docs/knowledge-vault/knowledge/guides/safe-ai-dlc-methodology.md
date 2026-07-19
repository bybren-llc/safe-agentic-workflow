---
type: guide
title: "SAFe x AI-DLC Methodology"
description: "SSoT stub: the authoritative definition of Bolts, Units of Work, mob elaboration, the human gate, and dependency-wiring rules."
tags: [ssot-stub, methodology, process, orchestration]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/guides/SAFE-AI-DLC-METHODOLOGY.md"
verified_against: "fd0fc6a"
---

# SAFe x AI-DLC Methodology

A pointer card. `docs/guides/SAFE-AI-DLC-METHODOLOGY.md` is 142 lines, added by GH#53, and defines
the vocabulary the rest of the orchestration material assumes. Its stated audience is "anyone
contributing to a project using this harness -- human or agent", with the instruction to read it
if you have only ever worked the sprint model.

## What It Is Authoritative For

- The fusion mapping table across SAFe, AI-DLC, and Linear artifacts.
- The Bolt vocabulary, including Units of Work and mob elaboration.
- The six-step "How to Run a Bolt" procedure.
- The human-gate decision list — what a human must decide before a Bolt proceeds.
- The four dependency-wiring rules for building the DAG.
- The boundary: when *not* to reach for a Bolt.

## When To Read It

Read it first, before running any multi-issue program. For a single ticket the standard
[SAFe Workflow](../../skills/safe-workflow.md) path applies instead and a Bolt is overhead — the
guide says so itself, which is unusual and worth trusting.

## Its Two Counterparts

The document is the human-readable half of a trio. The machine-readable counterpart is the
[SAFe x AI-DLC skill](../../skills/safe-ai-dlc.md), which is what an agent actually loads. The
scaffolding counterpart is the
[program template](../../subsystems/spec-templates/program-template.md), which is what the
program gets written into. The concept summary lives at
[SAFe x AI-DLC](../../methodology/safe-ai-dlc.md).

## Citations

- [SAFE-AI-DLC-METHODOLOGY.md](../../../guides/SAFE-AI-DLC-METHODOLOGY.md) — the authority.
- [AI-Driven Development Life Cycle](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/)
  — the external AWS anchor the guide builds on.
