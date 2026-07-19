---
type: command
title: "/media:extract-frames"
description: "Gemini-only command that identifies visually significant video frames and describes each as a storyboard entry."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/extract-frames.toml"
sources:
  - ".gemini/commands/media/extract-frames.toml"
verified_against: "fd0fc6a"
---

# /media:extract-frames

Read the name carefully before reaching for this one. It extracts no images. It finds the moments
that matter in a video and writes them up as a storyboard, for edit decision support.

## Overview

Gemini-only. Selects key frames on visual significance rather than fixed intervals, then describes
each in text. NAMING DRIFT: nothing is written to disk — there is no ffmpeg call, no image write
and no output path anywhere in the source, so "extract" means "describe" here. If you need scene
boundaries instead, use [/media:scene-detect](media-scene-detect.md).

## Invocation

- `/media:extract-frames <path>` — default `--storyboard`.
- `--detailed` or `--json` — prose or machine-readable variants.
- `--max N` — caps the frame count; the default is 20 key frames.
- Preconditions: Gemini 3+ for video; MP4, MOV, AVI, MKV or WEBM; up to 100MB.

## What It Does

- Verifies the target with `file {{args}} || echo "File not found"` — the only shell call.
- Identifies key frames on five signals: scene changes, significant moments (key actions,
  reactions, events), composition shifts, text appearances (title cards, lower thirds, captions),
  and subject changes.
- Per frame, records a precise timestamp, a detailed visual description, subjects and objects,
  composition and framing notes, and narrative relevance.
- Renders either the markdown Key Frame Report or the Storyboard table with columns for number,
  timestamp, visual, action, and audio or dialogue.
- Sends video contents to the Gemini API — stated as an explicit privacy note.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Frame selection is significance-based and the source states the count varies by content
  complexity, so two runs over the same input are not guaranteed to agree.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
