---
type: command
title: "/media:organize-files"
description: "Gemini-only command that renames and refiles a directory by analysing file contents rather than extensions, behind a dry-run plan."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/organize-files.toml"
sources:
  - ".gemini/commands/media/organize-files.toml"
verified_against: "fd0fc6a"
---

# /media:organize-files

The only destructive command in the media family: it renames and moves real files. The other ten
read and describe. Treat it accordingly — back up first, read the plan before answering the prompt.

## Overview

Gemini-only. Categorises a directory by content rather than extension, routes files into semantic
folders, proposes content-based names, and presents an Organization Plan for approval before
executing. Where [/media:analyze-images](media-analyze-images.md) only suggests filenames, this one
applies them.

## Invocation

- `/media:organize-files <directory>` — the directory to reorganize.
- `--dry-run`, `--interactive` — plan-only and per-file confirmation.
- `--images-only`, `--documents-only`, `--date-prefix`, `--no-subfolders` — scope and naming flags.

## What It Does

- Scans with `find {{args}} -type f -not -path "*/.*" | head -50` plus a `wc -l` count. HARD LIMIT:
  the plan is built from at most 50 files while the count reports the true total, so the plan
  under-reports on large directories. The `-not -path` predicate is what skips hidden files.
- Categorises across five rows: images by visual analysis, documents by text extraction, audio by
  metadata and transcription, code by purpose detection, data by schema analysis.
- Routes by content into `screenshots/`, `photos/people/`, `photos/products/`, `diagrams/`,
  `icons/`, `documents/invoices|contracts|reports|receipts/`, `tests/` and `utils/`.
- Renames using EXIF date plus content: `IMG_1234.jpg` to `2025-01-14_vacation_beach_sunset.jpg`.
- Presents Will Create Folders, Will Rename and Will Move tables, then prompts `Proceed? (y/n)`.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- DOC DRIFT: "Dry-run first: Always shows plan before execution" is listed as a safety feature
  while `--dry-run` is also an opt-in flag; whether the gate is unconditional is contradictory.
- DOC DRIFT: the Notes claim an option to preserve originals by copying, but no such flag appears
  in the Options list.
- Open questions: the undo script's path and language are UNKNOWN — the source names it and defines
  neither. Duplicate detection is stated as content hash plus visual similarity, with no threshold.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and shell-injection conventions this file follows.
