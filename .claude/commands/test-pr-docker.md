---
description: Test PR with Docker image build workflow
argument-hint: [PR-number]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

Test the Docker registry PR workflow by adding the `build-docker-image` label to a PR and verifying the build.

## Workflow

### 1. Get PR Number

If argument provided ($1):

- Use as PR number
- Fetch PR details: `gh pr view $1`

If no argument:

- Check if current branch has open PR
- Extract PR number from branch

### 2. Add Label to PR

Add `build-docker-image` label:

```bash
gh pr edit {PR-number} --add-label "build-docker-image"
```

Confirm label added:

```bash
gh pr view {PR-number} --json labels
```

### 3. Monitor Build

Explain to user:

- GitHub Actions will build Docker image (~5-10 min)
- Image will be tagged as `pr-{number}`
- Build status visible in PR checks
- Can monitor at: `https://{{GITHUB_ORG}}/{{PROJECT_NAME}}/actions`

Provide link to PR:

```bash
gh pr view {PR-number} --web
```

### 4. Verification Steps

Once build completes, guide user through verification:

**On Linux machine**:

```bash
# Pull PR-specific image
./scripts/dev-docker.sh pull-pr {PR-number}

# Verify image exists
docker images | grep {{PROJECT_NAME}}

# {{TICKET_PREFIX}}-400: Use {{PROJECT}}_IMAGE_TAG environment variable instead of editing compose file
# Set the tag before running docker compose:
export {{PROJECT}}_IMAGE_TAG=pr-{PR-number}

# Or update docker-compose.staging.yml image tag temporarily:
# Change: image: {{REGISTRY}}/{{PROJECT_NAME}}/dev:${{PROJECT}_IMAGE_TAG:-latest}
# To:     image: {{REGISTRY}}/{{PROJECT_NAME}}/dev:pr-{PR-number}

# Restart with PR image
./scripts/dev-docker.sh restart

# Verify services running
./scripts/dev-docker.sh status

# Check health
curl http://localhost:3000/api/health
```

### 5. Testing Complete

After verification:

```bash
# Revert docker-compose.dev.yml
# Remove label to stop builds
gh pr edit {PR-number} --remove-label "build-docker-image"
```

## Success Criteria

- ✅ Label added successfully
- ✅ GitHub Actions build triggered
- ✅ Image built with pr-{number} tag
- ✅ Image pullable on Linux machine
- ✅ Services start correctly
- ✅ Hot-reload verified
- ✅ Health check passes

## Output

Report each step's status:

- PR number and URL
- Label addition confirmation
- Build status (link to Actions)
- Verification instructions
- Expected next steps

This validates the entire PR Docker workflow before relying on it for future PRs.

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description               | Example               |
| ----------------- | ------------------------- | --------------------- |
| `{{TICKET_PREFIX}}` | Your Linear ticket prefix | `WOR`, `PROJ`, `TASK` |
