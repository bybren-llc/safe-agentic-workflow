# /planBranch - Start New Work Chunk with Plan-First Approach

Create implementation plan document and feature branch for new work.

**Usage**: `/planBranch [feature-name]`

## Steps

### 1. Validate Input
```bash
if [ -z "$ARGUMENTS" ]; then
  echo "ERROR: Feature name required"
  echo "Usage: /planBranch [feature-name]"
  echo "Example: /planBranch user-authentication"
  exit 1
fi

FEATURE_NAME="$ARGUMENTS"
SAFE_NAME=$(echo "$FEATURE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
DATE_PREFIX=$(date +%Y-%m-%d)
PLAN_FILE="docs/plans/${DATE_PREFIX}-${SAFE_NAME}-plan.md"
BRANCH_NAME="feature/$(date +%Y%m%d)-${SAFE_NAME}"
```

### 2. Check if Already on Main
```bash
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "WARNING: Not on main branch (currently on: $CURRENT_BRANCH)"
  echo "Run /gitFlow first to complete previous work, or switch to main manually"
  exit 1
fi
```

### 3. Ensure Main is Up-to-Date
```bash
echo "Syncing main branch..."
git pull origin main
```

### 4. Create Plan Document
```bash
mkdir -p docs/plans

cat > "$PLAN_FILE" << PLAN_EOF
# ${FEATURE_NAME} Implementation Plan

**Date**: $(date +%Y-%m-%d)
**Agent**: [Your Agent ID]
**Developer**: [Lead Developer]
**Branch**: ${BRANCH_NAME}
**ConTS Epic**: ConTS-XXXX (to be created)

---

## SAFe Context

**PI**: PI-25.X
**Sprint**: Sprint N of 5
**Sprint Goal**: [Current sprint goal]

---

## Problem Statement

[Clear description of what needs to be done and why]

---

## Objectives

### Primary Objectives (Must Have)
- [ ] Objective 1
- [ ] Objective 2
- [ ] Objective 3

### Secondary Objectives (Should Have)
- [ ] Optional enhancement 1
- [ ] Optional enhancement 2

---

## Timeline and Phases

### Phase 1: [Name] (X story points)
**ConTS Issue**: ConTS-XXX1
**Deliverables**:
1. Deliverable 1
2. Deliverable 2

### Phase 2: [Name] (X story points)
**ConTS Issue**: ConTS-XXX2
**Deliverables**:
1. Deliverable 1
2. Deliverable 2

---

## Acceptance Criteria

- [ ] Criterion 1: [Specific, measurable outcome]
- [ ] Criterion 2: [Specific, measurable outcome]
- [ ] All tests pass (lint, typecheck, unit, E2E)
- [ ] Documentation updated
- [ ] Code reviewed and approved

---

## Research References

- \`/docs/research/[relevant area]/\`
- \`/CLAUDE.md\` - Project guidelines
- [External resources if applicable]

---

## Risk Assessment

**Risk 1**: [Description]
- **Impact**: [High/Medium/Low]
- **Probability**: [High/Medium/Low]
- **Mitigation**: [Strategy to address risk]

---

## Dependencies

### Software Dependencies
- [Package or library name]
- [Service or API]

### File Dependencies
- [Existing files that will be modified]
- [New files to be created]

---

## Implementation Checklist

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Phase 2: [Name]
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Quality Gates
- [ ] \`npm run lint\` passes
- [ ] \`npm run typecheck\` passes
- [ ] \`npm test\` passes
- [ ] \`npm run test:e2e\` passes (if applicable)
- [ ] Documentation updated
- [ ] Code reviewed

---

## Rollback Procedures

**If implementation fails**:
1. [Rollback step 1]
2. [Rollback step 2]
3. Restore from backup: \`git checkout main\`

---

## Approval Status

- [ ] Plan documented (this file)
- [ ] ConTS epic created in Beads
- [ ] Human review: **PENDING APPROVAL**

---

**Next Steps**: Await approval before implementation.
PLAN_EOF

echo "Plan document created: $PLAN_FILE"
```

### 5. Create Feature Branch
```bash
echo "Creating feature branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"
```

### 6. Commit Plan Document
```bash
git add "$PLAN_FILE"
git commit -m "docs: implementation plan for ${FEATURE_NAME}

ConTS-XXXX"
git push -u origin "$BRANCH_NAME"

echo "Plan committed to branch: $BRANCH_NAME"
```

### 7. Output Instructions
```bash
echo ""
echo "/planBranch Complete!"
echo ""
echo "Plan File: $PLAN_FILE"
echo "Feature Branch: $BRANCH_NAME"
echo ""
echo "NEXT STEPS:"
echo "1. Review and complete the plan document"
echo "2. Create ConTS epic in Beads: bd create 'ConTS-${FEATURE_NAME}' -t epic"
echo "3. Await approval before implementation"
echo ""
echo "To sync with main later: /rebase-and-sync"
echo "To complete work: /gitFlow"
echo ""
```

## Summary

This command automates:
1. Validate feature name input
2. Ensure on main branch
3. Create comprehensive plan document template
4. Create feature branch with date prefix
5. Commit plan as Priority 0 task
6. Output next steps and await approval

**Use when**: Starting new work chunk after `/clear`
**Requires**: Feature name argument
**Next step**: Create ConTS epic, await approval before coding
