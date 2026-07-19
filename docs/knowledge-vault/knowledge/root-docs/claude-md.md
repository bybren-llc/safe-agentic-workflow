---
type: guide
title: "CLAUDE.md"
description: "SSoT stub: the project context file Claude Code loads automatically, holding commands, stack, and the pattern discovery mandate."
tags: [ssot-stub, providers, workflow, patterns]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# CLAUDE.md

This is a map-card. `CLAUDE.md` at the repository root is the source of truth — at 204 lines the
shortest of the six root docs, and the only one loaded automatically. Its claims reach every
[Claude Code](../../providers/claude-code.md) session whether or not anyone opens the file.

## What It Is Authoritative For

The development command table, the technology stack declaration, the repository structure summary,
the three metacognitive tags (`#PATH_DECISION`, `#PLAN_UNCERTAINTY`, `#EXPORT_CRITICAL`), the
pattern discovery protocol ordering, and project-specific implementation notes for authentication,
payments, analytics, and database.

Read it when you want to know what an agent already believes about this project before you tell it
anything. That is a different question from "what is true", and this file answers the first one.

## Nothing In It Runs As Shipped

Nearly every value is an unreplaced `{{PLACEHOLDER}}` token in this template repository — the
command table, the stack, the migration workflow. No command in it is runnable until an adopter
substitutes them. Treat the file as a shape to fill, not instructions to follow, and see
[Template Setup](template-setup.md) for the substitution pass.

## The File Class The README Warns About

An auto-loaded context file that has silently drifted is worse than no context file, because
nothing prompts a reader to doubt it. The README's Knowledge Vault section makes exactly this point:
an independent audit told developers to trust the vault *over* this project's canonical context
file, because the latter had drifted without anyone noticing. That is the argument for
[the vault](../../subsystems/knowledge-vault.md) stated by its sharpest example.

DOC DRIFT: its pattern discovery ordering puts `patterns_library/` first, contradicting
[AGENTS.md](agents.md), which starts at `specs/`. Both mark the protocol MANDATORY.

## Citations

- [CLAUDE.md](../../../../CLAUDE.md) — the full project context file.
