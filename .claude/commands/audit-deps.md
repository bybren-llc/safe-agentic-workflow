---
description: Run comprehensive dependency audit
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

Execute dependency audit to identify optimization opportunities and security issues.

## Audit Workflow

### 1. Security Audit

Check for vulnerabilities:

```bash
yarn audit
```

Report:

- Critical/High severity issues
- Packages with known vulnerabilities
- Recommended upgrades

### 2. Bundle Analysis

Run bundle analyzer:

```bash
ANALYZE=true yarn build
```

Identify:

- Largest packages
- Duplicate dependencies
- Unused code opportunities

### 3. Unused Dependencies

Run depcheck:

```bash
npx depcheck
```

Find:

- Unused dependencies (can remove)
- Missing dependencies (should add)
- Dependencies only in devDependencies

### 4. Outdated Packages

Check for updates:

```bash
yarn outdated
```

Report:

- Packages with newer versions
- Major vs minor vs patch updates
- Breaking change risks

### 5. Specific Checks

**Icon Libraries** (common bloat):

```bash
find . -name "*.tsx" -o -name "*.ts" | xargs grep -h "from.*icons" | sort -u
```

Analyze:

- Which icon libraries used
- Usage patterns
- Consolidation opportunities

**Large Packages**:

```bash
du -sh node_modules/* | sort -hr | head -20
```

Identify:

- Top 20 largest packages
- Unnecessary large dependencies

### 6. Create Audit Report

Document findings in `docs/agent-outputs/technical-docs/dependency-audit-report-{date}.md`:

```markdown
# Dependency Audit Report

**Date**: {current-date}
**Scope**: Full dependency audit
**Tools**: yarn audit, depcheck, bundle-analyzer

## Executive Summary

- Total packages: {count}
- Security issues: {count} ({severity})
- Optimization potential: {size} MB
- Quick wins: {count} tickets

## Findings

### 1. Security Issues

- List critical/high issues
- Recommended actions

### 2. Bundle Size Optimization

- Current size: {size}
- Bloat identified: {list}
- Savings potential: {size}

### 3. Unused Dependencies

- Runtime: {list}
- DevDependencies: {list}
- Action: Can remove

### 4. Missing Dependencies

- {list}
- Action: Should add

### 5. Outdated Packages

- Major updates: {list}
- Minor updates: {list}
- Patch updates: {list}

## Recommendations

### Immediate Actions (High Priority)

1. {action}
2. {action}

### Short-term (Medium Priority)

1. {action}
2. {action}

### Long-term (Low Priority)

1. {action}
2. {action}

## Implementation Tickets

Create Linear tickets for each actionable item:

- {{TICKET_PREFIX}}-{number}: {description}
```

### 7. Create Linear Tickets

For each significant finding:

- Create ticket with clear scope
- Add to backlog
- Prioritize based on impact
- Estimate effort

Use MCP:

```text
mcp__linear-mcp__create_issue
```

## Audit Frequency

Run audits:

- **Monthly**: Quick security check
- **Quarterly**: Full dependency audit
- **Before major releases**: Comprehensive audit
- **After dependency upgrades**: Validation audit

## Success Criteria

- ✅ All audit tools run successfully
- ✅ Findings documented completely
- ✅ Tickets created for actionable items
- ✅ Team has clear prioritization
- ✅ Baseline established for next audit

This provides systematic approach to dependency management and optimization.

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description               | Example               |
| ----------------- | ------------------------- | --------------------- |
| `{{TICKET_PREFIX}}` | Your Linear ticket prefix | `WOR`, `PROJ`, `TASK` |
