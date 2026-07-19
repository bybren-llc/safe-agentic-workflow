---
type: guide
title: "Meta-Prompts for Users"
description: "SSoT stub: authoritative set of copy-paste prompts that bootstrap setup, role selection, first ticket, and troubleshooting."
tags: [ssot-stub, onboarding, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/onboarding/META-PROMPTS-FOR-USERS.md"
verified_against: "fd0fc6a"
---

# Meta-Prompts for Users

This is a map-card. `docs/onboarding/META-PROMPTS-FOR-USERS.md` is the source of truth: 389 lines
whose payload is prompt text a human pastes into an agent, not procedure a human follows.

## What It Is Authoritative For

Seven meta-prompts, listed in order: Initial Setup, Agent Role Selection, First Linear Ticket,
Template Customization, Workflow Integration, Day 1 Checklist, and Troubleshooting. Usage Tips and
Additional Resources close the document.

## Why It Is The Entry Point

Every other onboarding document assumes the reader knows what to ask for. This one does not. It is
where a new adopter starts precisely because it removes the blank-page problem — you paste prompt 1
and the agent leads. From there it hands off: prompt 6 drives
[Day 1 Checklist](day-1-checklist.md), and prompts 2 and 3 lead into
[AGENTS.md](../root-docs/agents.md) and the daily-workflow guides. Read those *after* the prompt
that introduces them, not before, or the prompts read as redundant.

## Its Particular Staleness Mode

Because the payload is prompt text rather than procedure, this file goes stale differently from its
neighbours. A prompt that names a command or a role which has since been renamed still looks
correct on the page and only fails when pasted. Nothing detects that; it is worth re-reading
whenever the command set or role roster changes.

## Open Question

UNKNOWN: no source states whether these prompts were adapted for Gemini CLI, Codex CLI, or Cursor,
or whether they assume Claude Code slash-command syntax throughout. If you are onboarding on a
non-Claude provider, verify each prompt before trusting it.

## Next

- [Day 1 Checklist](day-1-checklist.md) — what prompt 6 sets in motion.
- [Agent Setup Guide](agent-setup-guide.md) — the install reference behind prompt 1.

## Citations

- [META-PROMPTS-FOR-USERS.md](../../../onboarding/META-PROMPTS-FOR-USERS.md) — the seven prompts.
