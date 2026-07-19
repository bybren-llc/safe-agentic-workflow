---
type: guide
title: "Database Data Dictionary (SSoT stub)"
description: "Pointer to the data dictionary, declared single source of truth for schema context."
tags: [ssot-stub, subsystems, security]
timestamp: 2026-07-19
status: active
sources:
  - "docs/database/DATA_DICTIONARY.md"
verified_against: "fd0fc6a"
---

# Database Data Dictionary (SSoT stub)

A map-card for `docs/database/DATA_DICTIONARY.md`, the 312-line document this harness names as the
single source of truth for schema context. Read this to know what that file claims to be and why
it is empty of your schema; read the file itself for anything you intend to act on.

## What it declares

The H1 reads "{{PROJECT_NAME}} Database Data Dictionary" and the opening blockquote states it is
the "Single Source of Truth for AI Agents and Development Context." That declaration is echoed
from [CLAUDE.md](../root-docs/claude-md.md), which points agents here rather than at migration
files or an ORM schema when they need to know what a table means.

## The catch

The `{{PROJECT_NAME}}` placeholder is unsubstituted, and the schema it documents is not one this
template repository contains. It is a shape to be filled during
[template setup](../root-docs/template-setup.md), not a description of anything live. Treating its
table listings as facts about your project before you have replaced them is the failure mode this
card exists to prevent.

## Where it sits

It is the first of four files indexed by the
[Database Documentation Index](database-readme.md), alongside the
[RLS Implementation Guide](rls-implementation-guide.md), the
[RLS Policy Catalog](rls-policy-catalog.md), and the
[RLS Database Migration SOP](rls-database-migration-sop.md). The dictionary answers "what is
this column"; the other three answer "who may read it" and "how do I change it."

## Citations

- [DATA_DICTIONARY.md](../../../database/DATA_DICTIONARY.md) — the dictionary itself.
