---
type: guide
title: "Gemini CLI Authoring Guide"
description: "SSoT stub: authoritative reference for authoring Gemini CLI skills, TOML commands, hooks, and multimodal features in this harness."
tags: [ssot-stub, providers, skills, commands, hooks]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md"
verified_against: "fd0fc6a"
---

# Gemini CLI Authoring Guide

A pointer card. `docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md` is 512 lines and is the authority for
everything you write under `.gemini/`. Its Claude-side twin is the
[Skill Authoring Guide](skill-authoring-guide.md); the two cover the same task on two providers.

## What It Is Authoritative For

- Skill and command authoring conventions for the `.gemini/` tree.
- The TOML command format — the shape Gemini commands take, where Claude uses markdown.
- Namespaced command naming: `/workflow:*`, `/local:*`, `/remote:*`, `/media:*`.
- Hooks configuration in `settings.json`.
- Multimodal audio and video features, which have no Claude-side equivalent.

Eight numbered sections: Introduction, Official Google Resources, Skill Authoring, Command
Authoring, Hooks Configuration, Multimodal Features, Our Harness Standards, and Examples from
This Harness.

## When To Read It

Read it before adding or changing anything under `.gemini/`, and again when checking
Gemini-versus-Claude parity for a new command or skill. Parity is the recurring failure mode here:
a command added on one provider and not mirrored on the other looks complete until someone runs
the other CLI.

## Boundaries

The Gemini-versus-Claude capability comparison it contains is duplicated in the README's Gemini
CLI Integration section. Two copies of a comparison table drift; treat this guide as the source
and the README as the shop window.

For the provider surface itself rather than how to author into it, see
[Gemini CLI](../../providers/gemini-cli.md) and [Claude Code](../../providers/claude-code.md).

## Citations

- [GEMINI_CLI_AUTHORING_GUIDE.md](../../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the authority.
- [SKILL_AUTHORING_GUIDE.md](../../../guides/SKILL_AUTHORING_GUIDE.md) — the Claude Code twin.
