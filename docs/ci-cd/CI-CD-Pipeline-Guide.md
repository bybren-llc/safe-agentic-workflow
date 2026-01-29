# {{PROJECT_NAME}}-app CI/CD Pipeline Guide

_Automated multi-team collaboration with enforced rebase-first workflow_

## 🎯 Overview

This CI/CD pipeline solves multi-team collaboration challenges by automating the rebase-first workflow, enforcing code quality standards, and preventing conflicts before they reach the `{{PRIMARY_DEV_BRANCH}}` branch.

## 🏗️ Pipeline Architecture

### Core Workflows

1. **Multi-Team Collaboration Pipeline** (`.github/workflows/multi-team-collaboration.yml`)
2. **Branch Protection Enforcement** (`.github/workflows/branch-protection.yml`)

### Supporting Files

- **CODEOWNERS** - Defines review requirements for different code areas
- **PR Template** - Standardizes pull request information
- **Package Scripts** - Provides CI/CD integration commands

## 🔄 Workflow Stages

### Stage 1: Structure Validation 🔍

**Triggers**: PR opened/updated to `{{PRIMARY_DEV_BRANCH}}`

**Validates**:

- Branch naming: `{{TICKET_PREFIX}}-{number}-{description}`
- PR title includes Linear ticket: `[{{TICKET_PREFIX}}-XXX]`
- Linear ticket extraction and validation

**Failure Actions**:

- Blocks PR progression
- Provides clear error messages
- Suggests corrections

### Stage 2: Rebase Status Check 🔄

**Checks**:

- Branch is up-to-date with `{{PRIMARY_DEV_BRANCH}}`
- No commits behind `{{PRIMARY_DEV_BRANCH}}` branch
- Linear history maintained

**Auto-Actions**:

- Comments on PR with rebase instructions
- Shows recent commits on `{{PRIMARY_DEV_BRANCH}}`
- Blocks merge until rebased

### Stage 3: Comprehensive Testing 🧪

**Test Matrix**:

- **Unit Tests**: Fast, isolated component tests
- **Integration Tests**: API and database integration
- **E2E Tests**: Full user workflow testing

**Parallel Execution**:

- Tests run simultaneously for speed
- Individual failure reporting
- Artifact collection for debugging

### Stage 4: Quality & Security Checks 🔍

**Code Quality**:

- ESLint with {{PROJECT_NAME}} standards
- TypeScript compilation
- Prettier formatting
- Code complexity analysis

**Security Scanning**:

- Dependency vulnerability audit
- Secret detection with TruffleHog
- Sensitive file pattern matching

### Stage 5: Build Verification 🏗️

**Build Process**:

- Next.js production build
- Asset optimization
- Build artifact validation
- Size impact analysis

### Stage 6: Conflict Detection 🚨

**High-Risk File Monitoring**:

- `.env.template`, `config.ts`, `package.json`
- `yarn.lock`, `prisma/schema.prisma`
- API routes and core utilities

**Conflict Prevention**:

- Early warning for risky changes
- Team notification requirements
- Extra review triggers

### Stage 7: Deployment Preview 🚀

**Conditional Deployment**:

- Triggered by `ready-for-preview` label
- Isolated preview environment
- Shareable preview URLs

### Stage 8: Auto-Merge (Optional) 🤖

**Smart Merging**:

- Triggered by `auto-merge` label
- All checks must pass
- Uses rebase strategy
- Maintains linear history

### Stage 9: Post-Merge Validation ✅

**Production Safety**:

- Smoke tests on `{{PRIMARY_DEV_BRANCH}}` branch
- Integration verification
- Team notifications on failure
- Linear ticket updates

## 🛡️ Branch Protection Rules

### Required Status Checks

All PRs to `{{PRIMARY_DEV_BRANCH}}` must pass:

- ✅ Structure validation
- ✅ Rebase status check
- ✅ All test suites
- ✅ Quality & security checks
- ✅ Build verification

### Review Requirements

- **Minimum 1 approval** required
- **Stale reviews dismissed** on new commits
- **CODEOWNERS approval** for sensitive areas
- **Linear history enforced**

### Protection Features

- **No force pushes** to `{{PRIMARY_DEV_BRANCH}}`
- **No deletions** allowed
- **Admin enforcement** included
- **Up-to-date branches** required

## 👥 Team-Specific Features

### Code Ownership

```bash
# Payment features
/app/api/payments/ @payments-team {{ARCHITECT_GITHUB_HANDLE}}
/lib/stripe/ @payments-team {{ARCHITECT_GITHUB_HANDLE}}

# Authentication
/app/api/auth/ @auth-team {{ARCHITECT_GITHUB_HANDLE}}
/middleware.ts @auth-team {{ARCHITECT_GITHUB_HANDLE}}

# Core configuration
/.env.template {{ARCHITECT_GITHUB_HANDLE}}
/config.ts {{ARCHITECT_GITHUB_HANDLE}}
```

### Team Notifications

**Slack Integration**:

- New PR notifications by team
- Build failure alerts
- Merge success confirmations
- Conflict warnings

**Team Assignment**:

- Auto-assignment based on ticket ranges
- {{TICKET_PREFIX}}-1X: Payments team
- {{TICKET_PREFIX}}-2X: Auth team
- {{TICKET_PREFIX}}-3X: Frontend team

## 🚀 Setup Instructions

### 1. Repository Configuration

```bash
# Enable required GitHub features
gh repo edit --enable-issues --enable-projects --enable-wiki

# Set branch protection rules
gh api repos/:owner/:repo/branches/dev/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[...]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field required_linear_history=true
```

### 2. Environment Variables

Add to GitHub repository secrets (Settings → Secrets and variables → Actions):

```bash
# Test environment secrets (recommended for CI)
STRIPE_TEST_SECRET_KEY=sk_test_...        # Stripe test mode secret key
STRIPE_TEST_WEBHOOK_SECRET=whsec_...      # Stripe test webhook signing secret

# Production secrets (when applicable)
STRIPE_SECRET_KEY=sk_live_...             # Production Stripe key
STRIPE_WEBHOOK_SECRET=whsec_...           # Production webhook secret

# Integration secrets
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
LINEAR_API_KEY=lin_api_...

# Optional deployment secrets
PREVIEW_DEPLOY_TOKEN=...
CODECOV_TOKEN=...
```

**Important Notes**:

- The CI pipeline uses GitHub secrets with safe fallbacks (`${{ secrets.STRIPE_TEST_SECRET_KEY || 'sk_test_placeholder' }}`)
- Tests will run with placeholders if secrets aren't configured, preventing 503 errors
- Real test keys provide better test coverage and more accurate CI results

### 3. Team Setup

```bash
# Create GitHub teams
gh api orgs/:org/teams --field name="payments-team"
gh api orgs/:org/teams --field name="auth-team"
gh api orgs/:org/teams --field name="frontend-team"
gh api orgs/:org/teams --field name="backend-team"
gh api orgs/:org/teams --field name="qa-team"

# Add team members
gh api orgs/:org/teams/payments-team/memberships/:username
```

### 4. Local Development Setup

```bash
# Install dependencies
yarn install

# Setup git hooks
yarn prepare

# Verify CI scripts work locally
yarn ci:validate
yarn ci:build
yarn ci:test
```

## 📋 Developer Workflow

### 1. Starting New Work

```bash
# Always start from latest dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b {{TICKET_PREFIX}}-15-stripe-checkout-integration

# Make changes and commit with SAFe format
git commit -m "feat(payments): add Stripe checkout flow [{{TICKET_PREFIX}}-15]"
```

### 2. Before Creating PR

```bash
# Ensure branch is up-to-date
git fetch origin
git rebase origin/dev

# Run local validation
yarn ci:validate

# Push with force-with-lease
git push --force-with-lease origin {{TICKET_PREFIX}}-15-stripe-checkout-integration
```

### 3. Creating PR

- Use the PR template
- Fill out all required sections
- Add appropriate labels
- Request reviews from CODEOWNERS

### 4. Responding to CI Failures

```bash
# If rebase needed
git rebase origin/dev
git push --force-with-lease origin feature-branch

# If tests fail
yarn test:unit --verbose
# Fix issues and commit

# If linting fails
yarn lint:fix
git add .
git commit -m "style: fix linting issues [{{TICKET_PREFIX}}-15]"
```

## 🔧 Troubleshooting

### Common Issues

**1. Branch Name Validation Fails**

```bash
# Rename branch
git branch -m {{TICKET_PREFIX}}-15-correct-format
git push origin -u {{TICKET_PREFIX}}-15-correct-format
git push origin --delete old-branch-name
```

**2. Rebase Conflicts**

```bash
# Start interactive rebase
git rebase -i origin/dev

# Resolve conflicts for each commit
git add .
git rebase --continue

# Force push when complete
git push --force-with-lease origin feature-branch
```

**3. Test Failures**

```bash
# Run specific test suite
yarn test:unit --testNamePattern="payment"

# Run with coverage
yarn test:coverage

# Debug E2E tests
yarn test:e2e --debug
```

**4. Build Failures**

```bash
# Check TypeScript errors
yarn type-check

# Verify build locally
yarn build

# Check for missing dependencies
yarn install --check-files
```

### Emergency Procedures

**1. Broken Dev Branch**

```bash
# Revert problematic commit
git checkout dev
git revert <commit-hash>
git push origin dev

# Notify teams immediately
# Create hotfix PR if needed
```

**2. CI Pipeline Down**

```bash
# Check GitHub status
curl -s https://www.githubstatus.com/api/v2/status.json

# Bypass checks temporarily (admin only)
gh api repos/:owner/:repo/branches/dev/protection \
  --method PUT \
  --field required_status_checks.strict=false
```

## 📊 Monitoring & Metrics

### Key Metrics

- **PR Merge Time**: Target < 24 hours
- **CI Success Rate**: Target > 95%
- **Rebase Compliance**: Target 100%
- **Test Coverage**: Target > 80%

### Dashboards

- GitHub Actions dashboard
- Slack notifications summary
- Linear ticket velocity
- Code quality trends

## 🔄 Continuous Improvement

### Weekly Reviews

- CI/CD performance analysis
- Team feedback collection
- Process optimization
- Tool updates

### Monthly Updates

- Pipeline enhancement planning
- New tool evaluation
- Team training needs
- Documentation updates

---

## 📞 Support

**Pipeline Issues**: {{ARCHITECT_GITHUB_HANDLE}} (ARCHitect-in-the-IDE)  
**Team Coordination**: #{{LINEAR_WORKSPACE}}-development
**Emergency**: dev-team@{{PROJECT_SLUG}}.com

**Last Updated**: 2025-08-16  
**Version**: 1.0  
**Maintained by**: {{PROJECT_NAME}} Development Team
