---
type: script
title: "generalize-onboarding-docs.sh"
description: "Replaces hardcoded project references in onboarding docs with template placeholders, backing up each file first."
tags: [operations, onboarding, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/generalize-onboarding-docs.sh"
sources:
  - "scripts/generalize-onboarding-docs.sh"
verified_against: "fd0fc6a"
---

# generalize-onboarding-docs.sh

Runs the inverse of [setup-template.sh](setup-template.md): it turns concrete project values in
the onboarding docs back into `{{PLACEHOLDER}}` tokens. Running it on a live, already-configured fork would
de-configure those five documents. This is a stub; the script is the source of truth.

## Overview

Template-preparation tooling, not part of any routine workflow — it was applied once to make the
onboarding set redistributable and has no reason to run again. It is bash under `set -euo pipefail`
at 3405 bytes, needs only standard text tooling, and targets a fixed brace-expansion list rather
than discovering files. Its one safety measure is a copy-before-edit.

## Inputs & Outputs

- **In** — no flags or arguments; the file list is hardcoded.
- **In** — five paths under `docs/onboarding/`: `DAY-1-CHECKLIST.md`, `SOCIAL-MEDIA-SETUP.md`,
  `AGENT-SETUP-GUIDE.md`, `META-PROMPTS-FOR-USERS.md`, `USER-JOURNEY-VALIDATION-REPORT.md`.
- **Out** — those files rewritten in place with placeholder tokens.
- **Out** `<file>.bak` — a copy of each existing target, made before editing and never cleaned up
  by this script. Removing them is the operator's job.
- **Exit** `0` — including when targets are missing, since each file is guarded by
  `if [ -f "$file" ]` and absent paths are skipped without failing.

## Invoked By

- Nothing. No workflow, hook, command, or other script references it; it is operator-run.
- Its logical counterpart is [setup-template.sh](setup-template.md), which performs the forward
  substitution — but neither script calls the other.

Two open questions from the source: the exact mapping of hardcoded strings to placeholder tokens is
UNKNOWN, and so is whether a second run over already-generalized files is a no-op or
double-substitutes.

## Citations

- [Day 1 Checklist](../../../onboarding/DAY-1-CHECKLIST.md) — one of the five documents it
  rewrites.
- [Agent Setup Guide](../../../onboarding/AGENT-SETUP-GUIDE.md) — another of the five.
