# Skill Authoring Guide

This guide explains how to create, structure, and maintain Claude Code Skills for the SAFe Agentic Workflow harness.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Official Anthropic Resources](#2-official-anthropic-resources)
3. [Community Resources](#3-community-resources)
4. [Skill Structure](#4-skill-structure)
5. [Our Harness Standards](#5-our-harness-standards)
6. [Step-by-Step: Create a New Skill](#6-step-by-step-create-a-new-skill)
7. [Examples from This Harness](#7-examples-from-this-harness)

---

## 1. Introduction

### What are Claude Code Skills?

Skills are organized folders of instructions, scripts, and resources that Claude Code can discover and load dynamically to perform better at specific tasks. When a skill activates, Claude gains access to domain-specific knowledge, patterns, and workflows.

### Why Create Custom Skills?

- **Consistency**: Enforce team standards across all development work
- **Efficiency**: Reduce token usage by loading context only when needed
- **Specialization**: Provide deep expertise for specific domains (security, testing, etc.)
- **Reusability**: Share patterns across projects and teams

### Skill Loading Hierarchy

Skills are loaded in this priority order (highest to lowest):

1. **Enterprise** - Organization-wide managed skills
2. **Personal** - `~/.claude/skills/` (user-specific)
3. **Project** - `.claude/skills/` (repository-specific)
4. **Plugin** - Bundled with installed plugins

---

## 2. Official Anthropic Resources

### Primary Documentation

| Resource | Description |
|----------|-------------|
| [Agent Skills Docs](https://code.claude.com/docs/en/skills) | Official installation, structure, and usage guide |
| [anthropics/skills](https://github.com/anthropics/skills) | Official skill marketplace repository |
| [Engineering Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | Deep-dive on skill architecture and real-world usage |
| [Skills Announcement](https://www.anthropic.com/news/skills) | Feature introduction and overview |

### Installing Official Skills

```bash
# Install from official marketplace
/plugin install {skill-name}@anthropic-agent-skills

# Example: Install document-skills
/plugin install document-skills@anthropic-agent-skills
```

---

## 3. Community Resources

### Quality Checklist

| Resource | Description |
|----------|-------------|
| [jezweb/claude-skills Checklist](https://github.com/jezweb/claude-skills/blob/main/ONE_PAGE_CHECKLIST.md) | Comprehensive skill quality checklist |
| [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) | Curated list of community skills |
| [SkillsMP](https://skillsmp.com) | Community skill aggregator and discovery |

### Community Skill Factories

| Resource | Description |
|----------|-------------|
| [claude-code-skill-factory](https://github.com/alirezarezvani/claude-code-skill-factory) | Toolkit for building production-ready skills |
| [Jamie-BitFlight/claude_skills](https://github.com/Jamie-BitFlight/claude_skills) | Skills plugin for Claude Code |

---

## 4. Skill Structure

### Required Files

Every skill must have a `SKILL.md` file. Additional files are optional but recommended.

```
my-skill/
├── SKILL.md        # Required - Main skill definition
├── README.md       # Recommended - Quick reference and metadata
├── references/     # Optional - Supporting documentation
│   └── api-spec.md
├── scripts/        # Optional - Executable helpers
│   └── validate.sh
└── assets/         # Optional - Templates, schemas
    └── template.json
```

### SKILL.md Structure

```markdown
---
name: my-skill-name
description: Brief description of what this skill does. Use when [trigger conditions].
allowed-tools: [Read, Grep, Glob]  # Optional - restrict available tools
model: opus                        # Optional - force specific model
---

## Purpose

[1-2 sentences explaining the skill's goal]

## When This Skill Applies

Invoke this skill when:

- [Trigger condition 1]
- [Trigger condition 2]
- [Trigger condition 3]

## [Domain-Specific Sections]

[Patterns, checklists, examples]

## Authoritative References

- **[Doc Name]**: `path/to/doc`
```

### YAML Frontmatter Reference

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | No | 64 chars | Lowercase letters, numbers, hyphens only. If omitted, uses directory name. |
| `description` | Recommended | 1024 chars | What it does + when to use it (Claude uses this for activation) |
| `argument-hint` | No | - | Hint shown during autocomplete (e.g., `[issue-number]`, `[filename] [format]`) |
| `disable-model-invocation` | No | - | Set `true` to prevent Claude from auto-loading. Users invoke manually with `/name`. |
| `user-invocable` | No | - | Set `false` to hide from `/` menu. Use for background knowledge Claude loads automatically. |
| `allowed-tools` | No | - | Comma-separated tools Claude can use when skill is active (e.g., `Read, Grep, Glob`) |
| `model` | No | - | Force specific Claude model when active |
| `context` | No | - | Set to `fork` to run in isolated subagent context |
| `agent` | No | - | Subagent type when `context: fork` is set (e.g., `Explore`, `Plan`, `general-purpose`, or custom agent name) |
| `hooks` | No | - | Hook configurations scoped to skill lifecycle (PreToolUse, PostToolUse, Stop) |

### Description Best Practices

Your description is **critical** - Claude uses it to decide when to activate the skill.

**Good descriptions include:**
- **What** the skill does (specific capabilities)
- **When** to use it (trigger keywords users would say)

```yaml
# Good: Specific and trigger-rich
description: Row Level Security patterns for database operations. Use when writing Prisma/database code, creating API routes that access data, or implementing webhooks. Enforces withUserContext, withAdminContext, or withSystemContext helpers. NEVER use direct prisma calls.

# Bad: Vague and missing triggers
description: Helps with database stuff.
```

### Invocation Control

Skills 2.0 gives you fine-grained control over who can invoke a skill:

| Frontmatter | User Invokes | Claude Invokes | Context Loading |
|-------------|-------------|----------------|-----------------|
| (default) | Yes | Yes | Description always in context, full skill loads on invoke |
| `disable-model-invocation: true` | Yes | No | Description NOT in context, loads only when user invokes |
| `user-invocable: false` | No | Yes | Description always in context, loads when Claude decides |

**When to use each**:

- **Default**: Most skills — both user and Claude can trigger
- **`disable-model-invocation: true`**: Dangerous operations with side effects (deploy, migrate, release)
- **`user-invocable: false`**: Background knowledge (API conventions, security patterns, workflow rules)

### Forked Context (`context: fork`)

Adding `context: fork` runs the skill in an isolated subagent — the skill content becomes the subagent's task prompt. The main conversation context is NOT inherited.

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

**When to use `context: fork`**:
- Research/analysis tasks that should not pollute main conversation
- Security audits that need isolation
- Pattern discovery that generates large intermediate output

**When NOT to use it**:
- Background knowledge skills (they need conversation context)
- Skills that provide guidelines without a concrete task

The `agent` field specifies the execution environment:
- `Explore` — Read-only tools, optimized for codebase exploration
- `Plan` — Read-only, for designing implementation approaches
- `general-purpose` — Full tool access (default if omitted)
- Custom agent name from `.claude/agents/`

### String Substitutions

Skills support dynamic value substitution:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` or `$N` | Access specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID (useful for logging) |
| `${CLAUDE_SKILL_DIR}` | Directory containing the SKILL.md file |

### Dynamic Context Injection

The `!` backtick syntax runs shell commands before skill content is sent to Claude:

```yaml
---
name: pr-summary
description: Summarize PR changes
context: fork
agent: Explore
---

## PR Context
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`

## Task
Summarize the changes in this pull request.
```

Commands run as preprocessing — Claude only sees the final output.

### Hooks in Skills

Skills can define hooks scoped to their lifecycle:

```yaml
---
name: secure-implementation
description: Implementation with security validation
hooks:
  PreToolUse:
    - matcher: Write
      command: "echo 'Validating security patterns before write'"
  PostToolUse:
    - matcher: Bash
      command: "echo 'Checking for security issues after bash execution'"
---
```

### Bundled Skills

Claude Code ships with built-in skills available in every session:

| Skill | Description | SAFe Alignment |
|-------|-------------|----------------|
| `/simplify` | Spawns 3 parallel review agents (code reuse, quality, efficiency) | Complements QAS review |
| `/batch` | Orchestrates large-scale parallel changes with git worktrees | Large refactoring / cross-cutting |
| `/debug` | Reads session debug log for troubleshooting | Agent debugging |
| `/claude-api` | Claude API/SDK reference (auto-activates on `anthropic` import) | For Claude-based projects |

---

## 5. Our Harness Standards

### Quality Checklist

Before submitting a new skill, verify:

- [ ] **Valid YAML frontmatter** with `name` and `description`
- [ ] **Clear purpose statement** (first section)
- [ ] **Trigger conditions documented** ("When This Skill Applies")
- [ ] **Imperative voice** throughout ("Do X" not "You should X")
- [ ] **Stop-the-line patterns** with FORBIDDEN/CORRECT sections
- [ ] **Code examples** with proper language tags
- [ ] **Authoritative references** linking to source docs
- [ ] **README.md** with badges and quick reference
- [ ] **Invocation control set** — `disable-model-invocation` for dangerous ops, `user-invocable: false` for background knowledge
- [ ] **Tool restrictions applied** — `allowed-tools` limits to minimum necessary tools
- [ ] **Forked context where appropriate** — Research/audit skills use `context: fork`
- [ ] **Arguments documented** — `argument-hint` set if skill accepts arguments

### Writing Guidelines

| Guideline | Reason |
|-----------|--------|
| Keep SKILL.md under 500 lines | Optimal token efficiency |
| Use `❌`/`✅` for forbidden/correct | Visual clarity |
| Include language tags on code blocks | Syntax highlighting |
| Link to authoritative docs | Traceability |
| Use imperative voice | Clearer instructions |

### README.md Template

Each skill should have a README.md for quick reference:

```markdown
# {Skill Name}

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)

> {One-line description from YAML frontmatter}

## Quick Start

This skill activates automatically when you:
- {Primary trigger 1}
- {Primary trigger 2}
- {Primary trigger 3}

## What This Skill Does

{2-3 sentence summary - what problem it solves, what value it provides}

## Trigger Keywords

| Primary (3-5) | Secondary (5-10) |
|---------------|------------------|
| {keyword} | {keyword} |

## Related Skills

- [{skill-name}](../skill-name/) - {why related}

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | YYYY-MM-DD |
| Harness Version | vX.X.X |

---

*Full implementation details in [SKILL.md](SKILL.md)*
```

### Badge Meanings

| Badge | When to Use |
|-------|-------------|
| ![production](https://img.shields.io/badge/status-production-green) | Stable, tested in production |
| ![beta](https://img.shields.io/badge/status-beta-yellow) | Working but may change |
| ![experimental](https://img.shields.io/badge/status-experimental-red) | New, use with caution |

---

## 6. Step-by-Step: Create a New Skill

### Step 1: Create the Folder

```bash
mkdir -p .claude/skills/{skill-name}
```

Use lowercase with hyphens for the folder name.

### Step 2: Create SKILL.md

Start with this template:

```markdown
---
name: {skill-name}
description: {What it does}. Use when {trigger conditions}.
# Uncomment and configure as needed:
# disable-model-invocation: true    # Only user can invoke (dangerous ops)
# user-invocable: false             # Only Claude can invoke (background knowledge)
# allowed-tools: Read, Grep, Glob  # Restrict available tools
# context: fork                     # Run in isolated subagent
# agent: Explore                    # Subagent type (with context: fork)
# argument-hint: "[ticket-id]"     # Autocomplete hint
---

## Purpose

{1-2 sentences explaining the skill's goal}

## When This Skill Applies

Invoke this skill when:

- {Trigger 1}
- {Trigger 2}
- {Trigger 3}

## Critical Rules

### ❌ FORBIDDEN Patterns

```typescript
// What NOT to do
```

### ✅ CORRECT Patterns

```typescript
// What TO do
```

## [Additional Sections]

{Domain-specific content}

## Authoritative References

- **{Doc Name}**: `{path/to/doc}`
```

### Step 3: Add Implementation Patterns

Include concrete examples with code blocks:

```markdown
## Common Patterns

### Pattern 1: {Name}

```typescript
// Example code
```

### Pattern 2: {Name}

```typescript
// Example code
```
```

### Step 4: Add Authoritative References

Link to the source documentation:

```markdown
## Authoritative References

- **CONTRIBUTING.md**: `../../CONTRIBUTING.md`
- **Database Schema**: `docs/database/DATA_DICTIONARY.md`
- **Official Docs**: [External Link](https://example.com)
```

### Step 5: Create README.md

Use the template from Section 5 above.

### Step 6: Test the Skill

1. Restart Claude Code (or start new session)
2. Ask: "What skills are available?"
3. Verify your skill appears in the list
4. Test a prompt that should trigger the skill
5. Verify Claude requests permission to use it

### Step 7: Commit and Document

```bash
git add .claude/skills/{skill-name}/
git commit -m "feat(skills): add {skill-name} skill"
```

---

## 7. Examples from This Harness

### Security-Focused Skill

**`rls-patterns/`** - Enforces Row Level Security for all database operations

Key features:
- Stop-the-line authority (blocks direct Prisma calls)
- Context helper patterns (withUserContext, withAdminContext)
- Protected tables documentation

### Comprehensive Patterns Skill

**`frontend-patterns/`** - Complete frontend development patterns

Key features:
- 489 lines of comprehensive patterns
- Next.js, Clerk, shadcn/ui coverage
- Accessibility checklist
- Common mistakes section

### Process/Workflow Skill

**`safe-workflow/`** - SAFe development workflow enforcement

Key features:
- Branch naming conventions
- Commit message format
- Rebase-first workflow
- Pre-PR validation checklist

---

## Maintenance

### Updating Skills

When updating a skill:

1. Update the content in SKILL.md
2. Update "Last Updated" in README.md
3. Bump harness version if significant change
4. Commit with clear message: `fix(skills): update {skill-name} for {reason}`

### Deprecating Skills

If a skill is being replaced or removed:

1. Add deprecation warning to top of SKILL.md
2. Update README.md badge to `deprecated`
3. Point users to replacement skill
4. Keep for at least one version cycle before removal

---

## Additional Resources

- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Best Practices Guide](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices)
- [Agent SDK Skills Reference](https://docs.claude.com/en/docs/agent-sdk/skills)

---

*This guide is part of the [{{PROJECT_SHORT}} SAFe Agentic Workflow](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}) harness.*
