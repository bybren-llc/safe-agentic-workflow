---
type: command
title: "/media:transcribe-audio"
description: "Gemini-only command that transcribes audio to timestamped text, SRT, WebVTT or JSON with automatic language detection."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/transcribe-audio.toml"
sources:
  - ".gemini/commands/media/transcribe-audio.toml"
verified_against: "fd0fc6a"
---

# /media:transcribe-audio

The plain transcription path: words out, subtitles if you want them. When knowing who spoke is the
point rather than a bonus, use [/media:extract-dialogue](media-extract-dialogue.md) instead.

## Overview

Gemini-only, and the shortest of the audio commands at three steps. Detects the language
automatically, transcribes through multimodal input, flags low-confidence segments for review, and
formats to one of four shapes including two standard subtitle formats. Transcription is model
inference with no external ASR dependency.

## Invocation

- `/media:transcribe-audio <path>` — default `--text`, lines prefixed `[HH:MM:SS]`.
- `--srt` — numbered cues with comma-millisecond timecodes.
- `--vtt` — a WEBVTT header with dot-millisecond timecodes.
- `--json` — a segments array of `{start, end, text, speaker}` with float seconds.

## What It Does

- Verifies the target with `file {{args}} || echo "File not found"` — the only shell call.
- Transcribes with automatic language detection, attaching speaker labels when multiple speakers
  are present and flagging low-confidence segments.
- Formats the result into the requested shape.
- Sends audio contents to the Gemini API — stated as an explicit privacy note.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- Preconditions: Gemini 3+ for audio; MP3, WAV, AIFF, AAC, OGG or FLAC; up to 100MB. Best results
  need clear audio and minimal background noise.
- DOC DRIFT: step two promises word-level timestamps, but every output example — text, SRT, VTT and
  JSON — is segment or utterance level. No output mode in this file can express a per-word
  timestamp, so treat the segment granularity as the real behaviour.
- Open question: the source says a language may be "specified" but defines no flag for it, so how a
  language is passed is UNKNOWN.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal conventions this file follows.
