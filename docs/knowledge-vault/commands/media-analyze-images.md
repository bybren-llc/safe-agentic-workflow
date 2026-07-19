---
type: command
title: "/media:analyze-images"
description: "Gemini-only command that finds images in a directory, describes their visual content and suggests content-based filenames."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/analyze-images.toml"
sources:
  - ".gemini/commands/media/analyze-images.toml"
verified_against: "fd0fc6a"
---

# /media:analyze-images

For a directory of opaque filenames — `IMG_1234.jpg`, `Screenshot 2025-01-14.png` — that someone
needs to make sense of. It describes what is in each image and proposes a name that says so. It
reads; [/media:organize-files](media-organize-files.md) is the one that actually renames.

## Overview

A directory-scoped command on the [Gemini surface](../providers/gemini-cli.md) only. Discovers
images with a single `find`, reads each through multimodal input, and emits an Image Analysis
Report carrying Description, Key Elements, Suggested Name and Dimensions per file. Read-only in its
defined steps; the Output Options section gestures at mutations that have no steps behind them.

## Invocation

- `/media:analyze-images <directory>` — the directory is the only argument.
- Preconditions: the path must be a directory the `find` call can walk.
- Formats matched by the `-iname` list: PNG, JPG, JPEG, GIF, WEBP, SVG, BMP.

## What It Does

- Discovers files with `find` piped through `head -20`. This is a hard cap: directories with more
  than 20 images are silently truncated. The Notes separately advise batches of 10-20, which is
  guidance the command does not enforce beyond that cap.
- Per image, describes content and identifies objects, text, colors and composition, then proposes
  a content-based filename.
- Emits the report; image contents are sent to the Gemini API, base64-encoded for the model.
- Names further actions it "can also" do — rename files, sort into category folders, OCR text,
  generate alt-text, describe thumbnails — with no steps, gates or dry-run defined for any of them.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- DOC DRIFT: Supported Formats lists SVG and the `find` call matches `*.svg`, but SVG is vector XML
  rather than a raster format Gemini vision consumes; whether SVG input works is unverified.
- Open question: it is UNKNOWN which of the "can also" actions, if any, prompt before writing.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — uses this command as
  its worked multimodal example.
