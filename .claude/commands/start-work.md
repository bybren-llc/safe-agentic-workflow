---
description: Start work on a new Linear ticket with proper workflow
argument-hint: [{{TICKET_PREFIX}}-number]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob, mcp__linear-mcp__*]
---

You are starting work on a new Linear ticket.

**Workflow Authority**: This harness command provides execution steps. CONTRIBUTING.md is the northstar for conventions (branch naming, commit format, SAFe patterns). Follow both:

## Pre-Flight Checklist

1. **Linear Ticket Exists?**
   - If no ticket number provided in arguments, ask user for Linear ticket number
   - Verify ticket exists in Linear using `mcp__linear-mcp__get_issue`
   - Confirm ticket is in appropriate status (Todo, In Progress)

2. **Stop-the-Line: AC/DoD Check** (MANDATORY)
   - Verify ticket has **Acceptance Criteria** or **Definition of Done**
   - If AC/DoD is missing or unclear:
     - **STOP** - Do not proceed with implementation
     - Route back to BSA/POPM to define AC/DoD
     - Dev agents are NOT responsible for inventing AC/DoD
   - Work begins ONLY when AC/DoD exists

3. **Branch Naming**
   - Format: `{{TICKET_PREFIX}}-{number}-{short-description}`
   - Must start with {{TICKET_PREFIX}}- and ticket number
   - Use lowercase with hyphens

4. **Start from Latest Dev**
   - Ensure starting from clean dev branch: `git checkout dev && git pull origin dev`
   - Verify no uncommitted changes

5. **Create Feature Branch**
   - Create branch: `git checkout -b {{TICKET_PREFIX}}-{number}-{description}`
   - Confirm branch created successfully

## Workflow

If argument provided ($1):

- Use as ticket number (e.g., `/start-work 347` → {{TICKET_PREFIX}}-347)
- Fetch ticket details from Linear
- Suggest branch name based on ticket title
- Execute checkout workflow

If no argument:

- Ask user for Linear ticket number
- Proceed with workflow

## Success Criteria

- ✅ Linear ticket verified
- ✅ AC/DoD confirmed (Stop-the-Line gate passed)
- ✅ On latest dev branch
- ✅ Feature branch created with correct naming
- ✅ Ready to begin work

Report status and any blockers. If AC/DoD is missing, report blocker and route to BSA.
