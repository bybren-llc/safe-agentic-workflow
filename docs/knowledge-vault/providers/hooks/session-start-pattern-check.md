---
type: script
title: "Hook: session-start-pattern-check.sh"
description: "Prints a pattern-library inventory and agent-system banner at session start; points at docs/patterns, not patterns_library."
tags: [providers, hooks, patterns, onboarding]
timestamp: 2026-07-19
status: active
domain: providers
resource: ".claude/hooks/session-start-pattern-check.sh"
sources:
  - ".claude/hooks/session-start-pattern-check.sh"
  - "agent_providers/claude_code/hooks/session-start-pattern-check.sh"
  - ".claude/hooks-config.json"
  - ".claude/agents"
verified_against: "fd0fc6a"
---

# Hook: session-start-pattern-check.sh

Counts markdown files in a pattern directory and prints an orientation banner meant to open a
session. It is read-only and cannot fail. Its one substantive problem is that it counts the wrong
directory, so the number it reports is confidently incorrect.

## Overview

It is the mechanical nudge behind
[Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md): remind the agent that
patterns exist before it writes anything. It needs `bash` and `find`. It is byte-identical to its
mirror at `agent_providers/claude_code/hooks/session-start-pattern-check.sh`.

## Inputs & Outputs

- **In** no arguments; `PATTERN_DIR` is hardcoded to `docs/patterns`.
- **In** the count comes from `find "$PATTERN_DIR" -name '*.md' -type f 2>/dev/null | wc -l`,
  computed before the `-d` guard and with `2>/dev/null` swallowing find's error — so on a missing
  directory the count silently reads 0.
- **Out** `stdout` — location, pattern count, four subdirectory hints (`api/`, `ui/`, `database/`,
  `testing/`), a reminder to check patterns before implementing, and an agent banner.
- **Exit** `0` — always; the else branch prints "Pattern library not found" and still exits 0.

## Invoked By

- Nothing. `.claude/hooks-config.json` has a SessionStart matcher, but it runs an inline echo
  listing slash commands rather than this script. Dead code as committed.
- DOC DRIFT: the script targets `docs/patterns` while root `CLAUDE.md`,
  `.cursor/rules/02-pattern-discovery.mdc`, and the pattern-discovery skill all name
  `patterns_library/` as the library. Both directories exist on disk, so the hook reports the wrong
  one without erroring.
- DOC DRIFT: the banner's "11 agents available in .claude/agents/" is correct, but it also asserts
  "Tool restrictions: Configured" and a per-phase model selection as facts it never checks —
  `.claude/settings.template.json` ships an empty permissions block.

## Citations

- [CLAUDE.md](../../../../CLAUDE.md) — names `patterns_library/` as the pattern library.
- [.claude README](../../../../.claude/README.md) — the harness hook inventory.
