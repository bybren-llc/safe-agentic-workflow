---
type: command
title: "/media:video-to-script"
description: "Gemini-only command that fuses video transcription and visual analysis into a standard screenplay, narrative or shot list."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/video-to-script.toml"
sources:
  - ".gemini/commands/media/video-to-script.toml"
verified_against: "fd0fc6a"
---

# /media:video-to-script

The fusion member of the video trio. It reads the audio and visual tracks separately and merges
them into a document a screenwriter or editor would recognise.

## Overview

Gemini-only. Transcribes the audio track, analyses the visual track in parallel, then merges both
into screenplay format. Its siblings take the same input, the same five formats and the same 100MB
cap and differ only in output shape: [/media:analyze-video](media-analyze-video.md) describes
scenes, [/media:scene-detect](media-scene-detect.md) emits boundaries and an EDL. No NLE or
subtitle tooling is involved — the merge is model inference.

## Invocation

- `/media:video-to-script <path>` — default `--screenplay`.
- `--narrative` — prose rather than script formatting.
- `--shot-list` — the technical shot breakdown.
- `--json` — structured scene data. Preconditions: Gemini 3+; MP4, MOV, AVI, MKV or WEBM; to 100MB.

## What It Does

- Verifies the target with a pre-executed `!{file {{args}} 2>/dev/null || echo "File not found"}`
  — the stderr redirect is what makes the echo branch the observable failure path.
- Transcribes the audio track: all dialogue with speaker attribution, sound effects and ambient
  audio, music cues and transitions, and non-verbal vocalizations.
- Analyses the visual track: interior and exterior scene locations, character actions and
  movements, camera angles and transitions, on-screen text and graphics.
- Merges both into screenplay format — FADE IN and FADE OUT, INT. and EXT. scene headings, action
  paragraphs, centred character cues with dialogue, and CUT TO or CLOSE-UP directions.
- Sends video contents to the Gemini API — stated as an explicit privacy note.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Source caveats bound the output: speaker names default to `Speaker N` unless identifiable,
  INT/EXT headings are inferred from visual context rather than known, and camera direction notes
  are approximate.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
