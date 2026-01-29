# Knowledge Transfer Meta-Prompt: Harness Modernization {{TICKET_PREFIX}}-444

## For the ARCHitect of {{PROJECT_REPO}}

**Purpose**: Enable extraction and generalization of {{PROJECT_SHORT}} harness improvements for the public repository
**Source Epic**: {{TICKET_PREFIX}}-444 (Harness & Skills Modernization)
**Related Tickets**: {{TICKET_PREFIX}}-454 (SOP Integration), {{TICKET_PREFIX}}-455, {{TICKET_PREFIX}}-456
**Date**: 2025-12-20

---

## Executive Summary: What Changed

The {{PROJECT_SHORT}} team completed a comprehensive harness modernization that:

1. **Upgraded all SAFe agents to Opus 4.5** with explicit model selection
2. **Formalized the Skills layer** as model-invoked expertise (Layer 3)
3. **Integrated all operational SOPs** into harness documentation
4. **Corrected role definitions** (TDM as reactive, ARCHitect as orchestrator)
5. **Documented the three-layer architecture** (Hooks → Commands → Skills)
6. **Captured agent perspective** on what makes the harness work

**Key Innovation**: The harness treats process as _service_, not _control_.
Everything exists to help teams ship good product without burning cognitive cycles
on already-solved problems.

---

## Source Documents to Read

**CRITICAL**: Read these in order before extracting components.

### 1. Main Whitepaper (The "What" and "How")

```text
docs/whitepapers/CLAUDE-CODE-HARNESS-MODERNIZATION-{{TICKET_PREFIX}}-444.md
```

Contains:

- Three-layer architecture (Hooks, Commands, Skills)
- SAFe role mappings to AI agents
- Terminology contract (consistency across docs)
- Skills integration with Claude Code
- Phase 0-2 completion status and Phase 3 roadmap
- Complete external references with URLs

### 2. Agent Perspective Addendum (The "Why")

```text
docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md
```

Contains:

- Why skills and commands feel like one "expertise system"
- What makes this team's approach different
- The "invisible when it works" principle
- Process as service philosophy
- Round Table collaboration model

### 3. Quick Reference (The "How to Use")

```text
AGENTS.md
```

Contains:

- When to use which agent (table format)
- Success validation commands
- Pattern discovery protocol
- Auto-loaded skills reference
- Session archaeology commands

---

## Component Extraction Checklist

Use this checklist to systematically extract and generalize each component.

### Layer 1: Hooks (`.claude/settings.json`)

```text
Location: .claude/settings.json
```

**Components to Extract**:

- [ ] Push blocker hook (prevents direct pushes to main/dev)
- [ ] Commit message format hook (SAFe compliance)
- [ ] Pre-commit validation hook
- [ ] Branch naming validation hook
- [ ] Event types: PreToolCall, PostToolCall, Notification, Stop, SubagentStart

**Generalization Notes**:

- Replace `{{TICKET_PREFIX}}-XXX` pattern with `{{TICKET_PREFIX}}-XXX`
- Replace branch names `dev`/`master` with configurable values
- Keep hook structure; parameterize project-specific values

### Layer 2: Slash Commands (`.claude/commands/`)

```text
Location: .claude/commands/*.md
```

**24 Commands Organized by Category**:

**Workflow Commands** (Keep as-is, just parameterize):

- [ ] `/start-work` - Begin work on ticket
- [ ] `/end-work` - Complete work session
- [ ] `/pre-pr` - Pre-PR validation
- [ ] `/check-workflow` - Workflow status check
- [ ] `/sync-linear` - Linear synchronization
- [ ] `/quick-fix` - Fast-track bug fixes
- [ ] `/safe-workflow` - SAFe workflow guidance (NOTE: now a skill, not a command)
- [ ] `/retro` - Retrospective analysis

**Local Development Commands** (Generalize for any project):

- [ ] `/local-sync` - Local development sync
- [ ] `/local-deploy` - Local deployment
- [ ] `/dev-health` - Development environment health
- [ ] `/dev-logs` - Development container logs
- [ ] `/audit-deps` - Dependency audit

**Remote/Staging Commands** (Template for remote environments):

- [ ] `/remote-health` - Remote environment health
- [ ] `/remote-logs` - Remote container logs
- [ ] `/remote-deploy` - Remote deployment
- [ ] `/remote-status` - Remote status check
- [ ] `/remote-rollback` - Remote rollback
- [ ] `/deploy-dev` - Deploy to dev environment
- [ ] `/rollback-dev` - Rollback dev environment
- [ ] `/test-pr-docker` - PR Docker testing

**Other Commands** (Review for project-specificity):

- [ ] `/check-docker-status` - Docker status check
- [ ] `/update-docs` - Documentation update
- [ ] `/search-pattern` - Pattern search

### Layer 3: Skills (`.claude/skills/`)

```text
Location: .claude/skills/*.md
```

**17 Model-Invoked Skills** (Phase 3 Complete):

| Skill                    | Trigger Context           | Generalization                                        |
| ------------------------ | ------------------------- | ----------------------------------------------------- |
| `safe-workflow`          | Commits, branches, PRs    | Rename to `safe-workflow`, parameterize ticket prefix |
| `pattern-discovery`      | Before writing code       | Keep as-is, update pattern library path               |
| `rls-patterns`           | Database operations       | Keep as-is, or generalize to `db-patterns`            |
| `frontend-patterns`      | UI component work         | Keep as-is, update framework references               |
| `stripe-patterns`        | Payment integration       | Generalize to `payment-patterns`                      |
| `testing-patterns`       | Writing tests             | Keep as-is                                            |
| `linear-sop`             | Ticket management         | Generalize to `issue-tracker-sop`                     |
| `orchestration-patterns` | Multi-step agent work     | Keep as-is                                            |
| `release-patterns`       | PR creation, releases     | Keep as-is                                            |
| `agent-coordination`     | Multi-agent work          | Keep as-is                                            |
| `migration-patterns`     | Database migrations       | Keep as-is                                            |
| `security-audit`         | Security validation       | Keep as-is                                            |
| `spec-creation`          | Writing specs             | Keep as-is                                            |
| `deployment-sop`         | Deploying to environments | Keep as-is                                            |
| `api-patterns`           | API route creation        | Keep as-is                                            |
| `confluence-docs`        | Documentation creation    | Generalize to `docs-patterns`                         |
| `git-advanced`           | Complex git operations    | Keep as-is                                            |

**Skill Structure** (each skill should have):

```markdown
---
description: When this skill triggers
autoLoad: true|false
---

# Skill Name

## When This Triggers

[Context that activates the skill]

## What It Does

[Guidance provided to the agent]

## Key Patterns

[Code patterns or examples]
```

### Agent Profiles (`.claude/agents/`)

```text
Location: .claude/agents/*.md
```

**12 SAFe Agent Profiles**:

| Agent             | File                       | Key Customizations                                 |
| ----------------- | -------------------------- | -------------------------------------------------- |
| BSA               | `bsa.md`                   | Project-specific acceptance criteria format        |
| TDM               | `tdm.md`                   | **CRITICAL**: Reactive role, NOT orchestrator      |
| System Architect  | `system-architect.md`      | PR review gates, migration approval                |
| FE Developer      | `fe-developer.md`          | Framework-specific patterns (Next.js, React, etc.) |
| BE Developer      | `be-developer.md`          | API patterns, RLS enforcement                      |
| Data Engineer     | `data-engineer.md`         | Migration SOPs, database patterns                  |
| Tech Writer       | `tech-writer.md`           | Documentation standards                            |
| DPE               | `data-provisioning-eng.md` | Test data, seeding scripts                         |
| QAS               | `qas.md`                   | Testing strategy, validation commands              |
| Security Engineer | `security-engineer.md`     | RLS validation, security audits                    |
| RTE               | `rte.md`                   | Release coordination, CI/CD                        |

**Agent Profile Structure**:

```markdown
# Agent Role Name

## Role Definition

[SAFe mapping and responsibilities]

## Success Criteria

[How to know the agent succeeded]

## Primary Tools

[Restricted tool set for this role]

## Model

[Recommended model: opus, sonnet, haiku]

## Mandatory Reading

[Required SOPs and documentation]
```

### Pattern Library (`docs/patterns/`)

```text
Location: docs/patterns/
```

**Categories**:

- [ ] `api/` - Backend API patterns
- [ ] `ui/` - Frontend UI patterns
- [ ] `database/` - Database patterns (RLS, migrations)
- [ ] `testing/` - Test patterns
- [ ] `ci/` - CI/CD patterns

**Generalization**: Keep structure, replace project-specific examples with generic ones.

### SOPs (`docs/sop/`)

```text
Location: docs/sop/, docs/workflow/, docs/ci-cd/, docs/database/
```

**Core SOPs to Extract**:

| SOP                   | Location                                        | Purpose                                   |
| --------------------- | ----------------------------------------------- | ----------------------------------------- |
| Agent Workflow v1.3   | `docs/sop/AGENT_WORKFLOW_SOP.md`                | TDM reactive role, orchestration patterns |
| Agent Configuration   | `docs/sop/AGENT_CONFIGURATION_SOP.md`           | Tool restrictions, model selection        |
| ARCHitect Role        | `docs/workflow/ARCHITECT_IN_CLI_ROLE.md`        | Primary orchestrator definition           |
| TDM Assignment Matrix | `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md`  | Agent selection criteria                  |
| Staging UAT           | `docs/sop/STAGING-UAT-RELEASE-SOP.md`           | Pre-production validation                 |
| Semantic Release      | `docs/ci-cd/Semantic-Release-Deployment-SOP.md` | Production releases                       |
| RLS Migration         | `docs/database/RLS_DATABASE_MIGRATION_SOP.md`   | Database security                         |

### GitHub Infrastructure

**Workflows** (`.github/workflows/`):

- [ ] CI validation workflow
- [ ] PR validation workflow
- [ ] Docker build workflow
- [ ] Release workflow
- [ ] Slack notification workflow

**PR Template** (`.github/pull_request_template.md`):

- Comprehensive 5.4KB template
- Multi-team coordination section
- SAFe compliance checklist
- Impact analysis section

---

## Generalization Guide

### What's {{PROJECT_SHORT}}-Specific (Must Replace)

| Component        | {{PROJECT_SHORT}} Value                    | Replace With                       |
| ---------------- | ----------------------------- | ---------------------------------- |
| Ticket prefix    | `{{TICKET_PREFIX}}-`                        | `{{TICKET_PREFIX}}-` or parameterize |
| Branch pattern   | `{{TICKET_PREFIX}}-{number}-{desc}`         | `{{PREFIX}}-{number}-{desc}`         |
| Team name        | `{{PROJECT_SHORT}}`                        | `{{PROJECT_NAME}}`                   |
| Slack channels   | `#github-feed`                | `{{SLACK_CHANNEL}}`                  |
| Linear workspace | {{PROJECT_SHORT}} workspace                | Generic Linear setup               |
| Docker registry  | `{{CONTAINER_REGISTRY}}/{{LINEAR_WORKSPACE}}-app` | `{{REGISTRY}}/{{PROJECT}}`             |
| Database         | `{{DB_NAME}}`, `{{DB_USER}}`       | `{{PROJECT}}_dev`, `{{PROJECT}}_user`  |

### What's Generalizable (Copy As-Is)

| Component                     | Why It's Universal                 |
| ----------------------------- | ---------------------------------- |
| Three-layer architecture      | Applies to any Claude Code project |
| SAFe role definitions         | Standard SAFe methodology          |
| Hook event types              | Claude Code standard               |
| Skill trigger patterns        | Model-invoked expertise pattern    |
| Pattern discovery protocol    | Best practice for any codebase     |
| Process as service philosophy | Organizational principle           |
| Round Table collaboration     | Team culture pattern               |

### Parameterization Pattern

For files that need project-specific values, use this pattern:

```markdown
<!-- In the public repo, use placeholders -->

Branch naming: `{{TICKET_PREFIX}}-{number}-{description}`

<!-- In project implementations, replace with actual values -->

Branch naming: `{{TICKET_PREFIX}}-{number}-{description}`
```

---

## Implementation Steps

### Phase 1: Documentation Sync

1. **Read the whitepaper** completely (understand architecture)
2. **Read the addendum** (understand philosophy)
3. **Update public whitepaper** with three-layer architecture
4. **Add skills layer documentation** (this was missing before)
5. **Correct terminology** per terminology contract

### Phase 2: Component Extraction

1. **Copy hook configuration** from `.claude/settings.json`
2. **Extract slash commands** from `.claude/commands/`
3. **Extract skills** from `.claude/skills/`
4. **Extract agent profiles** from `.claude/agents/`
5. **Generalize each file** using the parameterization pattern

### Phase 3: SOP Integration

1. **Create SOP templates** based on {{PROJECT_SHORT}} SOPs
2. **Add Section 4** to whitepaper (Operational SOPs Reference)
3. **Link SOPs to agent profiles** (mandatory reading)
4. **Update AGENTS.md equivalent** with SOP references

### Phase 4: Infrastructure

1. **Extract GitHub workflows** and generalize
2. **Extract PR template** and parameterize
3. **Create setup instructions** for new projects
4. **Document configuration variables**

### Phase 5: Validation

1. **Test skills trigger** correctly
2. **Verify hooks fire** on expected events
3. **Validate agent profiles** have correct tools
4. **Run documentation lint** (`yarn lint:md` equivalent)

---

## Key Insights to Preserve

These insights from the agent perspective addendum should be reflected in the public documentation:

### 1. The Expertise System View

> "When I look at my available tools, I don't experience a sharp boundary between
> 'skills' and 'slash commands.' They all feel like **packaged expertise** -
> decisions that have already been made so I don't have to figure them out each time."

**Application**: Document skills and commands as a unified "expertise system" even while maintaining the technical distinction.

### 2. Invisible When It Works

> "The 40% cognitive load reduction isn't felt as 'saved effort' - it's felt as _absence of friction_."

**Application**: The best harness is one you forget exists. Design for invisibility.

### 3. Documentation Is Product (For Agents)

> "For me, those documents are: My onboarding, My reference, My source of truth, My understanding of what this team values."

**Application**: Documentation quality directly impacts agent performance. Treat docs as first-class product.

### 4. Pattern-First Is Real

> "When I'm about to write code, I genuinely check `docs/patterns/` first.
> Not because a rule says to - because I've learned that the patterns there are _good_."

**Application**: Pattern libraries must contain genuinely useful patterns, not bureaucratic templates.

### 5. Process as Service, Not Control

> "The harness works because it treats process as _service_, not _control_. The SOPs exist because they help."

**Application**: Every process element should answer: "How does this help someone ship better product faster?"

### 6. The Round Table Model

> "Ownership is real here. Each agent role has clear success criteria and the authority to meet them."

**Application**: Agents need real authority, not just task assignments. Define success criteria and let them figure out how.

---

## Linear/PR References

For additional context, these artifacts document the implementation:

### Commits on {{TICKET_PREFIX}}-454 Branch

```text
fa4e942 docs(harness): integrate SOPs into whitepaper and AGENTS.md [{{TICKET_PREFIX}}-454]
c1f19b7 docs(harness): add SAFe Role Expansion Vision to Phase 3 roadmap [{{TICKET_PREFIX}}-454]
4d68d72 feat(harness): upgrade SAFe agents to Opus 4.5, add skills integration [{{TICKET_PREFIX}}-454]
9b3beec docs(harness): update whitepaper with Phase 0-2 completion [{{TICKET_PREFIX}}-454]
```

### Key Files Changed

- `AGENTS.md` - Role fixes, skills section, SOP links
- `docs/whitepapers/CLAUDE-CODE-HARNESS-MODERNIZATION-{{TICKET_PREFIX}}-444.md` - Main whitepaper
- `docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md` - Agent perspective

### PR (if merged)

Check PR #324 or subsequent PRs for full diff and review discussion.

---

## Quick Reference: File Locations

```text
{{PROJECT_SHORT}} Repository Structure (Source)
├── .claude/
│   ├── settings.json          # Hooks configuration
│   ├── commands/              # 24 slash commands
│   ├── skills/                # 17 model-invoked skills
│   └── agents/                # 12 agent profiles
├── AGENTS.md                  # Quick reference
├── CONTRIBUTING.md            # Workflow documentation
├── docs/
│   ├── whitepapers/
│   │   ├── CLAUDE-CODE-HARNESS-MODERNIZATION-{{TICKET_PREFIX}}-444.md
│   │   ├── CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md
│   │   └── CLAUDE-CODE-HARNESS-KT-META-PROMPT.md  # This file
│   ├── patterns/              # Pattern library
│   ├── sop/                   # Core SOPs
│   ├── workflow/              # Workflow SOPs
│   ├── ci-cd/                 # CI/CD SOPs
│   └── database/              # Database SOPs
└── .github/
    ├── workflows/             # 11 workflow files
    └── pull_request_template.md
```

---

## Final Notes

This meta-prompt is designed to be self-contained. The ARCHitect should be able to:

1. Read this document
2. Read the two whitepaper documents
3. Extract components systematically using the checklist
4. Generalize using the provided patterns
5. Implement in the public repository

The public repo is "a practical and artistic expression" of {{PROJECT_SHORT}}'s work.
We lead; the public repo follows with generalized versions that any SAFe/Agentic team can adopt.

**The goal is not documentation for documentation's sake. The goal is executable
institutional knowledge that helps teams ship great product.**

---

**Contributing**: This document accompanies the Claude Code Harness Modernization
whitepaper and should be updated when significant harness changes occur.

Submit improvements via PR to this repository or the
[{{PROJECT_REPO}}](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}) repository.
