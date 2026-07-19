---
type: command
title: "/media:analyze-video"
description: "Gemini-only command that breaks a video into scenes and reports setting, subjects, actions, dialogue and visual style per scene."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/analyze-video.toml"
sources:
  - ".gemini/commands/media/analyze-video.toml"
verified_against: "fd0fc6a"
---

# /media:analyze-video

The descriptive member of the video trio: it tells you what happens in each scene, in prose. Use it
when you need to understand a video you have not watched.

## Overview

Gemini-only. Identifies scenes and transitions through multimodal input, captures Setting,
Subjects, Actions, Dialogue and Visual Style per scene, and emits a Video Analysis Report with
per-scene timestamp blocks, a Summary narrative arc, and Visual Style Notes. Its siblings read the
same input and differ only in output shape: [/media:scene-detect](media-scene-detect.md) emits
boundary metadata, [/media:video-to-script](media-video-to-script.md) emits a formatted script.

## Invocation

- `/media:analyze-video <path>` — default `--summary`.
- `--detailed`, `--json`, `--timestamps` — alternative output modes.
- Preconditions: Gemini 3+ for video processing; MP4, MOV, AVI, MKV or WEBM; up to 100MB.

## What It Does

- Verifies the target with `file {{args}} || echo "File not found"` — the only shell call.
- Analyses scenes: transitions, visuals, objects, people, actions, settings, camera movement and
  composition, plus transcribed dialogue and on-screen text.
- Analyses the audio track alongside the visual content, which is where the overlap with the two
  sibling commands comes from.
- Emits the report, each scene block carrying start-end timestamps and a Transition field, closing
  with dominant colors, camera work and editing pace.
- Sends video contents to the Gemini API — stated as an explicit privacy note.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Long inputs are explicitly sampled at key intervals rather than analysed exhaustively, so scene
  lists for long videos are lossy by design, not by failure.
- Open question: the 100MB cap is stated but no error path is defined for exceeding it — the
  behaviour on oversized input is UNKNOWN.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
