---
type: command
title: "/media:sketch-to-code"
description: "Gemini-only command that turns sketches, wireframes and mockups into framework-specific component code or Mermaid diagrams."
tags: [commands, operations, providers, patterns]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/sketch-to-code.toml"
sources:
  - ".gemini/commands/media/sketch-to-code.toml"
verified_against: "fd0fc6a"
---

# /media:sketch-to-code

Takes a napkin drawing, a Figma screenshot or a flowchart and returns component code. The output is
explicitly a starting point, not production code — the source says so itself.

## Overview

Gemini-only, and one of two media commands that touch disk: it resolves an output directory and
saves generated code there. Accepts hand-drawn sketches, digital wireframes, UI mockups,
flowcharts and architecture diagrams. Unlike
[/media:organize-files](media-organize-files.md) it has no dry-run, no diff preview and no
confirmation gate anywhere in the file.

## Invocation

- `/media:sketch-to-code <image>` — the sketch or mockup to convert.
- `--react`, `--nextjs`, `--vue`, `--html`, `--tailwind`, `--shadcn`, `--mermaid` — output target.
- Preconditions: an image the model can read. Framework detection only matches react, next and vue,
  so `--html` and `--shadcn` have no detection path and must be passed explicitly.

## What It Does

- Detects the input with `ls -la {{args}} || echo "File not found"`, then identifies UI components,
  layout structure, visual hierarchy, interactive elements, and data flow for flowchart inputs.
- Determines the target framework by asking, or by grepping `package.json` for react, next or vue.
- Generates a component directory — `index.tsx`, `styles.css` when not Tailwind, `types.ts` — with
  semantic HTML, mobile-first responsive layout, ARIA attributes, sketch-matching placeholder
  content and interactive states.
- Resolves an output location by probing for `src/components`, then `components`, then `./`, and
  saves the generated code there.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- DOC DRIFT: this file carries no privacy note despite sending image contents to the Gemini API,
  unlike the audio and video media commands.
- Open question: the exact write path and the overwrite behaviour on a filename collision are
  UNKNOWN — step four resolves a directory but defines no collision rule.
- The source disclaims the output: review accessibility and responsiveness, add error handling.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — the TOML command
  format and shell-injection conventions this file follows.
