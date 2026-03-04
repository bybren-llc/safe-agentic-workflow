# Agent Output Directory Guide

**Purpose**: Standardized locations for AI agent work artifacts

**Created**: 2025-10-09
**Version**: 1.0
**Scope**: All AI agents (.claude/agents/)

---

## 🎯 Quick Reference

| Agent                                  | Output Directory                        | Naming Convention                 |
| -------------------------------------- | --------------------------------------- | --------------------------------- |
| **QAS** (Quality Assurance Specialist) | `/docs/agent-outputs/qa-validations/`   | `{{TICKET_PREFIX}}-{number}-qa-validation.md`   |
| **BSA** (Business Systems Analyst)     | `/docs/agent-outputs/requirements/`     | `{{TICKET_PREFIX}}-{number}-requirements.md`    |
| **System Architect**                   | `/docs/adr/`                            | `ADR-{number}-{title}.md`         |
| **Tech Writer**                        | `/docs/agent-outputs/technical-docs/`   | `{{TICKET_PREFIX}}-{number}-technical-docs.md`  |
| **Data Engineer**                      | `/docs/agent-outputs/technical-docs/`   | `{{TICKET_PREFIX}}-{number}-migration-plan.md`  |
| **TDM** (Technical Delivery Manager)   | `/docs/agent-outputs/delivery-reports/` | `{{TICKET_PREFIX}}-{number}-delivery-report.md` |

---

## 📂 Directory Structure

```text
/docs/agent-outputs/
  /qa-validations/          ← QAS writes test reports and validation results
  /requirements/            ← BSA writes specifications and requirements
  /technical-docs/          ← Tech Writer writes documentation and migration plans
  /delivery-reports/        ← TDM writes delivery status and blocker reports

/docs/adr/                  ← System Architect writes ADRs (for all teams)
```

---

## 🔐 Critical Documentation (NEVER MOVE)

These paths are hardcoded across 80+ files. **DO NOT MODIFY THESE LOCATIONS**:

### Database Documentation

- `/docs/database/DATA_DICTIONARY.md` - **SINGLE SOURCE OF TRUTH** (mandatory read before DB work)
- `/docs/database/RLS_DATABASE_MIGRATION_SOP.md` - **MANDATORY** for schema changes
- `/docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- `/docs/database/RLS_POLICY_CATALOG.md`

### Security & Architecture

- `/docs/guides/SECURITY_FIRST_ARCHITECTURE.md` - **REQUIRED** for new services
- `/docs/guides/RLS_TROUBLESHOOTING.md`
- `/docs/guides/AGENT_TEAM_GUIDE.md`

### Code Patterns

- `/patterns_library/api/` - API route patterns
- `/patterns_library/database/` - Database migration patterns
- `/patterns_library/testing/` - Test implementation patterns
- `/patterns_library/ui/` - UI component patterns

### Quality Reports (Legacy)

- `/docs/quality-reports/.markdownlint-cli2.jsonc` - Markdown linting config for QA reports

---

## ✅ Mandatory Reading Checklist

**Before starting ANY task**, agents must check:

### Database Work?

- [ ] Read `/docs/database/DATA_DICTIONARY.md` (MANDATORY)
- [ ] Read `/docs/database/RLS_DATABASE_MIGRATION_SOP.md` (if schema changes)
- [ ] Check RLS implications

### New Service/Feature?

- [ ] Read `/docs/guides/SECURITY_FIRST_ARCHITECTURE.md` (MANDATORY)
- [ ] Review security patterns

### Pattern Work?

- [ ] Check `/patterns_library/` for existing patterns FIRST
- [ ] Reuse before creating new patterns

---

## 📝 Agent-Specific Guidelines

### QAS (Quality Assurance Specialist)

**Output Location**: `/docs/agent-outputs/qa-validations/{{TICKET_PREFIX}}-{number}-qa-validation.md`

**What to Include**:

- Test execution results (pass/fail counts)
- Acceptance criteria validation
- Evidence (screenshots, logs, test output)
- Recommendation (APPROVE or REQUEST CHANGES)

**Backwards Compatibility**: Can still write to `/docs/quality-reports/` if needed

### BSA (Business Systems Analyst)

**Output Location**: `/docs/agent-outputs/requirements/{{TICKET_PREFIX}}-{number}-requirements.md`

**What to Include**:

- User story (As a... I want... So that...)
- Acceptance criteria (testable)
- Testing strategy (unit, integration, E2E)
- Pattern references

**Primary Location**: Still use `/specs/` for implementation specs (keep this convention)

### System Architect

**Output Location**: `/docs/adr/ADR-{number}-{title}.md`

**Note**: ADRs are for all teams, not agent-specific outputs. Use the existing ADR directory.

**What to Include**:

- Architecture Decision Records (ADRs)
- Design diagrams
- Pattern validation
- Architectural standards and patterns

**Naming**: Use sequential ADR numbers (ADR-001, ADR-002, etc.) with descriptive titles

### Tech Writer

**Output Location**: `/docs/agent-outputs/technical-docs/{{TICKET_PREFIX}}-{number}-technical-docs.md`

**What to Include**:

- API documentation
- User guides
- Migration guides
- Knowledge transfer documents

**New Convention**: Previously scattered, now centralized

### Data Engineer

**Output Location**: `/docs/agent-outputs/technical-docs/{{TICKET_PREFIX}}-{number}-migration-plan.md`

**What to Include**:

- Migration plan
- Rollback strategy
- Data impact analysis
- Schema change history

**Mandatory**: Still update `/docs/database/DATA_DICTIONARY.md` for schema changes

---

## 🚀 Usage Examples

### Example 1: QAS Validation Report

```bash
# QAS agent writes validation report
cat > /docs/agent-outputs/qa-validations/{{TICKET_PREFIX}}-334-qa-validation.md <<EOF
## QA Validation Report - {{TICKET_PREFIX}}-334

**Tests Executed**: 5/5 (100% pass)
**Acceptance Criteria Met**: 6/6 (100%)
**Recommendation**: ✅ APPROVE FOR MERGE

### Test Results
- Test 1: Navigation Component Validation - PASS
- Test 2: Configuration Validation - PASS
...
EOF
```

### Example 2: BSA Requirements Document

```bash
# BSA agent writes requirements
cat > /docs/agent-outputs/requirements/{{TICKET_PREFIX}}-335-requirements.md <<EOF
## Requirements - {{TICKET_PREFIX}}-335

**User Story**: As a user, I want to...

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

**Testing Strategy**:
- Unit: Test component X
- Integration: Test API Y
...
EOF
```

### Example 3: Tech Writer Documentation

```bash
# Tech Writer creates migration guide
cat > /docs/agent-outputs/technical-docs/{{TICKET_PREFIX}}-336-migration-guide.md <<EOF
## Migration Guide - {{TICKET_PREFIX}}-336

**What Changed**: Database schema update

**Steps**:
1. Backup database
2. Run migration
3. Verify data
...
EOF
```

---

## 🔄 File Lifecycle

1. **During Work**: Agents write to `/docs/agent-outputs/{category}/{{TICKET_PREFIX}}-{number}-*.md`
2. **PR Review**: Files attached to Linear ticket for evidence
3. **After Merge**: Files remain in agent-outputs for audit trail
4. **Quarterly Archive**: Old files moved to `/docs/archive/20XX-QX/` if desired

---

## 🛡️ Best Practices

### DO

✅ Use Linear ticket number in filename (`{{TICKET_PREFIX}}-{number}-*`)
✅ Write to designated agent output directory
✅ Keep critical docs in their current locations
✅ Read mandatory docs before starting work
✅ Include evidence and traceability

### DON'T

❌ Move `/docs/database/DATA_DICTIONARY.md`
❌ Move `/docs/database/RLS_*.md` files
❌ Move `/patterns_library/` directories
❌ Skip mandatory reading checklist
❌ Create new documentation locations without coordination

---

## 📞 Questions?

**For agents**: Follow this guide. If unclear, escalate to TDM or ARCHitect.

**For humans**: Update this guide when adding new agent types or output categories.

---

**Remember**: This guide provides **clarity without breaking existing workflows**.
All critical documentation paths remain unchanged.
