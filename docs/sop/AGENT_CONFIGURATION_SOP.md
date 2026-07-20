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
model: opus            # opus | sonnet | haiku | fable | inherit | claude-*
---
```

### Required Fields

| Field         | Description                          | Example                                  |
| ------------- | ------------------------------------ | ---------------------------------------- |
| `name`        | Unique agent identifier (kebab-case) | `be-developer`                           |
| `description` | Brief role description               | `Backend Developer - API implementation` |
| `tools`       | Array of allowed tools               | `[Read, Write, Edit, Bash]`              |
| `model`       | AI model selection                   | see [Model Selection](#model-selection)  |

---

## Model Selection

### Valid values

Per the [Claude Code subagent documentation](https://code.claude.com/docs/en/sub-agents), the
`model:` field in a subagent definition accepts:

| Value | Meaning |
| --- | --- |
| `opus`, `sonnet`, `haiku`, `fable` | model aliases |
| `claude-*` | a full model ID, e.g. `claude-opus-4-8` |
| `inherit` | use the main conversation's model |
| *(omitted)* | same as `inherit` |

**Fable is selectable via the `fable` alias.** A full `claude-fable-5` ID is not documented for
subagent frontmatter, so prefer the alias.

### Resolution order

Highest precedence first:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. the per-invocation `model` parameter
3. the agent definition's `model:` frontmatter
4. the main conversation's model

### Why a bad value is dangerous here

Claude Code resolves an unusable model by **silently falling back to the inherited model** — the
docs state this for org-excluded models and do not specify behaviour for a typo. There is also **no
documented way to check which model a subagent actually ran on** afterwards.

A misconfigured model therefore produces no error and cannot be detected at runtime. Validation has
to happen at config time, which is why `tests/test-agent-models.sh` exists and why it is proven to
fail on a deliberately broken value rather than only proven to pass.

### Current state

All 11 agents declare `model: opus`. Earlier revisions of this SOP described an "Opus for planning,
Sonnet for execution" split; that taxonomy was **never implemented on disk** and has been removed
rather than restated, because a documented contract that the files contradict is worse than none.

### Evaluating a different model

Do not adopt a per-role taxonomy on assertion. Run the work both ways and compare:

```bash
# Run the entire agent team on Fable for one session — no file edits, no commit
CLAUDE_CODE_SUBAGENT_MODEL=fable claude
```

Because the env var outranks frontmatter, this exercises every agent on the candidate model. Compare
the output against the same work on the current model, then change `model:` per role with the
evidence recorded on the ticket.

---

## Tool Restrictions by Agent Role

### Planning Agents

### BSA (Business Systems Analyst)

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob, mcp__{{MCP_LINEAR_SERVER}}__*]
model: opus
```

- **Why**: Needs Linear access for ticket analysis and spec creation

### System Architect

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: Pattern validation and architectural decisions

### Execution Agents

### BE Developer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: Implementation only, no Linear/git access (RTE handles)

### FE Developer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: UI implementation only

### Data Engineer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: Schema changes and migrations

### Data Provisioning Engineer

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: opus
```

- **Why**: ETL and data pipeline implementation

### Quality Agents

### QAS (Quality Assurance Specialist) - Gate Owner (v1.4)

```yaml
tools:
  [
    Read,
    Bash,
    Grep,
    mcp__{{MCP_LINEAR_SERVER}}__create_comment,
    mcp__{{MCP_LINEAR_SERVER}}__update_issue,
    mcp__{{MCP_LINEAR_SERVER}}__list_comments,
  ]
model: opus
```

- **Why Read/Bash/Grep**: Test execution and validation (no code modification)
- **Why Linear MCP**: Posts final evidence + verdict to Linear (system of record)
- **Role (v1.4)**: Gate Owner with iteration authority - work does not proceed without QAS approval

### Security Engineer

```yaml
tools: [Read, Bash, Grep]
model: opus
```

- **Why**: Security audits and validation only

### Documentation Agent

### Tech Writer

```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash]
model: opus
```

- **Why**: Documentation creation and editing, batch doc updates
- **Why Grep/Glob**: Find files needing updates across large doc sets

### Coordination Agents

### TDM (Technical Delivery Manager)

```yaml
tools: [Read, Bash, mcp__{{MCP_LINEAR_SERVER}}__*, mcp__{{MCP_CONFLUENCE_SERVER}}__*]
model: opus
```

- **Why**: Orchestration, Linear/Confluence updates, no code modification

### RTE (Release Train Engineer) - PR Shepherd (v1.4)

```yaml
tools: [Read, Bash, Grep]
model: opus
```

- **Why Read/Bash/Grep**: Git/PR management via Bash (git commands, gh CLI)
- **Role (v1.4)**: PR Shepherd - creates PRs, monitors CI, but does NOT write product code or merge
- **Boundaries**: {{AUTHOR_NAME}} (HITL) remains final merge authority. RTE shepherds PRs to "Ready for HITL Review"

---

## Model Selection Criteria

See [Model Selection](#model-selection) above for the valid values, the resolution order, and how to
evaluate a candidate model across the whole team.

This section previously prescribed an "Opus for planning, Sonnet for execution" split by role. That
split was never implemented — every agent declares `model: opus` — so the guidance has been removed
rather than restated. Choosing a per-role taxonomy is an open question to settle with evidence, not
a rule this document can assert.

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

**Linear MCP** (`mcp__{{MCP_LINEAR_SERVER}}__*`):

- ✅ BSA - Ticket analysis and spec creation
- ✅ TDM - Orchestration and progress updates
- ✅ QAS (v1.4) - Evidence posting and verdict (Gate Owner role - system of record)
- ❌ Execution agents - No direct Linear access (reduces noise)

**Confluence MCP** (`mcp__{{MCP_CONFLUENCE_SERVER}}__*`):

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
model: opus            # opus | sonnet | haiku | fable | inherit | claude-*
---
# Agent Name

## Role Overview

[Description of agent responsibilities]
```

### Step 3: Determine Tool Access

**Ask**:

1. Does this agent need to create/modify code? → `Write`, `Edit`
2. Does this agent need to run tests/validation? → `Bash`
3. Does this agent need to update Linear? → `mcp__{{MCP_LINEAR_SERVER}}__*`
4. Does this agent need to search codebase? → `Grep`, `Glob`

### Step 4: Select Model

Set `model:` to one of the values in [Model Selection](#model-selection). Every existing agent
declares `model: opus`; match that unless you have evidence for something else, and record the
evidence on the ticket.

Do not infer a role-to-model mapping from this document — there isn't one, deliberately. If you
want to try a different model, run the team on it with `CLAUDE_CODE_SUBAGENT_MODEL` and compare
before committing a per-role change.

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

1. Verify the `model` field in frontmatter
2. Run `bash tests/test-agent-models.sh` — it names the agent and the offending value
3. Correct the value to one listed in [Model Selection](#model-selection)

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
