---
description: Rollback remote dev environment to previous Docker image
argument-hint: [commit-sha]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

Rollback the remote development environment to a previous Docker image version.

> **📋 TEMPLATE**: This command is a template. Replace placeholders with your infrastructure values before use. See the **Customization Guide** at the bottom.

## Workflow

### 1. Assess Current Situation

Get current problematic version:

```bash
# ┌─────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your SSH and container settings │
# └─────────────────────────────────────────────────────────┘
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker inspect {{APP_CONTAINER_STAGING}} 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4 || docker inspect {{APP_CONTAINER_DEV}} | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

Check current status:

```bash
curl -s http://{{REMOTE_HOST}}:{{DEV_PORT}}/api/health 2>/dev/null || echo "Health check failed"
```

Document the issue for Linear ticket creation later.

### 2. List Available Rollback Targets

Show recent images on remote host:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker images {{REGISTRY}}/{{IMAGE_NAME}} --format 'table {{.Tag}}\t{{.ID}}\t{{.CreatedAt}}'"
```

Cross-reference with git commits to show messages:

```bash
git log origin/{{MAIN_BRANCH}} -10 --oneline
```

### 3. Select Rollback Target

**If argument provided** (commit SHA like `e9722d4`):

- Use specified commit as rollback target
- Verify image exists with that SHA tag

**If no argument provided**:

- Display last 5 available images with commit messages
- Recommend previous stable version (before current)
- Ask user to confirm selection

Default behavior: Select image before current (most common rollback scenario)

### 4. Pull Rollback Image

Pull the specific version from registry:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker pull {{REGISTRY}}/{{IMAGE_NAME}}:{{TAG_PREFIX}}-{target-sha}"
```

If image not in registry (old version pruned), use local cached image.

### 5. Update Configuration

Create backup of current config:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && cp {{COMPOSE_FILE}} {{COMPOSE_FILE}}.backup.$(date +%Y%m%d_%H%M%S)"
```

Update docker-compose file to use specific image tag:

```bash
# From: image: {{REGISTRY}}/{{IMAGE_NAME}}:latest
# To:   image: {{REGISTRY}}/{{IMAGE_NAME}}:{{TAG_PREFIX}}-{target-sha}
```

Use SSH + sed for inline replacement:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && sed -i 's|{{REGISTRY}}/{{IMAGE_NAME}}:latest|{{REGISTRY}}/{{IMAGE_NAME}}:{{TAG_PREFIX}}-{target-sha}|g' {{COMPOSE_FILE}}"
```

### 6. Restart Services

Restart with rollback image:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && {{DOCKER_SCRIPT}} restart"
```

Monitor startup:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && {{DOCKER_SCRIPT}} logs --tail 50"
```

### 7. Verify Rollback Success

Check services started:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker ps --filter name={{CONTAINER_PREFIX}}"
```

Verify health endpoint:

```bash
curl -s http://{{REMOTE_HOST}}:{{DEV_PORT}}/api/health | jq
```

Confirm correct commit SHA:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker inspect {{APP_CONTAINER_STAGING}} 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4 || docker inspect {{APP_CONTAINER_DEV}} | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

### 8. Post-Rollback Actions

**If rollback successful**:

- Keep rollback configuration in place
- Create Linear ticket documenting the issue with broken version
- Include error logs and health check failures
- Tag ticket with `bug` and `deployment-rollback` labels
- Notify team via Slack about rollback

**If rollback still has issues**:

- Try rolling back to an even older version
- Check if issue is environmental (database, Redis, etc.)
- Escalate to team for investigation

### 9. Rollback Report

Provide comprehensive rollback summary:

```text
⏮️  Remote Dev Environment Rollback

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Problem Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version:  3a49b85 - feat(ci): add Slack notifications [{{TICKET_PREFIX}}-350]
Issue:    Health check failing / Services crashing
Time:     Deployed 5 minutes ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Target
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Selected: e9722d4 - style(docs): apply markdown linting fixes [{{TICKET_PREFIX}}-347]
Reason:   Last known stable version
Age:      7 hours ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[14:30:00] Backup config... ✅ {{COMPOSE_FILE}}.backup.20251011_143000
[14:30:05] Pull rollback image... ✅ {{TAG_PREFIX}}-e9722d4 (45s)
[14:30:50] Update config... ✅ Set to {{TAG_PREFIX}}-e9722d4
[14:30:55] Restart services... ✅ Complete (28s)
[14:31:23] Health check... ✅ Passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Post-Rollback Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running:  e9722d4 - style(docs): apply markdown linting fixes [{{TICKET_PREFIX}}-347]
Status:   ✅ Healthy
URL:      http://{{REMOTE_HOST}}:{{DEV_PORT}}
Duration: 1m 23s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Rollback Complete - Environment Restored
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
• Create Linear ticket for broken version (3a49b85)
• Include error logs and symptoms
• Investigate root cause before redeploying
• Keep this version until fix is verified

To return to latest (when fixed):
  /remote-deploy
```

### 10. Restore to Latest (When Fixed)

When issue is resolved and new build is ready, restore to latest:

```bash
# Restore compose file to use :latest tag
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && sed -i 's|{{REGISTRY}}/{{IMAGE_NAME}}:{{TAG_PREFIX}}-[a-f0-9]*|{{REGISTRY}}/{{IMAGE_NAME}}:latest|g' {{COMPOSE_FILE}}"

# Then deploy normally
/remote-deploy
```

## Error Handling

### Image Not Available

If rollback target image not found:

- Try older version
- Pull from registry manually
- Check available tags: `docker images | grep {{IMAGE_NAME}}`

### Services Still Failing

If rollback doesn't fix issue:

- Problem may be environmental (database, Redis, config)
- Check database status
- Verify environment variables unchanged
- Try even older version

### Configuration Restore Fails

If config update fails:

- Manually restore from backup
- Verify SSH permissions
- Check disk space

## Success Criteria

- ✅ Rollback target selected
- ✅ Config backed up
- ✅ Rollback image pulled/available
- ✅ Config updated to specific version
- ✅ Services restarted successfully
- ✅ Health check passes
- ✅ Correct commit SHA running
- ✅ Error logs clean
- ✅ Linear ticket created for issue

## Prevention

Document issue in Linear to prevent recurrence:

- What broke
- How it was detected
- What version caused it
- How to test for this issue before deployment
- Consider adding pre-deployment checks

---

## Customization Guide

| Placeholder               | Description                      | Example                     |
| ------------------------- | -------------------------------- | --------------------------- |
| `{{SSH_KEY_PATH}}`          | Path to SSH private key          | `~/.ssh/id_ed25519_staging` |
| `{{REMOTE_USER}}`           | Username on remote host          | `deploy`                    |
| `{{REMOTE_HOST}}`           | Remote server hostname/IP        | `staging.example.com`       |
| `{{PROJECT_PATH}}`          | Project directory on remote      | `~/app`                     |
| `{{REGISTRY}}`              | Container registry URL           | `ghcr.io/myorg/myapp`       |
| `{{IMAGE_NAME}}`            | Docker image name                | `myapp`                     |
| `{{TAG_PREFIX}}`            | Image tag prefix                 | `dev`, `staging`, `prod`    |
| `{{COMPOSE_FILE}}`          | Docker compose filename          | `docker-compose.dev.yml`    |
| `{{DOCKER_SCRIPT}}`         | Your deployment script           | `./scripts/dev-docker.sh`   |
| `{{CONTAINER_PREFIX}}`      | Container name prefix for filter | `myapp`                     |
| `{{APP_CONTAINER_DEV}}`     | Dev app container name           | `myapp-dev`                 |
| `{{APP_CONTAINER_STAGING}}` | Staging app container name       | `myapp-staging`             |
| `{{DEV_PORT}}`              | Port your dev app runs on        | `3000`                      |
| `{{MAIN_BRANCH}}`           | Main git branch name             | `main`                      |
| `{{TICKET_PREFIX}}`         | Linear/Jira ticket prefix        | `WOR`, `PROJ`, `FEAT`       |

### Example Configuration

For a project called "MyApp" with a staging server at `staging.myapp.com`:

```bash
# SSH Settings
SSH_KEY_PATH=~/.ssh/id_ed25519
REMOTE_USER=deploy
REMOTE_HOST=staging.myapp.com

# Registry Settings
REGISTRY=ghcr.io/myorg/myapp
IMAGE_NAME=myapp
TAG_PREFIX=dev

# Project Settings
PROJECT_PATH=~/app
COMPOSE_FILE=docker-compose.dev.yml
DOCKER_SCRIPT=./scripts/dev-docker.sh
CONTAINER_PREFIX=myapp

# Container Names
APP_CONTAINER_DEV=myapp-dev
APP_CONTAINER_STAGING=myapp-staging

# Other
DEV_PORT=3000
MAIN_BRANCH=main
TICKET_PREFIX=PROJ
```
