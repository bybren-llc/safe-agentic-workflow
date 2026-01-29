# Onboarding Documentation Generalization Changes

## Overview

This document tracks the changes made to generalize onboarding documentation for broader adoption.

## Automated Script

Run the following script to apply all changes automatically:

```bash
bash scripts/generalize-onboarding-docs.sh
```

The script creates backups (.bak files) before making changes.

## Manual Changes (if script not used)

If you need to make changes manually, here are the specific updates required:

### Files to Update

1. `docs/onboarding/DAY-1-CHECKLIST.md`
2. `docs/onboarding/SOCIAL-MEDIA-SETUP.md`
3. `docs/onboarding/AGENT-SETUP-GUIDE.md`
4. `docs/onboarding/META-PROMPTS-FOR-USERS.md`
5. `docs/onboarding/USER-JOURNEY-VALIDATION-REPORT.md`

### Changes to Apply

#### 1. Replace "{{PROJECT_SHORT}} SAFe" with "SAFe"

**Find:**

- `{{PROJECT_SHORT}} SAFe Multi-Agent Development` → `SAFe Multi-Agent Development`
- `{{PROJECT_SHORT}} SAFe methodology` → `SAFe multi-agent methodology`
- `the {{PROJECT_SHORT}} methodology` → `the SAFe methodology`
- `{{PROJECT_SHORT}} SAFe` → `SAFe multi-agent` (general references)

#### 2. Generalize GitHub URLs

**Find:** `https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow`
**Replace:** `{{GITHUB_REPO_URL}}`

**Locations:**

- Clone commands
- Repository links
- PR links
- Discussion links

#### 3. Generalize GitIngest URLs

**Find:** `https://gitingest.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow`
**Replace:** `https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}`

#### 4. Generalize Project Name

**Find:** `cd {{PROJECT_NAME}}-Agentic-Workflow`
**Replace:** `cd {{PROJECT_NAME}}`

#### 5. Generalize Ticket Prefixes

**Find:** `{{TICKET_PREFIX}}-{number}` (e.g., `{{TICKET_PREFIX}}-326`, `{{TICKET_PREFIX}}-123`)
**Replace:** `{{TICKET_PREFIX}}-{number}`

**Find:** `PROJ-{number}` (example tickets)
**Replace:** `{{TICKET_PREFIX}}-{number}`

#### 6. Keep Generic Examples

**DO NOT CHANGE** these generic GitHub URLs (they're useful examples):

- `https://github.com/settings/tokens`
- `https://linear.app/settings/api`
- `https://id.atlassian.com/manage-profile/security/api-tokens`

## File-Specific Changes

### DAY-1-CHECKLIST.md

```diff
- # Day 1 Checklist: {{PROJECT_SHORT}} SAFe Multi-Agent Development
+ # Day 1 Checklist: SAFe Multi-Agent Development

- **Purpose**: Your first day with the {{PROJECT_SHORT}} SAFe methodology
+ **Purpose**: Your first day with the SAFe multi-agent methodology

- git clone https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
- cd {{PROJECT_NAME}}-Agentic-Workflow
+ git clone {{GITHUB_REPO_URL}}
+ cd {{PROJECT_NAME}}

- Visit: https://gitingest.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ Visit: https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}

- I want to create a test Linear ticket to validate my {{PROJECT_SHORT}} SAFe setup.
+ I want to create a test Linear ticket to validate my SAFe multi-agent setup.

- Title: `PROJ-1: Add Hello World endpoint...`
+ Title: `{{TICKET_PREFIX}}-1: Add Hello World endpoint...`

- **Congratulations!** You've completed Day 1 of the {{PROJECT_SHORT}} SAFe Multi-Agent Development methodology.
+ **Congratulations!** You've completed Day 1 of the SAFe Multi-Agent Development methodology.

- GitHub Discussions: https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow/discussions
+ GitHub Discussions: See your repository's discussions page

- Email: {{AUTHOR_EMAIL}}
+ (Remove or replace with your contact)
```

### SOCIAL-MEDIA-SETUP.md

```diff
- How to configure social sharing for the {{PROJECT_SHORT}} SAFe Multi-Agent Development repository.
+ How to configure social sharing for the SAFe Multi-Agent Development repository.

- 1. Go to: https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ 1. Go to: {{GITHUB_REPO_URL}}

- **Project Name**: "{{PROJECT_SHORT}} SAFe Multi-Agent Development"
+ **Project Name**: "{{PROJECT_NAME}} SAFe Multi-Agent Development"

- content="https://{{GITHUB_ORG}}.github.io/{{PROJECT_NAME}}-Agentic-Workflow/"
+ content="https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/"
```

### AGENT-SETUP-GUIDE.md

```diff
- ## Installing and Using the 11-Agent {{PROJECT_SHORT}} SAFe System
+ ## Installing and Using the 11-Agent SAFe System

- The {{PROJECT_SHORT}} SAFe methodology uses **11 specialized AI agents**
+ The SAFe multi-agent methodology uses **11 specialized AI agents**

- git clone https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
- cd {{PROJECT_NAME}}-Agentic-Workflow
+ git clone {{GITHUB_REPO_URL}}
+ cd {{PROJECT_NAME}}

- Create spec for {{TICKET_PREFIX}}-123
+ Create spec for {{TICKET_PREFIX}}-123

- I need to implement {{TICKET_PREFIX}}-123 (user profile feature).
+ I need to implement {{TICKET_PREFIX}}-123 (user profile feature).

- You've successfully set up the {{PROJECT_SHORT}} SAFe 11-agent system.
+ You've successfully set up the SAFe 11-agent system.
```

### META-PROMPTS-FOR-USERS.md

```diff
- # Meta-Prompts for {{PROJECT_SHORT}} SAFe Multi-Agent Development
+ # Meta-Prompts for SAFe Multi-Agent Development

- **Repository**: https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ **Repository**: {{GITHUB_REPO_URL}}

- I want to set up the {{PROJECT_SHORT}} SAFe Multi-Agent Development methodology
+ I want to set up the SAFe Multi-Agent Development methodology

- I've cloned the repository from https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ I've cloned the repository from {{GITHUB_REPO_URL}}

- I'm working on a task and need to know which {{PROJECT_SHORT}} SAFe agent to invoke.
+ I'm working on a task and need to know which SAFe agent to invoke.

- Based on the {{PROJECT_SHORT}} SAFe methodology with 11 agent roles:
+ Based on the SAFe multi-agent methodology with 11 agent roles:

- I've cloned the {{PROJECT_SHORT}} SAFe Agentic Workflow repository
+ I've cloned the SAFe Agentic Workflow repository

- I want to integrate the {{PROJECT_SHORT}} SAFe multi-agent workflow
+ I want to integrate the SAFe multi-agent workflow

- I've just set up the {{PROJECT_SHORT}} SAFe Multi-Agent Development methodology.
+ I've just set up the SAFe Multi-Agent Development methodology.

- Repository cloned: `git clone https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow`
+ Repository cloned: `git clone {{GITHUB_REPO_URL}}`

- I'm having trouble with the {{PROJECT_SHORT}} SAFe Multi-Agent Development setup.
+ I'm having trouble with the SAFe Multi-Agent Development setup.

- **GitIngest Link**: https://gitingest.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ **GitIngest Link**: https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}
```

### USER-JOURNEY-VALIDATION-REPORT.md

```diff
- ## {{PROJECT_NAME}}-Agentic-Workflow Repository
+ ## SAFe-Agentic-Workflow Repository

- **Ticket**: {{TICKET_PREFIX}}-326
+ **Ticket**: {{TICKET_PREFIX}}-326

- **Repository**: https://github.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ **Repository**: {{GITHUB_REPO_URL}}

- **URL**: https://gitingest.com/{{GITHUB_ORG}}/{{PROJECT_NAME}}-Agentic-Workflow
+ **URL**: https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}

- ### ✅ COMPLETED ({{TICKET_PREFIX}}-326)
+ ### ✅ COMPLETED ({{TICKET_PREFIX}}-326)

- ### Future Enhancements (Post-{{TICKET_PREFIX}}-326)
+ ### Future Enhancements (Post-{{TICKET_PREFIX}}-326)

- **{{TICKET_PREFIX}}-326 Achievement**: Transformed user onboarding
+ **{{TICKET_PREFIX}}-326 Achievement**: Transformed user onboarding
```

## Verification

After making changes, verify with:

```bash
# Check for remaining {{PROJECT_SHORT}} references (should find none)
grep -r "{{PROJECT_SHORT}}" docs/onboarding/*.md

# Check for hardcoded GitHub URLs (should find only generic ones)
grep -r "{{GITHUB_ORG}}" docs/onboarding/*.md

# Check for {{TICKET_PREFIX}}- ticket prefixes (should find none)
grep -r "{{TICKET_PREFIX}}-" docs/onboarding/*.md
```

## Rollback

If you used the automated script and need to rollback:

```bash
for f in docs/onboarding/*.bak; do
  mv "$f" "${f%.bak}"
done
```

## Impact

These changes make the onboarding documentation:

1. **Portable**: Works for any project using this methodology
2. **Customizable**: Clear placeholders for project-specific values
3. **Professional**: No hardcoded references to original project
4. **Reusable**: Can be adopted without modification

## Next Steps

After generalization, teams adopting this methodology should:

1. Replace `{{GITHUB_REPO_URL}}` with their repository URL
2. Replace `{{GITHUB_ORG}}` and `{{GITHUB_REPO}}` with their GitHub org/repo names
3. Replace `{{PROJECT_NAME}}` with their project directory name
4. Replace `{{TICKET_PREFIX}}` with their ticket prefix (e.g., `PROJ`, `TASK`, `FEAT`)
5. Update contact information (remove or replace email addresses)

These replacements can be done with a single script or manually as part of repository customization.
