---
name: deployment-sop
description: Deployment workflows for Convex + Vercel, pre-deploy validation, and smoke testing patterns. Use when deploying to staging or production, running smoke tests, or validating deployments.
---

# Deployment SOP Skill (ConTStack)

## Purpose

Guide safe, validated deployments to Convex Cloud and Vercel. This skill provides checklists and procedures for the ConTStack monorepo architecture.

## When This Skill Applies

Invoke this skill when:

- Deploying to staging or production
- Running pre-deploy validation
- Executing post-deploy smoke tests
- Deploying Convex backend functions
- Deploying Vercel frontend apps
- Coordinating release activities

## Architecture Overview

ConTStack uses a dual-deployment architecture:

| Component       | Platform     | Deployment Method           |
| --------------- | ------------ | --------------------------- |
| Backend (Convex)| Convex Cloud | `bunx convex deploy`        |
| Frontend Apps   | Vercel       | Git push + Vercel CLI       |
| bubble-api      | Vercel/Node  | Vercel Functions            |

## Local Development Setup

### Port Mappings

| App        | Port | Command           |
| ---------- | ---- | ----------------- |
| Main App   | 3003 | `bun dev:app`     |
| CRM        | 3006 | `bun dev:crm`     |
| bubble-api | 3007 | `bun dev:bubble`  |
| Web (Marketing) | 3000 | `bun dev:web` |

### Start Local Dev

```bash
# Full monorepo dev (all apps + Convex)
bun dev

# Individual services
bun dev:app      # Main SaaS app (port 3003)
bun dev:crm      # CRM app (port 3006)
bun dev:web      # Marketing site (port 3000)
bun dev:convex   # Backend API only
bun dev:email    # Email template preview
```

## Environment Variables

### Required for Deployment

Verify these are set before deploying:

```bash
# Convex (required for backend deploy)
CONVEX_DEPLOY_KEY=prod:xxx...    # From Convex Dashboard > Settings > Deploy Key

# Vercel (required for frontend deploy)
VERCEL_TOKEN=xxx...              # From Vercel > Settings > Tokens
VERCEL_ORG_ID=xxx...             # Team/org ID
VERCEL_PROJECT_ID=xxx...         # Project-specific ID

# Verify locally
echo $CONVEX_DEPLOY_KEY | head -c 20
echo $VERCEL_TOKEN | head -c 10
```

### Environment-Specific Variables

| Variable                | Staging                  | Production               |
| ----------------------- | ------------------------ | ------------------------ |
| `CONVEX_DEPLOYMENT`     | staging deployment name  | production deployment    |
| `NEXT_PUBLIC_CONVEX_URL`| https://xxx.convex.cloud | https://xxx.convex.cloud |
| `WORKOS_CLIENT_ID`      | staging client ID        | production client ID     |
| `WORKOS_API_KEY`        | staging API key          | production API key       |

## Pre-Deployment Checklist

Before ANY deployment:

### Code Quality Gates

- [ ] All CI checks pass (GitHub Actions green)
- [ ] TypeScript compiles: `bun typecheck`
- [ ] Linting passes: `bun lint`
- [ ] Unit tests pass: `bun test`
- [ ] E2E tests pass: `bun test:e2e:docker:comprehensive`

### Convex Schema Validation

- [ ] Schema changes reviewed for breaking changes
- [ ] Index changes validated (no dropped indexes in production)
- [ ] Migrations tested locally with `bunx convex dev`
- [ ] No orphaned schema references

```bash
# Validate Convex schema
cd packages/backend
bunx convex dev --typecheck-only

# Check for schema drift
bunx convex function-info
```

### Environment Verification

```bash
# Verify all required env vars
./scripts/verify-deploy-env.sh

# Or manually check
[ -n "$CONVEX_DEPLOY_KEY" ] && echo "Convex key: OK" || echo "Convex key: MISSING"
[ -n "$VERCEL_TOKEN" ] && echo "Vercel token: OK" || echo "Vercel token: MISSING"
```

### Build Validation

```bash
# Full build validation
bun run build

# Or with Turborepo
turbo build
```

## Deployment Procedures

### Staging Deployment

1. **Deploy Convex Backend First**

```bash
cd packages/backend

# Deploy to staging
CONVEX_DEPLOYMENT=staging bunx convex deploy

# Verify deployment
bunx convex deployment list
```

2. **Deploy Frontend to Vercel Preview**

```bash
# Push to staging branch triggers Vercel preview
git push origin staging

# Or manual deploy
vercel --env staging
```

3. **Run Staging Smoke Tests**

```bash
# See Post-Deployment Smoke Tests section
```

### Production Deployment

**STOP**: Production requires staging validation first!

1. **Verify Staging Success**

- [ ] Staging smoke tests passed
- [ ] No new errors in staging logs
- [ ] QA sign-off received (if applicable)

2. **Deploy Convex Backend**

```bash
cd packages/backend

# Production deploy
bunx convex deploy --prod

# Or with explicit deployment
CONVEX_DEPLOYMENT=production bunx convex deploy
```

3. **Deploy Frontend to Production**

```bash
# Merge to main triggers production deploy
git checkout main
git merge staging
git push origin main

# Or manual production deploy
vercel --prod
```

## Post-Deployment Smoke Tests

### Convex Backend Verification

```bash
# Check Convex deployment health
cd packages/backend
bunx convex logs --tail

# Verify functions are responding
bunx convex run --watch functions:health

# Check for errors in recent logs
bunx convex logs --error --since 5m
```

### Frontend Verification

```bash
# Health endpoint check
curl -s https://{domain}/api/health | jq .
# Expected: {"status":"healthy","timestamp":"...","convex":"connected"}

# Convex connection check
curl -s https://{domain}/api/convex-status | jq .
# Expected: {"connected":true,"deployment":"..."}
```

### Critical Flow Verification

- [ ] Authentication flow works (WorkOS sign-in/sign-up)
- [ ] Protected routes require auth
- [ ] Organization scoping works correctly
- [ ] Real-time updates function (Convex subscriptions)
- [ ] CRUD operations work for core entities

### Automated Smoke Test

```bash
# Run E2E smoke tests against deployed environment
PLAYWRIGHT_BASE_URL=https://{domain} bun test:e2e:smoke

# Or Docker-based
bun test:e2e:docker:smoke --base-url=https://{domain}
```

## Deployment Evidence Template

For issue tracking attachment:

```markdown
## Deployment Evidence - {TICKET_ID}

### Environment

- **Target**: Staging / Production
- **Branch**: `{branch_name}`
- **Commit**: `{commit_sha}`
- **Convex Deployment**: `{deployment_name}`
- **Vercel Deployment**: `{vercel_url}`

### Pre-Deployment

- [x] TypeScript compiles
- [x] Lint passes
- [x] Unit tests pass
- [x] E2E tests pass
- [x] Schema validated

### Convex Backend

- [x] Deploy successful: `bunx convex deploy` exited 0
- [x] Functions accessible
- [x] No errors in logs

### Vercel Frontend

- [x] Build successful
- [x] Health check: PASSED
- [x] Auth flow: PASSED

### Verification

Health Check:
curl -s https://{domain}/api/health
{"status":"healthy","timestamp":"2025-XX-XXTXX:XX:XX.XXXZ","convex":"connected"}

Convex Logs (last 5 min):
bunx convex logs --since 5m
[No errors detected]
```

## Rollback Procedures

### Convex Backend Rollback

Convex supports instant rollbacks to previous deployments:

```bash
cd packages/backend

# List recent deployments
bunx convex deployment list

# Rollback to previous deployment
bunx convex deployment rollback

# Or rollback to specific deployment
bunx convex deployment rollback --to {deployment_id}

# Verify rollback
bunx convex logs --tail
```

### Vercel Frontend Rollback

```bash
# List recent deployments
vercel ls

# Rollback to previous production deployment
vercel rollback

# Or rollback to specific deployment
vercel rollback {deployment_url}

# Instant rollback via Vercel Dashboard
# Vercel Dashboard > Deployments > Promote to Production
```

### Emergency Rollback (Both)

If critical failure detected:

1. **Immediate Actions**

```bash
# Rollback Convex first (backend)
cd packages/backend
bunx convex deployment rollback

# Rollback Vercel (frontend)
vercel rollback
```

2. **Verify Rollback**

```bash
# Run smoke tests
curl -s https://{domain}/api/health
bunx convex logs --since 5m --error
```

3. **Document Incident**

- Update issue tracker with rollback evidence
- Note root cause if known
- Schedule post-mortem if major incident

### Git-Based Rollback

If deployment tools fail:

```bash
# Revert the problematic commit
git revert {commit_sha}
git push origin main

# This triggers fresh deployment with reverted code
```

## Stop-the-Line Conditions

### FORBIDDEN

- Deploying with failing CI checks
- Skipping Convex schema validation
- Deploying breaking schema changes without migration plan
- Production deploy without staging validation
- Force-deploying over active incidents

### REQUIRED

- Health check MUST pass within 5 minutes
- Production deployments MUST have staging validation first
- Schema changes MUST be backwards-compatible or have migration
- Rollback plan MUST be confirmed before production deploy

## Branch - Environment Mapping

| Branch    | Convex Environment | Vercel Environment | Auto-Deploy |
| --------- | ------------------ | ------------------ | ----------- |
| `main`    | Production         | Production         | Yes         |
| `staging` | Staging            | Preview            | Yes         |
| `dev`     | Dev                | Preview            | Yes         |
| Feature   | Dev (shared)       | Preview            | Yes         |

## Troubleshooting

### Convex Deploy Fails

```bash
# Check for type errors
bunx convex dev --typecheck-only

# Check for schema issues
bunx convex codegen

# View detailed error
bunx convex deploy --debug
```

### Vercel Deploy Fails

```bash
# Check build logs
vercel logs {deployment_url}

# Rebuild with verbose
vercel --debug

# Check for env var issues
vercel env ls
```

### Post-Deploy Issues

```bash
# Convex function errors
bunx convex logs --error --since 30m

# Check subscription health
bunx convex logs --filter "subscription"

# Vercel function logs
vercel logs --output raw
```

## Related Documentation

- [packages/backend/CLAUDE.md](/packages/backend/CLAUDE.md) - Convex patterns
- [tests/CLAUDE.md](/tests/CLAUDE.md) - E2E testing guide
- [infra/CLAUDE.md](/infra/CLAUDE.md) - Infrastructure setup
- [docs/v1-setup-deployment-guide.md](/docs/v1-setup-deployment-guide.md) - Full deployment guide
