# GitHub Actions CI Workflow Pattern

## What It Does

Defines a standard continuous integration workflow for GitHub Actions that enforces code quality gates before any pull request can be merged. Includes lint, type-check, unit test, integration test, and build stages with matrix testing for multiple runtime versions, dependency caching for fast execution, and artifact upload for build outputs and test reports.

## When to Use

- Setting up CI for a new repository
- Standardizing quality gates across multiple repositories
- Adding matrix testing for multiple runtime versions (Node.js, Python, Go, etc.)
- Implementing caching to speed up CI pipelines
- Requiring build artifacts and test reports for review

## Code Pattern

### 1. Primary CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [{{MAIN_BRANCH}}]
  push:
    branches: [{{MAIN_BRANCH}}]

# Cancel in-progress runs for the same PR/branch
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  # Shared environment variables for all jobs
  CI: true
  {{RUNTIME_VERSION_VAR}}: '{{RUNTIME_DEFAULT_VERSION}}'  # e.g., NODE_VERSION: '20'

jobs:
  # ──────────────────────────────────────────────────────────────────
  # Stage 1: Code Quality (fast, runs first)
  # ──────────────────────────────────────────────────────────────────
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}  # e.g., actions/setup-node@v4
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ env.{{RUNTIME_VERSION_VAR}} }}
          cache: '{{PACKAGE_MANAGER}}'  # e.g., 'yarn', 'npm', 'pip', 'go'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}  # e.g., yarn install --frozen-lockfile

      - name: Run linter
        run: {{LINT_COMMAND}}

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ env.{{RUNTIME_VERSION_VAR}} }}
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Run type checker
        run: {{TYPE_CHECK_COMMAND}}

  # ──────────────────────────────────────────────────────────────────
  # Stage 2: Tests (runs in parallel after quality checks pass)
  # ──────────────────────────────────────────────────────────────────
  unit-tests:
    name: Unit Tests (${{ matrix.{{RUNTIME_VERSION_KEY}} }})
    needs: [lint, type-check]
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        {{RUNTIME_VERSION_KEY}}: ['{{RUNTIME_VERSION_MIN}}', '{{RUNTIME_DEFAULT_VERSION}}', '{{RUNTIME_VERSION_MAX}}']
        # e.g., node-version: ['18', '20', '22']
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ matrix.{{RUNTIME_VERSION_KEY}} }}
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Run unit tests
        run: {{TEST_UNIT_COMMAND}} --coverage

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: unit-test-results-${{ matrix.{{RUNTIME_VERSION_KEY}} }}
          path: |
            {{TEST_RESULTS_DIR}}/
            {{COVERAGE_DIR}}/
          retention-days: 7

  integration-tests:
    name: Integration Tests
    needs: [lint, type-check]
    runs-on: ubuntu-latest
    # Optional: Service containers for database, cache, etc.
    services:
      {{DATABASE_SERVICE_NAME}}:
        image: {{DATABASE_IMAGE}}  # e.g., postgres:16-alpine
        env:
          {{DATABASE_ENV_VARS}}
          # e.g.:
          # POSTGRES_USER: test
          # POSTGRES_PASSWORD: test
          # POSTGRES_DB: test_db
        ports:
          - {{DATABASE_PORT}}:{{DATABASE_PORT}}  # e.g., 5432:5432
        options: >-
          --health-cmd "{{DATABASE_HEALTH_CMD}}"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    env:
      {{DATABASE_URL_VAR}}: {{DATABASE_TEST_URL}}
      # e.g., DATABASE_URL: postgresql://test:test@localhost:5432/test_db
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ env.{{RUNTIME_VERSION_VAR}} }}
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Run database migrations
        run: {{DB_MIGRATE_COMMAND}}

      - name: Run integration tests
        run: {{TEST_INTEGRATION_COMMAND}}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: integration-test-results
          path: {{TEST_RESULTS_DIR}}/
          retention-days: 7

  # ──────────────────────────────────────────────────────────────────
  # Stage 3: Build (validates the application compiles and bundles)
  # ──────────────────────────────────────────────────────────────────
  build:
    name: Build
    needs: [unit-tests, integration-tests]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ env.{{RUNTIME_VERSION_VAR}} }}
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Build application
        run: {{BUILD_COMMAND}}
        env:
          # Add build-time environment variables here
          NODE_ENV: production

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: {{BUILD_OUTPUT_DIR}}/  # e.g., .next/, dist/, build/
          retention-days: 7

  # ──────────────────────────────────────────────────────────────────
  # Stage 4: E2E Tests (optional, runs against built application)
  # ──────────────────────────────────────────────────────────────────
  e2e-tests:
    name: E2E Tests
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup runtime
        uses: {{RUNTIME_SETUP_ACTION}}
        with:
          {{RUNTIME_VERSION_KEY}}: ${{ env.{{RUNTIME_VERSION_VAR}} }}
          cache: '{{PACKAGE_MANAGER}}'

      - name: Install dependencies
        run: {{INSTALL_COMMAND}}

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-output
          path: {{BUILD_OUTPUT_DIR}}/

      - name: Install E2E test browsers
        run: {{E2E_INSTALL_COMMAND}}  # e.g., npx playwright install --with-deps chromium

      - name: Run E2E tests
        run: {{TEST_E2E_COMMAND}}

      - name: Upload E2E results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-test-results
          path: |
            {{E2E_RESULTS_DIR}}/
            {{E2E_SCREENSHOTS_DIR}}/
          retention-days: 7
```

### 2. Advanced Caching Configuration

```yaml
# Insert this step after checkout for custom caching beyond package manager cache
- name: Cache build artifacts
  uses: actions/cache@v4
  with:
    path: |
      {{BUILD_CACHE_DIRS}}
      # Examples:
      # .next/cache        (Next.js)
      # node_modules/.cache (Babel, ESLint)
      # .turbo              (Turborepo)
      # __pycache__         (Python)
      # ~/.cache/go-build   (Go)
    key: build-cache-${{ runner.os }}-${{ hashFiles('{{LOCKFILE}}') }}
    restore-keys: |
      build-cache-${{ runner.os }}-
```

### 3. Required Status Checks Configuration

```yaml
# Recommended branch protection settings (configure in GitHub UI or via API):
#
# Required status checks:
#   - "Lint"
#   - "Type Check"
#   - "Unit Tests ({{RUNTIME_DEFAULT_VERSION}})"  # At minimum, default version
#   - "Integration Tests"
#   - "Build"
#
# Optional but recommended:
#   - "E2E Tests"
#
# Branch protection rules:
#   - Require pull request reviews before merging
#   - Require status checks to pass before merging
#   - Require branches to be up to date before merging
#   - Require linear history (rebase merge only)
```

## Customization Guide

1. **Replace all template placeholders** with your project-specific values:
   - `{{MAIN_BRANCH}}` - your primary branch (e.g., `main`, `master`, `develop`)
   - `{{RUNTIME_SETUP_ACTION}}` - setup action for your language (e.g., `actions/setup-node@v4`, `actions/setup-python@v5`, `actions/setup-go@v5`)
   - `{{RUNTIME_VERSION_KEY}}` - version key (e.g., `node-version`, `python-version`, `go-version`)
   - `{{PACKAGE_MANAGER}}` - package manager for caching (e.g., `yarn`, `npm`, `pip`)
   - `{{INSTALL_COMMAND}}` - dependency install (e.g., `yarn install --frozen-lockfile`)
   - All `{{*_COMMAND}}` placeholders - map to your actual scripts

2. **Adjust the matrix strategy** to test the runtime versions you support. Remove matrix testing if you only target a single version.

3. **Configure service containers** for integration tests. Remove the `services` block if your integration tests do not need a database or cache service.

4. **Remove the E2E stage** if your project does not have end-to-end tests, or move it to a separate workflow triggered on specific labels.

5. **Add secrets** for any steps that need authentication (deployment, artifact registries, external services). Use `${{ secrets.SECRET_NAME }}` syntax.

6. **Configure branch protection** in GitHub repository settings to require the status checks defined in this workflow.

## Security Checklist

- [ ] **No secrets in workflow file** - all sensitive values use `${{ secrets.* }}` references
- [ ] **Minimal permissions** - workflow uses least-privilege `permissions:` block if needed
- [ ] **Pinned action versions** - actions use specific versions (e.g., `@v4`), not `@main`
- [ ] **Frozen lockfile** - dependency install uses lockfile to prevent supply chain attacks
- [ ] **Concurrency control** - in-progress runs cancelled to save resources
- [ ] **Fail-fast disabled** - matrix strategy tests all versions even if one fails
- [ ] **Artifacts have retention limits** - build outputs expire to control storage costs
- [ ] **Service container credentials** - test database uses non-production credentials
- [ ] **Branch protection configured** - required checks enforced in GitHub settings
- [ ] **PR required for main branch** - direct pushes blocked by branch protection rules

## Validation Commands

```bash
# Validate workflow YAML syntax
{{PACKAGE_MANAGER_RUN}} action-validator .github/workflows/ci.yml  # or use actionlint

# Run the same checks locally that CI will run
{{LINT_COMMAND}} && {{TYPE_CHECK_COMMAND}} && {{TEST_UNIT_COMMAND}} && {{BUILD_COMMAND}}

# Full CI validation (same as what CI runs)
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Deployment Pipeline](./deployment-pipeline.md) - CD workflow triggered after CI passes
- [Secrets Management](../security/secrets-management.md) - Configure CI secrets securely
- [Environment Config](../config/environment-config.md) - Environment variables for CI
- [API Integration Test](../testing/api-integration-test.md) - Tests that run in the integration stage
- [E2E User Flow](../testing/e2e-user-flow.md) - Tests that run in the E2E stage

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
