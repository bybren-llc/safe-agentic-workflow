---
name: spec-creation
description: >
  Spec creation with pattern references, acceptance criteria, and demo scripts.
  Use when creating implementation specs, defining acceptance criteria, breaking
  down user stories, or translating business requirements to technical specs.
  Do NOT use for implementation work -- this is for planning and specification only.
---

# Spec Creation Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Guide spec creation with clear acceptance criteria, pattern references for execution agents, and testable success validation commands.

## When This Skill Applies

- Creating implementation specs
- Breaking down user stories
- Defining acceptance criteria
- Adding pattern references for execution
- Creating demo scripts for validation
- Translating business requirements to technical specs

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```markdown
# FORBIDDEN: Missing acceptance criteria
## Implementation
Just do the thing.

# FORBIDDEN: No pattern reference
## Technical Approach
Build it however you want.

# FORBIDDEN: No success validation
## Done Criteria
Looks good to reviewer.
```

### CORRECT Patterns

```markdown
# CORRECT: Clear acceptance criteria
## Acceptance Criteria
- [ ] User can click button -> modal appears
- [ ] Modal shows validation errors for empty fields
- [ ] Successful submission shows success toast

# CORRECT: Pattern reference for execution
## Pattern Reference
- **UI Pattern**: `patterns_library/ui/modal-form.md`
- **API Pattern**: `patterns_library/api/crud-endpoint.md`
- **RLS Pattern**: `patterns_library/security/rls-user-data.md`

# CORRECT: Success validation command
## Success Validation
{{CI_VALIDATE_COMMAND}}
```

## Spec Template (MANDATORY)

Every spec must include:

```markdown
# SPEC-{{TICKET_PREFIX}}-{number}: {Feature Name}

## Summary
{One paragraph describing the feature}

## User Story
As a [user type], I want [goal] so that [benefit].

## Acceptance Criteria
- [ ] {Testable criterion 1}
- [ ] {Testable criterion 2}
- [ ] {Testable criterion 3}

## Pattern References
- **UI**: `patterns_library/ui/{pattern}.md`
- **API**: `patterns_library/api/{pattern}.md`
- **Database**: `patterns_library/database/{pattern}.md`
- **Security**: Follow RLS patterns in `docs/database/RLS_IMPLEMENTATION_GUIDE.md`

## Success Validation Command
{validation command}

## Demo Script
1. Navigate to {page}
2. Click {button}
3. Observe {expected behavior}
4. Verify {success indicator}

## Logical Commits
1. `feat(scope): implement data model [{{TICKET_PREFIX}}-{number}]`
2. `feat(scope): add API endpoint [{{TICKET_PREFIX}}-{number}]`
3. `feat(scope): create UI component [{{TICKET_PREFIX}}-{number}]`
4. `test(scope): add unit tests [{{TICKET_PREFIX}}-{number}]`
```

## Acceptance Criteria Patterns

### User Action Criteria

```markdown
- [ ] User can {action} -> {result}
- [ ] When user {triggers}, system {responds}
- [ ] User receives {feedback} after {action}
```

### Data Criteria

```markdown
- [ ] Data persists after {action}
- [ ] User can only see their own {data type}
- [ ] {field} validates {constraint}
```

### Error Criteria

```markdown
- [ ] Invalid input shows {error message}
- [ ] Network failure shows retry option
- [ ] Unauthorized access returns 401
```

## Pattern Discovery for Specs

Before writing any spec:

```bash
# Find existing patterns
ls patterns_library/

# Search for similar implementations
grep -r "similar feature" app/ lib/

# Check existing specs for format
ls specs/
```

## Spec Quality Checklist

Before submitting spec:

- [ ] All acceptance criteria are testable (can verify pass/fail)
- [ ] Pattern references point to existing patterns
- [ ] Success validation command is runnable
- [ ] Demo script is step-by-step reproducible
- [ ] Logical commits follow SAFe format
- [ ] Ticket referenced

## Output Locations

| Output Type  | Location                                                  |
| ------------ | --------------------------------------------------------- |
| Impl specs   | `specs/SPEC-{{TICKET_PREFIX}}-{number}-{description}.md`  |
| Requirements | `docs/agent-outputs/requirements/{{TICKET_PREFIX}}-*.md`  |
| ADRs         | `docs/adr/ADR-{number}-{description}.md`                  |

## Evidence for Ticket System

After spec approval:

```markdown
**BSA Spec Evidence**

**Spec**: specs/SPEC-{{TICKET_PREFIX}}-{number}-{description}.md
**Status**: Approved by [reviewer]

**Deliverables**:
- [x] Acceptance criteria defined
- [x] Pattern references added
- [x] Demo script created
- [x] Ready for implementation
```

## Authoritative References

- **Spec Template**: `docs/archive/specs/spec_template.md`
- **Pattern Library**: `patterns_library/README.md`
- **Planning Guide**: `docs/team/PLANNING-AGENT-META-PROMPT.md`
- **SAFe Workflow**: `CONTRIBUTING.md`
