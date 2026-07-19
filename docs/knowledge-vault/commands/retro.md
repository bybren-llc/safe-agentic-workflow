---
type: command
title: "/retro"
description: "Structured seven-section retrospective of the current work session, from what worked well to wins."
tags: [commands, operations, process, methodology]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/retro.md"
sources:
  - ".gemini/commands/workflow/retro.toml"
verified_against: "fd0fc6a"
---

# /retro

Run at the close of a session to convert what just happened into something the team can act on. It
is a pure prompt: no shell, no git, no MCP, no file reads, no file writes.

## Overview

Imposes seven fixed sections on the model's own recollection of the session, each anchored by a
stated focus question. Because the source of the content is session context rather than any
artefact, nothing it produces is verifiable from the repository — it is a reflection aid, not
evidence. Contrast [`/end-work`](end-work.md), which does gather evidence.

## Invocation

- `/retro` — no arguments.
- `/workflow:retro` on the Gemini surface.
- Precondition: a session with enough history to reflect on.

## What It Does

- Prompts through seven sections in order: What Worked Really Well (keep doing), Observations and
  Learning Moments (what did we learn), What Could Be Better (what to improve), Process Insights
  (what patterns are emerging), Session Metrics (what did we accomplish), Questions for Discussion
  (what needs team input), and Wins to Celebrate.
- Session Metrics enumerates six countables: deliverables, PRs created, issues resolved, files
  modified, docs updated, and time spent.
- Sets an explicit output tone: honest, specific, constructive.
- Touches nothing — its frontmatter declares `allowed-tools` of Read, Write, Edit, Bash, Grep and
  Glob, none of which the body ever uses. The declaration overstates the command's reach.

## Provider Parity

- Gemini — section-for-section identical; the closest parity of any command in this lane.
- Gemini — drops the emoji section headers and drops "time spent" from Session Metrics.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the session lifecycle this command closes.
