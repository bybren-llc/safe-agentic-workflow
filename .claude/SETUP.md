# Claude Code Harness Setup Guide

## Quick Start (15 Minutes)

This guide helps you install the SAFe Claude Code harness in a new project.

---

## Prerequisites

- Claude Code CLI installed (`claude --version`)
- Git repository initialized
- Node.js project with `package.json`

---

## Step 1: Copy the Harness Structure

```bash
# From the source repository root, copy to your project:

# Copy slash commands (24 commands)
cp -r .claude/commands/ /path/to/your-project/.claude/commands/

# Copy skills (18 model-invoked skills)
cp -r .claude/skills/ /path/to/your-project/.claude/skills/

# Copy agent profiles (11 SAFe agents)
cp -r .claude/agents/ /path/to/your-project/.claude/agents/
```

---

## Step 2: Configure Hooks

Create or update your project's `.claude/settings.local.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "git branch --show-current 2>/dev/null | grep -q '^{{TICKET_PREFIX}}-[0-9]' || echo '⚠️ REMINDER: Branch should follow {{TICKET_PREFIX}}-{number}-{description} format.'",
            "description": "Remind about branch naming convention"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash.*git\\s+commit",
        "hooks": [
          {
            "type": "command",
            "command": "echo '📝 REMINDER: Commit message must follow SAFe format: type(scope): description [{{TICKET_PREFIX}}-XXX]'",
            "description": "Remind about commit message format"
          }
        ]
      },
      {
        "matcher": "Bash.*git\\s+push",
        "hooks": [
          {
            "type": "command",
            "command": "BRANCH=$(git branch --show-current); if [ \"$BRANCH\" = 'dev' ] || [ \"$BRANCH\" = 'master' ]; then echo '❌ BLOCKER: Cannot push directly to '$BRANCH'. Create a feature branch first.'; exit 1; fi",
            "description": "Block direct push to dev or master"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "echo '🚀 Session Started\\n📖 Key commands: /start-work, /pre-pr, /end-work\\n📚 Full list: see .claude/README.md'",
            "description": "Session start reminder"
          }
        ]
      }
    ]
  }
}
```

**Note**: Customize the ticket prefix (`{{TICKET_PREFIX}}-`) and branch names (`dev`/`master`) for your project.

---

## Step 3: Customize for Your Project

### Replace Ticket Prefix

Search and replace in all copied files:

| Find             | Replace With                       |
| ---------------- | ---------------------------------- |
| `{{TICKET_PREFIX}}-`           | Your ticket prefix (e.g., `PROJ-`) |
| `{{PROJECT_NAME}}` | Your project name                  |
| `dev` branch     | Your main development branch       |

### Update Linear Workspace

If using Linear MCP tools, update workspace references in:

- `.claude/skills/linear-sop/SKILL.md`
- `.claude/commands/start-work.md`
- `.claude/commands/sync-linear.md`

---

## Step 4: Validate Installation

### Check Skills Load

Ask Claude:

```
What skills are available?
```

Expected: List of 18 skills with descriptions.

**Known Issue (v2.0.73)**: The `/skills` command has a display bug. Skills work correctly but won't appear in `/skills` output. Ask Claude directly instead.

### Check Commands Work

Run:

```
/start-work TEST-123
```

Expected: Claude should guide you through starting work on a ticket.

### Check Hooks Fire

Create a test commit:

```bash
git checkout -b TEST-123-test-branch
echo "test" > test.txt
git add test.txt
git commit -m "test: validate hooks [TEST-123]"
```

Expected: See reminder about SAFe commit format before commit executes.

---

## Step 5: Copy Documentation (Recommended)

For full harness understanding, copy these docs:

```bash
# Core documentation
cp AGENTS.md /path/to/your-project/
cp CONTRIBUTING.md /path/to/your-project/

# Whitepapers
cp docs/whitepapers/CLAUDE-CODE-HARNESS-*.md /path/to/your-project/docs/whitepapers/

# SOPs
cp -r docs/sop/ /path/to/your-project/docs/sop/
cp -r patterns_library/ /path/to/your-project/patterns_library/
```

---

## Directory Structure

After setup, your `.claude/` directory should look like:

```text
.claude/
├── commands/           # 24 slash commands
│   ├── start-work.md
│   ├── pre-pr.md
│   ├── end-work.md
│   └── ... (21 more)
├── skills/             # 18 model-invoked skills
│   ├── safe-workflow/SKILL.md
│   ├── pattern-discovery/SKILL.md
│   ├── rls-patterns/SKILL.md
│   └── ... (14 more)
├── agents/             # 11 SAFe agent profiles
│   ├── bsa.md
│   ├── tdm.md
│   ├── rte.md
│   └── ... (8 more)
├── hooks/              # Hook scripts (if using)
│   ├── post-commit-linear-update.sh
│   └── post-push-docker-check.sh
├── settings.local.json # Hooks configuration
├── README.md           # Harness overview
├── SETUP.md            # This file
└── TROUBLESHOOTING.md  # Common issues
```

---

## Next Steps

1. **Read AGENTS.md** - Understand when to use which agent
2. **Read the Whitepaper** - Understand the three-layer architecture
3. **Try /start-work** - Begin your first ticket with the harness
4. **Check TROUBLESHOOTING.md** - If anything doesn't work

---

## Quick Command Reference

| Command                           | Purpose                       |
| --------------------------------- | ----------------------------- |
| `/start-work {{TICKET_PREFIX}}-123` | Begin work on a ticket        |
| `/check-workflow`                 | Check current workflow status |
| `/pre-pr`                         | Run validation before PR      |
| `/end-work`                       | Complete work session         |
| `/local-sync`                     | Sync after git pull           |
| `/remote-status`                  | Check remote Docker status    |

---

## Support

- **Issues**: Check `TROUBLESHOOTING.md` first
- **Documentation**: See `docs/whitepapers/` for architecture details
- **Workflow**: See `CONTRIBUTING.md` for complete workflow guide

---

**Version**: 1.0
**Last Updated**: 2025-12-20
