# Getting Started

End-to-end guide for adopting the SAFe Agentic Workflow harness — from first
clone to first PR to running autonomous agent teams.

---

## Table of Contents

1. [Choose Your Adoption Path](#1-choose-your-adoption-path)
2. [Configure the Harness](#2-configure-the-harness)
3. [Verify Your Setup](#3-verify-your-setup)
4. [Your First Agent Session](#4-your-first-agent-session)
5. [Your First PR](#5-your-first-pr)
6. [Enable Agent Teams (Optional)](#6-enable-agent-teams-optional)
7. [Set Up Dark Factory (Optional)](#7-set-up-dark-factory-optional)
8. [Next Steps](#8-next-steps)

---

## 1. Choose Your Adoption Path

### Path A: New Repository (Recommended)

Use the GitHub template to create a fresh repo:

1. Click **"Use this template"** on the [template repository](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}})
2. Name your new repository
3. Clone it locally:

```bash
git clone git@github.com:YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO
```

### Path B: Existing Repository

Pull the harness into a repo that already has code. See the
[Workspace Adoption Guide](WORKSPACE-ADOPTION-GUIDE.md) for detailed
instructions, but the quick version:

```bash
# Add template as a remote
git remote add harness https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}.git
git fetch harness

# Cherry-pick the harness directories into your repo
git checkout harness/{{MAIN_BRANCH}} -- \
  .claude/ .gemini/ CLAUDE.md AGENTS.md CONTRIBUTING.md \
  patterns_library/ specs/ specs_templates/ scripts/ \
  docs/ dark-factory/

# Commit the harness addition
git add -A && git commit -m "feat: adopt SAFe agentic workflow harness"
```

---

## 2. Configure the Harness

### Option A: Setup Wizard (Recommended)

```bash
bash scripts/setup-template.sh
```

The wizard prompts for your project values and replaces all `{{PLACEHOLDER}}`
tokens automatically.

### Option B: Manual Configuration

Replace placeholders across the repository. The essential ones:

| Placeholder | What It Is | Example |
|-------------|-----------|---------|
| `{{PROJECT_NAME}}` | Your project name | `my-saas-app` |
| `{{GITHUB_ORG}}` | GitHub org or username | `acme-corp` |
| `{{TICKET_PREFIX}}` | Linear/issue prefix | `ACM` |
| `{{MAIN_BRANCH}}` | Main branch name | `main` |
| `{{AUTHOR_NAME}}` | Your name | `Jane Smith` |
| `{{AUTHOR_HANDLE}}` | GitHub handle | `janesmith` |

See [TEMPLATE_SETUP.md](../../TEMPLATE_SETUP.md) for the full placeholder
reference (50+ tokens).

### Post-Configuration

After running the wizard or replacing placeholders:

1. **Review `CLAUDE.md`** — Update the technology stack section for your project
2. **Review `.claude/team-config.json`** — Adjust agent roles if needed
3. **Review optional features** — Remove integrations you don't need:
   [OPTIONAL-FEATURES.md](OPTIONAL-FEATURES.md)
4. **Set up `.env`** — Copy `.env.template` to `.env` and add your API keys

---

## 3. Verify Your Setup

Run the verification checklist:

```bash
# All placeholders replaced?
grep -r '{{' CLAUDE.md AGENTS.md CONTRIBUTING.md .claude/team-config.json \
  | grep -v 'OPTIONAL-FEATURES' | head -5
# Expect: no output (all replaced)

# Skills installed?
ls .claude/skills/ | wc -l
# Expect: 19 directories

# Commands installed?
ls .claude/commands/ | wc -l
# Expect: 24+ files

# Agent profiles installed?
ls .claude/agents/ | wc -l
# Expect: 12 files

# Gemini harness present?
ls .gemini/settings.json .gemini/GEMINI.md
# Expect: both files exist
```

---

## 4. Your First Agent Session

### Start Work on a Ticket

```bash
# Start Claude Code in your project
claude

# Use the start-work skill
/start-work {{TICKET_PREFIX}}-1
```

The TDM agent will:
1. Read the Linear ticket
2. Identify which agents are needed
3. Guide you through the SAFe workflow

### Quick Agent Invocation

You can invoke any of the 11 agents directly:

```
You are the BSA. Decompose this feature into stories with acceptance criteria:
[paste your feature description]
```

Or use the agent config files:

```
Read .claude/agents/be-developer.md and act as the Backend Developer.
Implement the API endpoint for {{TICKET_PREFIX}}-1.
```

### Key Workflow Commands

| Command | Purpose |
|---------|---------|
| `/start-work TICKET` | Begin work on a ticket |
| `/check-workflow` | Check current workflow state |
| `/pre-pr` | Run all validations before PR |
| `/end-work` | Complete work session |

---

## 5. Your First PR

### Create a Feature Branch

```bash
git checkout -b {{TICKET_PREFIX}}-1-my-feature-description
```

Branch naming follows: `{TICKET_PREFIX}-{number}-{description}`

### Commit Your Work

```bash
git add src/path/to/changes.ts
git commit -m "feat(scope): add feature description [{{TICKET_PREFIX}}-1]"
```

Commit format: `type(scope): description [TICKET-XXX]`

### Validate Before PR

```bash
# Run the pre-PR skill (runs lint, type-check, tests, build)
/pre-pr
```

### Create the PR

```bash
git push -u origin {{TICKET_PREFIX}}-1-my-feature-description
gh pr create \
  --title "feat(scope): add feature description [{{TICKET_PREFIX}}-1]" \
  --body "## Summary
- What changed and why

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass"
```

### Review Pipeline

Your PR goes through the three-stage review:
1. **System Architect** — Pattern and architectural compliance
2. **ARCHitect-in-CLI** — Comprehensive architecture review
3. **HITL** — Final human merge authority

---

## 6. Enable Agent Teams (Optional)

For parallel multi-agent work on larger features:

1. **Set the flag** in `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

2. **Start a team session**:

```
Create an agent team for {{TICKET_PREFIX}}-5. I need:
- TDM as team lead
- BE Developer for the API
- FE Developer for the UI
- QAS for validation
```

See [AGENT-TEAMS-GUIDE.md](../onboarding/AGENT-TEAMS-GUIDE.md) for details.

---

## 7. Set Up Dark Factory (Optional)

For persistent autonomous agent teams on a remote server:

### Prerequisites

- A remote Linux machine (any always-on server with SSH access)
- SSH access configured
- tmux, Claude Code, git, and GitHub CLI installed on the remote

### Quick Setup

```bash
# On the remote machine
cd /path/to/{{PROJECT_NAME}}

# One-time setup (validates merge queue enforcement)
./dark-factory/scripts/factory-setup.sh

# Edit configuration
nano ~/.dark-factory/env

# Launch a feature team
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-10

# Monitor from your local machine (via Cursor SSH)
./dark-factory/scripts/factory-status.sh
```

See [dark-factory/README.md](../../dark-factory/README.md) for the full guide.

---

## 8. Next Steps

### Essential Reading

| Doc | When to Read |
|-----|-------------|
| [CONTRIBUTING.md](../../CONTRIBUTING.md) | Before your first commit |
| [AGENTS.md](../../AGENTS.md) | To understand all 11 agent roles |
| [CLAUDE.md](../../CLAUDE.md) | Your project's AI assistant context |
| [Day 1 Checklist](../onboarding/DAY-1-CHECKLIST.md) | Structured first-day walkthrough |

### Deep Dives

| Doc | Topic |
|-----|-------|
| [Skill Authoring Guide](SKILL_AUTHORING_GUIDE.md) | Creating custom skills |
| [Gemini CLI Guide](GEMINI_CLI_AUTHORING_GUIDE.md) | Using Gemini CLI harness |
| [Round Table Philosophy](ROUND-TABLE-PHILOSOPHY.md) | Collaboration principles |
| [Agent Teams Guide](../onboarding/AGENT-TEAMS-GUIDE.md) | Multi-agent orchestration |
| [Dark Factory Guide](../../dark-factory/docs/DARK-FACTORY-GUIDE.md) | Persistent agent sessions |
| [Harness Sync Guide](../HARNESS_SYNC_GUIDE.md) | Keeping harness up to date |
| [Optional Features](OPTIONAL-FEATURES.md) | Removing unneeded integrations |

### Workflow Reference

```
Epic → Feature → Story → Implementation → QAS → PR → Review → Merge
  BSA    BSA      BSA     BE/FE/Data      QAS   RTE   ARCH    HITL
```

Every piece of work follows this SAFe flow. The agents enforce it.
