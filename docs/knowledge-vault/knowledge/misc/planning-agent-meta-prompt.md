---
type: guide
title: "Planning Agent Meta-Prompt (SSoT stub)"
description: "Pointer to the meta-prompt that drives the planning agent."
tags: [ssot-stub, agents, methodology, orchestration]
timestamp: 2026-07-19
status: active
sources:
  - "docs/team/PLANNING-AGENT-META-PROMPT.md"
verified_against: "fd0fc6a"
---

# Planning Agent Meta-Prompt (SSoT stub)

A map-card for `docs/team/PLANNING-AGENT-META-PROMPT.md`: 676 lines under an H1 of "Planning Agent
Meta Prompt", opening with an Overview, and the only file in `docs/team/`. Read this card to
decide whether the document is a wiring artifact or a copy-paste asset before you rely on it.

## What it is

A prompt payload stored as documentation. Unlike the role prompts under `agent_providers/`, which
are loaded by a provider configuration, this file's content is the instruction set itself, written
out at length in a docs directory that contains nothing else. Its length is the giveaway: it is
sized to be pasted into a session, not read by a human end to end.

## The open question

**UNKNOWN: no agent definition under `.claude/agents/` or `agent_providers/` has been confirmed to
load this file.** It may be wired into a provider, or it may be purely copy-paste. That gap is
unresolved at `fd0fc6a` and matters, because the two readings imply different maintenance duties —
a loaded prompt must stay in sync with the harness, a pasted one is a snapshot the user owns.
Verify before treating it as live configuration.

## Related reading

For prompts that are unambiguously user-invoked, see
[Meta-Prompts for Users](../onboarding/meta-prompts-for-users.md). For the planning methodology
the prompt serves, see [SAFe x AI-DLC](../../methodology/safe-ai-dlc.md) and the
[Agent Team Guide](../guides/agent-team-guide.md).

## Citations

- [PLANNING-AGENT-META-PROMPT.md](../../../team/PLANNING-AGENT-META-PROMPT.md) — the prompt itself.
