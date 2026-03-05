# AI Agent Harness for Multi-Agent Team Workflows

**A Production-Tested Three-Layer Architecture for Coordinated AI Teams**

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License">
  <a href=".claude/skills/">
    <img src="https://img.shields.io/badge/skills-18%20model--invoked-purple?style=flat-square" alt="Skills">
  </a>
  <a href=".claude/commands/">
    <img src="https://img.shields.io/badge/commands-23%20workflows-orange?style=flat-square" alt="Commands">
  </a>
  <img src="https://img.shields.io/badge/template-ready-brightgreen?style=flat-square" alt="Template Ready">
</p>

<p align="center">
  <strong>Supported AI Providers</strong><br>
  <a href=".claude/">
    <img src="https://img.shields.io/badge/Claude_Code-Anthropic-orange?style=flat-square&logo=anthropic" alt="Claude Code">
  </a>
  <a href=".gemini/">
    <img src="https://img.shields.io/badge/Gemini_CLI-Google-blue?style=flat-square&logo=google" alt="Gemini CLI">
  </a>
</p>

> **Template Repository** - Click "Use this template" above to create your own AI agent harness.
> After cloning, run `bash scripts/setup-template.sh` to customize for your project.
> See [TEMPLATE_SETUP.md](TEMPLATE_SETUP.md) for details.

---

## What This Is

A **production-tested AI agent harness** for teams that want structured AI workflows.

**Multi-provider support**: Works with both **Claude Code** (Anthropic) and **Gemini CLI** (Google).

**Built on SAFe methodology** (Scaled Agile Framework), adapted for AI agent teams.
Works for any team with repeatable processes: Software, Marketing, Research, Legal, Operations.

Includes:

- **18 Model-Invoked Skills** - Domain expertise that loads automatically (Skills 2.0 frontmatter)
- **23 Slash Commands** - Workflow automation for common tasks
- **11 SAFe Agent Profiles** - Specialized roles with clear boundaries
- **Three-Layer Architecture** - Hooks → Commands → Skills
- **Agent Teams** - Multi-agent orchestration with SAFe quality gates (experimental)

> **Origin**: 5 months production use, 169 issues, 2,193 commits. Implements patterns from
> [6 Anthropic engineering papers](#implementing-anthropics-research) and [SAFe methodology](https://scaledagileframework.com/).

---

## Quick Start (30 seconds)

### Claude Code (Anthropic)

```bash
# Copy harness to your project
cp -r .claude/ /your-project/.claude/

# Customize placeholders
edit .claude/SETUP.md  # Replace {{TICKET_PREFIX}}, {{PROJECT_NAME}}

# Start working
/start-work TICKET-123
```

### Gemini CLI (Google)

```bash
# Copy harness to your project
cp -r .gemini/ /your-project/.gemini/

# Install Gemini CLI (if needed)
npm install -g @google/gemini-cli

# Authenticate
export GEMINI_API_KEY="your-api-key"

# Start working
/workflow:start-work TICKET-123
```

**That's it.** Your AI assistant now has your team's workflow patterns built in.

---

## The Three-Layer Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│                      Claude Code Harness                              │
├──────────────────────────────────────────────────────────────────────┤
│  LAYER 1: HOOKS     │ Automatic guardrails (format checks, blockers) │
│  LAYER 2: COMMANDS  │ User-invoked workflows (/start-work, /pre-pr)  │
│  LAYER 3: SKILLS    │ Model-invoked expertise (pattern discovery)    │
└──────────────────────────────────────────────────────────────────────┘
```

> **Philosophy**: Process as _service_, not _control_.
> Everything exists to reduce cognitive load on already-solved problems.

---

## Choose Your Path

<details>
<summary><strong>For Practitioners</strong> - I want to use this today</summary>

### Getting Started

1. Copy `.claude/` directory to your project
2. Edit placeholders in `.claude/SETUP.md`
3. Run `/start-work` on your first ticket

### Key Commands

| Command           | Purpose                           |
| ----------------- | --------------------------------- |
| `/start-work`     | Begin ticket with proper workflow |
| `/pre-pr`         | Validate before pull request      |
| `/end-work`       | Complete session cleanly          |
| `/check-workflow` | Quick status check                |

### Full Command Reference

**Workflow** (7): `/start-work`, `/pre-pr`, `/end-work`, `/check-workflow`, `/update-docs`, `/retro`, `/sync-linear`

**Local Operations** (3): `/local-sync`, `/local-deploy`, `/quick-fix`

**Remote Operations** (5): `/remote-status`, `/remote-deploy`, `/remote-health`, `/remote-logs`, `/remote-rollback`

[Complete Setup Guide](.claude/SETUP.md)

</details>

<details>
<summary><strong>For Researchers</strong> - I want to understand the methodology</summary>

### Research Foundation

This harness implements patterns from 6 Anthropic engineering papers (see [below](#implementing-anthropics-research)).

See `docs/whitepapers/` for methodology deep-dives and comparative analysis.

</details>

<details>
<summary><strong>For Leaders</strong> - I want ROI and risk assessment</summary>

### Production Results (v1.0 Harness)

> **Note**: These metrics are from the **v1.0 harness** deployed on the {{PROJECT_SHORT}}-app project (5+ months production use). This repository is now at **v2.5** (Skills 2.0 + Agent Teams), which adds Skills 2.0 frontmatter to all 18 skills, Agent Teams orchestration, and comprehensive upgrade documentation.

| Metric           | Value              | Source     |
| ---------------- | ------------------ | ---------- |
| Issues Completed | 169                | Linear     |
| Velocity Growth  | 14× (Cycle 3→8)    | Linear     |
| Commits          | 2,193 (10.3/day)   | GitHub     |
| PR Merge Rate    | 90.9% (159/175)    | GitHub     |
| Documentation    | 136 docs, 36 specs | Repository |

### Adoption Requirements

- Claude Code CLI or Gemini CLI installed
- Git repository
- Team buy-in for structured workflows

### Known Limitations

- Single-team validation only
- Gemini CLI support is new (Claude Code has 5+ months production use)


</details>

---

## Gemini CLI Integration

<details>
<summary><strong>Why Gemini CLI?</strong> - Unique capabilities and when to use it</summary>

### Gemini CLI Unique Features

Gemini CLI offers capabilities that complement Claude Code:

| Feature | Gemini CLI | Claude Code |
|---------|------------|-------------|
| **Shell Injection** | `!{command}` - Execute shell, inject output into prompt | Via Bash tool only |
| **File Injection** | `@{file}` - Inject file contents into prompts | Via Read tool only |
| **Built-in Sandbox** | Google Cloud sandboxing | MCP sandboxing |
| **Model Options** | Gemini 3 Flash, Gemini 3.1 Pro Preview | Claude Opus, Sonnet, Haiku |
| **Command Format** | TOML | YAML + Markdown |
| **Namespaced Commands** | `/workflow:start-work` | `/start-work` |
| **Hooks** | `settings.json` hooks section | `hooks-config.json` |
| **MCP Servers** | `settings.json` mcpServers | `settings.local.json` |
| **Hook Migration** | `gemini hooks migrate --from-claude` | N/A |
| **Plan Mode** | `/plan` command, plan-then-execute | N/A |
| **Policy Engine** | YAML policies, seatbelt profiles | N/A |
| **Browser Agent** | Built-in experimental agent | MCP (claude-in-chrome) |
| **Extensions** | Bundled skill/MCP/command packages | N/A |
| **Checkpointing** | `/restore` session recovery | N/A |
| **Audio/Video** | Native multimodal (Gemini 3+) | N/A |

### When to Use Gemini CLI

**Choose Gemini CLI when you need:**
- Shell command output directly in prompts (`!{git log --oneline -5}`)
- File contents injected into context (`@{package.json}`)
- Plan mode for complex multi-step tasks (`/plan`)
- Audio/video transcription and analysis (Gemini 3+ multimodal)
- Policy engine for fine-grained tool control
- Google Cloud integration and Gemini model family access

**Choose Claude Code when you need:**
- Agent subprocesses with tool restrictions
- Claude model family access
- Production-tested workflow (5+ months validated)

### Gemini CLI Quick Reference

```bash
# Installation
npm install -g @google/gemini-cli

# Authentication (choose one)
export GEMINI_API_KEY="your-api-key"
# or
gcloud auth application-default login

# Start Gemini CLI
gemini

# List available commands
/help

# List available skills
/skills
```

### Command Syntax Differences

| Action | Claude Code | Gemini CLI |
|--------|-------------|------------|
| Start work | `/start-work {{TICKET_PREFIX}}-123` | `/workflow:start-work {{TICKET_PREFIX}}-123` |
| Pre-PR check | `/pre-pr` | `/workflow:pre-pr` |
| Local sync | `/local-sync` | `/local:sync` |
| Remote deploy | `/remote-deploy` | `/remote:deploy` |
| Search patterns | `/search-pattern "pattern"` | `/search-pattern "pattern"` |

### Gemini CLI Documentation

- **Official Docs**: [geminicli.com](https://geminicli.com)
- **Installation**: [geminicli.com/docs/get-started/installation/](https://geminicli.com/docs/get-started/installation/)
- **Authentication**: [geminicli.com/docs/get-started/authentication/](https://geminicli.com/docs/get-started/authentication/)
- **Custom Commands**: [geminicli.com/docs/cli/custom-commands/](https://geminicli.com/docs/cli/custom-commands/)
- **Skills**: [geminicli.com/docs/cli/skills/](https://geminicli.com/docs/cli/skills/)

</details>

---

## Implementing Anthropic's Research

This harness directly implements patterns from Anthropic's engineering papers:

| Paper                                                                                                       | What We Implement          |
| ----------------------------------------------------------------------------------------------------------- | -------------------------- |
| [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)                | 11-agent team structure    |
| [Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)    | Three-layer architecture   |
| [Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | 18 model-invoked skills    |
| [Skills Announcement](https://www.anthropic.com/news/skills)                                                | Skills 2.0 frontmatter, trigger patterns |
| [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)                    | Tool restrictions per role |

> "The best harness is one you forget exists." — [Agent Perspective](docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md)

---

## SAFe Foundation

<details>
<summary><strong>For Agile Practitioners</strong> - Deep dive into SAFe integration</summary>

This harness maps SAFe roles to AI agents:

| SAFe Role                | Agent            | Responsibility                    |
| ------------------------ | ---------------- | --------------------------------- |
| Business Systems Analyst | BSA              | Requirements, acceptance criteria |
| System Architect         | System Architect | Architecture decisions, ADRs      |
| Product Owner            | POPM (human)     | Final approval on deliverables    |
| Scrum Master             | TDM              | Coordination, blocker escalation  |
| Release Train Engineer   | RTE              | CI/CD, release coordination       |

### SAFe Concepts Implemented

- **Epic → Feature → Story → Enabler** hierarchy in specs
- **Sprint cycles** with velocity tracking
- **Evidence-based delivery** with Linear integration
- **Specs-driven workflow** - BSA plans, developers execute


</details>

---

## The 11-Agent Team

| Agent             | Role                    | When to Use               |
| ----------------- | ----------------------- | ------------------------- |
| BSA               | Requirements & specs    | Starting any feature      |
| System Architect  | Architecture review     | Significant changes       |
| FE Developer      | Frontend implementation | UI components             |
| BE Developer      | Backend implementation  | API routes, server logic  |
| Data Engineer     | Database & migrations   | Schema changes            |
| QAS               | Quality assurance       | Test validation           |
| Security Engineer | Security validation     | RLS, vulnerability checks |
| Tech Writer       | Documentation           | Guides, technical content |
| DPE               | Data provisioning       | Test data, seeds          |
| RTE               | Release coordination    | CI/CD, deployments        |
| TDM               | Coordination            | Blockers, escalation      |

See [AGENTS.md](AGENTS.md) for complete reference with invocation examples.

---

## Domain Adaptation Guide

The harness patterns work beyond software engineering:

### Marketing Team Example

| SWE Concept     | Marketing Adaptation  |
| --------------- | --------------------- |
| BSA (specs)     | Campaign Brief Writer |
| Code Review     | Asset Review          |
| `/pre-pr`       | `/pre-launch`         |
| Pattern Library | Brand Guidelines      |

### Research Team Example

| SWE Concept   | Research Adaptation  |
| ------------- | -------------------- |
| User Stories  | Research Questions   |
| Test Cases    | Validation Criteria  |
| CI/CD         | Peer Review Pipeline |
| Documentation | Literature Notes     |

---

## What Makes This Different

### Round Table Philosophy

Human and AI input have equal weight. No hierarchy, just expertise.

### Stop-the-Line Authority

Any agent can halt work for architectural or security concerns.

### Pattern Discovery Protocol

"Search First, Reuse Always, Create Only When Necessary"

### Evidence-Based Delivery

All work requires verifiable evidence. No "trust me, it works."

---

## vNext Workflow Contract (v1.4)

> **Note from the Author**: It became apparent early on that some of the autonomy and alignment we'd lost in our original harness was not going to work. This re-introduces strong solo and larger orchestration hats with selection criteria. Gates for QAS cover all scenarios.

### Complete Agent Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                        SAFe AGENTIC WORKFLOW - vNext                                     │
└─────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────┐
                                    │  USER/POPM   │
                                    │  Creates     │
                                    │  Linear      │
                                    │  Ticket      │
                                    └──────┬───────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │         BSA            │
                              │  • Defines AC/DoD      │
                              │  • Pattern discovery   │
                              │  • Creates spec        │
                              └────────────┬───────────┘
                                           │
                        ┌──────────────────┴──────────────────┐
                        │       STOP-THE-LINE GATE            │
                        │  AC/DoD exists? YES → Proceed       │
                        │                 NO  → STOP          │
                        └──────────────────┬──────────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    ▼                      ▼                      ▼
          ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
          │  BE-DEVELOPER   │    │  FE-DEVELOPER   │    │  DATA-ENGINEER  │
          │  Exit: "Ready   │    │  Exit: "Ready   │    │  Exit: "Ready   │
          │   for QAS"      │    │   for QAS"      │    │   for QAS"      │
          └────────┬────────┘    └────────┬────────┘    └────────┬────────┘
                   └──────────────────────┼──────────────────────┘
                                          ▼
                        ┌─────────────────────────────────┐
                        │        QAS (GATE OWNER)         │
                        │  • Iteration authority          │
                        │  • Bounce back repeatedly       │
                        │  • Final evidence to Linear     │
                        │  Exit: "Approved for RTE"       │
                        └────────────┬────────────────────┘
                                     ▼
                        ┌─────────────────────────────────┐
                        │        RTE (PR SHEPHERD)        │
                        │  • PR creation (from spec)      │
                        │  • CI/CD monitoring             │
                        │  • NO code, NO merge            │
                        │  Exit: "Ready for HITL Review"  │
                        └────────────┬────────────────────┘
                                     ▼
                    ┌─────────────────────────────────────────────┐
                    │           3-STAGE PR REVIEW                 │
                    │  Stage 1: System Architect (pattern)        │
                    │  Stage 2: ARCHitect-in-CLI (architecture)   │
                    │  Stage 3: HITL ({{AUTHOR_NAME}}) → MERGE              │
                    └─────────────────────────────────────────────┘
```

### Exit States

```
┌─────────────────┬───────────────────────────────────────────┐
│ Role            │ Exit State                                │
├─────────────────┼───────────────────────────────────────────┤
│ BE-Developer    │ "Ready for QAS"                           │
│ FE-Developer    │ "Ready for QAS"                           │
│ Data-Engineer   │ "Ready for QAS"                           │
│ QAS             │ "Approved for RTE"                        │
│ RTE             │ "Ready for HITL Review"                   │
│ System Architect│ "Stage 1 Approved - Ready for ARCHitect"  │
│ HITL            │ MERGED                                    │
└─────────────────┴───────────────────────────────────────────┘
```

### Gate Quick Reference

```
┌─────────────────┬─────────────────┬─────────────────────────┐
│ Gate            │ Owner           │ Blocking?               │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Stop-the-Line   │ Implementer     │ YES - no AC = no work   │
│ QAS Gate        │ QAS             │ YES - no approval = stop│
│ Stage 1 Review  │ System Architect│ YES - pattern check     │
│ Stage 2 Review  │ ARCHitect-CLI   │ YES - architecture check│
│ HITL Merge      │ {{AUTHOR_NAME}}            │ YES - final authority   │
└─────────────────┴─────────────────┴─────────────────────────┘
```

### Role Collapsing ({{TICKET_PREFIX}}-499)

```
┌─────────────────────────────────────────────────────────────┐
│                  ROLE COLLAPSING AUTHORITY                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  COLLAPSIBLE:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ RTE (Release Train Engineer)                         │   │
│  │ • PR creation can be done by implementer             │   │
│  │ • Use when: Simple PRs, single-agent work            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  NOT COLLAPSIBLE (Independence Gates):                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ QAS (Quality Assurance Specialist)                   │   │
│  │ • ALWAYS spawn subagent - never self-review          │   │
│  │ • Rationale: Self-review bias, quality enforcement   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Security Engineer                                    │   │
│  │ • ALWAYS spawn subagent - never self-audit           │   │
│  │ • Rationale: Security blindness, conflict of interest│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Collapsed Workflow Example

```
Standard Workflow:
Implementer → QAS → RTE → HITL
                     │
                     └─ RTE handles PR creation

Collapsed Workflow (RTE collapsed):
Implementer → QAS → [Implementer handles PR] → HITL
               │
               └─ QAS gate ALWAYS present, never collapsed

Note: Quality gates are immutable. QAS and SecEng cannot be collapsed.
```

<details>
<summary><strong>Part 1: Core Workflow Architecture</strong> - Complete flow diagrams</summary>

### 1.1 Complete Agent Flow (Detailed)

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                        SAFe AGENTIC WORKFLOW - vNext                                    │
└─────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────┐
                                    │  USER/POPM   │
                                    │  Creates     │
                                    │  Linear      │
                                    │  Ticket      │
                                    └──────┬───────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │         BSA            │
                              │  • Defines AC/DoD      │
                              │  • Pattern discovery   │
                              │  • Creates spec        │
                              └────────────┬───────────┘
                                           │
                        ┌──────────────────┴──────────────────┐
                        │       STOP-THE-LINE GATE            │
                        │  ┌────────────────────────────────┐ │
                        │  │ AC/DoD exists?                 │ │
                        │  │  • YES → Proceed               │ │
                        │  │  • NO  → STOP, route to BSA    │ │
                        │  └────────────────────────────────┘ │
                        └──────────────────┬──────────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
                    ▼                      ▼                      ▼
          ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
          │  BE-DEVELOPER   │    │  FE-DEVELOPER   │    │  DATA-ENGINEER  │
          │                 │    │                 │    │                 │
          │  Owns:          │    │  Owns:          │    │  Owns:          │
          │  • API routes   │    │  • UI components│    │  • Schema/DB    │
          │  • Server logic │    │  • Client logic │    │  • Migrations   │
          │  • SAFe commits │    │  • SAFe commits │    │  • SAFe commits │
          │                 │    │                 │    │                 │
          │  Must NOT:      │    │  Must NOT:      │    │  Must NOT:      │
          │  • Create PRs   │    │  • Create PRs   │    │  • Create PRs   │
          │  • Merge        │    │  • Merge        │    │  • Merge        │
          │                 │    │                 │    │  • Skip ARCHitect│
          └────────┬────────┘    └────────┬────────┘    └────────┬────────┘
                   │                      │                      │
                   │    Exit: "Ready for QAS"                    │
                   └──────────────────────┼──────────────────────┘
                                          │
                                          ▼
                        ┌─────────────────────────────────┐
                        │              QAS                │
                        │         (GATE OWNER)            │
                        │                                 │
                        │  Powers:                        │
                        │  • Iteration authority          │
                        │  • Bounce back repeatedly       │
                        │  • Route to specialists         │
                        │  • Final evidence to Linear     │
                        │                                 │
                        │  Tools (Linear MCP):            │
                        │  • mcp__{{MCP_LINEAR_SERVER}}__            │
                        │      create_comment             │
                        │  • mcp__{{MCP_LINEAR_SERVER}}__            │
                        │      update_issue               │
                        │  • mcp__{{MCP_LINEAR_SERVER}}__            │
                        │      list_comments              │
                        └────────────┬────────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
                    ▼                                 ▼
          ┌─────────────────┐               ┌─────────────────┐
          │    BLOCKED      │               │    APPROVED     │
          │                 │               │                 │
          │  Routes to:     │               │  Exit State:    │
          │  • Implementer  │               │  "Approved      │
          │  • Tech Writer  │               │   for RTE"      │
          │  • Sys Architect│               │                 │
          └────────┬────────┘               └────────┬────────┘
                   │                                  │
                   │ (Loop until fixed)               │
                   └──────────────────────────────────┤
                                                      │
                                                      ▼
                              ┌─────────────────────────────────┐
                              │              RTE                │
                              │        (PR SHEPHERD)            │
                              │                                 │
                              │  Owns:                          │
                              │  • PR creation (from spec)      │
                              │  • CI/CD monitoring             │
                              │  • Evidence assembly            │
                              │  • PR metadata edits            │
                              │                                 │
                              │  Must NOT:                      │
                              │  • Write product code           │
                              │  • Merge PRs                    │
                              │  • Approve own work             │
                              └────────────┬────────────────────┘
                                           │
                                           ▼
                    ┌─────────────────────────────────────────────┐
                    │           3-STAGE PR REVIEW                 │
                    │                                             │
                    │  ┌─────────────────────────────────────┐    │
                    │  │ STAGE 1: System Architect           │    │
                    │  │  • Pattern compliance               │    │
                    │  │  • RLS enforcement                  │    │
                    │  │  • Technical validation             │    │
                    │  │  → Exit: "Stage 1 Approved"         │    │
                    │  └─────────────────┬───────────────────┘    │
                    │                    ▼                        │
                    │  ┌─────────────────────────────────────┐    │
                    │  │ STAGE 2: ARCHitect-in-CLI           │    │
                    │  │  • Comprehensive review             │    │
                    │  │  • Architecture validation          │    │
                    │  │  • Security verification            │    │
                    │  │  → Exit: "Stage 2 Approved"         │    │
                    │  └─────────────────┬───────────────────┘    │
                    │                    ▼                        │
                    │  ┌─────────────────────────────────────┐    │
                    │  │ STAGE 3: HITL ({{AUTHOR_NAME}})               │    │
                    │  │  • Final human review               │    │
                    │  │  • Merge authority                  │    │
                    │  │  → Action: MERGE                    │    │
                    │  └─────────────────────────────────────┘    │
                    └─────────────────────────────────────────────┘
```

### 1.2 Exit States Flow (with Handoff Statements)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EXIT STATE PROGRESSION                              │
└─────────────────────────────────────────────────────────────────────────────┘

  IMPLEMENTATION                QAS                   RTE                 HITL
  ─────────────                ─────                 ─────               ──────

  ┌─────────────┐         ┌─────────────┐       ┌─────────────┐     ┌─────────────┐
  │   Coding    │         │  Validating │       │  Shepherding│     │  Reviewing  │
  │   Testing   │         │  Iterating  │       │  CI/CD      │     │  Merging    │
  │   Commits   │         │  Evidence   │       │  Assembling │     │             │
  └──────┬──────┘         └──────┬──────┘       └──────┬──────┘     └──────┬──────┘
         │                       │                     │                   │
         ▼                       ▼                     ▼                   ▼
  ╔═════════════╗         ╔═════════════╗       ╔═════════════╗     ╔═════════════╗
  ║  "Ready     ║  ────▶  ║ "Approved   ║ ────▶ ║ "Ready for  ║ ──▶ ║   MERGED    ║
  ║  for QAS"   ║         ║  for RTE"   ║       ║ HITL Review"║     ║             ║
  ╚═════════════╝         ╚═════════════╝       ╚═════════════╝     ╚═════════════╝
         │                       │                     │
         │                       │                     │
         ▼                       ▼                     ▼
  ┌─────────────┐         ┌─────────────┐       ┌─────────────┐
  │ Handoff     │         │ Handoff     │       │ Handoff     │
  │ Statement:  │         │ Statement:  │       │ Statement:  │
  │             │         │             │       │             │
  │ "BE/FE/DE   │         │ "QAS valid- │       │ "PR #XXX    │
  │ impl done   │         │ ation done  │       │ ready for   │
  │ for {{TICKET_PREFIX}}-X.  │         │ for {{TICKET_PREFIX}}-X.  │       │ HITL review.│
  │ All valid-  │         │ All PASSED. │       │ CI green,   │
  │ ation pass. │         │ Approved    │       │ reviews     │
  │ AC/DoD      │         │ for RTE."   │       │ complete."  │
  │ confirmed.  │         │             │       │             │
  │ Ready for   │         │             │       │             │
  │ QAS."       │         │             │       │             │
  └─────────────┘         └─────────────┘       └─────────────┘
```

### 1.3 Stop-the-Line Gate (Mandatory)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      STOP-THE-LINE GATE (MANDATORY)                         │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │  TICKET ARRIVES │
                              │  (Linear {{TICKET_PREFIX}}-X) │
                              └────────┬────────┘
                                       │
                                       ▼
                         ┌─────────────────────────┐
                         │   CHECK: AC/DoD EXISTS? │
                         └────────────┬────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │                                   │
                    ▼                                   ▼
          ┌─────────────────┐                 ┌─────────────────┐
          │       YES       │                 │        NO       │
          │                 │                 │                 │
          │  AC/DoD is      │                 │  AC/DoD missing │
          │  defined and    │                 │  or unclear     │
          │  clear          │                 │                 │
          └────────┬────────┘                 └────────┬────────┘
                   │                                   │
                   ▼                                   ▼
          ┌─────────────────┐                 ╔═════════════════╗
          │    PROCEED      │                 ║   FULL STOP     ║
          │                 │                 ║                 ║
          │  Begin          │                 ║  • Do NOT       ║
          │  implementation │                 ║    proceed      ║
          │                 │                 ║                 ║
          │                 │                 ║  • Route back   ║
          │                 │                 ║    to BSA/POPM  ║
          │                 │                 ║                 ║
          │                 │                 ║  • You are NOT  ║
          │                 │                 ║    responsible  ║
          │                 │                 ║    for inventing║
          │                 │                 ║    AC/DoD       ║
          └─────────────────┘                 ╚═════════════════╝


  ┌───────────────────────────────────────────────────────────────────────────┐
  │  POLICY: Implementation agents (BE/FE/DE) must verify AC/DoD exists      │
  │          before starting ANY work. This is a hard gate, not optional.    │
  └───────────────────────────────────────────────────────────────────────────┘
```

### 1.4 QAS Iteration Loop

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QAS ITERATION AUTHORITY                             │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │  WORK ARRIVES   │
                              │  "Ready for QAS"│
                              └────────┬────────┘
                                       │
                                       ▼
                         ┌─────────────────────────┐
                         │   QAS VALIDATES WORK    │
                         │                         │
                         │  • Run test suites      │
                         │  • Check AC/DoD         │
                         │  • Verify evidence      │
                         │  • Review documentation │
                         └────────────┬────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │                                   │
                    ▼                                   ▼
          ┌─────────────────┐                 ┌─────────────────┐
          │   ALL PASS ✓    │                 │   ISSUES FOUND  │
          │                 │                 │                 │
          │  • Tests pass   │                 │  • Tests fail   │
          │  • AC/DoD met   │                 │  • AC incomplete│
          │  • Evidence OK  │                 │  • Docs missing │
          │  • Docs match   │                 │  • Pattern issue│
          └────────┬────────┘                 └────────┬────────┘
                   │                                   │
                   ▼                                   ▼
          ╔═════════════════╗                 ┌─────────────────┐
          ║    APPROVED     ║                 │     BLOCKED     │
          ║                 ║                 │                 │
          ║  Post evidence  ║                 │  Route to:      │
          ║  to Linear      ║                 │                 │
          ║                 ║                 │  ┌───────────┐  │
          ║  Exit: "Approved║                 │  │Code bugs  │──┼──▶ @be-developer
          ║  for RTE"       ║                 │  └───────────┘  │     @fe-developer
          ╚═════════════════╝                 │  ┌───────────┐  │
                                              │  │Validation │──┼──▶ Implementer
                                              │  │fails      │  │
                                              │  └───────────┘  │
                                              │  ┌───────────┐  │
                                              │  │Doc gaps   │──┼──▶ @tech-writer
                                              │  └───────────┘  │
                                              │  ┌───────────┐  │
                                              │  │Pattern    │──┼──▶ @system-architect
                                              │  │violation  │  │
                                              │  └───────────┘  │
                                              │  ┌───────────┐  │
                                              │  │AC/DoD     │──┼──▶ @bsa
                                              │  │missing    │  │
                                              │  └───────────┘  │
                                              └────────┬────────┘
                                                       │
                                                       │ (Fix and return)
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │  REPEAT UNTIL   │
                                              │  ALL PASS       │
                                              │                 │
                                              │  QAS has full   │
                                              │  iteration      │
                                              │  authority      │
                                              └─────────────────┘
```

</details>

<details>
<summary><strong>Part 2: Role Definitions</strong> - Contract specifications for each role</summary>

### 2.1 Role Ownership Matrix

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              ROLE OWNERSHIP MATRIX                                      │
├─────────────────┬───────────────────────────────────────────────────────────────────────┤
│                 │                           RESPONSIBILITIES                            │
│      ROLE       ├───────────┬───────────┬───────────┬───────────┬───────────┬──────────┤
│                 │   CODE    │  COMMITS  │    PR     │   MERGE   │  EVIDENCE │   GATE   │
├─────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼──────────┤
│ BE-Developer    │    ✓      │    ✓      │    ✗      │    ✗      │  Partial  │    ✗     │
│ FE-Developer    │    ✓      │    ✓      │    ✗      │    ✗      │  Partial  │    ✗     │
│ Data-Engineer   │    ✓      │    ✓      │    ✗      │    ✗      │  Partial  │    ✗     │
├─────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼──────────┤
│ QAS             │    ✗      │    ✗      │    ✗      │    ✗      │    ✓      │    ✓     │
├─────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼──────────┤
│ RTE             │    ✗      │  Metadata │    ✓      │    ✗      │  Assembly │    ✗     │
├─────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼──────────┤
│ System Architect│  Review   │    ✗      │  Stage 1  │    ✗      │  Review   │  Stage 1 │
│ ARCHitect-CLI   │  Review   │    ✗      │  Stage 2  │    ✗      │  Review   │  Stage 2 │
├─────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼──────────┤
│ HITL ({{AUTHOR_NAME}})    │  Review   │    ✗      │  Stage 3  │    ✓      │  Final    │  Stage 3 │
└─────────────────┴───────────┴───────────┴───────────┴───────────┴───────────┴──────────┘

Legend:
  ✓ = Owns/Authorized
  ✗ = Not Authorized
  Partial = Captures during work, QAS collects
  Review = Read-only review authority
  Metadata = PR title, labels, body only (not code)
  Assembly = Collects from all agents
```

### 2.2 Implementation Agents Contract (BE/FE/DE)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION AGENT CONTRACT                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PRECONDITION (Mandatory Gate):                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Verify AC/DoD exists → If missing, STOP and route to BSA/POPM      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  OWNS:                                     MUST NOT:                        │
│  ├─ Code changes                           ├─ Create PRs                    │
│  ├─ Atomic SAFe commits                    ├─ Merge to dev/master           │
│  └─ Local validation                       └─ Invent AC/DoD                 │
│                                                                             │
│  MUST DO:                                                                   │
│  ├─ Run validation loop until ALL pass                                      │
│  ├─ Confirm ALL AC/DoD satisfied                                            │
│  ├─ Commit own work (SAFe format)                                           │
│  └─ Provide handoff statement                                               │
│                                                                             │
│  EXIT STATE: "Ready for QAS"                                                │
│                                                                             │
│  HANDOFF TEMPLATE:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "[BE/FE/DE] implementation complete for {{TICKET_PREFIX}}-XXX.                   │   │
│  │   All validation passing. AC/DoD confirmed.                         │   │
│  │   Ready for QAS review."                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 QAS Gate Owner Contract

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QAS GATE OWNER CONTRACT                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ROLE: GATE (not just validator)                                            │
│  ───────────────────────────────                                            │
│  Work does NOT proceed without QAS approval.                                │
│                                                                             │
│  OWNS:                                     MUST NOT:                        │
│  ├─ Independent verification               ├─ Modify product code           │
│  ├─ Iteration authority                    ├─ Skip AC/DoD verification      │
│  ├─ QA artifacts                           └─ Approve incomplete work       │
│  └─ Final evidence to Linear                                                │
│                                                                             │
│  LINEAR MCP TOOLS:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • mcp__{{MCP_LINEAR_SERVER}}__create_comment  (post evidence)                 │   │
│  │  • mcp__{{MCP_LINEAR_SERVER}}__update_issue    (update status)                 │   │
│  │  • mcp__{{MCP_LINEAR_SERVER}}__list_comments   (read context)                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ROUTING AUTHORITY:                                                         │
│  ┌────────────────┬──────────────────┬───────────────────────────────┐     │
│  │ Issue Type     │ Route To         │ Action                        │     │
│  ├────────────────┼──────────────────┼───────────────────────────────┤     │
│  │ Code bugs      │ @be/fe-developer │ Return with specific issues   │     │
│  │ Validation fail│ Implementer      │ Return with failure output    │     │
│  │ Doc mismatch   │ @tech-writer     │ Route for documentation fix   │     │
│  │ Pattern issue  │ @system-architect│ Escalate for pattern review   │     │
│  │ AC/DoD missing │ @bsa             │ Cannot approve without AC     │     │
│  └────────────────┴──────────────────┴───────────────────────────────┘     │
│                                                                             │
│  EXIT STATE: "Approved for RTE"                                             │
│                                                                             │
│  HANDOFF TEMPLATE:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "QAS validation complete for {{TICKET_PREFIX}}-XXX.                              │   │
│  │   All criteria PASSED. Evidence posted to Linear.                   │   │
│  │   Approved for RTE."                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.4 RTE PR Shepherd Contract

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RTE PR SHEPHERD CONTRACT                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PREREQUISITE (QAS Gate):                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Work MUST have QAS approval ("Approved for RTE" status)            │   │
│  │  Evidence MUST be posted to Linear                                  │   │
│  │  If QAS not approved → STOP and wait                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  OWNS:                                     MUST NOT (NEVER):                │
│  ├─ PR creation (from spec)                ├─ Merge PRs (HITL only)         │
│  ├─ CI/CD monitoring                       ├─ Write product code            │
│  ├─ Evidence assembly                      ├─ Approve own work              │
│  ├─ PR metadata (title, labels, body)      └─ Have merge cmd examples       │
│  └─ Coordination between agents                                             │
│                                                                             │
│  IF CI FAILS:                                                               │
│  ┌────────────────────────────┬─────────────────────────────────────┐      │
│  │ Failure Type               │ Route To                            │      │
│  ├────────────────────────────┼─────────────────────────────────────┤      │
│  │ Structural/pattern issues  │ System Architect                    │      │
│  │ Implementation bugs        │ Original implementer (BE/FE/DE)     │      │
│  │ NEVER fix code yourself    │ ---                                 │      │
│  └────────────────────────────┴─────────────────────────────────────┘      │
│                                                                             │
│  EXIT STATE: "Ready for HITL Review"                                        │
│                                                                             │
│  HANDOFF TEMPLATE:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "PR #XXX for {{TICKET_PREFIX}}-YYY is Ready for HITL Review.                     │   │
│  │   All CI green, reviews complete, evidence attached.                │   │
│  │   Awaiting final merge approval from {{AUTHOR_NAME}}."                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.5 System Architect Stage 1 Contract

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SYSTEM ARCHITECT STAGE 1 CONTRACT                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ROLE: Stage 1 of 3-Stage PR Review Process                                 │
│  ───────────────────────────────────────────                                │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Stage 1: System Architect (you) - Technical/pattern validation     │   │
│  │  Stage 2: ARCHitect-in-CLI - Comprehensive review                   │   │
│  │  Stage 3: HITL ({{AUTHOR_NAME}}) - Final merge authority                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  OWNS:                                     MUST NOT:                        │
│  ├─ Pattern compliance review              ├─ Merge PRs                     │
│  ├─ RLS enforcement verification           ├─ Skip to Stage 3               │
│  ├─ Architecture validation                └─ Approve security bypasses     │
│  └─ Stage 1 gate authority                                                  │
│                                                                             │
│  VALIDATION CHECKLIST:                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [ ] RLS context enforced (no direct Prisma calls)                  │   │
│  │  [ ] withUserContext/withAdminContext/withSystemContext used        │   │
│  │  [ ] Authentication checks present                                  │   │
│  │  [ ] Pattern library followed                                       │   │
│  │  [ ] TypeScript types valid                                         │   │
│  │  [ ] Error handling comprehensive                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  EXIT STATE: "Stage 1 Approved - Ready for ARCHitect"                       │
│                                                                             │
│  HANDOFF TEMPLATE:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "Stage 1 review complete for PR #XXX ({{TICKET_PREFIX}}-YYY).                    │   │
│  │   Pattern compliance verified, RLS enforced.                        │   │
│  │   Approved for ARCHitect-in-CLI review (Stage 2)."                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Routing Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ROUTING CHEAT SHEET                                │
├─────────────────┬───────────────────────────────────────────────────────────┤
│ Issue           │ Route To                                                  │
├─────────────────┼───────────────────────────────────────────────────────────┤
│ Code bugs       │ @be-developer / @fe-developer                             │
│ Validation fail │ Original implementer                                      │
│ Doc mismatch    │ @tech-writer                                              │
│ Pattern issue   │ @system-architect                                         │
│ AC/DoD missing  │ @bsa                                                      │
│ CI failure      │ Implementer (code) or Architect (infra)                   │
│ Blocked > 4hrs  │ @tdm                                                      │
└─────────────────┴───────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary><strong>What Changed and Why</strong> - vNext Contract Changelog</summary>

### Why This Upgrade Matters

This contract establishes **proper SAFe governance for an AI agent team** - treating agents as
accountable team members with clear boundaries, not autonomous actors.

### Key Changes Summary

| Category        | Before                 | After                                        | Why                                           |
| --------------- | ---------------------- | -------------------------------------------- | --------------------------------------------- |
| AC/DoD Check    | Optional/informal      | **Stop-the-Line Gate** (mandatory)           | Agents shouldn't invent requirements          |
| QAS Role        | Report producer        | **Gate Owner** with iteration authority      | Quality is enforced, not just documented      |
| RTE Role        | Could touch code/merge | **PR shepherd only** (no code, no merge)     | Clear separation of concerns                  |
| Exit States     | Informal "done"        | Explicit states per role                     | Clear chain of custody                        |
| Evidence        | Scattered              | **Linear as system of record**               | Auditable, traceable delivery                 |
| PR Review       | Undefined stages       | **3-stage process**                          | Layered review with clear ownership           |
| Role Collapsing | Not defined            | **{{TICKET_PREFIX}}-499**: RTE collapsible, QAS/SecEng not | Flexibility with safety                       |

### Detailed File Changes

**Harness Files Updated (10)**:

| File | Change | Rationale |
|------|--------|-----------|
| `.claude/README.md` | Added Role Execution Modes | Clarify solo vs multi-agent operation |
| `.claude/commands/start-work.md` | Added Stop-the-Line gate | Agents must verify AC/DoD exists |
| `.claude/agents/be-developer.md` | Added Precondition, Ownership, Exit | Clear boundaries for implementers |
| `.claude/agents/fe-developer.md` | Added Precondition, Ownership, Exit | Clear boundaries for implementers |
| `.claude/agents/data-engineer.md` | Added Precondition, Ownership, Exit | Clear boundaries for implementers |
| `.claude/agents/qas.md` | Upgraded to Gate Owner + Linear MCP | QAS is a gate, not just validator |
| `.claude/agents/rte.md` | Added QAS prerequisite, removed merge | RTE shepherds, doesn't merge |
| `.claude/agents/system-architect.md` | Added Stage 1 review role | First stage of 3-stage review |
| `.claude/commands/search-pattern.md` | Added Grep tool parameters | Better pattern search UX |
| `.claude/skills/orchestration-patterns/SKILL.md` | Fixed command references | Documentation accuracy |

**New Documentation Added (4)**:

| File | Purpose |
|------|---------|
| `docs/sop/AGENT_CONFIGURATION_SOP.md` | Tool restrictions, model selection per role |
| `docs/guides/AGENT_TEAM_GUIDE.md` | Comprehensive agent team reference |
| `docs/workflow/WORKFLOW_COMPARISON.md` | TDM role clarification (coordinator, not orchestrator) |
| `docs/workflow/WORKFLOW_MIGRATION_GUIDE.md` | Guide for transitioning to vNext |

**Project Docs Updated (6)**:

| File | Change |
|------|--------|
| `AGENTS.md` | Exit States table, role updates |
| `README.md` | vNext workflow diagrams, Author's Note |
| `CONTRIBUTING.md` | Exit States, Gate Reference, Role Collapsing |
| `docs/sop/AGENT_WORKFLOW_SOP.md` | v1.4 with vNext sections |
| `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md` | v1.4 updates |
| `docs/workflow/ARCHITECT_IN_CLI_ROLE.md` | Role Collapsing Authority |

### Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-23 | Claude Code (Opus 4.5) | Initial vNext contract (Phases 1-2) |
| 1.1 | 2025-12-23 | Claude Code (Opus 4.5) | Phase 3 docs + errata |
| 1.2 | 2025-12-23 | Claude Code (Opus 4.5) | Alignment fixes (TDM role, QAS write policy) |
| 1.3 | 2025-12-23 | Claude Code (Opus 4.5) | {{TICKET_PREFIX}}-499: Role collapsing policy |

### Source Document

Full knowledge transfer document: [{{TICKET_PREFIX}}-497-vnext-workflow-contract-kt.md](https://github.com/{{GITHUB_ORG}}/{{PROJECT_SHORT}}-app/blob/main/docs/agent-outputs/technical-docs/{{TICKET_PREFIX}}-497-vnext-workflow-contract-kt.md)

</details>

<details>
<summary><strong>Appendix A: Quick Reference Cards</strong> - Printable cheat sheets</summary>

### A.1 Exit State Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    EXIT STATE CHEAT SHEET                   │
├─────────────────┬───────────────────────────────────────────┤
│ Role            │ Exit State                                │
├─────────────────┼───────────────────────────────────────────┤
│ BE-Developer    │ "Ready for QAS"                           │
│ FE-Developer    │ "Ready for QAS"                           │
│ Data-Engineer   │ "Ready for QAS"                           │
│ QAS             │ "Approved for RTE"                        │
│ RTE             │ "Ready for HITL Review"                   │
│ System Architect│ "Stage 1 Approved - Ready for ARCHitect"  │
│ ARCHitect-CLI   │ "Stage 2 Approved - Ready for HITL"       │
│ HITL            │ MERGED                                    │
└─────────────────┴───────────────────────────────────────────┘
```

### A.2 Gate Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                      GATE CHEAT SHEET                       │
├─────────────────┬─────────────────┬─────────────────────────┤
│ Gate            │ Owner           │ Blocking?               │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Stop-the-Line   │ Implementer     │ YES - no AC = no work   │
│ QAS Gate        │ QAS             │ YES - no approval = stop│
│ Stage 1 Review  │ System Architect│ YES - pattern check     │
│ Stage 2 Review  │ ARCHitect-CLI   │ YES - architecture check│
│ HITL Merge      │ {{AUTHOR_NAME}}            │ YES - final authority   │
└─────────────────┴─────────────────┴─────────────────────────┘
```

### A.3 Routing Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    ROUTING CHEAT SHEET                      │
├─────────────────┬───────────────────────────────────────────┤
│ Issue           │ Route To                                  │
├─────────────────┼───────────────────────────────────────────┤
│ Code bugs       │ @be-developer / @fe-developer             │
│ Validation fail │ Original implementer                      │
│ Doc mismatch    │ @tech-writer                              │
│ Pattern issue   │ @system-architect                         │
│ AC/DoD missing  │ @bsa                                      │
│ CI failure      │ Implementer (code) or Architect (infra)   │
│ Blocked > 4hrs  │ @tdm                                      │
└─────────────────┴───────────────────────────────────────────┘
```

</details>

See [Agent Workflow SOP v1.4](docs/sop/AGENT_WORKFLOW_SOP.md) for complete details.

---

## Important Caveats

**Version 2.5** - Production-tested but with known limitations:

- **Production validated**: 5+ months, 169 issues, 2,193 commits (Claude Code)
- **Multi-provider**: Supports Claude Code and Gemini CLI
- **Generalized**: Placeholders for project-specific values
- **Single-team validation**: Multi-team scalability not yet proven
- **Gemini CLI maturing**: Gemini CLI harness aligned with v0.32.1 (March 2026), less production-tested than Claude Code
- **Domain examples**: Non-SWE adaptations are theoretical (documented, not validated)

See project documentation for honest assessment of limitations.

---

## Repository Structure

```text
.claude/                 # Claude Code harness configuration
├── commands/            # 23 slash commands for workflow automation
├── skills/              # 18 model-invoked skills for domain expertise
├── agents/              # 11 SAFe agent profiles
├── team-config.json     # Agent Teams settings (optional, experimental)
└── SETUP.md             # Installation and customization guide

.gemini/                 # Gemini CLI harness configuration
├── commands/            # 29 TOML commands (namespaced: /workflow:*, /local:*, /remote:*, /media:*)
├── skills/              # 17 model-invoked skills (team-coordination is Claude-only)
├── settings.json        # Configuration (model, hooks, policy, security)
├── GEMINI.md            # System instructions
└── README.md            # Gemini-specific setup guide

docs/                    # Additional documentation
├── whitepapers/         # Harness architecture and philosophy
└── onboarding/          # Getting started guides
```

---

## Meta-Note: Self-Validation

This methodology was **validated by itself**: 7 SAFe agents performed meta-circular validation of the harness documentation and caught critical fabricated data before publication.


**The methodology caught its own problems.** That's the proof it works.

---

## Citation

Download: [CITATION.bib](CITATION.bib) | [CITATION.cff](CITATION.cff)

### APA 7th Edition

```text
{{AUTHOR_LAST_NAME}}, {{AUTHOR_INITIALS}}, & {{PROJECT_SHORT}} Development Team. (2025). Evidence-based multi-agent
development: A SAFe framework implementation with Claude Code [White paper].
https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}
```

---

## Contributing

We welcome contributions:

- **Patterns**: Share production-tested patterns
- **Case Studies**: Document your implementation experience
- **Research**: Explore open questions from Section 10
- **Improvements**: Suggest methodology enhancements

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Attribution

This project is the **Words To Film By™** multi-agent harness, adapted for SAFe development workflows.

**Creator**: J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) - [jscottgraham.us](https://jscottgraham.us)
**Organization**: [ByBren, LLC](https://github.com/bybren-llc)
**Enterprise**: [Words To Film By™](https://wordstofilmby.com)

If you use this harness in your own projects, you must include attribution.
See [NOTICE](NOTICE) for details.

**Historical Context**: Evolved from [Auggie's Architect Handbook](https://github.com/cheddarfox/auggies-architect-handbook)

---

<p align="center">
  <strong>Words To Film By™</strong><br>
  <a href="https://wordstofilmby.com">Website</a> •
  <a href="mailto:scott@wordstofilmby.com">Contact</a> •
  <a href="https://github.com/sponsors/bybren-llc">Sponsor</a>
</p>

<p align="center">
  <em>"Your AI team, ready to work."</em>
</p>

<p align="center">
  <strong>Version</strong>: {{HARNESS_VERSION}} (March 2026)<br>
  <strong>Status</strong>: Production-validated, multi-provider (Claude Code + Gemini CLI)
</p>
