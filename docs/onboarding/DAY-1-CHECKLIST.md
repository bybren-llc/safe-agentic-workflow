# Day 1 Checklist: SAFe Multi-Agent Development

**Purpose**: Your first day with the SAFe multi-agent methodology - complete this checklist to validate your setup.

**Time Estimate**: 2-3 hours

**Prerequisites**:

- Access to Claude Code or Augment Code
- Linear/Jira account with API access
- GitHub account with repository access
- Basic understanding of SAFe principles (optional but helpful)

---

## Phase 1: Repository Setup (30 minutes)

### Step 1.1: Clone Repository

```bash
# Clone the template repository
git clone {{GITHUB_REPO_URL}}
cd {{PROJECT_NAME}}

# Explore the structure
ls -la
cat README.md
```

**Validation**:

- [ ] Repository cloned successfully
- [ ] Can see `.claude/agents/` directory
- [ ] Can see `whitepaper/` directory
- [ ] Can see `AGENTS.md` file

---

### Step 1.2: Load Repository Context (Optional but Recommended)

**Option A: Use GitIngest** (Recommended)

1. Visit: https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}
2. Copy the generated context
3. Paste into your AI assistant (Claude, ChatGPT, etc.)
4. Ask: "Explain the SAFe multi-agent methodology in 3 paragraphs"

**Option B: Read Documentation**

1. Read: `README.md` (5 min)
2. Read: `AGENTS.md` (10 min)
3. Read: `whitepaper/section-1-executive-summary.md` (5 min)

**Validation**:

- [ ] Understand the 11 agent roles
- [ ] Understand the SAFe workflow (Epic → Feature → Story)
- [ ] Understand the "Search First, Reuse Always" philosophy

---

## Phase 2: Agent Provider Setup (30 minutes)

### Step 2.1: Choose Your Agent Provider

**Option A: Claude Code** (Recommended)

- Best for: Teams using Claude API
- Installation: https://docs.anthropic.com/claude/docs/claude-code
- Agent files location: `.claude/agents/`

**Option B: Augment Code**

- Best for: Teams using Augment
- Installation: https://www.augmentcode.com/
- Agent files location: `agent_providers/augment/`

**Decision**:

- [ ] I'm using: [Claude Code / Augment Code / Other]

---

### Step 2.2: Install Agent Prompts

**For Claude Code**:

```bash
# Option 1: Copy to user directory (single user)
cp -r .claude/agents/* ~/.claude/agents/

# Option 2: Use in-project (team sharing)
# Agents are already in .claude/agents/ - no action needed
# Claude Code will auto-detect them
```

**For Augment Code**:

```bash
# Copy Augment-specific configurations
cp -r agent_providers/augment/* ~/.augment/
```

**Validation**:

- [ ] Agent files copied to correct location
- [ ] Can see 11 agent files (bsa.md, system-architect.md, etc.)
- [ ] Agent provider recognizes the agents

---

### Step 2.3: Verify Agent Installation

**Test Agent Invocation**:

1. Open your agent provider (Claude Code or Augment)
2. Try to invoke the BSA agent
3. Ask: "What is your role as the BSA agent?"

**Expected Response**: The agent should respond with its role description from the agent prompt file.

**Validation**:

- [ ] Agent responds with correct role description
- [ ] Agent mentions "Business Systems Analyst"
- [ ] Agent mentions "pattern discovery" and "acceptance criteria"

---

## Phase 3: Tool Integration (30 minutes)

### Step 3.1: Linear/Jira Setup

**Linear Setup**:

```bash
# Get your Linear API key
# Visit: https://linear.app/settings/api

# Set environment variable (add to ~/.bashrc or ~/.zshrc)
export LINEAR_API_KEY="your_api_key_here"

# Test Linear access
curl -H "Authorization: Bearer $LINEAR_API_KEY" \
  https://api.linear.app/graphql \
  -d '{"query": "{ viewer { id name } }"}'
```

**Jira Setup** (Alternative):

```bash
# Get your Jira API token
# Visit: https://id.atlassian.com/manage-profile/security/api-tokens

export JIRA_API_TOKEN="your_token_here"
export JIRA_EMAIL="your_email@example.com"
export JIRA_DOMAIN="your-domain.atlassian.net"
```

**Validation**:

- [ ] API key/token obtained
- [ ] Environment variable set
- [ ] API access tested successfully

---

### Step 3.2: GitHub Setup

```bash
# Get your GitHub Personal Access Token
# Visit: https://github.com/settings/tokens
# Scopes needed: repo, workflow, write:packages

export GITHUB_TOKEN="your_github_token_here"

# Test GitHub access
gh auth status
```

**Validation**:

- [ ] GitHub token obtained
- [ ] Environment variable set
- [ ] GitHub CLI authenticated

---

### Step 3.3: Configure Project Settings

**Create your project configuration**:

```bash
# Copy template (if it exists)
cp .env.template .env 2>/dev/null || touch .env

# Edit .env with your values
cat > .env << EOF
# Project Configuration
PROJECT_NAME="YourProjectName"
TICKET_PREFIX="PROJ"
PRIMARY_DEV_BRANCH="main"
ARCHITECT_GITHUB_HANDLE="your-github-handle"

# API Keys
LINEAR_API_KEY="$LINEAR_API_KEY"
GITHUB_TOKEN="$GITHUB_TOKEN"

# Optional
CONFLUENCE_URL="https://your-domain.atlassian.net/wiki"
EOF
```

**Validation**:

- [ ] `.env` file created
- [ ] All required variables set
- [ ] File added to `.gitignore` (security)

---

## Phase 4: First Agent Workflow (45 minutes)

### Step 4.1: Create Your First Linear Ticket

**Invoke BSA Agent**:

```
I want to create a test Linear ticket to validate my SAFe multi-agent setup.

Feature: Add a "Hello World" endpoint to validate the agent workflow.

Please help me:
1. Create a user story in proper format
2. Define acceptance criteria
3. Outline testing strategy
4. Suggest which agents to invoke for implementation

Use the BSA agent workflow from .claude/agents/bsa.md
```

**Expected Output**:

- User story in "As a... I want... So that..." format
- 3-5 testable acceptance criteria
- Testing strategy (unit, integration, E2E)
- Agent invocation sequence

**Validation**:

- [ ] BSA agent created proper user story
- [ ] Acceptance criteria are testable
- [ ] Testing strategy is comprehensive
- [ ] Agent sequence makes sense

---

### Step 4.2: Create Linear Ticket

**Manual Creation** (for now):

1. Go to Linear: https://linear.app
2. Create new issue
3. Title: `{{TICKET_PREFIX}}-1: Add Hello World endpoint for agent workflow validation`
4. Description: Paste BSA output
5. Add acceptance criteria
6. Add testing strategy

**Validation**:

- [ ] Linear ticket created
- [ ] Ticket has proper format ({{TICKET_PREFIX}}-1)
- [ ] All BSA output included
- [ ] Ticket is in "Backlog" or "Ready" state

---

### Step 4.3: Implement with Agent

**Invoke Backend Developer Agent**:

```
I'm implementing Linear ticket {{TICKET_PREFIX}}-1: Add Hello World endpoint.

User Story:
[PASTE USER STORY FROM BSA]

Acceptance Criteria:
[PASTE ACCEPTANCE CRITERIA]

Please help me:
1. Search for existing API endpoint patterns in the codebase
2. Implement the Hello World endpoint following existing patterns
3. Write tests according to the testing strategy
4. Validate the implementation meets all acceptance criteria

Use the BE Developer agent workflow from .claude/agents/be-developer.md
```

**Expected Output**:

- Pattern discovery results
- Implementation code
- Test code
- Validation that ACs are met

**Validation**:

- [ ] Agent searched for patterns first
- [ ] Implementation follows existing patterns
- [ ] Tests are comprehensive
- [ ] All acceptance criteria addressed

---

### Step 4.4: Create Pull Request

**Create Feature Branch**:

```bash
git checkout -b {{TICKET_PREFIX}}-1-hello-world-endpoint
git add .
git commit -m "feat(api): add Hello World endpoint [{{TICKET_PREFIX}}-1]

- Add GET /api/hello endpoint
- Return JSON with message and timestamp
- Add unit and integration tests
- Update API documentation

Closes {{TICKET_PREFIX}}-1"
git push origin {{TICKET_PREFIX}}-1-hello-world-endpoint
```

**Create PR**:

```bash
# Using GitHub CLI
gh pr create \
  --title "feat(api): add Hello World endpoint [{{TICKET_PREFIX}}-1]" \
  --body "Implements {{TICKET_PREFIX}}-1

## Changes
- Add GET /api/hello endpoint
- Add tests
- Update docs

## Testing
- Unit tests pass
- Integration tests pass
- Manual testing completed

## Linear Ticket
https://linear.app/your-team/issue/{{TICKET_PREFIX}}-1"
```

**Validation**:

- [ ] Feature branch created with proper name
- [ ] Commit message follows conventional commits
- [ ] PR created with proper title and description
- [ ] PR links to Linear ticket

---

## Phase 5: Validation & Retrospective (15 minutes)

### Step 5.1: Validate Complete Workflow

**Checklist**:

- [ ] Repository cloned and explored
- [ ] Agent provider installed (Claude Code or Augment)
- [ ] 11 agents installed and accessible
- [ ] Linear/Jira API access configured
- [ ] GitHub access configured
- [ ] BSA agent invoked successfully
- [ ] Linear ticket created with proper format
- [ ] Backend agent invoked for implementation
- [ ] Pattern discovery workflow followed
- [ ] Tests written and passing
- [ ] PR created with proper format
- [ ] PR links to Linear ticket

**Success Criteria**: All items checked ✅

---

### Step 5.2: First Day Retrospective

**Reflect on your experience**:

1. **What went well?**
   - [ ] Agent invocation was intuitive
   - [ ] Pattern discovery was helpful
   - [ ] Documentation was clear
   - [ ] Workflow felt natural

2. **What was confusing?**
   - [ ] Agent installation process
   - [ ] Which agent to invoke when
   - [ ] Pattern discovery workflow
   - [ ] Linear integration
   - [ ] PR creation process

3. **What questions do I still have?**
   - Write down 3-5 questions
   - Search documentation for answers
   - Ask in GitHub Discussions if needed

4. **What would I change?**
   - Document any pain points
   - Suggest improvements
   - Consider contributing back to the repository

---

### Step 5.3: Next Steps

**You're ready to use the methodology!** Here's what to do next:

1. **Read More Documentation**:
   - [ ] `whitepaper/section-9-implementation-guide.md` - Full implementation guide
   - [ ] `CONTRIBUTING.md` - Complete workflow guide
   - [ ] `docs/ci-cd/CI-CD-Pipeline-Guide.md` - CI/CD integration

2. **Explore Agent Roles**:
   - [ ] Read all 11 agent prompts in `.claude/agents/`
   - [ ] Understand when to use each agent
   - [ ] Practice invoking different agents

3. **Customize for Your Project**:
   - [ ] Replace {{PLACEHOLDERS}} with your project values
   - [ ] Customize DATA_DICTIONARY.md for your schema
   - [ ] Add your patterns to patterns_library/
   - [ ] Update CONTRIBUTING.md with your team's workflow

4. **Start Real Work**:
   - [ ] Create your first real Linear ticket
   - [ ] Implement a real feature using agents
   - [ ] Follow the complete SAFe workflow
   - [ ] Measure your velocity and iterate

---

## Troubleshooting

### Common Issues

**Issue**: Agent not found

- **Solution**: Verify agent files are in correct directory (`~/.claude/agents/` or `.claude/agents/`)

**Issue**: Agent doesn't respond correctly

- **Solution**: Check agent prompt file has correct frontmatter (name, description, tools, model)

**Issue**: Linear API fails

- **Solution**: Verify API key is correct and has proper permissions

**Issue**: Pattern discovery returns no results

- **Solution**: Ensure patterns_library/ directory exists and has content

**Issue**: PR creation fails

- **Solution**: Verify GitHub token has `repo` and `workflow` scopes

---

## Success!

**Congratulations!** 🎉 You've completed Day 1 of the SAFe Multi-Agent Development methodology.

**You now know how to**:

- ✅ Set up the agent system
- ✅ Invoke agents for different tasks
- ✅ Create Linear tickets with proper format
- ✅ Follow the pattern discovery workflow
- ✅ Create PRs with evidence and links

**Next**: Start using the methodology for real work and iterate based on your team's needs.

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: scott@{{PROJECT_DOMAIN}}
- Documentation: See `docs/onboarding/` for more guides
