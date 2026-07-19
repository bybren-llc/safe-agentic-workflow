---
type: guide
title: "Start Here"
description: "The ordered path into this harness for someone new, where each step states why it comes where it does."
tags: [onboarding, methodology, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
verified_against: "fd0fc6a"
---

# Start Here

This is the learning door. The [index](index.md) is the reference door — use that when you already
know what you are looking for. **Each step below states why it comes at that position.** The
ordering is the teaching.

## 1. Understand what this repository is

Read [Three-Layer Architecture](methodology/three-layer-architecture.md) first, because every other
concept sits inside it. Hooks fire on events, commands are user-invoked, skills load themselves when
context matches. Until you can place an artifact in one of those three layers, the directory tree
looks arbitrary.

## 2. Learn the collaboration model before the mechanics

[Round Table Philosophy](methodology/round-table-philosophy.md) comes second, not last, because it
explains why agents here are expected to disagree with you. Read the mechanics first and stop-the-line
authority looks like insubordination; read this first and it looks like the point.

## 3. Learn the one rule you cannot violate

[Stop-the-Line Gate](methodology/stop-the-line-gate.md) is third because everything after it assumes
it. Work does not begin without Acceptance Criteria and a Definition of Done. An implementing agent
that invents its own AC has already failed, no matter how good the code is.

## 4. Meet the roles, then their boundaries

[Roles](roles/index.md) defines who does what. Read [Exit States](methodology/exit-states.md)
immediately after, because a role is defined as much by where it hands off as by what it does — and
the handoff strings are literal, checked values, not prose.

## 5. Only now, the tooling

[Skills](skills/index.md) and [Commands](commands/index.md) make sense once you know which role
invokes them and at which gate. Reading them earlier gives you a list of tools with no idea when to
reach for one.

## 6. Pick your cadence

[SAFe x AI-DLC](methodology/safe-ai-dlc.md) is optional and comes last, because it is an
**alternative** to sprint cadence, not a replacement for anything above. Bolts suit agent-speed
programs; the standard sprint path remains valid. Choose deliberately.

## One traced request, end to end

Abstractions are cheap. Follow a single ticket through the real system, and check each hop against
the code:

1. [`/start-work`](commands/start-work.md) opens the ticket and refuses to branch until AC and DoD
   exist — the gate from step 3, enforced in a command.
2. [BSA](roles/bsa.md) writes the Acceptance Criteria that gate demanded.
3. An implementer — say [BE Developer](roles/be-developer.md) — builds against them and exits at the
   literal state `Ready for QAS`.
4. [QAS](roles/qas.md) independently verifies the work against those AC and sets `Approved for RTE`.
   The independence is the gate — the verifier is never the implementer.
5. [RTE](roles/rte.md) assembles the PR. Its tool grant is `Read`, `Bash`, `Grep` — no write tools —
   so it shepherds rather than fixes.
6. [`pr-validation.yml`](operations/workflows/pr-validation.md) runs in CI.
7. A human merges. No agent holds that authority, RTE included.

Every hop above is a real file in this repository. If a claim here disagrees with the code, the code
wins and the concept is wrong — [file that as a finding](methodology/evidence-based-delivery.md).

## Where to go next

Browse by intent rather than by directory: [Domains](domains/index.md) regroups everything by
question — how sync works, how the providers stay in parity, how the subsystems fit together.
