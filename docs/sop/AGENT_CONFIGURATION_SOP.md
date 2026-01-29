# Agent Configuration SOP

## Standard Operating Procedure for Configuring Claude Code Agents

**Version**: 1.0
**Last Updated**: 2025-10-03
**Owner**: {{PROJECT_SHORT}} Development Team

---

## Overview

This SOP defines how to configure and maintain the 11-agent system for the {{PROJECT_SHORT}} application.
All agent configurations use YAML frontmatter to specify tool restrictions and model selection.

## Agent Configuration Format

### YAML Frontmatter Structure

Every agent file in `.claude/agents/` must start with YAML frontmatter:

```yaml
---
name: agent-name
description: Brief description of agent role
tools: [Tool1, Tool2, Tool3]
model: opus|sonnet
---
```

### Required Fields

| Field         | Description                          | Example                                  |
| ------------- | ------------------------------------ | ---------------------------------------- |
| `name`        | Unique agent identifier (kebab-case) | `be-developer`                           |
| `description` | Brief role description               | `Backend Developer - API implementation` |
| `tools`       | Array of allowed tools               | `[Read, Write, Edit, Bash]`              |
| `model`       | AI model selection                   | `opus` or `sonnet`                       |

---

## Tool Restrictions by Agent Role

### Planning Agents (Opus Model)

### BSA (Business Systems Analyst)

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob, mcp__linear-mcp__*]
model: opus
```

- **Why**: Needs Linear access for ticket analysis and spec creation
- **Why Opus**: Complex planning and requirements decomposition

### System Architect

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: Pattern validation and architectural decisions
- **Why Opus**: High-level architectural thinking required

### Execution Agents (Sonnet Model)

### BE Developer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: sonnet
```

- **Why**: Implementation only, no Linear/git access (RTE handles)
- **Why Sonnet**: Fast, efficient implementation

### FE Developer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: sonnet
```

- **Why**: UI implementation only
- **Why Sonnet**: Fast, efficient implementation

### Data Engineer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: sonnet
```

- **Why**: Schema changes and migrations
- **Why Sonnet**: Structured implementation work

### Data Provisioning Engineer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: sonnet
```

- **Why**: ETL and data pipeline implementation
- **Why Sonnet**: Structured implementation work

### Quality Agents (Sonnet Model)

### QAS (Quality Assurance Specialist) - Gate Owner (v1.4)

```yaml
tools:
  [
    Read,
    Bash,
    Grep,
    mcp__linear-mcp__create_comment,
    mcp__linear-mcp__update_issue,
    mcp__linear-mcp__list_comments,
  ]
model: sonnet
```

- **Why Read/Bash/Grep**: Test execution and validation (no code modification)
- **Why Linear MCP**: Posts final evidence + verdict to Linear (system of record)
- **Why Sonnet**: Efficient test validation
- **Role (v1.4)**: Gate Owner with iteration authority - work does not proceed without QAS approval

### Security Engineer

```yaml
tools: [Read, Bash, Grep]
model: sonnet
```

- **Why**: Security audits and validation only
- **Why Sonnet**: Focused security checks

### Documentation Agent (Sonnet Model)

### Tech Writer

```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash]
model: sonnet
```

- **Why**: Documentation creation and editing, batch doc updates
- **Why Grep/Glob**: Find files needing updates across large doc sets
- **Why Sonnet**: Efficient documentation writing

### Coordination Agents (Sonnet Model)

### TDM (Technical Delivery Manager)

```yaml
tools: [Read, Bash, mcp__linear-mcp__*, mcp__confluence-mcp__*]
model: sonnet
```

- **Why**: Orchestration, Linear/Confluence updates, no code modification
- **Why Sonnet**: Efficient coordination and management

### RTE (Release Train Engineer) - PR Shepherd (v1.4)

```yaml
tools: [Read, Bash, Grep]
model: sonnet
```

- **Why Read/Bash/Grep**: Git/PR management via Bash (git commands, gh CLI)
- **Why Sonnet**: Efficient release coordination
- **Role (v1.4)**: PR Shepherd - creates PRs, monitors CI, but does NOT write product code or merge
- **Boundaries**: Scott (HITL) remains final merge authority. RTE shepherds PRs to "Ready for HITL Review"

---

## Model Selection Criteria

### When to Use Opus

- **Complex Planning**: BSA requirements decomposition
- **Architectural Decisions**: System Architect pattern validation
- **Strategic Thinking**: High-level design and tradeoff analysis

**Cost**: Higher per token, but critical for planning accuracy

### When to Use Sonnet

- **Implementation**: All execution agents (BE, FE, DE, etc.)
- **Testing**: QAS and Security Engineer
- **Documentation**: Tech Writer
- **Coordination**: TDM and RTE

**Cost**: Lower per token, optimized for structured tasks

---

## Tool Access Guidelines

### Core Tools

**Available to Most Agents**:

- `Read` - Read files (all agents)
- `Write` - Create new files (implementation agents)
- `Edit` - Modify existing files (implementation agents)
- `Bash` - Execute bash commands (most agents)
- `Grep` - Search file contents (implementation and quality agents)
- `Glob` - File pattern matching (implementation agents)

### Restricted Tools

**Linear MCP** (`mcp__linear-mcp__*`):

- ✅ BSA - Ticket analysis and spec creation
- ✅ TDM - Orchestration and progress updates
- ✅ QAS (v1.4) - Evidence posting and verdict (Gate Owner role - system of record)
- ❌ Execution agents - No direct Linear access (reduces noise)

**Confluence MCP** (`mcp__confluence-mcp__*`):

- ✅ TDM - Documentation coordination
- ❌ Others - Limited to essential use cases

### Git Operations

**Via Bash Tool**:

- ✅ RTE - PR creation, branch management (via `git` and `gh` commands)
- ❌ Execution agents - No direct git access (RTE handles releases)

---

## Adding a New Agent

### Step 1: Create Agent File

```bash
# Create file in .claude/agents/
touch .claude/agents/new-agent.md
```

### Step 2: Add Frontmatter

```yaml
---
name: new-agent
description: Brief role description
tools: [appropriate tools based on role]
model: opus|sonnet
---
# Agent Name

## Role Overview

[Description of agent responsibilities]
```

### Step 3: Determine Tool Access

**Ask**:

1. Does this agent need to create/modify code? → `Write`, `Edit`
2. Does this agent need to run tests/validation? → `Bash`
3. Does this agent need to update Linear? → `mcp__linear-mcp__*`
4. Does this agent need to search codebase? → `Grep`, `Glob`

### Step 4: Select Model

**Opus if**:

- Complex planning or architecture
- Strategic decision-making
- Pattern creation/validation

**Sonnet if**:

- Implementation work
- Testing and validation
- Documentation
- Coordination

### Step 5: Test Configuration

```bash
# Verify frontmatter syntax
head -10 .claude/agents/new-agent.md

# Test agent invocation (after restart)
# Main Claude uses Task tool to invoke agent
```

---

## Modifying Existing Agents

### Changing Tool Access

1. Read current agent file
2. Update `tools` array in frontmatter
3. Document reason for change in git commit
4. Update this SOP if pattern changes

**Example**:

```bash
# Before
tools: [Read, Bash]

# After (adding grep capability)
tools: [Read, Bash, Grep]
```

### Changing Model Selection

1. Evaluate if agent role changed (planning vs execution)
2. Update `model` field
3. Test performance and cost impact
4. Document in Linear ticket

---

## Validation Checklist

Before committing agent configuration changes:

- [ ] YAML frontmatter syntax is valid
- [ ] `name` field matches filename (kebab-case)
- [ ] `tools` array includes only necessary tools
- [ ] `model` selection appropriate for agent role
- [ ] Agent description is clear and concise
- [ ] Tool restrictions documented in this SOP
- [ ] Changes tested with agent invocation

---

## Troubleshooting

### Agent Cannot Access Tool

**Error**: "Tool X not available to agent Y"

**Solution**:

1. Check agent frontmatter `tools` array
2. Add required tool if justified by agent role
3. Update SOP with rationale

### Agent Using Wrong Model

**Error**: Performance issues or unexpected behavior

**Solution**:

1. Verify `model` field in frontmatter
2. Confirm Opus for planning, Sonnet for execution
3. Test with corrected model

### Frontmatter Parse Error

**Error**: Agent fails to load

**Solution**:

1. Verify YAML syntax (proper indentation, quotes)
2. Ensure `---` delimiters on separate lines
3. Validate with YAML linter if needed

---

## Related Documentation

- [Agent Workflow SOP](./AGENT_WORKFLOW_SOP.md) - How to invoke and orchestrate agents
- [AGENTS.md](/AGENTS.md) - Agent team quick reference
- [CONTRIBUTING.md](/CONTRIBUTING.md) - Development workflow

---

**Questions?** Contact {{PROJECT_SHORT}} Development Team or System Architect
