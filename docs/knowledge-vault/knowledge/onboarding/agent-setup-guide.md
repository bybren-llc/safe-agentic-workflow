---
type: guide
title: "Agent Setup Guide"
description: "SSoT stub: authoritative install-and-verify walkthrough for the 11-agent system and first agent invocation."
tags: [ssot-stub, onboarding, agents]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/onboarding/AGENT-SETUP-GUIDE.md"
verified_against: "fd0fc6a"
---

# Agent Setup Guide

This is a map-card, not a copy. `docs/onboarding/AGENT-SETUP-GUIDE.md` is the source of truth for
installing the 11-agent system; read it there and use this page only to decide whether you need it.

## What It Is Authoritative For

Installing the eleven agents, the first invocation, the difference between direct-mention and
Task-tool invocation, the per-role capability reference, and setup validation with troubleshooting.
It runs nine numbered Parts plus Resources and Success sections across 474 lines, and states 30-45
minutes to complete. The only prerequisite it names is Claude Code or Augment Code already
installed.

## When To Read It

Read it first, before any of the daily-workflow guides. Each of
[Agent Teams Guide](agent-teams-guide.md), [Engineer Daily Workflow](engineer-daily-workflow.md),
and [QAS Daily Workflow](qas-daily-workflow.md) opens by assuming "repository cloned with agent
system verified" — this is the document that earns that assumption. Also read it when an adopter's
agents are simply not being found or invoked correctly, since its validation section is the fastest
way to tell a missing install from a wrong invocation form.

For the roster it installs, see [AGENTS.md](../root-docs/agents.md), which covers which agent to
reach for once they all exist.

## One Discrepancy Worth Knowing

This guide names Augment Code alongside Claude Code as a supported provider. The four-provider list
in the repository README does not include Augment Code. The guide's claim is the narrower,
setup-specific one; treat the README list as the canonical provider set and this as an additional
path the setup instructions still support.

## Next

- [Day 1 Checklist](day-1-checklist.md) — the same ground time-boxed for a person's first day.
- [Meta-Prompts for Users](meta-prompts-for-users.md) — the prompts that drive this setup.

## Citations

- [AGENT-SETUP-GUIDE.md](../../../onboarding/AGENT-SETUP-GUIDE.md) — the full install walkthrough.
