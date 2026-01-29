---
description: Deploy latest Docker image to local Docker environment
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

Deploy the latest Docker image from GitHub Container Registry to your LOCAL machine's Docker.
Works on any machine with Docker Desktop or Docker Engine installed.

## Usage

```bash
/local-deploy              # Deploy using dev mode (source-mounted, hot-reload)
/local-deploy --staging    # Deploy using staging mode (self-contained, production-like)
/local-deploy --rebuild    # Trigger GitHub Actions build first, then deploy
/local-deploy --staging --rebuild  # Build and deploy to staging mode
```

## Deployment Modes

| Mode                      | Flag        | Container                    | Use Case                                                                     |
| ------------------------- | ----------- | ---------------------------- | ---------------------------------------------------------------------------- |
| **Development** (default) | (none)      | `{{PROJECT_NAME}}-dev-app`     | Active development with hot-reload (STANDARD port 3000)                      |
| **Staging**               | `--staging` | `{{PROJECT_NAME}}-staging-app` | Production-like, self-contained, survives git operations (port 3001)         |
| **Both**                  | `--both`    | Both containers              | Run dev and staging simultaneously ({{TICKET_PREFIX}}-400/{{TICKET_PREFIX}}-401) |

**When to use each mode:**

- **Dev mode**: You're actively writing code and want hot-reload (STANDARD port 3000)
- **Staging mode**: Testing, demos, or when you need stability during git operations (port 3001)
- **Both modes**: Run both simultaneously for testing migrations, feature comparison, etc.

## Workflow

### 1. Parse Arguments

Check flags:

```bash
# Check command arguments
if [[ "$*" == *"--staging"* ]]; then
  MODE="staging"
else
  MODE="development"
fi

if [[ "$*" == *"--rebuild"* ]]; then
  REBUILD=true
else
  REBUILD=false
fi
```

### 2. Pre-Deployment Status Check

Get current running status (check both container types):

```bash
# Check for staging container
docker ps --filter name={{PROJECT_NAME}}-staging-app --format '{{.Names}}\t{{.Status}}'

# Check for dev container ({{TICKET_PREFIX}}-400: updated container name)
docker ps --filter name={{PROJECT_NAME}}-dev-app --format '{{.Names}}\t{{.Status}}'
```

Get current commit SHA:

```bash
# Try staging first, then dev ({{TICKET_PREFIX}}-400: updated container names)
docker inspect {{PROJECT_NAME}}-staging-app 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'"' -f4 || \
docker inspect {{PROJECT_NAME}}-dev-app 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'"' -f4
```

Get latest commit from dev branch:

```bash
git log origin/dev -1 --format='%h %s'
```

Report pre-deployment state showing:

- Current commit and message
- Target commit and message
- Container uptime
- Services status
- Current mode (staging vs dev)

### 3. Trigger GitHub Actions Build (Conditional)

**Only run if --rebuild flag is present**

If `$REBUILD` is true:

```bash
# Trigger workflow
gh workflow run "Build and Push Dev Docker Image" --ref dev
```

Show confirmation:

```text
Triggering GitHub Actions build...
Workflow: Build and Push Dev Docker Image
Branch: dev
```

Wait for workflow to start (5-10 seconds):

```bash
sleep 10
```

Get workflow run ID:

```bash
WORKFLOW_RUN_ID=$(gh run list --workflow="Build and Push Dev Docker Image" --limit 1 --json databaseId --jq '.[0].databaseId')
```

Poll for completion (check every 30 seconds):

```bash
while true; do
  STATUS=$(gh run view $WORKFLOW_RUN_ID --json status --jq '.status')
  if [[ "$STATUS" == "completed" ]]; then
    CONCLUSION=$(gh run view $WORKFLOW_RUN_ID --json conclusion --jq '.conclusion')
    if [[ "$CONCLUSION" == "success" ]]; then
      echo "Build completed successfully"
      break
    else
      echo "Build failed"
      exit 1
    fi
  fi
  echo "Build in progress... (status: $STATUS)"
  sleep 30
done
```

Expected duration: 2-5 minutes

If `$REBUILD` is false:

```text
Skipped: Using latest available image from registry
```

### 4. Deploy Based on Mode

**Staging Mode** (`--staging`):

```bash
./scripts/dev-docker.sh deploy
```

This single command:

1. Checks for port conflicts with dev stack
2. Pulls latest image from ghcr.io
3. Starts staging compose (no source mounts)
4. Waits for health check (up to 90s)
5. Reports status with container revision

**Development Mode** (default):

```bash
./scripts/dev-docker.sh pull
./scripts/dev-docker.sh restart
```

This:

1. Pulls latest image from ghcr.io
2. Restarts dev containers with source mounts
3. Enables hot-reload for active development

### 5. Verify Deployment

Check services started successfully:

```bash
# For dev mode (STANDARD port 3000, {{TICKET_PREFIX}}-401)
docker ps --filter name={{PROJECT_NAME}}-dev --format 'table {{.Names}}\t{{.Status}}'

# For staging mode (port 3001)
docker ps --filter name={{PROJECT_NAME}}-staging --format 'table {{.Names}}\t{{.Status}}'
```

Verify health endpoint:

```bash
# Dev (STANDARD port 3000)
curl -s http://localhost:3000/api/health | jq

# Staging (port 3001)
curl -s http://localhost:3001/api/health | jq
```

Expected response:

```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T...",
  "environment": "development"
}
```

Confirm new commit SHA:

```bash
# Staging
docker inspect {{PROJECT_NAME}}-staging-app | grep 'org.opencontainers.image.revision' | cut -d'"' -f4

# Dev ({{TICKET_PREFIX}}-400: updated container name)
docker inspect {{PROJECT_NAME}}-dev-app | grep 'org.opencontainers.image.revision' | cut -d'"' -f4
```

### 6. Post-Deployment Monitoring

Check logs for startup issues:

```bash
# Staging ({{TICKET_PREFIX}}-400: use container name)
docker logs {{PROJECT_NAME}}-staging-app --tail 50

# Dev ({{TICKET_PREFIX}}-400: use container name or script)
docker logs {{PROJECT_NAME}}-dev-app --tail 50
# Or use script
./scripts/dev-docker.sh logs --tail 50
```

Look for:

- "Server started" messages
- Database connection success
- No error stack traces
- Warning messages (document but may be ok)

If issues detected, offer to run `/local-rollback`

### 7. Deployment Report

Provide comprehensive deployment summary:

```text
Local Docker Deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode: STAGING (self-contained)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pre-Deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current:  e9722d4 - style(docs): apply markdown linting fixes [{{TICKET_PREFIX}}-347]
Status:   Up 7 hours (healthy)

Target:   3a49b85 - feat(ci): add Slack notifications [{{TICKET_PREFIX}}-350]
Changes:  1 new commit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Build (if --rebuild used)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[14:20:00] Triggering workflow... Started
[14:20:10] Polling for completion...
[14:22:45] Build completed Success (2m 35s)

OR

Skipped: Using latest available image

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Deployment Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[14:23:15] Pulling image... Complete (1m 42s)
[14:24:57] Stopping services... Complete (8s)
[14:25:05] Starting services... Complete (23s)
[14:25:28] Health check... Passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Post-Deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running:  3a49b85 - feat(ci): add Slack notifications [{{TICKET_PREFIX}}-350]
Status:   Healthy
URL:      http://localhost:3000
Duration: 2m 13s (or 4m 48s with rebuild)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Deployment Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
- Test your changes: http://localhost:3000
- View logs: /local-logs or docker logs [container]
- Check health: /local-health
- Rollback if issues: /local-rollback (when available)
```

## Switching Between Modes

**From Dev to Staging**:

```bash
./scripts/dev-docker.sh stop          # Stop dev containers
./scripts/dev-docker.sh deploy        # Start staging containers
```

**From Staging to Dev**:

```bash
./scripts/dev-docker.sh stop-staging  # Stop staging containers
./scripts/dev-docker.sh start         # Start dev containers
```

## Running Both Modes Simultaneously ({{TICKET_PREFIX}}-400/{{TICKET_PREFIX}}-401)

**Port Allocation**:

| Service    | Dev Mode (STANDARD) | Staging Mode |
| ---------- | ------------------- | ------------ |
| App        | 3000                | 3001         |
| PostgreSQL | 5432                | 5433         |
| Redis      | 6379                | 6380         |

**Start both environments**:

```bash
./scripts/dev-docker.sh start         # Start dev (STANDARD port 3000)
./scripts/dev-docker.sh deploy        # Start staging (port 3001)
```

**Verify both running**:

```bash
docker ps --filter name={{PROJECT_NAME}} --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

**Expected**: 6 containers (3 dev + 3 staging)

## Error Handling

### GitHub Actions Workflow Not Found

If workflow trigger fails:

```bash
# List available workflows
gh workflow list
```

Check workflow name exactly matches "Build and Push Dev Docker Image"

### Build Fails

If GitHub Actions build fails:

- Show workflow logs: `gh run view $WORKFLOW_RUN_ID --log`
- Offer to continue with latest available image (skip rebuild)
- OR abort deployment

### Image Pull Fails

Common causes:

- Registry authentication expired
- Network connectivity issues
- Disk space full

Provide diagnostic commands:

```bash
df -h
docker login ghcr.io
docker system prune -a  # Cleanup old images
```

### Port Conflicts

If ports are in use (common when switching modes):

```bash
# Check what's using ports
sudo lsof -i :3000
sudo lsof -i :5432
sudo lsof -i :6379

# Stop both stacks
./scripts/dev-docker.sh stop          # Dev stack
./scripts/dev-docker.sh stop-staging  # Staging stack

# If docker-proxy stuck, restart Docker
sudo systemctl restart docker
```

### Services Fail to Start

If services don't start:

1. Check error logs
2. Verify database is running
3. Check environment variables
4. Offer rollback (when `/local-rollback` available)

### Health Check Fails

If health endpoint not responding:

- Wait additional 30 seconds (slow start)
- Check container logs for errors
- Verify ports not blocked
- Offer rollback if persistent

## Success Criteria

- Image pulled successfully (or built if --rebuild)
- Old containers stopped cleanly
- New containers started
- All services healthy
- Health endpoint responding
- New commit SHA confirmed
- No errors in logs (or only known warnings)
- Total deployment time < 5 minutes (or < 8 minutes with rebuild)

## Rollback Trigger Conditions

Automatically suggest rollback if:

- Health check fails after 2 minutes
- Critical errors in logs
- Services crash immediately
- Database connection fails

Command to offer: `/local-rollback` (when available)

## Related Commands

- `/local-health` - Check local environment health
- `/local-logs` - View application logs
- `/local-restart` - Restart Docker services only (no pull)
- `/local-sync` - Sync local development environment (source code)
- `/remote-deploy` - Deploy TO a remote machine via SSH
- `/remote-status` - Check if remote machine needs update

## Notes

**When to Use**:

- After PR merges to `dev` branch
- When GitHub Actions build completes
- When testing new Docker image locally
- When updating local environment for testing

**What Gets Deployed**:

- Pre-built Docker image from ghcr.io
- Dev mode: Source-mounted with hot-reload
- Staging mode: Self-contained production-like environment

**Performance**:

- Default (no rebuild): ~2-3 minutes
- With rebuild: ~5-8 minutes (includes GitHub Actions build time)

**Comparison**:

- **`/local-deploy`**: Deploy on YOUR local machine (wherever you run the command)
- **`/remote-deploy`**: Deploy TO a remote machine via SSH
- **`/local-sync`**: Source code sync (not Docker deployment)
