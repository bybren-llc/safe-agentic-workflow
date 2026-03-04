# Deployment Pipeline Pattern

## What It Does

Defines a staging-then-production deployment workflow with automated staging deployment, smoke tests, a manual approval gate for production, and a documented rollback strategy. Ensures that every change is validated in a production-like environment before reaching end users, and that any failed deployment can be reversed quickly.

## When to Use

- Deploying web applications, APIs, or services to cloud infrastructure
- Projects that require a staging environment for pre-production validation
- Teams that need a manual approval gate before production deployments
- Any deployment that must support zero-downtime rollback
- Projects following the SAFe release train model with controlled releases

## Code Pattern

### 1. Deployment Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [{{MAIN_BRANCH}}]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
      skip_staging:
        description: 'Skip staging (hotfix only)'
        required: false
        default: false
        type: boolean

# Only one deployment at a time
concurrency:
  group: deploy-${{ github.event.inputs.environment || 'staging' }}
  cancel-in-progress: false  # Never cancel in-progress deployments

env:
  CI: true

jobs:
  # ──────────────────────────────────────────────────────────────────
  # Stage 1: Run CI Checks (guard against broken deploys)
  # ──────────────────────────────────────────────────────────────────
  ci-check:
    name: CI Validation
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: '{{RUNTIME_DEFAULT_VERSION}}'
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Run CI validation
        run: {{CI_VALIDATE_COMMAND}}

      - name: Build application
        run: {{BUILD_COMMAND}}
        env:
          NODE_ENV: production

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: deploy-build
          path: {{BUILD_OUTPUT_DIR}}/
          retention-days: 3

  # ──────────────────────────────────────────────────────────────────
  # Stage 2: Deploy to Staging
  # ──────────────────────────────────────────────────────────────────
  deploy-staging:
    name: Deploy to Staging
    needs: [ci-check]
    if: >-
      github.event.inputs.skip_staging != 'true' ||
      github.event.inputs.environment != 'production'
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: ${{ vars.STAGING_URL }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: deploy-build
          path: {{BUILD_OUTPUT_DIR}}/

      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment..."
          # Replace with your deployment command:
          # {{DEPLOY_COMMAND}} --env staging
          #
          # Examples by platform:
          # Vercel:    vercel deploy --prebuilt --token=${{ secrets.VERCEL_TOKEN }}
          # AWS:       aws ecs update-service --cluster staging --service app --force-new-deployment
          # Railway:   railway up --environment staging
          # Fly.io:    flyctl deploy --config fly.staging.toml
          # Heroku:    git push heroku-staging main
          # Docker:    docker push $REGISTRY/app:staging && kubectl rollout restart deployment/app -n staging
        env:
          {{DEPLOY_TOKEN_VAR}}: ${{ secrets.{{DEPLOY_TOKEN_SECRET}} }}

      - name: Record deployment
        run: |
          echo "## Staging Deployment" >> $GITHUB_STEP_SUMMARY
          echo "- **Commit**: ${{ github.sha }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Branch**: ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Time**: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> $GITHUB_STEP_SUMMARY
          echo "- **URL**: ${{ vars.STAGING_URL }}" >> $GITHUB_STEP_SUMMARY

  # ──────────────────────────────────────────────────────────────────
  # Stage 3: Smoke Tests (automated validation of staging)
  # ──────────────────────────────────────────────────────────────────
  smoke-tests:
    name: Smoke Tests (Staging)
    needs: [deploy-staging]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: '{{RUNTIME_DEFAULT_VERSION}}'
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Wait for deployment to stabilize
        run: sleep 30

      - name: Health check
        run: |
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${{ vars.STAGING_URL }}/api/health")
          if [ "$STATUS" != "200" ]; then
            echo "Health check failed with status $STATUS"
            exit 1
          fi
          echo "Health check passed (HTTP $STATUS)"

      - name: Run smoke tests
        run: {{SMOKE_TEST_COMMAND}}
        # e.g., npx playwright test --config=playwright.smoke.config.ts
        # e.g., pytest tests/smoke/ --base-url=$STAGING_URL
        env:
          BASE_URL: ${{ vars.STAGING_URL }}

      - name: Upload smoke test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: smoke-test-results
          path: {{SMOKE_TEST_RESULTS_DIR}}/
          retention-days: 7

  # ──────────────────────────────────────────────────────────────────
  # Stage 4: Production Deployment (manual approval gate)
  # ──────────────────────────────────────────────────────────────────
  deploy-production:
    name: Deploy to Production
    needs: [smoke-tests]
    runs-on: ubuntu-latest
    environment:
      name: production  # Requires manual approval in GitHub environment settings
      url: ${{ vars.PRODUCTION_URL }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: deploy-build
          path: {{BUILD_OUTPUT_DIR}}/

      - name: Pre-deployment database backup
        run: |
          echo "Creating pre-deployment database backup..."
          # Replace with your backup command:
          # {{DB_BACKUP_COMMAND}}
          #
          # Examples:
          # pg_dump $DATABASE_URL > backup-$(date +%Y%m%d-%H%M%S).sql
          # aws rds create-db-snapshot --db-instance-identifier prod-db --db-snapshot-identifier pre-deploy-${{ github.sha }}
        env:
          {{DATABASE_URL_VAR}}: ${{ secrets.PRODUCTION_DATABASE_URL }}

      - name: Deploy to production
        run: |
          echo "Deploying to production environment..."
          # Replace with your deployment command:
          # {{DEPLOY_COMMAND}} --env production
        env:
          {{DEPLOY_TOKEN_VAR}}: ${{ secrets.{{DEPLOY_TOKEN_SECRET}} }}

      - name: Production health check
        run: |
          echo "Waiting for production deployment to stabilize..."
          sleep 30
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${{ vars.PRODUCTION_URL }}/api/health")
          if [ "$STATUS" != "200" ]; then
            echo "PRODUCTION HEALTH CHECK FAILED (HTTP $STATUS)"
            echo "Initiating rollback..."
            exit 1
          fi
          echo "Production health check passed (HTTP $STATUS)"

      - name: Record production deployment
        run: |
          echo "## Production Deployment" >> $GITHUB_STEP_SUMMARY
          echo "- **Commit**: ${{ github.sha }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Branch**: ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Time**: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> $GITHUB_STEP_SUMMARY
          echo "- **URL**: ${{ vars.PRODUCTION_URL }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Approved by**: Manual approval via GitHub environment" >> $GITHUB_STEP_SUMMARY

      - name: Create release tag
        run: |
          TAG="deploy-$(date +%Y%m%d-%H%M%S)"
          git tag "$TAG" ${{ github.sha }}
          git push origin "$TAG"
          echo "Created release tag: $TAG"
```

### 2. Health Check Endpoint

```{{LANGUAGE}}
// {{SOURCE_DIR}}/api/health/route.{{EXT}}
// (or equivalent for your framework)

/**
 * GET /api/health
 *
 * Returns application health status. Used by:
 * - Deployment pipeline smoke tests
 * - Load balancer health checks
 * - Monitoring systems
 *
 * Should verify all critical dependencies (database, cache, external services).
 */
async function healthCheck() {
  const checks = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.COMMIT_SHA || 'unknown',
    checks: {} as Record<string, { status: string; latencyMs: number }>,
  };

  // Check database connectivity
  try {
    const start = Date.now();
    await {{DATABASE_HEALTH_QUERY}};  // e.g., prisma.$queryRaw`SELECT 1`
    checks.checks.database = {
      status: 'healthy',
      latencyMs: Date.now() - start,
    };
  } catch (error) {
    checks.status = 'unhealthy';
    checks.checks.database = {
      status: 'unhealthy',
      latencyMs: -1,
    };
  }

  // Check cache connectivity (if applicable)
  // try {
  //   const start = Date.now();
  //   await redis.ping();
  //   checks.checks.cache = { status: 'healthy', latencyMs: Date.now() - start };
  // } catch {
  //   checks.checks.cache = { status: 'unhealthy', latencyMs: -1 };
  // }

  const statusCode = checks.status === 'healthy' ? 200 : 503;
  return new Response(JSON.stringify(checks), {
    status: statusCode,
    headers: { 'Content-Type': 'application/json' },
  });
}
```

### 3. Rollback Procedure

```bash
#!/usr/bin/env bash
# scripts/rollback.sh
#
# Manual rollback script. Use when automated rollback is insufficient.
# This script is meant to be run by a human operator.
#
# Usage: ./scripts/rollback.sh <environment> [target-tag]
#
# Examples:
#   ./scripts/rollback.sh staging
#   ./scripts/rollback.sh production deploy-20260303-143022

set -euo pipefail

ENVIRONMENT="${1:?Usage: rollback.sh <environment> [target-tag]}"
TARGET_TAG="${2:-}"

echo "============================================"
echo " ROLLBACK: ${ENVIRONMENT}"
echo "============================================"
echo ""

# 1. Determine rollback target
if [ -z "$TARGET_TAG" ]; then
  echo "No target tag specified. Finding previous deployment..."
  TARGET_TAG=$(git tag --sort=-creatordate | grep "^deploy-" | head -2 | tail -1)
  echo "Rolling back to: ${TARGET_TAG}"
else
  echo "Rolling back to specified tag: ${TARGET_TAG}"
fi

if [ -z "$TARGET_TAG" ]; then
  echo "ERROR: No previous deployment tag found."
  exit 1
fi

# 2. Confirm with operator
echo ""
echo "This will deploy tag '${TARGET_TAG}' to '${ENVIRONMENT}'."
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Rollback cancelled."
  exit 0
fi

# 3. Execute rollback
echo ""
echo "Checking out ${TARGET_TAG}..."
git checkout "${TARGET_TAG}"

echo "Building from rollback target..."
# {{BUILD_COMMAND}}

echo "Deploying to ${ENVIRONMENT}..."
# {{DEPLOY_COMMAND}} --env "${ENVIRONMENT}"

# 4. Verify
echo ""
echo "Verifying deployment..."
sleep 30
# Replace with your environment URL variable:
# STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${ENVIRONMENT_URL}/api/health")

echo ""
echo "============================================"
echo " ROLLBACK COMPLETE"
echo "============================================"
echo " Environment: ${ENVIRONMENT}"
echo " Rolled back to: ${TARGET_TAG}"
echo " Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================"
echo ""
echo "NEXT STEPS:"
echo "  1. Verify application functionality"
echo "  2. Check error rates in monitoring"
echo "  3. Create incident ticket if needed"
echo "  4. Return to main branch: git checkout {{MAIN_BRANCH}}"
```

## Customization Guide

1. **Replace all template placeholders** with your project-specific values:
   - `{{MAIN_BRANCH}}` - primary branch name (e.g., `main`, `master`)
   - `{{DEPLOY_COMMAND}}` - your deployment CLI command
   - `{{DEPLOY_TOKEN_VAR}}` / `{{DEPLOY_TOKEN_SECRET}}` - deployment credentials
   - `{{DATABASE_URL_VAR}}` - database connection variable name
   - `{{DATABASE_HEALTH_QUERY}}` - a lightweight query to verify database connectivity
   - `{{SMOKE_TEST_COMMAND}}` - command to run smoke tests against a live URL
   - All `{{*_COMMAND}}` placeholders from CLAUDE.md

2. **Configure GitHub Environments** in your repository settings:
   - Create `staging` environment (no approval required, auto-deploy)
   - Create `production` environment (require manual approval, restrict to specific reviewers)
   - Add environment-specific variables (`STAGING_URL`, `PRODUCTION_URL`)
   - Add environment-specific secrets (database URLs, deploy tokens)

3. **Adapt the deployment steps** for your hosting platform. The deploy steps are intentionally generic; replace them with your platform's CLI commands.

4. **Customize the health check endpoint** to verify your specific dependencies (database, cache, external APIs, message queues).

5. **Adjust the rollback script** for your deployment platform. Some platforms (Vercel, Railway) have built-in rollback; others require redeploying a previous artifact.

6. **Add database migration steps** to the production deployment if your application requires schema changes. Run migrations before deploying the new code, and ensure migrations are backward-compatible.

## Security Checklist

- [ ] **Production requires manual approval** - GitHub environment protection rules configured
- [ ] **Deployment secrets isolated** - staging and production use separate secret sets
- [ ] **Database backup before production deploy** - automated backup step included
- [ ] **Health check verifies all dependencies** - not just HTTP 200, but database and cache too
- [ ] **Rollback procedure documented and tested** - team has practiced rollback at least once
- [ ] **Deployment tags created** - every production deploy is tagged for traceability
- [ ] **Concurrency prevents parallel deploys** - only one deployment runs at a time per environment
- [ ] **CI checks gate deployment** - broken code cannot be deployed
- [ ] **No secrets in build artifacts** - secrets injected at runtime, not baked into builds
- [ ] **Deployment audit trail** - GitHub Actions logs provide who approved and when

## Validation Commands

```bash
# Validate workflow YAML syntax
{{PACKAGE_MANAGER_RUN}} action-validator .github/workflows/deploy.yml

# Test health check endpoint locally
curl -s http://localhost:{{PORT}}/api/health | jq .

# Run smoke tests locally against a running instance
BASE_URL=http://localhost:{{PORT}} {{SMOKE_TEST_COMMAND}}

# Full CI validation (same gate as deployment pipeline)
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [GitHub Actions Workflow](./github-actions-workflow.md) - CI workflow that gates this deployment
- [Secrets Management](../security/secrets-management.md) - Managing deployment credentials
- [Environment Config](../config/environment-config.md) - Environment-specific configuration
- [Structured Logging](../config/structured-logging.md) - Deployment event logging
- [RLS Migration](../database/rls-migration.md) - Database migrations in deployment pipeline

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
