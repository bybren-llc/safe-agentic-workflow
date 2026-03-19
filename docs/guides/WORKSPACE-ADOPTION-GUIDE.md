# Workspace Adoption Guide

How to bring the SAFe Agentic Workflow harness into an existing repository or
multi-repo workspace. Covers monorepo adoption, multi-repo sync, and remote
dark factory configuration.

---

## Table of Contents

1. [Overview](#overview)
2. [Single Repo Adoption](#single-repo-adoption)
3. [Multi-Repo Strategy](#multi-repo-strategy)
4. [Dark Factory on Remote Server](#dark-factory-on-remote-server)
5. [Keeping the Harness Updated](#keeping-the-harness-updated)
6. [Customization After Adoption](#customization-after-adoption)

---

## Overview

The harness is designed as a GitHub template, but it works equally well when
pulled into an existing repository. The key directories are:

```
.claude/          # Claude Code harness (agents, skills, commands, hooks) — primary provider
.gemini/          # Gemini CLI harness (commands, skills, settings) — secondary provider
.codex/           # Codex CLI harness (config.toml, reads AGENTS.md) — TOML config, MCP native
.cursor/          # Cursor IDE harness (.mdc rules with glob-based activation, background agents)
.agents/          # Shared agent skills (discovered by Codex CLI and other agents)
CLAUDE.md         # AI assistant context (read by Claude Code on every session)
AGENTS.md         # Agent role reference (also read by Codex CLI as system instructions)
CONTRIBUTING.md   # Git workflow and commit standards
patterns_library/ # Reusable code patterns
dark-factory/     # Persistent agent teams via tmux (optional)
scripts/          # Setup and utility scripts
docs/             # Documentation
```

**What you keep vs. customize:**
- `.claude/`, `.gemini/`, `.codex/`, `.cursor/`, `.agents/`, `patterns_library/` — keep as-is, customize placeholders
- `CLAUDE.md` — customize the technology stack section for your project
- `CONTRIBUTING.md` — customize branch/commit conventions if they differ
- `dark-factory/` — optional, include only if using remote agent teams

---

## Single Repo Adoption

### Step 1: Add the Template as a Remote

```bash
cd /path/to/your-project
git remote add harness https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}.git
git fetch harness
```

### Step 2: Pull Harness Files

```bash
# Checkout harness directories into your repo
git checkout harness/{{MAIN_BRANCH}} -- \
  .claude/ \
  .gemini/ \
  .codex/ \
  .cursor/ \
  .agents/ \
  CLAUDE.md \
  AGENTS.md \
  CONTRIBUTING.md \
  patterns_library/ \
  specs/ \
  specs_templates/ \
  scripts/ \
  docs/ \
  dark-factory/ \
  .geminiignore

# Commit the initial adoption
git add -A
git commit -m "feat: adopt SAFe agentic workflow harness v2.7.0"
```

### Step 3: Run the Setup Wizard

```bash
bash scripts/setup-template.sh
```

This replaces all `{{PLACEHOLDER}}` tokens with your project values.

### Step 4: Customize for Your Project

1. **`CLAUDE.md`** — Update the technology stack section:
   - Frontend framework, backend framework, database, ORM, auth provider
   - Dev commands (lint, build, test, deploy)
   - Database migration workflow

2. **`.claude/team-config.json`** — Adjust if needed:
   - `workflow.ticket_prefix` — your Linear prefix
   - `workflow.main_branch` — your main branch name
   - `quality_gates` — your actual CI commands

3. **Remove unused integrations** — See [OPTIONAL-FEATURES.md](OPTIONAL-FEATURES.md)

### Step 5: Verify

```bash
# Confirm no unreplaced placeholders in key files
grep -c '{{' CLAUDE.md AGENTS.md CONTRIBUTING.md .claude/team-config.json
# Expect: 0 for each file

# Confirm harness structure
ls .claude/agents/ | wc -l  # 11 agents
ls .claude/skills/ | wc -l  # 18 skills
ls .claude/commands/ | wc -l  # 23+ commands
```

---

## Multi-Repo Strategy

When your organization has multiple repositories (e.g., a workspace and a
packages repo), each can adopt the harness independently.

### Architecture

```
{{GITHUB_ORG}}/
├── {{PROJECT_NAME}}/             # Main application repo (PRIMARY)
│   ├── .claude/                  # Full harness
│   ├── dark-factory/             # Agent teams run here
│   └── ...
│
└── {{PROJECT_NAME}}-packages/    # Shared packages repo (SECONDARY)
    ├── .claude/                  # Synced harness (subset or full)
    └── ...
```

### Primary Repo Setup

Your main workspace gets the full harness:

```bash
cd {{PROJECT_NAME}}
# Full adoption as described in "Single Repo Adoption" above
```

### Secondary Repo Setup

Other repos can adopt the same harness:

**Option A: Independent adoption** (simpler)

```bash
cd {{PROJECT_NAME}}-packages
git remote add harness https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}.git
git fetch harness
git checkout harness/{{MAIN_BRANCH}} -- .claude/ .gemini/ .codex/ .cursor/ .agents/ CLAUDE.md AGENTS.md
# Run setup wizard with this repo's values
bash scripts/setup-template.sh
```

**Option B: Sync from primary** (keeps repos aligned)

```bash
cd {{PROJECT_NAME}}-packages
# Copy harness from workspace
cp -r ../{{PROJECT_NAME}}/.claude/ .claude/
cp -r ../{{PROJECT_NAME}}/.gemini/ .gemini/
cp -r ../{{PROJECT_NAME}}/.codex/ .codex/
cp -r ../{{PROJECT_NAME}}/.cursor/ .cursor/
cp -r ../{{PROJECT_NAME}}/.agents/ .agents/
cp ../{{PROJECT_NAME}}/CLAUDE.md .
cp ../{{PROJECT_NAME}}/AGENTS.md .

# Adjust project-specific values
sed -i "s/{{PROJECT_NAME}}/{{PROJECT_NAME}}-packages/g" CLAUDE.md
```

### Cross-Repo Agent Work

Agents in the dark factory can work across repos by:

1. **Git worktrees** — Each agent pane gets its own worktree, and different
   agents can point to different repos
2. **Multiple sessions** — Run separate dark factory sessions for each repo:
   ```bash
   # Session 1: workspace
   cd {{PROJECT_NAME}}
   ./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-10

   # Session 2: packages (in another terminal)
   cd {{PROJECT_NAME}}-packages
   ./dark-factory/scripts/factory-start.sh story {{TICKET_PREFIX}}-11
   ```
3. **Shared Linear** — Both repos use the same Linear workspace and ticket
   prefix, so agents reference the same tickets

### Keeping Repos in Sync

Use the harness sync script to pull upstream updates into both repos:

```bash
# In each repo
./scripts/sync-claude-harness.sh sync --latest
```

Or sync manually from your primary repo:

```bash
cd {{PROJECT_NAME}}-packages
cp -r ../{{PROJECT_NAME}}/.claude/ .claude/
cp -r ../{{PROJECT_NAME}}/.gemini/ .gemini/
bash scripts/setup-template.sh
```

---

## Dark Factory on Remote Server

### Server Setup

On your remote dev server (any always-on Linux machine with SSH access):

```bash
# 1. Clone your primary workspace
git clone git@github.com:{{GITHUB_ORG}}/{{PROJECT_NAME}}.git
cd {{PROJECT_NAME}}

# 2. Run dark factory setup
./dark-factory/scripts/factory-setup.sh

# 3. Configure environment
nano ~/.dark-factory/env
```

### Environment Configuration

Edit `~/.dark-factory/env` with your actual values:

```bash
FACTORY_PROJECT_DIR="/home/{{REMOTE_USER}}/{{PROJECT_NAME}}"
FACTORY_MAIN_BRANCH="{{MAIN_BRANCH}}"
FACTORY_TICKET_PREFIX="{{TICKET_PREFIX}}"
FACTORY_LOG_DIR="$HOME/.dark-factory/logs"
FACTORY_WORKTREE_DIR="$HOME/.dark-factory/worktrees"
FACTORY_USE_WORKTREES=true
FACTORY_AUTO_PERMISSIONS=true
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### Running Agent Teams

```bash
# Start a feature team for a ticket
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-10

# Monitor from your local machine via SSH
ssh {{REMOTE_HOST}} './dark-factory/scripts/factory-status.sh'

# Or connect via Cursor IDE Remote-SSH
# See: dark-factory/docs/CURSOR-SSH-GUIDE.md
```

### Working on Multiple Repos from the Factory

To have agents work on a secondary repo from the same server:

```bash
# Clone the packages repo alongside workspace
cd /home/{{REMOTE_USER}}
git clone git@github.com:{{GITHUB_ORG}}/{{PROJECT_NAME}}-packages.git

# Start a separate factory session pointing to packages
cd {{PROJECT_NAME}}-packages
# Temporarily override FACTORY_PROJECT_DIR
FACTORY_PROJECT_DIR="$(pwd)" ./dark-factory/scripts/factory-start.sh story {{TICKET_PREFIX}}-11
```

---

## Keeping the Harness Updated

### Understanding What Gets Updated

The harness has two update mechanisms:

1. **`sync-claude-harness.sh`** — Multi-domain sync (v2.10.0+). Syncs any
   directories listed in your manifest's `sync_scope` (e.g., `.claude/`,
   `.gemini/`, `.codex/`, `.cursor/`, `.agents/`, `dark-factory/`). A manifest
   is required.
2. **Manual git checkout** — Updates everything else (docs, scripts,
   patterns_library). Required for full upgrades that include release-tier files.

### Method 1: Sync Script (multi-domain)

The sync script pulls upstream updates for all declared scope domains while
preserving your project-specific customizations via the manifest:

```bash
# Initialize sync config (first time only)
./scripts/sync-claude-harness.sh init
./scripts/sync-claude-harness.sh manifest init --yes

# Check what version you're on
./scripts/sync-claude-harness.sh version

# Check for available updates
./scripts/sync-claude-harness.sh status

# Preview changes before applying
./scripts/sync-claude-harness.sh sync --dry-run

# Apply a specific release (syncs all domains in sync_scope)
./scripts/sync-claude-harness.sh sync --version v2.10.0

# Or sync specific domains only
./scripts/sync-claude-harness.sh sync --version v2.10.0 --scope .claude,.gemini

# Or apply the latest release
./scripts/sync-claude-harness.sh sync --latest
```

**Protect your customizations**: Use the `protected` section in your
`.harness-manifest.yml` to list files that should never be overwritten.

**If something breaks**: Roll back to the pre-sync backup:

```bash
./scripts/sync-claude-harness.sh rollback
```

### Method 2: Full Harness Update (all directories)

For major version upgrades that include new docs, scripts, dark-factory
changes, or Gemini harness updates:

```bash
# 1. Ensure you have the harness remote
git remote get-url harness || \
  git remote add harness https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}.git

# 2. Fetch the latest
git fetch harness

# 3. Checkout updated directories (review the list — skip any you've
#    heavily customized and want to merge manually)
git checkout harness/{{MAIN_BRANCH}} -- \
  .claude/ \
  .gemini/ \
  .codex/ \
  .cursor/ \
  .agents/ \
  dark-factory/ \
  patterns_library/ \
  scripts/sync-claude-harness.sh \
  docs/

# 4. Re-run setup wizard to re-apply your placeholder values
bash scripts/setup-template.sh

# 5. Review what changed
git diff --stat

# 6. Commit the upgrade
git add -A
git commit -m "chore: upgrade harness to vX.Y.Z"
```

**Important**: Do NOT blindly checkout files you have customized:
- `CLAUDE.md` — Your tech stack section is project-specific
- `.claude/team-config.json` — Your ticket prefix, main branch, quality gates
- `CONTRIBUTING.md` — Your branch/commit conventions if modified

For these files, manually diff and merge:

```bash
# Compare your version with upstream
git diff HEAD harness/{{MAIN_BRANCH}} -- CLAUDE.md
git diff HEAD harness/{{MAIN_BRANCH}} -- .claude/team-config.json
```

### What to Update vs. What to Keep

| Files | Update Strategy |
|-------|----------------|
| `.claude/skills/`, `.claude/commands/` | Always update from upstream |
| `.claude/agents/` | Update, then review for project-specific customizations |
| `.claude/team-config.json` | Merge carefully — your custom values matter |
| `.claude/hooks/` | Update, review for project-specific hook logic |
| `CLAUDE.md` | Keep your tech stack section, merge structural changes |
| `CONTRIBUTING.md` | Keep your conventions, merge new sections |
| `.gemini/` | Always update from upstream |
| `.codex/` | Always update from upstream |
| `.cursor/rules/` | Update, review for project-specific rule customizations |
| `.agents/skills/` | Always update from upstream |
| `dark-factory/scripts/` | Always update from upstream |
| `dark-factory/templates/` | Update, review `env.template` for new variables |
| `dark-factory/docs/` | Always update from upstream |
| `patterns_library/` | Update upstream patterns, keep project-specific additions |
| `scripts/` | Update, review for new scripts |
| `docs/` | Always update from upstream |

### Upgrading Across Multiple Repos

If you have multiple repos using the harness:

```bash
# Update primary repo first
cd {{PROJECT_NAME}}
git fetch harness && git checkout harness/{{MAIN_BRANCH}} -- .claude/ .gemini/ .codex/ .cursor/ .agents/
bash scripts/setup-template.sh
git add -A && git commit -m "chore: upgrade harness to vX.Y.Z"

# Then sync secondary repos from primary
cd ../{{PROJECT_NAME}}-packages
cp -r ../{{PROJECT_NAME}}/.claude/ .claude/
cp -r ../{{PROJECT_NAME}}/.gemini/ .gemini/
cp -r ../{{PROJECT_NAME}}/.codex/ .codex/
cp -r ../{{PROJECT_NAME}}/.cursor/ .cursor/
cp -r ../{{PROJECT_NAME}}/.agents/ .agents/
# Adjust project-specific values
bash scripts/setup-template.sh
git add -A && git commit -m "chore: upgrade harness to vX.Y.Z"
```

See [HARNESS_SYNC_GUIDE.md](../HARNESS_SYNC_GUIDE.md) for full details on the
sync script's configuration, exclusion patterns, and conflict resolution.

---

## Customization After Adoption

### Adding Project-Specific Patterns

```bash
# Add patterns to the library
echo "# My Custom Pattern" > patterns_library/api/custom-endpoint.md
```

Agents will discover and use them via the pattern discovery protocol.

### Adding Custom Skills

Create a new skill directory:

```
.claude/skills/my-custom-skill/
├── README.md    # What this skill does
└── SKILL.md     # Skill implementation (with frontmatter)
```

See [SKILL_AUTHORING_GUIDE.md](SKILL_AUTHORING_GUIDE.md).

### Adding Custom Commands

```
.claude/commands/my-command.md
```

Commands are markdown files that Claude Code discovers automatically.

### Modifying Agent Profiles

Edit files in `.claude/agents/` to adjust agent behavior for your project.
Keep the SAFe role structure but customize the domain knowledge.
