# Augment Starter Kit for {{PROJECT_SHORT}} SAFe-Agentic-Workflow

## Overview

This directory contains the starter kit for using the {{PROJECT_SHORT}} SAFe-Agentic-Workflow with Augment. Unlike the Claude Code "golden path" which is fully automated, this path requires some manual setup and adaptation.

## What's Included

### `rules/` Directory

Contains pre-translated rules and guidelines adapted from the Claude prompts:

- `CONTRIBUTING.md` - Git workflow and contribution standards
- `coding-standards.md` - Code quality and style guidelines
- `confluence-standards.md` - Documentation standards
- `linear-api-sop.md` - Linear integration guidelines
- `project-guidelines.md` - Project-specific guidelines
- `review-checklist.md` - Code review checklist

### `instructions.md`

Comprehensive instructions for setting up and using the workflow with Augment.

## Key Differences from Claude Code Path

### ✅ What Works the Same

- Universal workflow files (`project_workflow/`, `patterns_library/`, `specs_templates/`)
- SAFe ART agent roles and responsibilities
- Evidence-based delivery model
- Pattern-driven development approach
- Spec-driven workflow

### ⚠️ Manual Steps Required

#### 1. Pattern Discovery Protocol

**Claude Code**: Automated search of `~/.claude/todos/` session history
**Augment**: Manual search using:

```bash
# Search codebase for patterns
grep -r "pattern_name" .
# Search git history
git log --grep="pattern_name"
# Search pattern library
find patterns_library/ -name "*pattern*"
```

#### 2. Automation Hooks

**Claude Code**: Automated hooks for session start, pre-bash validation, post-commit Linear updates
**Augment**: Manual execution of validation commands:

```bash
# Before starting work
cat patterns_library/README.md
# Before committing
yarn ci:validate
# After committing
# Manually update Linear ticket with session evidence
```

#### 3. Agent Configuration

**Claude Code**: Automatic agent selection based on YAML frontmatter
**Augment**: Manual role assignment and context switching

## Setup Instructions

### 1. Initial Setup

1. Copy this directory to your project as `.augment/`
2. Review all files in the `rules/` directory
3. Customize placeholders (e.g., `__TICKET_PREFIX__`) for your project
4. Add `.augment/` to your `.gitignore`

### 2. Team Training

1. Share `instructions.md` with all team members
2. Review the universal `AGENTS.md` file
3. Establish manual processes for pattern discovery
4. Set up Linear integration workflows

### 3. Workflow Adaptation

1. Use `specs_templates/` for all planning work
2. Reference `patterns_library/` before writing new code
3. Follow `project_workflow/CONTRIBUTING.md` for git workflow
4. Use `linting_configs/` for code quality

## Daily Workflow

### For Planning Agents (BSA, System Architect)

1. Use `specs_templates/planning_template.md` for epics
2. Use `specs_templates/spec_template.md` for user stories
3. Manually search pattern library before proposing new patterns
4. Include metacognitive handoff notes (`#PATH_DECISION`, `#PLAN_UNCERTAINTY`, `#EXPORT_CRITICAL`)

### For Execution Agents (Developers, Engineers)

1. Read spec file completely before starting
2. Manually search for existing patterns:
   ```bash
   grep -r "similar_functionality" .
   git log --grep="related_feature"
   find patterns_library/ -name "*relevant*"
   ```
3. Follow pattern templates exactly
4. Run validation frequently: `yarn ci:validate`
5. Make atomic commits with clear messages

### For Quality Agents (QAS, Security, RTE)

1. Follow testing strategies from specs
2. Use review checklist from `rules/review-checklist.md`
3. Manually attach evidence to Linear tickets
4. Coordinate releases using `project_workflow/` templates

## Bridging the Automation Gap

### Session History Alternative

Since Augment doesn't have automated session history search:

1. Keep manual notes of patterns used
2. Document solutions in team wiki/Confluence
3. Use git commit messages as searchable history
4. Maintain team knowledge base

### Linear Integration Alternative

Since automated Linear updates aren't available:

1. Manually update tickets with session evidence
2. Attach test results and validation outputs
3. Use Linear's API for bulk updates if needed
4. Establish team processes for evidence tracking

## Support and Evolution

### Getting Help

1. Review the universal documentation in the root directory
2. Check Confluence for team-specific adaptations
3. Consult with System Architect for pattern approval
4. Escalate to TDM for process issues

### Contributing Improvements

1. Document successful manual processes
2. Propose automation scripts where possible
3. Share learnings with the broader team
4. Contribute back to the template repository

## Success Metrics

You'll know the workflow is working when:

- [ ] All work follows the spec-driven approach
- [ ] Pattern reuse is consistently high
- [ ] Code quality metrics meet standards
- [ ] Evidence is consistently attached to Linear tickets
- [ ] Team velocity and quality improve over time
