# Claude Code Configuration

This directory contains the {{PROJECT_SHORT}} Claude Code harness: hooks, slash commands, and (coming soon) skills for workflow automation.

## Harness Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│                      {{PROJECT_SHORT}} Claude Code Harness                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  HOOKS (Guardrails)              SLASH COMMANDS (User-Invoked)        │
│  ├─ Pre-commit reminders         ├─ /start-work                       │
│  ├─ Push blocker (uncommitted)   ├─ /remote-deploy                    │
│  └─ Auto-format on edit          └─ /pre-pr                           │
│                                                                       │
│  SKILLS (Model-Invoked) ✅ Available                                  │
│  ├─ safe-workflow      (SAFe commit/PR patterns)                      │
│  ├─ pattern-discovery  (search docs/patterns first)                   │
│  ├─ rls-patterns       (database security helpers)                    │
│  └─ frontend-patterns  (Clerk, shadcn, Next.js App Router)            │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

**Key distinction:**

- **Hooks**: Automatic guardrails (reminders and critical blockers)
- **Slash Commands**: Explicit user-invoked workflows (`/start-work`, `/pre-pr`)
- **Skills**: Model-invoked expertise packs (Claude auto-loads relevant context)

## Team Principles (SAFe + Round Table)

This harness is designed to help every teammate (human + AI) uphold:

- **SAFe Pillars**: Alignment, Built-in Quality, Program Execution, Transparency
- **{{PROJECT_SHORT}} Round Table**: humans + AI agents are peers; Stop-the-Line authority is encouraged

Canonical reference: `.cursor/rules/06-team-culture.mdc`

## Role Execution Modes ({{TICKET_PREFIX}}-499)

### Collapsed vs Separated Roles

The vNext workflow defines role separation (Implementation → QAS → RTE → HITL), but roles can be **collapsed** for efficiency when appropriate.

**Key principle**: Subagents are for efficiency _and_ independence; only coordination roles may be collapsed.

### Role Classification

| Role                      | Type                    | Collapsible?    | Notes                                |
| ------------------------- | ----------------------- | --------------- | ------------------------------------ |
| Implementation (BE/FE/DE) | Execution               | N/A (base role) | -                                    |
| RTE                       | Coordination/Automation | ✅ Yes          | PR creation, CI shepherding          |
| QAS                       | Independence Gate       | ❌ No\*         | \*See Self-QA exception below        |
| SecEng                    | Independence Gate       | ❌ No\*         | Security audit requires independence |
| HITL                      | Final Authority         | ❌ Never        | {{AUTHOR_NAME}} merges                         |

### Collapsed Roles (In-Flow with HITL)

The main Claude instance can collapse **coordination roles** (RTE) when:

- Working in-flow with HITL (sequential, no parallelism benefit)
- PR creation is the natural next step after implementation
- Already have full context from implementation

**Hat Convention** for traceability:

- "Operating as **Implementation** → exit state `Ready for QAS`"
- "Operating as **RTE (collapsed)** → PR creation + CI shepherding → exit state `Ready for HITL Review`"

### Independence Roles (Never Silently Collapsed)

**QAS** and **SecEng** are independence gates, not efficiency roles:

- **Default = spawn subagent** for independent verification
- If collapsed: Must be explicitly labeled **"Self-QA (non-independent)"**
- Self-QA only allowed when:
  - Change is docs-only / harness-only / low-risk, **AND**
  - Exception recorded in Linear (reason + evidence)
- Still requires next independent gate (HITL) before merge

### Invariants (Always Apply)

Regardless of role collapsing, these invariants are **never relaxed**:

- ✅ Stop-the-Line gate (AC/DoD must exist before implementation)
- ✅ Validation loop (tests pass, lint clean)
- ✅ Evidence in Linear (system of record)
- ✅ HITL merge authority

See: `docs/workflow/ARCHITECT_IN_CLI_ROLE.md` for orchestrator authority.

## Slash Commands

### Workflow Commands

| Command           | Purpose                               | Usage                              |
| ----------------- | ------------------------------------- | ---------------------------------- |
| `/start-work`     | Begin new ticket with proper workflow | `/start-work 347` or `/start-work` |
| `/pre-pr`         | Run complete validation before PR     | `/pre-pr`                          |
| `/end-work`       | Complete work session cleanly         | `/end-work`                        |
| `/check-workflow` | Quick status check of workflow        | `/check-workflow`                  |
| `/update-docs`    | Identify and update documentation     | `/update-docs`                     |
| `/retro`          | Conduct retrospective analysis        | `/retro`                           |
| `/sync-linear`    | Sync current work with Linear ticket  | `/sync-linear`                     |

### Local Operations

| Command         | Purpose                             | Usage           |
| --------------- | ----------------------------------- | --------------- |
| `/local-sync`   | Full sync after git pull            | `/local-sync`   |
| `/local-deploy` | Deploy to local Docker environment  | `/local-deploy` |
| `/quick-fix`    | Fast-track workflow for small fixes | `/quick-fix`    |

### Remote Operations (Pop OS)

These are the **canonical commands** for Pop OS machine operations.

| Command            | Purpose                              | Usage              |
| ------------------ | ------------------------------------ | ------------------ |
| `/remote-status`   | Check if Docker environment outdated | `/remote-status`   |
| `/remote-deploy`   | Deploy latest image to staging       | `/remote-deploy`   |
| `/remote-health`   | Full health dashboard                | `/remote-health`   |
| `/remote-logs`     | View container logs                  | `/remote-logs`     |
| `/remote-rollback` | Rollback to previous image           | `/remote-rollback` |

### Deprecated Aliases

These commands are thin wrappers pointing to canonical `/remote-*` commands. **Use the canonical versions.**

| Command                | Alias For          | Note                   |
| ---------------------- | ------------------ | ---------------------- |
| `/check-docker-status` | `/remote-status`   | Deprecated per {{TICKET_PREFIX}}-445 |
| `/deploy-dev`          | `/remote-deploy`   | Deprecated per {{TICKET_PREFIX}}-445 |
| `/dev-health`          | `/remote-health`   | Deprecated per {{TICKET_PREFIX}}-445 |
| `/dev-logs`            | `/remote-logs`     | Deprecated per {{TICKET_PREFIX}}-445 |
| `/rollback-dev`        | `/remote-rollback` | Deprecated per {{TICKET_PREFIX}}-445 |

### Other Commands

| Command           | Purpose                            | Usage                 |
| ----------------- | ---------------------------------- | --------------------- |
| `/test-pr-docker` | Test PR Docker workflow            | `/test-pr-docker 225` |
| `/audit-deps`     | Run comprehensive dependency audit | `/audit-deps`         |
| `/search-pattern` | Search for code patterns           | `/search-pattern`     |

## Dual-Mode Deployment ({{TICKET_PREFIX}}-445 Terminology Contract)

Pop OS supports two deployment modes. **Use canonical terminology:**

| Mode        | Container Name     | Port | Use Case                     |
| ----------- | ------------------ | ---- | ---------------------------- |
| **Dev**     | `{{DEV_CONTAINER}}`     | 3000 | Daily development (STANDARD) |
| **Staging** | `{{STAGING_CONTAINER}}` | 3001 | Release validation/UAT       |

**Important:**

- "dev branch" = Git branch (source code)
- "dev-mode container" = Docker deployment on Pop OS (port 3000)
- "staging-mode container" = Docker deployment on Pop OS (port 3001)

Both containers run images built from the `dev` branch. The difference is configuration (ports, volume mounts).

See: `docs/agent-outputs/workflow-analysis/HARNESS_AND_SKILLS_AUDIT_2025-12-18.md`

## Typical Workflow

```bash
# 1. Start new ticket
/start-work 347

# 2. Make changes, commit work...
# git add . && git commit -m "feat(scope): description [{{TICKET_PREFIX}}-347]"

# 3. Check status periodically
/check-workflow

# 4. Update documentation before PR
/update-docs

# 5. Validate before creating PR
/pre-pr

# 6. Create PR (if validation passes)
# git push --force-with-lease origin {{TICKET_PREFIX}}-347-branch
# # Use the PR template as your PR body baseline:
# # gh pr create --title "feat(scope): description [{{TICKET_PREFIX}}-347]" --body "$(cat .github/pull_request_template.md)"
# gh pr create ...

# 7. End session cleanly
/end-work
```

## Hooks Configuration

Hooks provide automatic reminders, validation, and critical blockers during development.
Configuration is in `hooks-config.json`.

### Active Hooks (from hooks-config.json)

**Session Lifecycle:**

| Event          | Behavior                                        |
| -------------- | ----------------------------------------------- |
| `SessionStart` | Shows available commands and workflow reminders |
| `SessionEnd`   | Warns if uncommitted changes exist              |

**Pre-Tool Hooks (Prevention):**

| Trigger               | Behavior                                                                      |
| --------------------- | ----------------------------------------------------------------------------- |
| On prompt submit      | Reminds about `{{TICKET_PREFIX}}-{number}` branch naming convention                         |
| Before `git commit`   | Reminds about SAFe commit format                                              |
| Before `git push`     | ❌ **BLOCKS** if on dev/master; ❌ **BLOCKS** if uncommitted; warns if behind |
| Before `gh pr create` | Reminds to run `/pre-pr` validation first                                     |

**Post-Tool Hooks (Feedback):**

| Trigger             | Behavior                                              |
| ------------------- | ----------------------------------------------------- |
| After `ci:validate` | Reports pass/fail result                              |
| After file edit     | Auto-formats with Prettier/ESLint; reminds about docs |

### Wired Hook Scripts

Scripts in `.claude/hooks/` that are actively wired via `hooks-config.json`:

| Script                         | Trigger            | Purpose                                                  |
| ------------------------------ | ------------------ | -------------------------------------------------------- |
| `post-commit-linear-update.sh` | After `git commit` | Outputs suggested Linear comment with commit hash (HITL) |
| `post-push-docker-check.sh`    | After `git push`   | Checks if Pop OS Docker needs image update               |

### Installing Hooks

1. Open Claude Code settings
2. Navigate to hooks configuration
3. Copy contents of `hooks-config.json`
4. Paste into hooks settings
5. Save and reload Claude Code

## Skills

Skills are model-invoked expertise packs that Claude loads automatically when relevant context is detected.

### Skills Index (17 Skills)

| Skill | Purpose | Related Skills |
|-------|---------|----------------|
| [safe-workflow](skills/safe-workflow/) | Branch naming, commit format, PR workflow | release-patterns, git-advanced |
| [release-patterns](skills/release-patterns/) | PR creation, CI/CD validation | safe-workflow, deployment-sop |
| [pattern-discovery](skills/pattern-discovery/) | Search patterns before implementing | api-patterns, frontend-patterns |
| [agent-coordination](skills/agent-coordination/) | Agent assignment, blocker escalation | orchestration-patterns, linear-sop |
| [rls-patterns](skills/rls-patterns/) | Row Level Security for database ops | api-patterns, security-audit |
| [spec-creation](skills/spec-creation/) | Specs with acceptance criteria | pattern-discovery, testing-patterns |
| [orchestration-patterns](skills/orchestration-patterns/) | Multi-step task orchestration | agent-coordination, linear-sop |
| [testing-patterns](skills/testing-patterns/) | Jest and Playwright patterns | api-patterns, spec-creation |
| [security-audit](skills/security-audit/) | RLS validation, vulnerability scanning | rls-patterns, api-patterns |
| [linear-sop](skills/linear-sop/) | Linear ticket management | orchestration-patterns |
| [migration-patterns](skills/migration-patterns/) | Database migrations with RLS | rls-patterns |
| [frontend-patterns](skills/frontend-patterns/) | Next.js, Clerk, shadcn/ui | api-patterns, testing-patterns |
| [api-patterns](skills/api-patterns/) | API routes with Zod validation | rls-patterns, testing-patterns |
| [git-advanced](skills/git-advanced/) | Rebase, bisect, cherry-pick | safe-workflow |
| [stripe-patterns](skills/stripe-patterns/) | Payment integration, webhooks | api-patterns, security-audit |
| [deployment-sop](skills/deployment-sop/) | Deployment workflows, smoke tests | release-patterns |
| [confluence-docs](skills/confluence-docs/) | ADRs, runbooks, architecture docs | spec-creation |

### Skill Structure

Each skill folder contains:
- `SKILL.md` - Main skill definition (Claude loads this)
- `README.md` - Quick reference and metadata

Skills live in `.claude/skills/{skill-name}/`.

### Creating New Skills

See the **[Skill Authoring Guide](../docs/guides/SKILL_AUTHORING_GUIDE.md)** for:
- Official Anthropic resources
- Community checklists (jezweb/claude-skills)
- Our harness quality standards
- Step-by-step skill creation

### Listing Available Skills

**Known Issue**: The `/skills` command has a display bug in Claude Code v2.0.73 (GitHub Issue #14733).
Skills ARE working, but won't appear in `/skills` output.

**Workaround**: Ask Claude directly:

```text
What skills are available?
```

Or list the filesystem:

```bash
ls .claude/skills/
```

## Customization

### Adding New Slash Commands

Create a new markdown file in `.claude/commands/`:

```markdown
---
description: Command purpose
argument-hint: [optional args]
---

Command instructions here.

Use $1, $2 for positional arguments.
Use $ARGUMENTS for all arguments.
```

### Modifying Hooks

Edit `hooks-config.json` following this structure:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "shell-command-here",
            "description": "What this hook does"
          }
        ]
      }
    ]
  }
}
```

## Documentation

- **Harness Audit**: `docs/agent-outputs/workflow-analysis/HARNESS_AND_SKILLS_AUDIT_2025-12-18.md`
- **CONTRIBUTING.md**: Project workflow requirements
- **Slash Commands Guide**: [Claude Code slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- **Hooks Guide**: [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)

## Troubleshooting

### Slash Commands Not Working

1. Verify `.claude/commands/` directory exists
2. Check file permissions (should be readable)
3. Restart Claude Code
4. Run `claude --debug` to see command loading

### Hooks Not Triggering

1. Verify hooks are configured in Claude Code settings
2. Check JSON syntax in `hooks-config.json`
3. Run `claude --debug` to see hook execution
4. Verify matchers are correct regex patterns

## Maintenance

These configurations are part of the project and should be:

- Committed to version control
- Updated when workflow changes
- Documented when modified
- Tested after changes

---

**Last Updated**: 2026-01-04
**Maintained by**: {{PROJECT_SHORT}} Development Team + ARCHitect-in-the-IDE (Auggie)
