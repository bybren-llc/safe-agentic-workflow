# Cursor Rules for SAFe Agentic Workflow

This directory contains `.mdc` rule files that translate the SAFe harness methodology into Cursor IDE's native rule format.

## How Cursor Rules Work

Cursor uses `.cursor/rules/*.mdc` files with YAML frontmatter to provide context-aware instructions to the AI assistant. There are three activation modes:

| Mode          | Frontmatter                     | When Active                              |
|---------------|---------------------------------|------------------------------------------|
| Always Apply  | `alwaysApply: true`             | Active in every conversation             |
| Auto-Attached | `globs: "pattern"`              | Active when matching files are open/edited|
| Manual        | `alwaysApply: false`, no globs  | Active when referenced with `@rule-name` |

## Rule Index

### Always-Apply Core (active in every conversation)

| File                        | Purpose                                           |
|-----------------------------|---------------------------------------------------|
| `00-core-principles.mdc`   | SAFe methodology, round-table philosophy, evidence-based delivery |
| `01-git-workflow.mdc`       | Branch naming, commit format, rebase-first, PR process |
| `02-pattern-discovery.mdc`  | MANDATORY pattern discovery before implementing anything |

### Auto-Attached Tech Rules (active when matching files are open)

| File                     | Globs                                      | Purpose                                |
|--------------------------|--------------------------------------------|----------------------------------------|
| `10-backend-python.mdc`  | `core/**/*.py, edgekit/**/*.py`            | FastAPI, SQLAlchemy, async, Alembic    |
| `11-frontend-react.mdc`  | `sdk/**/*.tsx, sdk/**/*.ts`                | React 18, Electron, ShadCN, Tailwind  |
| `12-database-sql.mdc`    | `alembic/**, **/models.py, **/schemas.py`  | PostgreSQL 16, migrations, RLS         |
| `13-testing.mdc`          | `tests/**/*.py, tests/**`                  | pytest, integration, E2E Docker        |

### Agent-Role Rules (manual, use `@rule-name` to activate)

| File                       | Purpose                                           |
|----------------------------|---------------------------------------------------|
| `20-agent-architect.mdc`   | System Architect: pattern validation, Stage 1 review, ADRs |
| `21-agent-backend.mdc`     | BE Developer: API implementation, RLS enforcement  |
| `22-agent-qas.mdc`         | QAS: independent gate, acceptance criteria verification |
| `23-agent-security.mdc`    | SecEng: OWASP, RLS validation, vulnerability scanning |

## Usage

### Always-Apply Rules

These load automatically. No action needed. They ensure every conversation respects SAFe principles, git workflow standards, and the pattern discovery protocol.

### Auto-Attached Rules

These activate when you open or edit files matching their glob pattern. For example, editing `core/gateway/router.py` will automatically load `10-backend-python.mdc`.

### Agent-Role Rules

Reference these manually when you want Cursor to adopt a specific SAFe agent persona:

```
@20-agent-architect Review this PR for pattern compliance
@21-agent-backend Implement the API endpoint from spec REN-123
@22-agent-qas Validate acceptance criteria for this feature
@23-agent-security Audit RLS policies for this new table
```

## Design Principles

1. **DRY**: Rules reference existing docs (CLAUDE.md, AGENTS.md, patterns_library/) rather than duplicating content
2. **Concise**: Each rule stays under 200 lines to respect Cursor's context limits
3. **Template-Ready**: Uses `{{TICKET_PREFIX}}`, `{{MAIN_BRANCH}}`, and other placeholders for project customization
4. **Hierarchical**: Numbering (00-02, 10-13, 20-23) groups rules by activation type

## Relationship to Other Configurations

| Tool        | Config Location                    | Purpose                         |
|-------------|------------------------------------|---------------------------------|
| Claude Code | `.claude/agents/`, `.claude/skills/` | Agent definitions and skills    |
| Augment     | `agent_providers/augment/rules/`   | Augment Code rules              |
| Cursor      | `.cursor/rules/` (this directory)  | Cursor IDE rules                |

All configurations reference the same source docs (CLAUDE.md, AGENTS.md, CONTRIBUTING.md, patterns_library/) to maintain consistency.
