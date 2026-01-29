# Pull Request: [Brief Description] [{{TICKET_PREFIX}}-XXX]

## 📋 Summary

<!-- Provide a brief description of the changes in this PR -->

**Linear Ticket**: [{{TICKET_PREFIX}}-XXX](https://linear.app/{{LINEAR_WORKSPACE}}/issue/{{TICKET_PREFIX}}-XXX)
**Type**: `feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore`  
**Team**: `payments` | `auth` | `frontend` | `backend` | `qa` | `devops`

## 🎯 Changes Made

<!-- List the main changes made in this PR -->

- [ ] Change 1
- [ ] Change 2
- [ ] Change 3

## 🧪 Testing

### Test Coverage

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] E2E tests added/updated
- [ ] Manual testing completed

### Test Results

```bash
# Paste test results here
yarn test
```

## 📊 Impact Analysis

### Files Changed

<!-- Auto-populated by CI, but you can add context -->

### Breaking Changes

- [ ] No breaking changes
- [ ] Breaking changes (describe below)

**Breaking Change Details:**

<!-- If there are breaking changes, describe them here -->

## 🔄 Multi-Team Coordination

### Rebase Status

- [ ] Branch is up-to-date with `dev`
- [ ] No merge conflicts
- [ ] Linear history maintained

### Team Dependencies

- [ ] No dependencies on other teams
- [ ] Coordinated with: <!-- @mention teams -->

### High-Risk Files Modified

<!-- Check if any of these files were modified -->

- [ ] `.env.template`
- [ ] `config.ts` or `config/features.ts`
- [ ] `package.json` or `yarn.lock`
- [ ] `prisma/schema.prisma`
- [ ] API routes (`app/api/`)

**If high-risk files modified, explain why:**

<!-- Provide justification for changes to sensitive files -->

## 🚀 Deployment

### Environment Variables

- [ ] No new environment variables
- [ ] New environment variables added (list below)

**New Environment Variables:**

```bash
# List any new environment variables
VARIABLE_NAME=description
```

### Database Changes

- [ ] No database changes
- [ ] Database migration required
- [ ] Seed data changes

**If database changes made:**

- [ ] **DATA_DICTIONARY.md updated** (MANDATORY - single source of truth)
- [ ] Table/column definitions added with purpose and constraints
- [ ] Table count metrics updated in quick reference
- [ ] RLS policy additions documented (if user data involved)
- [ ] "Recent Changes" section updated with Linear ticket reference
- [ ] **RLS compliance verified** (if user data tables/columns added)
- [ ] Security review completed for sensitive data changes

### Feature Flags

- [ ] No feature flags involved
- [ ] Feature flag changes (describe below)

**Feature Flag Changes:**

<!-- Describe any feature flag modifications -->

## 📚 Documentation

- [ ] Code comments updated
- [ ] README updated
- [ ] API documentation updated
- [ ] Confluence documentation updated

**Database Documentation (if schema changes):**

- [ ] **docs/database/DATA_DICTIONARY.md updated** (MANDATORY)
- [ ] Related RLS documentation updated
- [ ] Team notified of schema changes
- [ ] Confluence sync scheduled (if applicable)

## ✅ Pre-merge Checklist

### Code Quality

- [ ] ESLint passes
- [ ] TypeScript compilation successful
- [ ] Prettier formatting applied
- [ ] No console.log statements in production code
- [ ] No TODO comments without tickets

### Security

- [ ] No secrets committed
- [ ] No sensitive data exposed
- [ ] Security audit passes
- [ ] Input validation implemented

### Performance

- [ ] No performance regressions
- [ ] Bundle size impact acceptable
- [ ] Database queries optimized

### SAFe Compliance

- [ ] Commit messages follow SAFe format
- [ ] Linear ticket linked and updated
- [ ] Acceptance criteria met
- [ ] Definition of Done satisfied

### Database Compliance (if schema changes)

- [ ] RLS_DATABASE_MIGRATION_SOP.md procedures followed
- [ ] DATA_DICTIONARY.md updated with schema changes
- [ ] Security implications reviewed and documented
- [ ] No user data exposed without proper RLS protection

## 🔍 Review Focus Areas

<!-- Guide reviewers on what to focus on -->

**Please pay special attention to:**

- [ ] Business logic in `[specific files]`
- [ ] Error handling in `[specific areas]`
- [ ] Performance of `[specific features]`
- [ ] Security of `[specific endpoints]`

## 📸 Screenshots/Videos

<!-- Add screenshots or videos if UI changes are involved -->

**Before:**

<!-- Screenshot of before state -->

**After:**

<!-- Screenshot of after state -->

## 🤝 Reviewer Assignment

<!-- Auto-assigned based on CODEOWNERS, but you can request specific reviewers -->

**Required Reviewers:**

- [ ] @{{ARCHITECT_GITHUB_HANDLE}} (ARCHitect-in-the-IDE)
- [ ] Team lead: @<!-- team-lead -->

**Optional Reviewers:**

- [ ] @<!-- optional-reviewer-1 -->
- [ ] @<!-- optional-reviewer-2 -->

## 📝 Additional Notes

<!-- Any additional context, concerns, or notes for reviewers -->

---

## 🚨 For Reviewers

### Review Checklist

- [ ] Code follows {{PROJECT_NAME}} coding standards
- [ ] Business logic is sound
- [ ] Error handling is comprehensive
- [ ] Tests are adequate and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance impact is acceptable
- [ ] Multi-team coordination considered

### Approval Criteria

- [ ] All CI checks pass
- [ ] Code review approved
- [ ] QA testing completed (if required)
- [ ] Architect approval (for high-risk changes)

---

**Merge Strategy**: `Rebase and merge` (maintains linear history)

<!--
Template Version: 1.0
Last Updated: 2025-08-16
Maintained by: {{PROJECT_NAME}} Development Team
-->
