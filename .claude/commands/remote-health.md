---
description: Check remote dev environment health dashboard
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Remote Health Command

Display comprehensive health status of your remote dev environment including containers, resources, connectivity, and recent issues.

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" at the end to adapt for your infrastructure.

## Workflow

### 1. Container Health Check

Check all project services:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your SSH and container details              │
# └─────────────────────────────────────────────────────────────────────┘

ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker ps --filter name={PROJECT} --format 'table {{.Names}}\t{{.Status}}\t{{.State}}'"
```

Get detailed health status:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker inspect {CONTAINER_NAME} --format='{{.Name}}: {{.State.Health.Status}}'"
```

### 2. Resource Usage

Check CPU and Memory usage:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}'"
```

Check disk space:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "df -h / | tail -1"
```

Check Docker disk usage:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} "docker system df"
```

### 3. Application Health Endpoint

Test your app's health endpoint:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your health endpoint URL                    │
# └─────────────────────────────────────────────────────────────────────┘

curl -s -w '\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n' \
  http://{REMOTE_HOST}:{APP_PORT}/api/health
```

Expected response:

```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T19:35:00.000Z",
  "uptime": 25234.567,
  "environment": "development"
}
```

### 4. Database Connectivity

Test PostgreSQL connection:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your database container and credentials     │
# └─────────────────────────────────────────────────────────────────────┘

ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker exec {DB_CONTAINER} pg_isready -U {DB_USER}"
```

### 5. Redis/Cache Connectivity

Test Redis connection:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker exec {REDIS_CONTAINER} redis-cli ping"
```

Expected: `PONG`

### 6. Recent Error Check

Check for recent errors in logs:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker logs {CONTAINER_NAME} --since 5m 2>&1 | grep -i 'error\|fatal\|exception' | tail -10"
```

### 7. Version Information

Get running version:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker inspect {CONTAINER_NAME} | grep 'org.opencontainers.image.revision'"
```

### 8. Health Dashboard Report

Generate comprehensive health report:

```text
🏥 Remote Dev Environment Health Dashboard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Container Health
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{PROJECT}-app            ✅ Healthy  Up 2 hours
{PROJECT}-postgres       ✅ Healthy  Up 2 hours
{PROJECT}-redis          ✅ Healthy  Up 2 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource Usage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Container               CPU      Memory
{PROJECT}-app          2.45%    312MB / 2GB  (15%)
{PROJECT}-postgres     0.12%    45MB / 2GB   (2%)
{PROJECT}-redis        0.08%    8MB / 2GB    (0%)

Disk Space:            125GB / 250GB (50% used)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Status: ✅ HEALTHY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Health Score Calculation

Calculate overall health score (0-100):

| Criteria                  | Points |
| ------------------------- | ------ |
| Containers running        | +30    |
| Health checks passing     | +20    |
| Resource usage < 80%      | +15    |
| No recent errors          | +15    |
| Response time < 500ms     | +10    |
| Database/Redis responding | +10    |

**Score Interpretation**:

- 90-100: ✅ Excellent
- 70-89: ⚠️ Good (minor issues)
- 50-69: ⚠️ Degraded (needs attention)
- 0-49: ❌ Critical (immediate action required)

## Alert Conditions

### Critical Alerts (❌)

- Any container stopped/crashed
- Health endpoint not responding
- Database unreachable
- Disk space > 90%

### Warning Alerts (⚠️)

- Response time > 1 second
- Memory usage > 80%
- Error spike in last 5 minutes

## Customization Guide

| Placeholder         | Description               | Example                     |
| ------------------- | ------------------------- | --------------------------- |
| `{SSH_KEY_PATH}`    | Path to SSH private key   | `~/.ssh/id_ed25519_staging` |
| `{REMOTE_USER}`     | Username on remote host   | `deploy`                    |
| `{REMOTE_HOST}`     | Remote server hostname/IP | `staging.example.com`       |
| `{PROJECT}`         | Your project name         | `myapp`                     |
| `{CONTAINER_NAME}`  | Docker container name     | `myapp-staging`             |
| `{APP_PORT}`        | Port your app runs on     | `3000`                      |
| `{DB_CONTAINER}`    | Database container name   | `myapp-postgres`            |
| `{DB_USER}`         | Database username         | `app_user`                  |
| `{REDIS_CONTAINER}` | Redis container name      | `myapp-redis`               |

## Related Commands

- `/remote-logs` - View detailed logs
- `/remote-status` - Check for updates
- `/remote-deploy` - Deploy latest version
- `/remote-rollback` - Rollback if unhealthy
