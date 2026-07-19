---
type: script
title: "install-prompts.sh"
description: "Installs the agent prompt files for Claude Code or Augment Code, either per-user or in-project for team sharing."
tags: [operations, agents, onboarding]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/install-prompts.sh"
sources:
  - "scripts/install-prompts.sh"
verified_against: "fd0fc6a"
---

# install-prompts.sh

Copies agent prompt files out of the repo's `.claude/` tree into a destination agents directory,
**overwriting existing files with no diff and no backup step**. 285 lines of bash under `set -e`.

## Overview

Agent prompts have to live where the coding tool looks for them, and different tools look in
different places. The script covers three destinations from one source of truth, selected by flag
with `MODE` defaulting to `user`: `install_claude_user` copies out to the user-level agents dir,
`install_claude_team` uses the in-project `.claude/agents` as-is (a no-op copy — team sharing is
just the checked-in tree), and `install_augment` sources `agent_providers/augment`. `REPO_ROOT` is
derived from `BASH_SOURCE`, so it is safe to call from any cwd. Its own header still carries
unresolved `{{PROJECT_SHORT}}` placeholders, which makes it a substitution target of
[setup-template.sh](setup-template.md) — `.sh` is in that script's find pattern list.

## Inputs & Outputs

- **In** no argument — default per-user Claude Code install.
- **In** `--team` — installs into the project so agents are shared with the repo.
- **In** `--augment` — installs the Augment Code prompt set instead.
- **In** `--help` — prints usage.
- **Out** agent files — `cp -v "$CLAUDE_AGENTS_DIR"/*.md` or `cp -v "$AUGMENT_AGENTS_DIR"/*.md` into
  the destination agents directory.
- **Out** hooks — `.claude/hooks/*.sh` copied into a user hooks directory, suppressed with
  `2>/dev/null || true` so a missing hooks directory is silent and non-fatal.
- **Note** the header and the success message both claim 11 agents, but the copy is an unchecked
  `*.md` glob. `.claude/agents/` holds 12 `.md` files: 11 agent prompts plus a `README.md`, which
  the glob installs alongside them. The count is a comment, not an assertion.
- **Caveat** no dry-run, no uninstall, and no idempotency check beyond `cp` overwrite. `cp -v` makes
  the transcript the only record of what was installed.

## Invoked By

- Manual, run once during developer onboarding.
- **UNKNOWN**: no automated caller was found; whether any command or workflow invokes it is
  unresolved.

## Citations

- [Agent Setup Guide](../../knowledge/onboarding/agent-setup-guide.md) — where prompt installation
  sits in onboarding.
- [Agent Providers](../../providers/agent-providers.md) — the provider surfaces being installed.
