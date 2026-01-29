# Meta-Prompts for SAFe Multi-Agent Development

**Purpose**: Copy-paste prompts to help you get started with the 11-agent team structure.

**Repository**: {{GITHUB_REPO_URL}}

---

## 📋 Table of Contents

1. [Initial Setup Meta-Prompt](#1-initial-setup-meta-prompt)
2. [Agent Role Selection Meta-Prompt](#2-agent-role-selection-meta-prompt)
3. [First Linear Ticket Meta-Prompt](#3-first-linear-ticket-meta-prompt)
4. [Template Customization Meta-Prompt](#4-template-customization-meta-prompt)
5. [Workflow Integration Meta-Prompt](#5-workflow-integration-meta-prompt)

---

## 1. Initial Setup Meta-Prompt

**When to use**: First time setting up the SAFe multi-agent methodology in your project.

**Copy-paste this to your AI assistant**:

```
I want to set up the SAFe Multi-Agent Development methodology in my project. I've cloned the repository from {{GITHUB_REPO_URL}}.

Please help me with the following:

1. **Agent Provider Selection**: I'm using [Claude Code / Augment Code / Other]. What do I need to do to install the 11 agent prompts?

2. **Agent Files**: I see agent files in two locations:
   - `.claude/agents/` (11 files)
   - `agent_providers/claude_code/prompts/` (11 files)

   Which directory should I use, and how do I install them?

3. **Environment Setup**: The implementation guide mentions `.env.template` but I don't see it in the repository. What environment variables do I need to configure?

4. **First Steps**: After installing agents, what should I do first to validate the setup is working?

5. **Template Customization**: I see placeholders like {{PROJECT_NAME}}, {{TICKET_PREFIX}}, etc. Can you help me identify all placeholders I need to replace and where to find them?

My project details:
- Project name: [YOUR_PROJECT_NAME]
- Ticket system: [Linear / Jira / GitHub Issues]
- Primary development branch: [main / dev / develop]
- Tech stack: [YOUR_TECH_STACK]
- Team size: [NUMBER] developers

Please provide step-by-step instructions for getting started.
```

**Expected outcome**: Your AI assistant will guide you through initial setup with project-specific instructions.

---

## 2. Agent Role Selection Meta-Prompt

**When to use**: When you need to decide which agent to invoke for a specific task.

**Copy-paste this to your AI assistant**:

```
I'm working on a task and need to know which SAFe multi-agent agent to invoke. Here's my task:

**Task Description**: [DESCRIBE YOUR TASK]

**Task Type**: [Feature / Bug Fix / Refactor / Documentation / Testing / Security / Infrastructure]

**Complexity**: [Simple / Medium / Complex]

**Areas Involved**: [Frontend / Backend / Database / API / Testing / Documentation / Security]

Based on the SAFe multi-agent methodology with 11 agent roles:
1. TDM (Technical Delivery Manager)
2. BSA (Business Systems Analyst)
3. System Architect
4. FE Developer (Frontend)
5. BE Developer (Backend)
6. DE (Data Engineer)
7. TW (Technical Writer)
8. DPE (Data Provisioning Engineer)
9. QAS (Quality Assurance Specialist)
10. SecEng (Security Engineer)
11. RTE (Release Train Engineer)

Please recommend:
1. Which agent(s) should I invoke for this task?
2. In what order should I invoke them?
3. What should I ask each agent to do?
4. What success criteria should I use to validate each agent's work?

Reference: See AGENTS.md in the repository for agent role descriptions.
```

**Expected outcome**: Clear guidance on which agent(s) to use and in what sequence.

---

## 3. First Linear Ticket Meta-Prompt

**When to use**: Creating your first Linear ticket using the SAFe methodology.

**Copy-paste this to your AI assistant**:

```
I want to create my first Linear ticket using the SAFe multi-agent methodology. I'm ready to invoke the BSA (Business Systems Analyst) agent.

**Feature Request**: [DESCRIBE YOUR FEATURE]

**Business Value**: [WHY THIS FEATURE MATTERS]

**User Impact**: [WHO BENEFITS AND HOW]

Please help me:

1. **User Story Format**: Convert my feature request into a proper user story format:
   - As a [USER_TYPE]
   - I want to [ACTION]
   - So that [BENEFIT]

2. **Acceptance Criteria**: Define clear, testable acceptance criteria (Given/When/Then format preferred)

3. **Testing Strategy**: Outline what types of tests are needed:
   - Unit tests
   - Integration tests
   - E2E tests
   - Manual testing steps

4. **Technical Considerations**: Identify:
   - Which parts of the codebase will be affected
   - What patterns from the pattern library might apply
   - What security considerations exist
   - What database changes might be needed

5. **Ticket Structure**: Format this as a Linear ticket with:
   - Title: [TICKET_PREFIX]-XXX: [Short description]
   - Description: User story + context
   - Acceptance Criteria: Numbered list
   - Testing Strategy: Detailed plan
   - Technical Notes: Architecture considerations

Reference the BSA agent prompt at `.claude/agents/bsa.md` for the complete workflow.
```

**Expected outcome**: A complete Linear ticket ready to be created, following SAFe best practices.

---

## 4. Template Customization Meta-Prompt

**When to use**: When you need to customize the repository templates for your project.

**Copy-paste this to your AI assistant**:

```
I've cloned the SAFe multi-agent Agentic Workflow repository and need to customize it for my project. I see several template placeholders that need to be replaced.

**My Project Details**:
- Project Name: [YOUR_PROJECT_NAME]
- GitHub Organization: [YOUR_ORG]
- Repository Name: [YOUR_REPO]
- Ticket Prefix: [YOUR_PREFIX] (e.g., PROJ, TEAM, etc.)
- Primary Dev Branch: [main / dev / develop]
- Architect GitHub Handle: [YOUR_GITHUB_HANDLE]
- Confluence URL: [YOUR_CONFLUENCE_URL or N/A]
- Database Superuser Role: [YOUR_DB_SUPERUSER_ROLE]
- Database App User Role: [YOUR_DB_APP_USER_ROLE]

Please help me:

1. **Find All Placeholders**: Search the repository for all instances of:
   - {{PROJECT_NAME}}
   - {{TICKET_PREFIX}}
   - {{PRIMARY_DEV_BRANCH}}
   - {{ARCHITECT_GITHUB_HANDLE}}
   - {{CONFLUENCE_URL}}
   - {{DB_SUPERUSER_ROLE}}
   - {{DB_APP_USER_ROLE}}
   - Any other {{PLACEHOLDERS}}

2. **Replacement Plan**: Create a find-and-replace plan showing:
   - File path
   - Line number
   - Old value (placeholder)
   - New value (my project-specific value)

3. **Validation**: After replacement, what should I check to ensure everything is configured correctly?

4. **Git Strategy**: Should I:
   - Replace placeholders in a single commit?
   - Create a branch for customization?
   - Keep placeholders and use environment variables?

Please provide a systematic approach to customizing this template repository.
```

**Expected outcome**: Complete customization plan with all placeholders identified and replacement strategy.

---

## 5. Workflow Integration Meta-Prompt

**When to use**: Integrating the SAFe workflow with your existing tools (Linear, GitHub, CI/CD).

**Copy-paste this to your AI assistant**:

```
I want to integrate the SAFe multi-agent multi-agent workflow with my existing development tools.

**My Current Setup**:
- Issue Tracking: [Linear / Jira / GitHub Issues]
- Version Control: [GitHub / GitLab / Bitbucket]
- CI/CD: [GitHub Actions / GitLab CI / Jenkins / CircleCI]
- Documentation: [Confluence / GitHub Wiki / Notion / Other]
- Team Size: [NUMBER] developers
- Current Workflow: [Describe your current git workflow]

**Integration Goals**:
1. Connect agents to Linear/Jira for ticket management
2. Automate PR creation and validation
3. Enforce SAFe workflow in CI/CD pipeline
4. Set up documentation automation

Please help me:

1. **Linear/Jira Integration**:
   - How do agents update tickets?
   - What API keys/tokens do I need?
   - How to configure agent access to issue tracking?

2. **GitHub Integration**:
   - How to set up branch naming conventions (TICKET-XXX-description)?
   - How to configure PR templates?
   - How to enforce rebase-first workflow?
   - How to set up CODEOWNERS for agent-based review?

3. **CI/CD Integration**:
   - What validation checks should run on every PR?
   - How to enforce agent-created evidence in tickets?
   - How to validate RLS policies in CI?
   - How to run pattern library checks?

4. **Documentation Integration**:
   - How to sync specs with Confluence/Wiki?
   - How to automate documentation updates?
   - How to maintain DATA_DICTIONARY.md?

5. **Team Onboarding**:
   - How to train team on agent invocation?
   - What's the learning curve?
   - How to handle resistance to AI-assisted development?

Reference: See CI-CD-Pipeline-Guide.md and CONTRIBUTING.md for workflow details.
```

**Expected outcome**: Complete integration plan for connecting SAFe workflow to your existing tools.

---

## 6. Day 1 Checklist Meta-Prompt

**When to use**: Your first day using the methodology - validates you're set up correctly.

**Copy-paste this to your AI assistant**:

```
I've just set up the SAFe Multi-Agent Development methodology. Please help me validate my setup by walking through this Day 1 checklist:

**Setup Validation**:
- [ ] Repository cloned: `git clone {{GITHUB_REPO_URL}}`
- [ ] Agent provider installed: [Claude Code / Augment Code]
- [ ] Agent prompts copied to correct location
- [ ] Environment variables configured
- [ ] Linear/Jira API access configured
- [ ] GitHub access configured

**First Agent Invocation**:
- [ ] Invoke BSA agent with a simple test task
- [ ] BSA creates a user story with acceptance criteria
- [ ] User story follows format: "As a... I want... So that..."
- [ ] Acceptance criteria are testable

**First Ticket Creation**:
- [ ] Create Linear ticket with BSA output
- [ ] Ticket has proper format: [TICKET_PREFIX]-XXX: Description
- [ ] Ticket includes acceptance criteria
- [ ] Ticket includes testing strategy

**First Implementation**:
- [ ] Create feature branch: `git checkout -b [TICKET]-description`
- [ ] Invoke appropriate agent (FE/BE/DE) for implementation
- [ ] Agent follows pattern discovery workflow
- [ ] Agent creates evidence (code, tests, documentation)

**First PR**:
- [ ] Create PR with proper title: `feat(scope): description [TICKET]`
- [ ] PR includes link to Linear ticket
- [ ] PR passes CI validation
- [ ] PR follows rebase-first workflow

**Validation Questions**:
1. Did the agent invocation work as expected?
2. Was the pattern discovery process clear?
3. Did the agent create proper evidence?
4. Did the workflow feel natural or confusing?
5. What questions do I still have?

Please guide me through each step and help me troubleshoot any issues.
```

**Expected outcome**: Validated setup with first successful ticket → implementation → PR cycle.

---

## 7. Troubleshooting Meta-Prompt

**When to use**: When something isn't working and you need help debugging.

**Copy-paste this to your AI assistant**:

```
I'm having trouble with the SAFe Multi-Agent Development setup. Here's my issue:

**Problem Description**: [DESCRIBE WHAT'S NOT WORKING]

**What I've Tried**: [LIST TROUBLESHOOTING STEPS YOU'VE TAKEN]

**Error Messages**: [PASTE ANY ERROR MESSAGES]

**My Setup**:
- Agent Provider: [Claude Code / Augment Code / Other]
- Operating System: [macOS / Linux / Windows]
- Repository Location: [PATH]
- Agent Files Location: [PATH]

**Common Issues to Check**:
1. **Agent Not Found**: Are agent files in the correct directory?
2. **Agent Not Responding**: Is the agent provider (Claude Code) running?
3. **Linear Integration Failing**: Are API keys configured correctly?
4. **Pattern Discovery Not Working**: Is the pattern library accessible?
5. **RLS Validation Failing**: Are database roles configured?

Please help me:
1. Diagnose the root cause of my issue
2. Provide step-by-step troubleshooting steps
3. Suggest workarounds if needed
4. Identify if this is a setup issue or methodology misunderstanding

Reference: Check AGENTS.md, CONTRIBUTING.md, and CI-CD-Pipeline-Guide.md for configuration details.
```

**Expected outcome**: Diagnosis and resolution of setup/workflow issues.

---

## Usage Tips

### For Best Results:

1. **Be Specific**: Replace [PLACEHOLDERS] with your actual project details
2. **Provide Context**: The more context you give, the better the AI can help
3. **Iterate**: Don't expect perfect results on first try - refine based on responses
4. **Reference Docs**: Point the AI to specific files in the repository for context
5. **Use GitIngest**: Load the entire repository context using the GitIngest link for comprehensive help

### Meta-Prompt Workflow:

```
1. Choose appropriate meta-prompt for your task
2. Fill in [PLACEHOLDERS] with your project details
3. Copy-paste to your AI assistant (Claude, ChatGPT, etc.)
4. Review AI response and ask follow-up questions
5. Implement recommendations
6. Validate with success criteria
```

---

## Additional Resources

- **AGENTS.md**: Quick reference for all 11 agent roles
- **CONTRIBUTING.md**: Complete workflow guide
- **whitepaper/section-9-implementation-guide.md**: Detailed implementation steps
- **GitIngest Link**: https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}

---

**Questions?** Open an issue on GitHub or contact scott@{{PROJECT_DOMAIN}}
