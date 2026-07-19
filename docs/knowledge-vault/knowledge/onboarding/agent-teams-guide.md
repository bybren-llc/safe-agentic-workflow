---
type: guide
title: "Agent Teams Guide"
description: "SSoT stub: authoritative reference for the experimental Agent Teams feature, team sizing, gate hooks, and token cost."
tags: [ssot-stub, onboarding, orchestration, agents, gates]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "docs/onboarding/AGENT-TEAMS-GUIDE.md"
verified_against: "fd0fc6a"
---

# Agent Teams Guide

This is a map-card. `docs/onboarding/AGENT-TEAMS-GUIDE.md` is the source of truth for the Agent
Teams feature — 613 lines, 11 H2 sections — and every source that mentions the feature flags it
experimental.

## What It Is Authoritative For

What Agent Teams are, how to enable them, the first-team quick start, mapping the SAFe workflow
onto a team, team sizing, quality gate hooks, token cost, known limitations, troubleshooting, and
running teams remotely through the Dark Factory. Prerequisites are Claude Code 2.1.0 or later with
the experimental feature enabled; the enablement key name is
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in `.claude/settings.json`.

## The Distinction It Draws

Agent Teams are one of three multi-agent approaches the harness describes, and the guide is careful
to separate them: subagents launched through the Task tool, background agents running as headless
sessions, and Agent Teams. In a team the lead is TDM or the ARCHitect-in-CLI, teammates are
specialist roles, and coordination happens through a shared TaskList plus inter-agent messages —
with SAFe gates encoded as task dependencies rather than as prose. That encoding is why this guide
matters: it is where [Stop-the-Line Gate](../../methodology/stop-the-line-gate.md) stops being a
norm and becomes a scheduling constraint.

## When To Read It

Read it when you are considering parallel multi-agent execution, and read the token cost section
before you commit — parallelism here is bought with tokens, not saved. Read the known limitations
section before you promise anything, because the feature is experimental.

One asymmetry to note: `team-coordination` is the only skill absent from `.gemini/skills/`, so this
capability does not carry across providers the way the rest of the skill set does.

## Next

- [Agent Setup Guide](agent-setup-guide.md) — install and verify the agents first.
- [Dark Factory](../../subsystems/dark-factory.md) — running teams remotely.

## Citations

- [AGENT-TEAMS-GUIDE.md](../../../onboarding/AGENT-TEAMS-GUIDE.md) — the full feature reference.
