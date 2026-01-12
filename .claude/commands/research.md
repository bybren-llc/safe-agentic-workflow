---
description: Research the codebase to understand how something works. Creates a research document and Beads issues for discoveries.
arguments:
  - name: topic
    description: The topic or question to research
    required: true
---

# Research Protocol (Spike)

You are conducting objective research on the codebase. Your goal is to document **what exists**, not to critique or recommend changes. In SAFe terms, this is a technical spike.

## Critical Rules

1. **DO NOT** critique the implementation or identify problems
2. **DO NOT** recommend refactoring, optimization, or architectural changes
3. **ONLY** describe what exists, where it exists, how it works, and how components interact
4. You are creating a technical map/documentation of the existing system

## Research Topic

$ARGUMENTS

## Process

### Step 1: Initial Beads Check

First, check for existing related work:

```bash
bd list --status open --json
bd list --label spike,research --json
```

If related issues exist, review them for context.

### Step 2: Create Research Issue in Beads

```bash
bd create "ConTS-Spike: $ARGUMENTS" -t spike -p 2 -l spike,research,rpi --json
```

Save the returned issue ID as `$RESEARCH_ID`.

### Step 3: Spawn Parallel Research Agents

Use the Task tool to spawn these agents concurrently:

1. **codebase-locator**: Find all files related to the topic
2. **codebase-analyzer**: Understand patterns and conventions
3. **beads-context**: Check for historical context in Beads

For each agent, provide:
- The research topic
- Specific aspect to investigate
- Output format requirements

### Step 4: Compile Findings

After all agents complete, synthesize their findings into a research document.

Create file: `thoughts/shared/research/YYYY-MM-DD-{slug}.md`

Use this template:

```markdown
---
date: [ISO timestamp]
researcher: Claude
beads_issue: $RESEARCH_ID
git_commit: [current commit hash]
branch: [current branch]
topic: "$ARGUMENTS"
tags: [spike, research, relevant-component-names]
status: complete
sprint: [current sprint context]
---

# Spike: $ARGUMENTS

**ConTS Issue:** [$RESEARCH_ID](bd show $RESEARCH_ID)
**Type**: Technical Spike
**Time-box**: [X hours]

## Research Question
$ARGUMENTS

## Summary
[High-level documentation of what was found]

## Detailed Findings

### [Component/Area 1]
- Description of what exists (`file.ext:line`)
- How it connects to other components
- Current implementation details

### [Component/Area 2]
...

## Code References
- `path/to/file.ts:123` - Description
- `another/file.ts:45-67` - Description

## Discovered Issues

During research, the following items were identified for future work:

| ConTS ID | Type | Description |
|----------|------|-------------|
| ConTS-xxxx | bug | Description |
| ConTS-yyyy | enabler | Description |

## Architecture Documentation
[Current patterns, conventions, and design implementations]

## Open Questions
[Any areas that need further investigation]

## Spike Outcome
[Key decisions or recommendations based on findings]
```

### Step 5: Create Discovered Issues

For each discovery during research:

```bash
bd create "ConTS-Discovered: [description]" -t [bug|enabler|story] -p [priority] \
  -l discovered,spike \
  --json
bd dep add [new-id] $RESEARCH_ID --type discovered-from
```

### Step 6: Close Research Issue

```bash
bd update $RESEARCH_ID --status in_progress
# After document is complete:
bd close $RESEARCH_ID --reason "Spike complete. See thoughts/shared/research/YYYY-MM-DD-{slug}.md"
```

## Output

After completing research:
1. Provide a summary of findings
2. Link to the research document
3. List any discovered issues created in Beads (ConTS- prefixed)
4. Suggest next steps (usually: /plan)
