# Agent Setup Guide

## Installing and Using the 11-Agent SAFe multi-agent System

**Time to Complete**: 30-45 minutes  
**Prerequisites**: Claude Code or Augment Code installed  
**Difficulty**: Beginner-friendly

---

## 🎯 What You'll Learn

By the end of this guide, you'll know how to:

1. Install the 11 SAFe multi-agent agents
2. Invoke agents for different tasks
3. Understand agent roles and when to use each
4. Validate your setup is working correctly

---

## Part 1: Understanding the Agent System

### What Are Agents?

The SAFe multi-agent methodology uses **11 specialized AI agents** that act like team members. Each agent has:

- **Specific role** (BSA, System Architect, Backend Dev, etc.)
- **Tool restrictions** (only access tools needed for their role)
- **Model selection** (Opus for planning, Sonnet for execution)
- **Clear success criteria** (validation commands to check their work)

### The 11 Agent Roles

**Planning Agents** (Opus Model - Slower but Thorough):

1. **BSA** (Business Systems Analyst) - Creates specs with acceptance criteria
2. **System Architect** - Validates patterns, makes architectural decisions

**Execution Agents** (Sonnet Model - Fast): 3. **BE Developer** - Implements backend/API code 4. **FE Developer** - Implements frontend/UI code 5. **Data Engineer** - Creates database migrations 6. **Data Provisioning Engineer** - Builds data pipelines

**Quality Agents** (Sonnet Model): 7. **QAS** (Quality Assurance Specialist) - Writes and runs tests 8. **Security Engineer** - Validates security and RLS policies

**Documentation Agent** (Sonnet Model): 9. **Tech Writer** - Creates technical documentation

**Coordination Agents** (Sonnet Model): 10. **TDM** (Technical Delivery Manager) - Orchestrates agents, updates Linear 11. **RTE** (Release Train Engineer) - Creates PRs, manages releases

---

## Part 2: Installation

### Option A: Claude Code (Recommended)

**Step 1: Verify Claude Code is Installed**

```bash
# Check if Claude Code is available
which claude-code
# or
claude-code --version
```

If not installed, visit: https://docs.anthropic.com/claude/docs/claude-code

**Step 2: Clone the Repository**

```bash
git clone {{GITHUB_REPO_URL}}
cd {{PROJECT_NAME}}
```

**Step 3: Install Agents**

The agents are already in `.claude/agents/` directory. Claude Code will auto-detect them!

```bash
# Verify agents are present
ls -la .claude/agents/
# Should see 11 .md files
```

**Step 4: Verify Installation**

```bash
# Run the session-start hook to verify
.claude/hooks/session-start-pattern-check.sh
```

Expected output:

```
📚 Pattern Library Status:
   Location: docs/patterns
   Available patterns: 12

🤖 Agent System Ready
   11 agents available in .claude/agents/
   Tool restrictions: ✅ Configured
   Model selection: ✅ Opus (planning), Sonnet (execution)
```

---

### Option B: Augment Code

**Step 1: Verify Augment Code is Installed**

```bash
# Check if Augment is available
which augment
```

If not installed, visit: https://www.augmentcode.com/

**Step 2: Clone the Repository**

```bash
git clone {{GITHUB_REPO_URL}}
cd {{PROJECT_NAME}}
```

**Step 3: Copy Augment Configurations**

```bash
# Copy Augment-specific agent configurations
cp -r agent_providers/augment/* ~/.augment/
```

**Step 4: Verify Installation**

```bash
# Check Augment recognizes the agents
augment agents list
```

---

## Part 3: First Agent Invocation

### Test 1: Invoke BSA Agent

**In Claude Code or Augment, type**:

```
@bsa What is your role as the BSA agent?
```

**Expected Response**: The agent should respond with:

- "I am the Business Systems Analyst (BSA)"
- Mentions "pattern discovery" and "acceptance criteria"
- Explains their role in creating specs

**If this works**: ✅ Your agent system is installed correctly!

---

### Test 2: Create a Simple Spec

**Invoke BSA with a real task**:

```
@bsa I need to create a spec for a simple "Hello World" API endpoint.

Feature: Add a GET /api/hello endpoint that returns a JSON response with a message and timestamp.

Please:
1. Create a user story in proper format
2. Define acceptance criteria
3. Suggest which patterns from the pattern library might apply
4. Outline testing strategy
```

**Expected Output**:

- User story: "As a developer, I want to..."
- 3-5 acceptance criteria
- Pattern reference (likely `patterns_library/api/user-context-api.md` or similar)
- Testing strategy (unit tests, integration tests)

**If this works**: ✅ Your BSA agent is functioning correctly!

---

### Test 3: Invoke Backend Developer

**After BSA creates the spec, invoke BE Developer**:

```
@be-developer I have a spec for a Hello World endpoint.

User Story: [PASTE BSA OUTPUT]

Please:
1. Search for existing API endpoint patterns
2. Implement the endpoint following the pattern
3. Show me the code

Note: This is just a test, so you can show me the implementation without actually creating files.
```

**Expected Output**:

- Pattern discovery results (searches `patterns_library/api/`)
- Implementation code following the pattern
- Explanation of how it meets acceptance criteria

**If this works**: ✅ Your execution agents are working!

---

## Part 4: Understanding Agent Invocation

### Method 1: Direct Mention (Simple Tasks)

```
@agent-name [Your request]
```

**Example**:

```
@tech-writer Update the README.md to include installation instructions for the agent system.
```

---

### Method 2: Task Tool (Complex Tasks)

For complex, multi-step tasks, use the Task tool:

```typescript
Task({
  subagent_type: "agent-name",
  description: "Short 3-5 word description",
  prompt: "Detailed instructions for the agent",
});
```

**Example**:

```typescript
Task({
  subagent_type: "bsa",
  description: "Create spec for {{TICKET_PREFIX}}-123",
  prompt:
    "Create comprehensive spec for {{TICKET_PREFIX}}-123 user profile feature. Include pattern discovery, acceptance criteria, and testing strategy. Reference existing patterns from patterns_library/.",
});
```

---

## Part 5: Common Workflows

### Workflow 1: Simple Feature Implementation

```
1. @bsa Create spec for [feature]
   → BSA creates spec with pattern references

2. @be-developer Implement [feature] using spec
   → BE Developer implements using patterns

3. @qas Test [feature] implementation
   → QAS writes and runs tests

4. @rte Create PR for [feature]
   → RTE creates PR with proper format
```

---

### Workflow 2: Full-Stack Feature

```
1. @bsa Create spec for [feature]
   → BSA creates comprehensive spec

2. @data-engineer Create migration for [feature]
   → DE creates database migration (if needed)

3. @be-developer Implement API for [feature]
   → BE implements backend

4. @fe-developer Implement UI for [feature]
   → FE implements frontend

5. @qas Test [feature] end-to-end
   → QAS validates complete flow

6. @rte Create PR for [feature]
   → RTE coordinates final PR
```

---

### Workflow 3: TDM-Orchestrated (Complex)

```
@tdm I need to implement {{TICKET_PREFIX}}-123 (user profile feature).

Please:
1. Read the Linear ticket
2. Coordinate the BSA to create a spec
3. Assign appropriate execution agents
4. Monitor progress and update Linear
5. Coordinate final PR via RTE
```

The TDM will orchestrate all other agents automatically!

---

## Part 6: Agent Capabilities Reference

### What Each Agent Can Do

| Agent                 | Can Do                                             | Cannot Do                                   |
| --------------------- | -------------------------------------------------- | ------------------------------------------- |
| **BSA**               | Read/write specs, search patterns, update Linear   | Write code, create PRs                      |
| **System Architect**  | Read/write patterns, validate architecture         | Implement features, run tests               |
| **BE Developer**      | Implement backend code, search patterns            | Update Linear, create PRs, modify DB schema |
| **FE Developer**      | Implement frontend code, search patterns           | Update Linear, create PRs, backend code     |
| **Data Engineer**     | Create migrations, update schema                   | Implement features, create PRs              |
| **QAS**               | Write/run tests, validate ACs                      | Implement features, update Linear           |
| **Security Engineer** | Audit security, validate RLS                       | Implement features, create PRs              |
| **Tech Writer**       | Write documentation                                | Implement features, create PRs              |
| **TDM**               | Orchestrate agents, update Linear, read Confluence | Write code, create PRs                      |
| **RTE**               | Create PRs, run CI/CD, manage releases             | Implement features, update Linear           |

---

## Part 7: Validation & Troubleshooting

### Verify Your Setup

**Run these commands to validate**:

```bash
# 1. Check agents are present
ls .claude/agents/*.md | wc -l
# Should output: 11

# 2. Check pattern library
ls patterns_library/**/*.md | wc -l
# Should output: 12

# 3. Run session-start hook
.claude/hooks/session-start-pattern-check.sh
# Should show agent system ready

# 4. Check agent frontmatter
head -6 .claude/agents/bsa.md
# Should show: name, description, tools, model
```

---

### Common Issues

**Issue**: Agent not found

- **Solution**: Verify `.claude/agents/` directory exists and has 11 .md files
- **Check**: `ls -la .claude/agents/`

**Issue**: Agent doesn't respond correctly

- **Solution**: Check agent frontmatter has correct format
- **Check**: `head -10 .claude/agents/bsa.md`

**Issue**: Agent can't access a tool

- **Solution**: Check `tools:` line in agent frontmatter
- **Example**: BSA should have `tools: [Read, Write, Edit, Bash, Grep, Glob, mcp__{{MCP_LINEAR_SERVER}}__*]`

**Issue**: Pattern discovery not working

- **Solution**: Verify pattern library exists
- **Check**: `ls patterns_library/`

---

## Part 8: Next Steps

### You're Ready! Here's What to Do Next:

1. **Read the Cheat Sheet**: See `AGENTS.md` for quick reference
2. **Try a Real Task**: Create your first Linear ticket and implement it
3. **Explore Patterns**: Browse `patterns_library/` to see what's available
4. **Read SOPs**: Check `docs/sop/` for detailed workflows
5. **Customize**: Replace {{PLACEHOLDERS}} with your project values

---

## Part 9: Quick Reference

### Agent Invocation Cheat Sheet

```bash
# Planning
@bsa Create spec for [feature]
@system-architect Validate [architecture decision]

# Implementation
@be-developer Implement [backend feature]
@fe-developer Implement [frontend feature]
@data-engineer Create migration for [schema change]

# Quality
@qas Test [feature]
@security-engineer Audit [security concern]

# Documentation
@tech-writer Document [feature]

# Coordination
@tdm Orchestrate [complex task]
@rte Create PR for [feature]
```

---

### Success Validation Commands

```bash
# Frontend
yarn lint && yarn build && echo "FE SUCCESS"

# Backend
yarn test:integration && echo "BE SUCCESS"

# Documentation
yarn lint:md && echo "DOCS SUCCESS"

# Database
npx prisma migrate dev --name [name] && echo "MIGRATION SUCCESS"

# CI/CD
yarn ci:validate && echo "CI SUCCESS"
```

---

## Resources

- **AGENTS.md**: Quick reference for all 11 agents
- **docs/sop/AGENT_CONFIGURATION_SOP.md**: Detailed configuration guide
- **docs/sop/AGENT_WORKFLOW_SOP.md**: Workflow and orchestration guide
- **patterns_library/README.md**: Pattern library index
- **CONTRIBUTING.md**: Git workflow and PR process
- **Confluence Cheat Sheet**: https://{{AUTHOR_HANDLE}}.atlassian.net/wiki/spaces/WA/pages/366411778

---

## Success!

**Congratulations!** 🎉 You've successfully set up the SAFe multi-agent 11-agent system.

**You now know how to**:

- ✅ Install agents in Claude Code or Augment
- ✅ Invoke agents for different tasks
- ✅ Understand agent roles and capabilities
- ✅ Validate your setup is working
- ✅ Use common workflows

**Next**: Complete the [Day 1 Checklist](./DAY-1-CHECKLIST.md) to validate your full workflow!

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: {{AUTHOR_EMAIL}}
