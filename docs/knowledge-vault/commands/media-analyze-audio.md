---
type: command
title: "/media:analyze-audio"
description: "Gemini-only command that classifies audio as speech, music, ambient or mixed and reports mood, segments and technical quality."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/analyze-audio.toml"
sources:
  - ".gemini/commands/media/analyze-audio.toml"
verified_against: "fd0fc6a"
---

# /media:analyze-audio

Reach for this when you have an audio file and no idea what is on it. It answers "what kind of
sound is this" rather than "what was said" — for words, use
[/media:transcribe-audio](media-transcribe-audio.md).

## Overview

One of eleven media commands that exist only on the [Gemini surface](../providers/gemini-cli.md).
Classifies the file into Speech, Music, Ambient or Mixed, then branches its analysis on that
classification, and finally emits an Audio Analysis Report. The only shell call in the whole file
is `file` — everything else is model multimodal inference, not a signal-processing tool.

## Invocation

- `/media:analyze-audio <path>` — default `--summary` report.
- `/media:analyze-audio <path> --detailed` or `--json` — fuller prose, or machine-readable output.
- Preconditions: Gemini 3+ for audio processing; input in MP3, WAV, AIFF, AAC, OGG or FLAC.

## What It Does

- Verifies the target with a pre-executed `!{file {{args}} 2>/dev/null || echo "File not found"}`
  — the stderr redirect is what makes the echo branch the observable failure path.
- Classifies content type, then branches: speech yields language and dialect, pace in WPM,
  emotional tone and clarity; music yields genre, tempo, instrumentation and energy; ambient or
  mixed yields source identification, layering, and dominant versus background.
- Emits the report: File Info, Content Type, Mood and Tone, a timestamped Key Segments table, and
  Technical Quality (clarity, background noise, dynamic range, overall).
- Sends audio contents to the Gemini API — the file states this as an explicit privacy note.
- Marks duration estimates as approximate.

## Provider Parity

- Gemini — the only implementation.
- Claude — absent. No `.claude/commands` counterpart exists, so this capability has zero parity;
  a Claude operator has no equivalent path to it.
- Open question: unlike the video and dialogue commands, this file states no file size limit. It is
  UNKNOWN whether the same 100MB cap applies here.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and multimodal command conventions this file follows.
