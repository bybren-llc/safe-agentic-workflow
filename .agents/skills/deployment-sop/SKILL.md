---
name: deployment-sop
description: >
  Deployment workflows, pre-deploy validation, smoke testing, and rollback
  procedures. Use when deploying to staging or production, running smoke tests,
  validating deployments, or planning rollback. Do NOT use for local development
  or CI pipeline configuration.
---

# Deployment SOP Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Route to existing deployment SOPs and provide checklists for safe, validated deployments. This skill does NOT duplicate SOP content -- it links to authoritative sources.

## When This Skill Applies

- Deploying to staging or production
- Running pre-deploy validation
- Executing post-deploy smoke tests
- Coordinating release activities
- Planning rollback procedures

## Authoritative References (MUST READ)

| Document                 | Location                                          | Purpose                     |
| ------------------------ | ------------------------------------------------- | --------------------------- |
| Semantic Release SOP     | `docs/ci-cd/Semantic-Release-Deployment-SOP.md`   | Release automation workflow |
| Staging/UAT Release SOP  | `docs/sop/STAGING-UAT-RELEASE-SOP.md`             | UAT validation process      |
| Dev Machine Access       | `docs/deployment/LINUX-DEV-MACHINE-ACCESS-SOP.md` | Dev server access           |
| Production Server Access | `docs/deployment/PRODUCTION-SERVER-ACCESS-SOP.md` | Production deployment       |

## Pre-Deployment Checklist

Before ANY deployment:

- [ ] All CI checks pass (GitHub Actions green)
- [ ] PR merged to target branch
- [ ] No unresolved blockers in ticket system
- [ ] Database migrations tested locally
- [ ] Environment variables verified

```bash
# Validate before deploy
{{CI_VALIDATE_COMMAND}}
{{BUILD_COMMAND}}
```

## Post-Deployment Smoke Test

After deployment completes:

- [ ] Health endpoint responds: `curl https://{{DOMAIN}}/api/health`
- [ ] Database connection verified (check health response)
- [ ] Authentication flow works (sign-in/sign-up)
- [ ] Critical user flows functional
- [ ] No new errors in logs

```bash
# Smoke test commands
curl -s https://{{DOMAIN}}/api/health | jq .
# Expected: {"status":"healthy","timestamp":"..."}
```

## Deployment Evidence Template

For ticket attachment:

```markdown
## Deployment Evidence - {{TICKET_PREFIX}}-XXX

### Environment
- **Target**: Staging / Production
- **Branch**: `{branch_name}`
- **Commit**: `{commit_sha}`

### Pre-Deployment
- [x] CI checks passed
- [x] PR merged
- [x] Migrations verified

### Post-Deployment
- [x] Health check: PASSED
- [x] Auth flow: PASSED
- [x] Smoke tests: PASSED

### Verification
curl -s https://{{DOMAIN}}/api/health
{"status":"healthy","timestamp":"..."}
```

## Rollback Procedure

If deployment fails:

1. **Identify failure** - Check deployment logs, error tracking
2. **Revert commit** - `git revert {commit_sha}`
3. **Push revert** - Triggers automatic rollback deployment
4. **Verify rollback** - Run smoke tests again
5. **Document incident** - Update ticket with evidence

## Stop-the-Line Conditions

### FORBIDDEN

- Deploying with failing CI checks
- Skipping smoke tests on production
- Deploying database migrations without local testing
- Force-deploying over active incidents

### REQUIRED

- Health check MUST pass within 5 minutes
- Production deployments MUST have staging validation first
- Rollback plan MUST be documented before production deploy

## Branch to Environment Mapping

| Branch            | Environment   | Auto-Deploy     |
| ----------------- | ------------- | --------------- |
| `dev`             | Staging       | {{STAGING_DEPLOY_MODE}} |
| `{{MAIN_BRANCH}}` | Production   | {{PROD_DEPLOY_MODE}}    |
