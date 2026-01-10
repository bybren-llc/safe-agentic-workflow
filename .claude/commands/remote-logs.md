---
description: View remote dev container logs
argument-hint: [--follow] [--tail N]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

View logs from the remote development environment containers.

> **📋 TEMPLATE**: This command is a template. Replace placeholders with your infrastructure values before use. See the **Customization Guide** at the bottom.

## Workflow

### 1. Determine Log Mode

**If argument contains `--follow` or `-f`**:

- Stream logs in real-time
- Useful for monitoring deployments
- Press Ctrl+C to exit

**If argument contains `--tail N`**:

- Show last N lines
- Default to 100 if not specified

**If no arguments**:

- Show last 100 lines (default)

### 2. Execute Log Command

Get logs from all services:

```bash
# ┌─────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your SSH and project settings   │
# └─────────────────────────────────────────────────────────┘
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "cd {PROJECT_PATH} && ./scripts/dev-docker.sh logs --tail 100"
```

For specific service:

```bash
# Container names - customize for your project

# App logs (dev-mode - STANDARD port 3000)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {APP_CONTAINER_DEV} --tail 100"

# App logs (staging-mode - port 3001)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {APP_CONTAINER_STAGING} --tail 100"

# PostgreSQL logs (staging)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {DB_CONTAINER_STAGING} --tail 100"

# PostgreSQL logs (dev)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {DB_CONTAINER_DEV} --tail 100"

# Redis logs (staging)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {REDIS_CONTAINER_STAGING} --tail 100"

# Redis logs (dev)
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {REDIS_CONTAINER_DEV} --tail 100"
```

### 3. Filter and Highlight

Parse logs for common patterns:

**Error Detection**:

- `ERROR`, `Error`, `error`
- `FATAL`, `Fatal`
- `Exception`, `exception`
- Stack traces

**Warning Detection**:

- `WARN`, `Warning`, `warning`
- `deprecated`

**Success Markers**:

- `started`, `listening`, `ready`
- `connected`, `successful`

Highlight critical issues in output.

### 4. Log Analysis

Provide quick analysis:

```text
📋 Remote Dev Logs Analysis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dev Containers (STANDARD port {DEV_PORT})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{APP_CONTAINER_DEV} (Next.js):
  Status:    ✅ Running
  Errors:    0
  Warnings:  2
  Last Line: [14:35:22] Ready on http://localhost:{DEV_PORT}

{DB_CONTAINER_DEV}:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:10] database system is ready

{REDIS_CONTAINER_DEV}:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:08] Ready to accept connections

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Staging Containers (port {STAGING_PORT})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{APP_CONTAINER_STAGING} (Next.js):
  Status:    ✅ Running
  Errors:    0
  Warnings:  1
  Last Line: [14:35:22] Ready on http://localhost:{STAGING_PORT}
  Recent warnings:
    [14:34:15] WARN: Using development build
    [14:34:18] WARN: PostHog not initialized (missing key)

{DB_CONTAINER_STAGING}:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:10] database system is ready

{REDIS_CONTAINER_STAGING}:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:08] Ready to accept connections

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Health: ✅ Healthy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommendation: No critical issues detected
Warnings are expected for dev environment
```

### 5. Interactive Follow Mode

If `--follow` requested, start streaming:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "cd {PROJECT_PATH} && ./scripts/dev-docker.sh logs --follow"
```

Inform user:

- "Streaming logs... (Press Ctrl+C to stop)"
- Show timestamp of each log line
- Highlight errors in red if possible

### 6. Log Search

Offer quick log search options:

**Search for specific term**:

```bash
# Search staging or dev logs
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {APP_CONTAINER_STAGING} 2>&1 | grep -i 'search-term'"
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker logs {APP_CONTAINER_DEV} 2>&1 | grep -i 'search-term'"
```

**Common search patterns**:

- "ERROR" - All errors
- "database" - Database connection logs
- "Redis" - Redis connection logs
- "API" - API request logs
- "POST /api" - POST requests only

## Usage Examples

### View Recent Logs

```bash
/remote-logs
```

Shows last 100 lines from all containers

### Follow Logs in Real-Time

```bash
/remote-logs --follow
```

Streams logs continuously

### View More Lines

```bash
/remote-logs --tail 500
```

Shows last 500 lines

### View and Follow

```bash
/remote-logs --tail 200 --follow
```

Shows last 200 lines, then continues streaming

## Error Handling

### SSH Connection Fails

Check network connectivity:

```bash
# Check if remote host is reachable
ping {REMOTE_HOST}

# Or check via VPN/Tailscale
tailscale status | grep {REMOTE_HOST}
```

Provide manual SSH command:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST}
```

### Container Not Found

If container doesn't exist:

- Check services are running: `/remote-health`
- Start services: `/remote-deploy`

### Permission Issues

If log access denied:

- Verify docker group membership
- Provide sudo alternative

## Output Options

### Compact Mode (Default)

Show analysis summary + filtered logs (errors/warnings highlighted)

### Full Mode (If requested)

Show complete raw logs without filtering

### Service-Specific Mode

If user specifies container name, map to appropriate container:

Staging mode:

- `app` or `next` → {APP_CONTAINER_STAGING}
- `postgres` or `db` → {DB_CONTAINER_STAGING}
- `redis` → {REDIS_CONTAINER_STAGING}

Dev mode:

- `app` or `next` → {APP_CONTAINER_DEV}
- `postgres` or `db` → {DB_CONTAINER_DEV}
- `redis` → {REDIS_CONTAINER_DEV}

## Success Criteria

- ✅ SSH connection successful
- ✅ Logs retrieved
- ✅ Errors/warnings identified
- ✅ Quick analysis provided
- ✅ Follow mode works (if requested)
- ✅ Easy to read formatting

## Related Commands

- `/remote-health` - Check service health
- `/remote-status` - Check deployment status
- `/remote-deploy` - Deploy latest version
- `/remote-rollback` - Rollback if errors found

---

## Customization Guide

| Placeholder                 | Description                     | Example                     |
| --------------------------- | ------------------------------- | --------------------------- |
| `{SSH_KEY_PATH}`            | Path to SSH private key         | `~/.ssh/id_ed25519_staging` |
| `{REMOTE_USER}`             | Username on remote host         | `deploy`                    |
| `{REMOTE_HOST}`             | Remote server hostname/IP       | `staging.example.com`       |
| `{PROJECT_PATH}`            | Project directory on remote     | `~/app`                     |
| `{APP_CONTAINER_DEV}`       | Dev app container name          | `myapp-dev`                 |
| `{APP_CONTAINER_STAGING}`   | Staging app container name      | `myapp-staging`             |
| `{DB_CONTAINER_DEV}`        | Dev database container name     | `myapp-dev-postgres`        |
| `{DB_CONTAINER_STAGING}`    | Staging database container name | `myapp-staging-postgres`    |
| `{REDIS_CONTAINER_DEV}`     | Dev Redis container name        | `myapp-dev-redis`           |
| `{REDIS_CONTAINER_STAGING}` | Staging Redis container name    | `myapp-staging-redis`       |
| `{DEV_PORT}`                | Port your dev app runs on       | `3000`                      |
| `{STAGING_PORT}`            | Port your staging app runs on   | `3001`                      |

### Example Configuration

For a project called "MyApp" with a staging server at `staging.myapp.com`:

```bash
# SSH Settings
SSH_KEY_PATH=~/.ssh/id_ed25519
REMOTE_USER=deploy
REMOTE_HOST=staging.myapp.com

# Container Names
APP_CONTAINER_DEV=myapp-dev
APP_CONTAINER_STAGING=myapp-staging
DB_CONTAINER_DEV=myapp-dev-postgres
DB_CONTAINER_STAGING=myapp-staging-postgres
REDIS_CONTAINER_DEV=myapp-dev-redis
REDIS_CONTAINER_STAGING=myapp-staging-redis

# Ports
DEV_PORT=3000
STAGING_PORT=3001
```
