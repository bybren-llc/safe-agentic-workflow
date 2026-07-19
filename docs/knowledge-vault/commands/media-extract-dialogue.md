---
type: command
title: "/media:extract-dialogue"
description: "Gemini-only command that transcribes audio with speaker diarization, emitting screenplay, JSON or plain labeled transcript."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/extract-dialogue.toml"
sources:
  - ".gemini/commands/media/extract-dialogue.toml"
verified_against: "fd0fc6a"
---

# /media:extract-dialogue

For multi-speaker audio — interviews, panels, calls — where knowing who said what matters as much
as what was said. Diarization is the product here, not a side effect.

## Overview

Gemini-only. Estimates the speaker count, assigns consistent `Speaker N` labels, then transcribes
with attribution and per-turn timestamps into one of three shapes. It overlaps
[/media:transcribe-audio](media-transcribe-audio.md), which also attaches speaker labels — but that
command does so only when multiple speakers happen to be detected, and offers no speaker hint.

## Invocation

- `/media:extract-dialogue <path>` — default `--screenplay`.
- `--json` — a speakers array plus a dialogue array of `{speaker, start, end, text}`.
- `--transcript` — plain `Speaker N [HH:MM:SS]: text` lines.
- `--speakers N` — a hint for the expected speaker count, not a constraint.

## What It Does

- Verifies the target with a pre-executed `!{file {{args}} 2>/dev/null || echo "File not found"}`
  — the stderr redirect is what makes the echo branch the observable failure path.
- Identifies speakers by pitch, pace and accent, and flags overlapping speech.
- Transcribes with attribution, preserving pauses and interruptions and noting non-verbal sounds
  such as laughter, applause and silence.
- Formats into screenplay, JSON or transcript shape.
- Sends audio contents to the Gemini API — stated as an explicit privacy note.
- Performs diarization as model inference: no external ASR or diarization library is involved.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Preconditions: Gemini 3+ for audio; MP3, WAV, AIFF, AAC, OGG or FLAC; up to 100MB.
- Accuracy is bounded by the source's own caveats: speaker identification is approximate and
  voice-characteristic based, improves with distinct voices and minimal crosstalk, and overlapping
  segments are flagged but transcribed with reduced accuracy.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
