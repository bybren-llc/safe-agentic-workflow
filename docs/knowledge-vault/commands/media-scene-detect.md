---
type: command
title: "/media:scene-detect"
description: "Gemini-only command that detects and classifies video scene boundaries, emitting a scene table or a CMX 3600 EDL."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/scene-detect.toml"
sources:
  - ".gemini/commands/media/scene-detect.toml"
verified_against: "fd0fc6a"
---

# /media:scene-detect

The metadata member of the video trio. Where
[/media:analyze-video](media-analyze-video.md) narrates what each scene contains, this one produces
boundaries and transition types — and can hand an NLE a CMX 3600 EDL.

## Overview

Gemini-only, built for video editing workflows and content indexing. Scans for scene boundaries,
classifies each transition into one of six named types, and emits a scene list plus an Average
Scene Length figure and a Transition Summary tallying cuts, fades, dissolves and other. Detection
is model inference: no ffmpeg, no PySceneDetect, nothing but `file` on the shell.

## Invocation

- `/media:scene-detect <path>` — default `--table`: Scene, Start, End, Duration, Transition In,
  Description.
- `--edl` — a CMX 3600 Edit Decision List, stated as following the standard for NLE compatibility.
- `--json`, `--timestamps` — machine-readable and bare-boundary variants.
- Preconditions: Gemini 3+ for video; MP4, MOV, AVI, MKV or WEBM; up to 100MB.

## What It Does

- Verifies the target with `file {{args}} || echo "File not found"` — the only shell call.
- Scans for boundaries on significant frame-to-frame visual change, color palette, composition and
  content shifts, hard cuts and gradual transitions, and audio changes coinciding with visual ones.
- Classifies every transition as Cut, Fade In, Fade Out, Dissolve, Wipe or Jump Cut.
- Emits the scene list in the requested shape with the summary statistics appended.
- Sends video contents to the Gemini API — stated as an explicit privacy note.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Source caveats: transition classification is approximate and visual-analysis based, and very
  fast-paced content produces a high scene count.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
