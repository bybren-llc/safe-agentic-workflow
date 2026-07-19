---
type: guide
title: "Skill Authoring Guide"
description: "SSoT stub: authoritative reference for creating and maintaining Claude Code skills, including Skills 2.0 frontmatter fields."
tags: [ssot-stub, skills, providers, patterns]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "docs/guides/SKILL_AUTHORING_GUIDE.md"
verified_against: "fd0fc6a"
---

# Skill Authoring Guide

A pointer card. `docs/guides/SKILL_AUTHORING_GUIDE.md` is 541 lines and is the authority for
anything that lands in `.claude/skills/`. Its Gemini-side twin is the
[Gemini CLI Authoring Guide](gemini-cli-authoring-guide.md).

## What It Is Authoritative For

- Skill folder structure — what a skill directory contains and why.
- This harness's skill standards, which are stricter than the upstream Anthropic guidance.
- The step-by-step procedure for creating a new skill.
- Maintenance expectations once a skill exists.

Seven numbered sections: Introduction, Official Anthropic Resources, Community Resources, Skill
Structure, Our Harness Standards, Step-by-Step Create a New Skill, and Examples from This Harness.

## The Skills 2.0 Frontmatter Fields

[CONTRIBUTING.md](../root-docs/contributing.md) does not define these itself — it routes here for
them: `disable-model-invocation`, `user-invocable`, `context: fork`, `allowed-tools`, and
`argument-hint`. If you are auditing a skill's frontmatter, this guide is the field reference.

## When To Read It

Read it when adding a skill to `.claude/skills/`, and when auditing an existing skill's
frontmatter and trigger wording. Trigger wording is the part that most often goes wrong: a skill
nothing invokes is indistinguishable from a skill that does not exist.

## Mirroring

A skill added on the Claude side usually needs mirroring into `.gemini/skills/` and
`.agents/skills/`. See [Agent Providers](../../providers/agent-providers.md) for the shape of the
provider trees and [Portable Agents](../../providers/agents-portable.md) for the neutral one.

## Citations

- [SKILL_AUTHORING_GUIDE.md](../../../guides/SKILL_AUTHORING_GUIDE.md) — the authority.
- [GEMINI_CLI_AUTHORING_GUIDE.md](../../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the Gemini twin.
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) — routes here for Skills 2.0 fields.
