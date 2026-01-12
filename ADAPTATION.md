# ConTStack Adaptation Guide

> Tracking all changes made to adapt WTFB harness for ConTStack (Convex + WorkOS + Polar)

## Tech Stack Mapping

| Component | WTFB Original | ConTStack Adaptation |
|-----------|---------------|----------------------|
| **Database** | Prisma + PostgreSQL + Supabase RLS | Convex |
| **Payment** | Stripe | Polar |
| **Authentication** | Clerk | WorkOS AuthKit |
| **Project Management** | Linear | Linear + Beads (agent task management) |
| **Analytics** | PostHog | PostHog (same) |
| **Documentation** | Confluence | Markdown in repo |
| **Frontend** | Next.js + shadcn/ui | Same (no change) |
| **Testing** | Jest/Playwright | Vitest + Docker Playwright + Chrome DevTools MCP |

## Port Mappings

| Port | Service | Purpose |
|------|---------|---------|
| 3000 | web | Marketing/landing site |
| 3003 | app | Main SaaS application (default) |
| 3006 | crm | CRM application |
| 3007 | bubble-api | BubbleLab workflow API |
| 3005 | e2e-test | Docker Playwright E2E tests |
| TBD | beads | Agent task management |
| TBD | email | Email service for agents |
| TBD | serena | Serena MCP server |

## Migration Notes

### Skill Renames and Deprecations

| Original Skill | New Skill | Reason |
|----------------|-----------|--------|
| `stripe-patterns` | `payment-patterns` | ConTStack uses Polar instead of Stripe |

### Deprecated Skills

The following skills have been deprecated and replaced:

1. **stripe-patterns** -> **payment-patterns**
   - Location: `.claude/skills/stripe-patterns/DEPRECATED.md`
   - Replacement: `.claude/skills/payment-patterns/SKILL.md`
   - Reason: Polar is the payment provider for ConTStack (simpler developer experience, better OSS support)

### Post-Migration Cleanup

After confirming all migrations are complete and tested:

```bash
# Remove deprecated skill folders
rm -rf .claude/skills/stripe-patterns

# Verify no references to old skills remain
grep -r "stripe-patterns" .claude/
```

### Environment Variable Mapping

| WTFB Original | ConTStack Adaptation | Notes |
|---------------|----------------------|-------|
| `STRIPE_SECRET_KEY` | `POLAR_ACCESS_TOKEN` | Sandbox token for dev |
| `STRIPE_WEBHOOK_SECRET` | `POLAR_WEBHOOK_SECRET` | For webhook verification |
| `STRIPE_PUBLISHABLE_KEY` | N/A | Not needed with Polar |
| `CLERK_SECRET_KEY` | `WORKOS_API_KEY` | Auth provider change |
| `CLERK_PUBLISHABLE_KEY` | `WORKOS_CLIENT_ID` | Auth provider change |
| `DATABASE_URL` | N/A | Convex handles this internally |
| `DIRECT_URL` | N/A | Convex handles this internally |

## Upstream Tracking

To sync with upstream WTFB updates:

git remote add upstream https://github.com/bybren-llc/wtfb-safe-agentic-workflow.git
git fetch upstream
git merge upstream/main --no-commit

## Original Source

Based on WTFB Safe Agentic Workflow implementing Boris Cherry Claude Code methodology.
