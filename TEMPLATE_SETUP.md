# Template Setup Guide

This repository is a **GitHub template** for AI agent team workflows. After creating a new repository from this template, run the setup wizard to customize it for your project.

## Quick Setup

```bash
bash scripts/setup-template.sh
```

The wizard prompts for your project values and replaces all placeholders automatically.

## Manual Setup

If you prefer manual customization, replace these placeholders across the repository:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{PROJECT_NAME}}` | Project/repo short name | `my-saas-app` |
| `{{PROJECT_REPO}}` | Full repo name (for URLs) | `my-saas-app` |
| `{{PROJECT_SHORT}}` | Project acronym (uppercase) | `ACME` |
| `{{PROJECT_DOMAIN}}` | Project website domain | `acme.com` |
| `{{GITHUB_ORG}}` | GitHub organization or username | `acme-corp` |
| `{{COMPANY_NAME}}` | Company/org display name | `Acme Corp` |
| `{{AUTHOR_NAME}}` | Primary author full name | `Jane Smith` |
| `{{AUTHOR_FIRST_NAME}}` | Author first name | `Jane` |
| `{{AUTHOR_LAST_NAME}}` | Author last name | `Smith` |
| `{{AUTHOR_INITIALS}}` | Author initials (derived) | `J. S.` |
| `{{AUTHOR_HANDLE}}` | Author GitHub handle | `janesmith` |
| `{{AUTHOR_EMAIL}}` | Author email | `jane@acme.com` |
| `{{AUTHOR_WEBSITE}}` | Author website URL | `https://janesmith.dev` |
| `{{ARCHITECT_GITHUB_HANDLE}}` | Lead architect GitHub handle | `lead-dev` |
| `{{TICKET_PREFIX}}` | Linear/issue tracker prefix (uppercase) | `ACM` |
| `{{TICKET_PREFIX_LOWER}}` | Ticket prefix lowercase | `acm` |
| `{{LINEAR_WORKSPACE}}` | Linear workspace slug | `acme` |
| `{{SECURITY_EMAIL}}` | Security contact email | `security@acme.com` |
| `{{DB_USER}}` | Database username | `app_user` |
| `{{DB_PASSWORD}}` | Database password | `app_password` |
| `{{DB_NAME}}` | Database name | `app_dev` |
| `{{DB_CONTAINER}}` | Database container name | `app-postgres` |
| `{{DEV_CONTAINER}}` | Dev app container name | `app-dev` |
| `{{STAGING_CONTAINER}}` | Staging app container name | `app-staging` |
| `{{CONTAINER_REGISTRY}}` | Container registry URL | `ghcr.io/acme-corp` |
| `{{GITHUB_REPO_URL}}` | Full GitHub repo URL (derived) | `https://github.com/acme-corp/my-saas-app` |

Additional placeholders in `CLAUDE.md` and `CONTRIBUTING.md` (technology stack):

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{FRONTEND_FRAMEWORK}}` | Frontend framework | `Next.js` |
| `{{BACKEND_FRAMEWORK}}` | Backend framework | `Node.js` |
| `{{DATABASE_SYSTEM}}` | Database system | `PostgreSQL` |
| `{{ORM_TOOL}}` | ORM/query builder | `Prisma` |
| `{{AUTH_PROVIDER}}` | Authentication provider | `Clerk` |
| `{{LINT_COMMAND}}` | Lint command | `yarn lint` |
| `{{BUILD_COMMAND}}` | Build command | `yarn build` |
| `{{TEST_UNIT_COMMAND}}` | Unit test command | `yarn test:unit` |
| `{{DEV_COMMAND}}` | Dev server command | `yarn dev` |
| `{{MAIN_BRANCH}}` | Main branch name | `main` |

## Post-Setup Checklist

- [ ] Setup wizard completed (or manual placeholders replaced)
- [ ] `.env.template` reviewed and updated with your service keys
- [ ] `LICENSE` copyright line updated
- [ ] `.github/FUNDING.yml` updated (or removed if not sponsoring)
- [ ] `CLAUDE.md` technology stack section customized
- [ ] Linear workspace configured (see `docs/onboarding/`)
- [ ] GitHub repository settings: enable "Template repository" if sharing
- [ ] Delete this file (`TEMPLATE_SETUP.md`) after setup
