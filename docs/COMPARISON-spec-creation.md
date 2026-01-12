# Comparison: WTFB Spec-Creation vs ConTStack RPI Workflow

> A comprehensive analysis of two development planning approaches to inform a unified strategy

## Executive Summary

**WTFB Spec-Creation Skill**: A structured approach to creating implementation specifications that emphasizes pattern references, testable acceptance criteria, and demo scripts. It focuses on translating business requirements into actionable specs with explicit verification commands and logical commit sequences. The approach is ticket-centric (Linear integration) and ensures every spec has runnable validation commands before implementation begins.

**ConTStack RPI Workflow**: A three-phase Research-Plan-Implement workflow that emphasizes objective codebase understanding before planning. It separates "what exists" (research) from "what to build" (plan), uses Beads issue tracking for dependency management, and creates persistent documentation in a `thoughts/shared/` directory structure. The approach focuses on phase-based implementation with blocking dependencies and explicit handoff patterns between sessions.

---

## Side-by-Side Comparison Table

| Aspect | WTFB Spec-Creation | ConTStack RPI Workflow |
|--------|-------------------|------------------------|
| **Purpose** | Translate requirements to implementation specs with testable criteria | Systematic research, planning, and implementation with context preservation |
| **Workflow Steps** | 1. Pattern Discovery 2. Spec Creation 3. Acceptance Criteria 4. Demo Script 5. Logical Commits | 1. Research (objective documentation) 2. Plan (with epic/phases) 3. Implement (phase by phase) |
| **Output Format** | Single spec document per feature | Separate research doc + plan doc + implementation |
| **File Naming** | `SPEC-{TICKET}-{number}-{description}.md` | `YYYY-MM-DD-{topic-slug}.md` (research) `YYYY-MM-DD-{beads-id}-{slug}.md` (plans) |
| **Output Location** | `specs/` directory | `thoughts/shared/research/` and `thoughts/shared/plans/` |
| **Evidence Requirements** | Markdown checklist for Linear comments | Beads issue linking with metadata frontmatter |
| **Handoff Pattern** | Linear ticket comments with deliverable checklist | Beads sync + handoff documents in `thoughts/shared/handoffs/` |
| **Issue Tracking** | Linear integration with ticket prefix | Beads CLI (`bd`) with dependency trees |
| **Verification** | Success validation commands + demo scripts | Automated (tests, lint, typecheck) + manual criteria per phase |
| **Pattern References** | Explicit links to `docs/patterns/` | Implicit via research findings with file:line references |
| **Commit Strategy** | Pre-defined logical commits in spec | Emergent from phase completion |
| **Agent Support** | Single agent execution | Sub-agent spawning (codebase-locator, codebase-analyzer, etc.) |
| **Research Phase** | Pattern discovery (brief) | Dedicated research protocol (objective, no critique) |
| **Dependency Management** | Implicit in commit sequence | Explicit blocking dependencies in Beads |
| **Session Continuity** | Via Linear ticket history | Via handoff docs + Beads notes + `/compact` command |

---

## WTFB Strengths

### 1. User Story Integration
WTFB explicitly includes user story format in every spec:
```markdown
As a [user type], I want [goal] so that [benefit].
```
This maintains connection to business value throughout technical implementation.

### 2. Pre-Defined Commit Sequence
Logical commits are planned upfront:
```markdown
1. `feat(scope): implement data model [TICKET-123]`
2. `feat(scope): add API endpoint [TICKET-123]`
3. `feat(scope): create UI component [TICKET-123]`
4. `test(scope): add unit tests [TICKET-123]`
```
This provides clear implementation order and ensures consistent commit history.

### 3. Runnable Validation Commands
Every spec includes executable verification:
```bash
yarn test:unit --grep "ModalForm"
curl -X POST http://localhost:3000/api/endpoint -d '{"test": true}'
```
This eliminates ambiguity about "done" state.

### 4. Demo Script as Living Documentation
Step-by-step demo scripts serve dual purposes:
- Verification that implementation works
- User-facing documentation/onboarding

### 5. Explicit Pattern References
Direct links to pattern library:
```markdown
- **UI Pattern**: `docs/patterns/ui/modal-form.md`
- **API Pattern**: `docs/patterns/api/crud-endpoint.md`
```
This ensures consistency and reduces decision fatigue during implementation.

### 6. Stop-the-Line Conditions
Clear anti-patterns that MUST be avoided:
- FORBIDDEN: Missing acceptance criteria
- FORBIDDEN: No pattern reference
- FORBIDDEN: No success validation

This prevents low-quality specs from entering the pipeline.

### 7. Quality Checklist
Built-in pre-submission checklist ensures completeness before work begins.

---

## ConTStack Strengths

### 1. Separation of Research and Planning
The explicit research phase produces objective documentation:
- **Critical Rule**: "DO NOT critique or recommend changes"
- **Focus**: Document what exists, where, how it works
- Creates a "technical map" before proposing changes

This prevents premature optimization and ensures complete understanding.

### 2. Beads Dependency Management
Sophisticated blocking dependencies:
```bash
bd dep add [phase-2-id] [phase-1-id] --type blocks
bd dep tree $EPIC_ID
```
This enables:
- Clear work ordering
- Unblocked work discovery (`bd ready --json`)
- Discovered issue linking

### 3. Phase-Based Implementation
Plans break down into discrete phases with:
- Individual Beads issues per phase
- Explicit blocking relationships
- Before/after code snippets with line numbers
- Per-phase success criteria

### 4. Context Window Management
Explicit strategies for staying in the "smart zone":
- Sub-agents for parallel research
- Compact frequently
- Store persistent context in Beads notes
- Handoff documents between sessions

### 5. Sub-Agent Architecture
Parallel agent spawning for research:
- **codebase-locator**: Find relevant files
- **codebase-analyzer**: Understand patterns
- **beads-context**: Historical context
- **plan-validator**: Conflict checking

This enables efficient context gathering.

### 6. Discovered Issue Protocol
Systematic capture of findings during research:
```bash
bd create "Discovered: [description]" -t [bug|task] -p [priority] \
  -l discovered,research --json
bd dep add [new-id] $RESEARCH_ID --type discovered-from
```
Ensures nothing found during research is lost.

### 7. Session Continuity
Rich handoff protocol:
- `/compact` - Create session handoff document
- `/handoff` - Full end-of-session protocol
- Beads sync on session start
- Research/plan documents persist between sessions

### 8. Specific Code References
Plans include exact file paths and line numbers:
```markdown
1. **File:** `/src/path/to/file.ts` (line 45)
   **Before:** [code]
   **After:** [code]
```
This reduces ambiguity during implementation.

---

## Recommended Unified Approach

### Core Philosophy: Research-Spec-Implement (RSI)

Combine WTFB's spec rigor with ConTStack's research depth:

```
Research (ConTStack) -> Spec (WTFB) -> Implement (ConTStack phases)
```

### Phase 1: Research Protocol (from ConTStack)
- Objective codebase documentation
- Sub-agent parallel research
- Beads issue for tracking
- Discovered issues captured
- Output: `thoughts/shared/research/YYYY-MM-DD-{topic}.md`

### Phase 2: Spec Creation (enhanced WTFB)
- User story integration
- Acceptance criteria with testable outcomes
- Pattern references (explicit links)
- Success validation commands
- Demo script for verification
- **NEW**: Link to research document
- **NEW**: Beads epic created
- Output: `specs/SPEC-{BEADS_ID}-{description}.md`

### Phase 3: Implementation Phases (from ConTStack)
- Beads phase issues with blocking dependencies
- Per-phase success criteria
- Before/after code snippets
- Automated + manual verification
- **NEW**: Pre-defined logical commits from spec

### Recommended Template Structure

```markdown
---
date: [ISO timestamp]
researcher: Claude
beads_epic: $EPIC_ID
git_commit: [current commit hash]
branch: [current branch]
feature: "[Feature Name]"
ticket: [External ticket if any]
phases: [phase-ids]
status: draft | approved | implementing | complete
---

# SPEC-{BEADS_ID}: {Feature Name}

## Research Summary
**Research Doc:** [link]
**Key Findings:** [brief summary]

## User Story
As a [user type], I want [goal] so that [benefit].

## Acceptance Criteria
- [ ] User can {action} -> {result}
- [ ] When user {triggers}, system {responds}
- [ ] {field} validates {constraint}

## Pattern References
- **UI**: `docs/patterns/ui/{pattern}.md`
- **API**: `docs/patterns/api/{pattern}.md`
- **Security**: `docs/patterns/security/{pattern}.md`

## Success Validation Command
` ``bash
npm test -- --grep "FeatureName"
curl -X POST http://localhost:3000/api/endpoint -d '{"test": true}'
` ``

## Demo Script
1. Navigate to {page}
2. Click {button}
3. Observe {expected behavior}
4. Verify {success indicator}

## Implementation Phases

### Phase 1: [Name] (Beads: {phase-1-id})
**Goal:** [What this phase accomplishes]
**Blocked By:** None

#### Changes
1. **File:** `/src/path/file.ts` (line 45)
   **Before:** [code]
   **After:** [code]

#### Success Criteria
- [ ] Tests pass: `npm test`
- [ ] Lint clean: `npm run lint`

#### Logical Commits
1. `feat(scope): implement data model [BEADS-{phase-1-id}]`

---

### Phase 2: [Name] (Beads: {phase-2-id})
**Blocked By:** Phase 1 ({phase-1-id})

[Same structure]

---

## Risk Assessment
- [Risk]: [Mitigation]

## Open Questions
- [Decision needed]
```

---

## Implementation Notes

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `.claude/commands/spec.md` | CREATE | New unified spec command |
| `.claude/commands/research.md` | MODIFY | Add link to spec phase |
| `.claude/commands/plan.md` | DEPRECATE | Merge into spec command |
| `docs/templates/spec-template.md` | CREATE | Authoritative template |
| `docs/patterns/README.md` | CREATE | Pattern library index |
| `CLAUDE.md` | MODIFY | Update RPI -> RSI documentation |

### Migration Steps

1. **Create Pattern Library**
   ```bash
   mkdir -p docs/patterns/{ui,api,database,security}
   ```
   Populate with existing patterns extracted from research docs.

2. **Create Spec Command**
   New `/spec` command that:
   - Checks for existing research doc
   - Prompts for research if none exists
   - Creates unified spec with all elements
   - Creates Beads epic and phases
   - Includes stop-the-line validation

3. **Update Research Output**
   Research docs should explicitly note:
   - "Ready for spec creation: /spec [topic]"
   - Discovered patterns to add to library

4. **Deprecate Separate Plan Command**
   - `/plan` becomes alias for `/spec`
   - Existing plans migrated to spec format

5. **Add Quality Gates**
   Pre-implementation checklist (from WTFB):
   - All acceptance criteria are testable
   - Pattern references point to existing patterns
   - Success validation command is runnable
   - Demo script is step-by-step reproducible
   - Beads epic and phases created

### Recommended Slash Commands

| Command | Purpose |
|---------|---------|
| `/research [topic]` | Objective codebase investigation |
| `/spec [topic]` | Create unified spec (includes planning) |
| `/implement [spec-path]` | Execute spec phase by phase |
| `/status` | Show current workflow status |
| `/handoff` | End-of-session protocol |

### Beads Label Strategy

| Label | Purpose |
|-------|---------|
| `research` | Research phase work |
| `spec` | Spec creation/review |
| `phase` | Implementation phase |
| `discovered` | Found during research |
| `blocked` | Waiting on dependency |
| `pattern` | Pattern library updates |

---

## Decision Points for User

1. **Pattern Library**: Does ConTStack want to adopt explicit pattern references like WTFB?
   - Recommendation: Yes - reduces inconsistency

2. **User Stories**: Should specs include explicit user story format?
   - Recommendation: Yes - maintains business value connection

3. **Demo Scripts**: Should every feature have a demo script?
   - Recommendation: Yes for user-facing features, optional for infrastructure

4. **Commit Pre-Planning**: Should specs define logical commits upfront?
   - Recommendation: Yes - improves git history consistency

5. **Stop-the-Line Rules**: Should specs be blocked if missing required elements?
   - Recommendation: Yes - prevents low-quality specs from proceeding

---

## Summary

| Aspect | WTFB | ConTStack | Unified |
|--------|------|-----------|---------|
| Research Depth | Light | Deep | Deep |
| Spec Structure | Strong | Weak | Strong |
| Phase Management | Commits | Beads Issues | Both |
| Pattern References | Explicit | Implicit | Explicit |
| Validation | Commands + Demo | Criteria | Both |
| Session Continuity | Linear | Beads + Handoffs | Beads + Handoffs |
| Agent Support | Single | Sub-agents | Sub-agents |

The unified RSI (Research-Spec-Implement) approach takes the best of both worlds:
- ConTStack's deep research and session continuity
- WTFB's rigorous spec structure and validation
- Combined dependency management via Beads
- Explicit pattern references for consistency
