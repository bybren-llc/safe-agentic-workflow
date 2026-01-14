# Gemini CLI Authoring Guide

This guide explains how to create, structure, and maintain Gemini CLI Skills and Commands for the SAFe Agentic Workflow harness.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Official Google Resources](#2-official-google-resources)
3. [Skill Authoring](#3-skill-authoring)
4. [Command Authoring](#4-command-authoring)
5. [Hooks Configuration](#5-hooks-configuration)
6. [Multimodal Features](#6-multimodal-features)
7. [Our Harness Standards](#7-our-harness-standards)
8. [Examples from This Harness](#8-examples-from-this-harness)

---

## 1. Introduction

### What is Gemini CLI?

Gemini CLI is Google's open-source AI agent that brings Gemini directly into your terminal. It uses a ReAct (reason and act) loop with built-in tools and MCP servers.

### Gemini CLI vs Claude Code

| Feature | Gemini CLI | Claude Code |
|---------|------------|-------------|
| **Skills** | `.gemini/skills/SKILL.md` | `.claude/skills/SKILL.md` |
| **Commands** | `.gemini/commands/*.toml` | `.claude/commands/*.md` |
| **Config** | `settings.json` | `settings.local.json` |
| **Hooks** | `settings.json` hooks section | `hooks-config.json` |
| **Shell Injection** | `!{command}` in prompts | Via Bash tool |
| **File Injection** | `@{file}` in prompts | Via Read tool |

### Why Both?

- **Claude Code**: 5+ months production-tested, MCP integrations, agent subprocesses
- **Gemini CLI**: Shell/file injection, multimodal (images, PDFs, audio), Google services

---

## 2. Official Google Resources

### Primary Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| **Main Docs** | [geminicli.com/docs](https://geminicli.com/docs) | Official documentation |
| **GitHub** | [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Source code |
| **Skills** | [geminicli.com/docs/cli/skills](https://geminicli.com/docs/cli/skills/) | Skill specification |
| **Commands** | [geminicli.com/docs/cli/custom-commands](https://geminicli.com/docs/cli/custom-commands/) | Command specification |
| **Hooks** | [geminicli.com/docs/hooks](https://geminicli.com/docs/hooks/) | Hooks reference |
| **Settings Schema** | [GitHub Schema](https://raw.githubusercontent.com/google-gemini/gemini-cli/main/schemas/settings.schema.json) | JSON Schema |

### Hands-On Tutorial

- [Google Codelabs - Gemini CLI](https://codelabs.developers.google.com/gemini-cli-hands-on)

---

## 3. Skill Authoring

### Directory Structure

```
.gemini/skills/
├── my-skill/
│   └── SKILL.md        # Required
├── another-skill/
│   ├── SKILL.md        # Required
│   ├── scripts/        # Optional - executable helpers
│   ├── references/     # Optional - supporting docs
│   └── assets/         # Optional - templates, schemas
```

### Discovery Tiers (Priority Order)

1. **Project**: `.gemini/skills/` (highest priority)
2. **User**: `~/.gemini/skills/`
3. **Extension**: Bundled with installed extensions

### SKILL.md Format

```markdown
---
name: my-skill-name
description: What this skill does. Use when [trigger conditions].
---

# Skill Title

## Purpose

[1-2 sentences explaining the skill's goal]

## When This Skill Applies

Invoke this skill when:

- [Trigger condition 1]
- [Trigger condition 2]

## [Domain-Specific Sections]

[Patterns, checklists, examples]
```

### Required Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | **Yes** | Unique identifier (lowercase alphanumeric + dashes) |
| `description` | **Yes** | What it does + when to use (Gemini uses this for auto-activation) |

### Description Best Practices

Gemini uses the description to decide when to activate the skill.

```yaml
# Good: Specific triggers
description: Row Level Security patterns for database operations. Use when writing Prisma/database code, creating API routes, or implementing webhooks.

# Bad: Vague
description: Helps with database stuff.
```

### Auto-Activation Process

1. **Discovery**: Gemini CLI scans skill directories at session start
2. **Injection**: Skill names and descriptions added to system prompt
3. **Decision**: Gemini decides relevance based on user request
4. **Consent**: User confirms skill activation
5. **Load**: Skill body and folder structure added to context

---

## 4. Command Authoring

### Directory Structure

```
.gemini/commands/
├── my-command.toml              # → /my-command
├── workflow/
│   ├── start-work.toml          # → /workflow:start-work
│   └── pre-pr.toml              # → /workflow:pre-pr
├── media/
│   ├── analyze-images.toml      # → /media:analyze-images
│   └── extract-pdf.toml         # → /media:extract-pdf
```

### Namespacing

Subdirectories create namespaced commands using colons:

| File Path | Command |
|-----------|---------|
| `commands/test.toml` | `/test` |
| `commands/git/commit.toml` | `/git:commit` |
| `commands/workflow/pre-pr.toml` | `/workflow:pre-pr` |

### TOML Format

```toml
description = "Brief description shown in /help"

prompt = """
# Command Title

Your prompt content here.

## Using Arguments

User input: {{args}}

## Shell Execution

```bash
!{git status}
```

## File Injection

@{package.json}
"""
```

### Required vs Optional Fields

| Field | Required | Description |
|-------|----------|-------------|
| `prompt` | **Yes** | The text sent to Gemini (string or multi-line) |
| `description` | No | Brief description for `/help` menu |

### Special Syntax

#### 1. Argument Injection: `{{args}}`

User input after the command is substituted:

```toml
prompt = """
Search for: {{args}}

!{grep -r "{{args}}" . --include="*.ts"}
"""
```

- Outside `!{}`: Injected exactly as typed
- Inside `!{}`: Automatically shell-escaped

#### 2. Shell Execution: `!{command}`

Execute shell commands and inject output:

```toml
prompt = """
Current git status:

!{git status --short}

Recent commits:

!{git log --oneline -5}
"""
```

- User prompted for confirmation before execution
- Error output includes exit codes
- Must have balanced braces

#### 3. File Injection: `@{path}`

Embed file or directory contents:

```toml
prompt = """
Analyze this config:

@{package.json}

And this source file:

@{src/index.ts}
"""
```

- **Files**: Content inserted directly
- **Directories**: All files traversed
- **Images/PDFs**: Base64-encoded for multimodal input
- Respects `.gitignore` and `.geminiignore`

### Multimodal Command Example

```toml
description = "Analyze an image file"

prompt = """
Analyze this image and describe its contents:

@{{{args}}}

Provide:
1. Visual description
2. Key elements identified
3. Suggested filename based on content
"""
```

---

## 5. Hooks Configuration

### Enabling Hooks

Add to `.gemini/settings.json`:

```json
{
  "tools": { "enableHooks": true },
  "hooks": {
    "BeforeTool": [
      {
        "hooks": [
          {
            "name": "my-hook",
            "type": "command",
            "command": "./scripts/before-tool.sh",
            "timeout": 30000
          }
        ]
      }
    ]
  }
}
```

### Available Hook Events

| Event | Trigger | Use Case |
|-------|---------|----------|
| `SessionStart` | Session begins | Initialize resources |
| `SessionEnd` | Session ends | Cleanup, save state |
| `BeforeAgent` | After prompt, before planning | Add context |
| `AfterAgent` | Agent loop ends | Review output |
| `BeforeModel` | Before LLM request | Modify prompts |
| `AfterModel` | After LLM response | Filter responses |
| `BeforeToolSelection` | Before tool filtering | Restrict tools |
| `BeforeTool` | Before tool execution | Validate, block |
| `AfterTool` | After tool execution | Process results |
| `PreCompress` | Before context compression | Save state |
| `Notification` | Permission events | Auto-approve |

### Migrating from Claude Code

```bash
gemini hooks migrate --from-claude
```

---

## 6. Multimodal Features

### Supported File Types

| Category | Formats | Use Case |
|----------|---------|----------|
| **Images** | PNG, JPG, GIF, WEBP, SVG, BMP | Visual analysis, OCR |
| **Audio** | MP3, WAV, AIFF, AAC, OGG, FLAC | Transcription |
| **Documents** | PDF | Text extraction, tables |

### File Size Limits

| Version | Limit |
|---------|-------|
| Gemini 2.x | 20MB |
| Gemini 3.x | 100MB |

### Multimodal Command Pattern

```toml
description = "Analyze images in a directory"

prompt = """
Analyze the images in this directory:

@{{{args}}}

For each image:
1. Describe visual content
2. Extract any text (OCR)
3. Suggest descriptive filename
"""
```

### Image Analysis Use Cases

- Rename photos based on content
- Extract invoice data to CSV
- Generate alt-text for accessibility
- Convert sketches to code
- Organize files by visual category

---

## 7. Our Harness Standards

### Skill Quality Checklist

Before adding a skill:

- [ ] **Valid YAML frontmatter** with `name` and `description`
- [ ] **Clear purpose statement** (first section)
- [ ] **Trigger conditions documented** ("When This Skill Applies")
- [ ] **Imperative voice** throughout ("Do X" not "You should X")
- [ ] **Code examples** with proper language tags
- [ ] **Under 500 lines** for optimal token efficiency

### Command Quality Checklist

Before adding a command:

- [ ] **Valid TOML syntax** (test with `python3 -c "import tomllib; ..."`)
- [ ] **`prompt` field present** (required)
- [ ] **`description` field present** (for /help visibility)
- [ ] **Escaped backslashes** in regex patterns (`\\` not `\`)
- [ ] **Balanced braces** in `!{}` and `@{}` blocks
- [ ] **Clear usage examples** in prompt

### TOML Syntax Gotchas

```toml
# WRONG: Unescaped backslash
!{grep "foo\\.bar" .}

# CORRECT: Escaped backslash
!{grep "foo\\\\.bar" .}

# WRONG: Unescaped regex alternation
!{grep "error\\|warning" .}

# CORRECT: Use -E flag instead
!{grep -E "error|warning" .}
```

### Validation Script

```bash
python3 -c "
import tomllib
with open('.gemini/commands/my-command.toml', 'rb') as f:
    tomllib.load(f)
print('Valid TOML')
"
```

---

## 8. Examples from This Harness

### Skill Example: safe-workflow

```markdown
---
name: safe-workflow
description: SAFe development workflow guidance including branch naming conventions, commit message format, rebase-first workflow, and CI validation. Use when starting work on a Linear ticket, preparing commits, creating branches, writing PR descriptions, or asking about contribution guidelines.
---

# SAFe Workflow Skill

## Purpose

Enforce SAFe (Scaled Agile Framework) development practices...
```

### Command Example: /workflow:start-work

```toml
description = "Start work on a new Linear ticket with proper workflow"

prompt = """
# Start Work Command

You are starting work on a new Linear ticket.

**Ticket**: {{args}}

## Workflow

### 1. Create Feature Branch

```bash
!{git checkout -b {{args}}}
```
...
"""
```

### Multimodal Command Example: /media:analyze-images

```toml
description = "Analyze and describe images in a directory"

prompt = """
# Analyze Images Command

Analyze images in the specified directory using Gemini's multimodal vision.

**Target**: {{args}}

@{{{args}}}
...
"""
```

---

## Quick Reference Card

### File Locations

| Type | Location |
|------|----------|
| Skills | `.gemini/skills/<name>/SKILL.md` |
| Commands | `.gemini/commands/**/*.toml` |
| Settings | `.gemini/settings.json` |
| System Instructions | `.gemini/GEMINI.md` |

### Command Syntax

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{{args}}` | User input | `Search: {{args}}` |
| `!{cmd}` | Shell output | `!{git status}` |
| `@{path}` | File contents | `@{package.json}` |

### Namespacing

| Path | Command |
|------|---------|
| `commands/foo.toml` | `/foo` |
| `commands/bar/baz.toml` | `/bar:baz` |

---

## See Also

- [SKILL_AUTHORING_GUIDE.md](./SKILL_AUTHORING_GUIDE.md) - Claude Code skill guide
- [.gemini/README.md](../../.gemini/README.md) - Gemini CLI harness documentation
- [geminicli.com/docs](https://geminicli.com/docs) - Official documentation
