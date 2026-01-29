# GitHub Workflow Patterns for SAFe Multi-Agent Development

This document describes the GitHub Actions workflow patterns used in SAFe multi-agent development. These are architectural patterns—not copy-paste templates—that teams should adapt to their specific infrastructure.

## Overview

A mature SAFe agentic workflow typically includes these workflow categories:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow Architecture                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  VALIDATION WORKFLOWS                                                    │
│  ├─ Branch naming validation (enforce ticket references)                 │
│  ├─ Multi-team collaboration (rebase-first, linear history)             │
│  └─ Migration validation (database schema safety)                        │
│                                                                          │
│  BUILD WORKFLOWS                                                         │
│  ├─ Development image build (Docker for dev/staging)                     │
│  └─ Release build (production artifacts)                                 │
│                                                                          │
│  PROTECTION WORKFLOWS                                                    │
│  ├─ Branch protection (enforce PR requirements)                          │
│  ├─ Database protection (prevent destructive operations)                 │
│  └─ RLS enforcement (soft-enforcement reminders)                         │
│                                                                          │
│  NOTIFICATION WORKFLOWS                                                  │
│  └─ PR merge notifications (Slack, Linear updates)                       │
│                                                                          │
│  RELEASE WORKFLOWS                                                       │
│  └─ Semantic release (changelog, versioning, deployment)                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Workflow Patterns

### 1. Branch Naming Validation

**Purpose**: Enforce SAFe ticket references in branch names.

**Pattern**:

```yaml
name: Validate Branch Name
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Check branch name format
        run: |
          BRANCH="${{ github.head_ref }}"
          # Enforce pattern: {{TICKET_PREFIX}}-{number}-{description}
          if [[ ! "$BRANCH" =~ ^[A-Z]+-[0-9]+-[a-z0-9-]+$ ]]; then
            echo "❌ Branch name must match pattern: PREFIX-123-description"
            exit 1
          fi
```

**Key Features**:

- Runs on PR open/sync
- Validates ticket reference in branch name
- Provides clear error messages

### 2. Multi-Team Collaboration

**Purpose**: Enforce rebase-first workflow and linear history.

**Pattern**:

```yaml
name: Multi-Team Collaboration
on:
  pull_request:
    branches: [main, dev]

jobs:
  rebase-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check linear history
        run: |
          # Ensure branch is rebased on target
          git fetch origin ${{ github.base_ref }}
          BEHIND=$(git rev-list --count HEAD..origin/${{ github.base_ref }})
          if [ "$BEHIND" -gt 0 ]; then
            echo "❌ Branch is $BEHIND commits behind. Please rebase."
            exit 1
          fi

      - name: Check for merge commits
        run: |
          # Ensure no merge commits (linear history)
          MERGE_COMMITS=$(git log --merges --oneline origin/${{ github.base_ref }}..HEAD | wc -l)
          if [ "$MERGE_COMMITS" -gt 0 ]; then
            echo "❌ Merge commits detected. Use rebase instead."
            exit 1
          fi
```

**Key Features**:

- Enforces rebase-first workflow
- Prevents merge commits
- Maintains linear history for easy bisect

### 3. Migration Validation

**Purpose**: Validate database migrations before merge.

**Pattern**:

```yaml
name: Migration Validation
on:
  pull_request:
    paths:
      - "prisma/migrations/**"
      - "prisma/schema.prisma"

jobs:
  validate-migration:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4

      - name: Test migration applies cleanly
        run: npx prisma migrate deploy

      - name: Check for destructive changes
        run: |
          # Scan for DROP, TRUNCATE, DELETE without WHERE
          if grep -rE "(DROP TABLE|TRUNCATE|DELETE FROM.*[^WHERE])" prisma/migrations/; then
            echo "⚠️ Destructive operation detected. Requires architect approval."
          fi
```

**Key Features**:

- Tests migration against ephemeral database
- Detects destructive operations
- Requires approval for risky changes

### 4. RLS Soft Enforcement

**Purpose**: Remind developers about Row-Level Security requirements.

**Pattern**:

```yaml
name: RLS Soft Enforcement
on:
  pull_request:
    paths:
      - "app/api/**"
      - "lib/db/**"

jobs:
  rls-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for direct Prisma usage
        run: |
          # Warn if prisma is used without RLS context
          if grep -rE "prisma\.(user|account|subscription)" --include="*.ts" app/ lib/; then
            echo "⚠️ Direct Prisma access detected."
            echo "Consider using withUserContext/withAdminContext helpers."
            # Note: This is soft enforcement (warning, not failure)
          fi
```

**Key Features**:

- Runs on API/database file changes
- Provides educational warnings
- Doesn't block (soft enforcement)

### 5. Development Image Build

**Purpose**: Build Docker images for dev/staging environments.

**Pattern**:

```yaml
name: Build Dev Image
on:
  push:
    branches: [dev]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

**Key Features**:

- Triggers on dev branch push
- Tags with SHA for traceability
- Pushes to container registry

### 6. Semantic Release

**Purpose**: Automate versioning and changelog generation.

**Pattern**:

```yaml
name: Release
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Semantic Release
        uses: cycjimmy/semantic-release-action@v4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Key Features**:

- Uses conventional commits for versioning
- Generates changelog automatically
- Creates GitHub releases

### 7. PR Merge Notifications

**Purpose**: Notify team channels when PRs are merged.

**Pattern**:

```yaml
name: Notify PR Merge
on:
  pull_request:
    types: [closed]

jobs:
  notify:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ PR merged: ${{ github.event.pull_request.title }}"
            }
```

**Key Features**:

- Only runs on actual merge (not close)
- Integrates with team communication
- Includes PR context

## Implementation Recommendations

### Minimal Setup (Start Here)

1. **Branch naming validation** - Enforce ticket references
2. **Multi-team collaboration** - Enforce rebase-first
3. **PR template** - Comprehensive checklist

### Standard Setup (Most Teams)

Add to minimal:

4. **Migration validation** - If using database migrations
5. **RLS soft enforcement** - If using Row-Level Security
6. **Semantic release** - For automated versioning

### Full Setup (Mature Teams)

Add to standard:

7. **Development image build** - If using Docker
8. **PR merge notifications** - For team visibility
9. **Database protection** - For production safety

## SAFe Alignment

These workflows support SAFe principles:

| Workflow                 | SAFe Principle                           |
| ------------------------ | ---------------------------------------- |
| Branch naming            | Traceability to backlog items            |
| Multi-team collaboration | Continuous integration, built-in quality |
| Migration validation     | Built-in quality, risk reduction         |
| RLS enforcement          | Security, compliance                     |
| Semantic release         | Continuous delivery, transparency        |
| PR merge notifications   | Transparency, team coordination          |

## Related Documentation

- **PR Template**: `.github/pull_request_template.md`
- **Contributing Guide**: `CONTRIBUTING.md`
- **CI/CD Pipeline Guide**: `docs/ci-cd/CI-CD-Pipeline-Guide.md`

---

**Note**: These are architectural patterns, not copy-paste templates. Adapt them to your specific infrastructure, secrets management, and deployment targets.
