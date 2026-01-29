# Contributing to **PROJECT_NAME**

## Overview

This project follows the {{PROJECT_SHORT}} SAFe-Agentic-Workflow, which implements evidence-based delivery with a hybrid team of human and AI agents.

## Core Principles

1. **Evidence-Based Delivery**: All work must produce verifiable evidence attached to Linear tickets
2. **Pattern-Driven Development**: Search first, reuse always, create only when necessary
3. **Spec-Driven Workflow**: Follow detailed specifications as single source of truth
4. **SAFe ART Model**: Respect specialized agent roles and responsibilities

## Git Workflow

### Branch Naming Convention

```
__TICKET_PREFIX__-{number}-{description}
```

Examples:

- `__TICKET_PREFIX__-123-add-user-authentication`
- `__TICKET_PREFIX__-456-fix-payment-processing`

### Commit Message Format

```
type(scope): description [__TICKET_PREFIX__-XXX]

Optional body explaining the change in more detail.
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:

- `feat(auth): add user login endpoint [__TICKET_PREFIX__-123]`
- `fix(payments): resolve stripe webhook validation [__TICKET_PREFIX__-456]`

### Development Workflow

1. **Create Feature Branch**

   ```bash
   git checkout __PRIMARY_DEV_BRANCH__
   git pull origin __PRIMARY_DEV_BRANCH__
   git checkout -b __TICKET_PREFIX__-XXX-feature-name
   ```

2. **Follow Spec-Driven Development**
   - Read the complete `spec.md` file for your ticket
   - Perform pattern discovery before writing code
   - Follow referenced patterns from `patterns_library/`
   - Make atomic commits for each logical change

3. **Validate Frequently**

   ```bash
   yarn ci:validate  # Run full validation suite
   yarn lint         # Check code style
   yarn test:unit    # Run unit tests
   yarn build        # Verify build succeeds
   ```

4. **Before Creating PR**
   ```bash
   git checkout __PRIMARY_DEV_BRANCH__
   git pull origin __PRIMARY_DEV_BRANCH__
   git checkout __TICKET_PREFIX__-XXX-feature-name
   git rebase __PRIMARY_DEV_BRANCH__
   yarn ci:validate  # Must pass
   git push --force-with-lease origin __TICKET_PREFIX__-XXX-feature-name
   ```

## Pull Request Process

### PR Requirements

- [ ] Title follows format: `type(scope): description [__TICKET_PREFIX__-XXX]`
- [ ] Uses PR template from `.github/pull_request_template.md`
- [ ] All CI checks passing
- [ ] Evidence attached to Linear ticket
- [ ] Spec acceptance criteria met

### PR Template Usage

The PR template includes:

- Summary of changes
- Linear ticket reference
- Testing evidence
- Security review checklist
- Session evidence (for AI agents)

### Review Process

1. **Automated Checks**: All CI/CD checks must pass
2. **Code Review**: Required reviewers based on CODEOWNERS
3. **Security Review**: Required for security-sensitive changes
4. **Final Approval**: Must be up-to-date with **PRIMARY_DEV_BRANCH**

### Merge Strategy

- **Method**: "Rebase and merge" (maintains linear history)
- **Requirements**: All checks passed, reviews approved
- **Cleanup**: Delete feature branch after merge

## Quality Standards

### Code Quality

```bash
yarn lint         # ESLint validation
yarn type-check   # TypeScript validation
yarn format:check # Prettier formatting
```

### Testing Requirements

```bash
yarn test:unit        # Unit tests (required)
yarn test:integration # Integration tests (required)
yarn test:e2e        # End-to-end tests (for UI changes)
```

### Security Requirements

- Use `withUserContext`/`withAdminContext`/`withSystemContext` for database operations
- Validate all inputs with Zod schemas
- Follow RLS (Row Level Security) patterns
- No direct Prisma calls outside context helpers

## Pattern Discovery Protocol

Before writing new code, MUST search:

1. **Codebase**: `grep -r "similar_functionality" .`
2. **Git History**: `git log --grep="related_feature"`
3. **Pattern Library**: `find patterns_library/ -name "*relevant*"`
4. **Session History**: (Claude Code only) Search `~/.claude/todos/`

## Evidence-Based Delivery

### Required Evidence

- Test results (unit, integration, e2e)
- Validation command outputs (`yarn ci:validate`)
- Manual testing screenshots/videos
- Performance metrics (if applicable)
- Security review results (if applicable)

### Evidence Attachment

1. Collect all evidence during development
2. Attach to Linear ticket before PR creation
3. Reference in PR description
4. Include session ID for AI agent work

## Agent Roles & Responsibilities

### Planning Agents

- **BSA**: Creates detailed specs from business requirements
- **System Architect**: Reviews patterns and architectural decisions

### Execution Agents

- **Backend Developer**: API routes, server logic, database operations
- **Frontend Developer**: UI components, client-side logic, user interactions
- **Data Engineer**: Schema changes, migrations, database architecture

### Quality & Coordination Agents

- **QAS**: Executes testing strategy, validates acceptance criteria
- **Security Engineer**: Security validation, RLS enforcement
- **TDM**: Coordination, blocker escalation, Linear management
- **RTE**: PR creation, CI/CD validation, release coordination

## Environment Setup

### Prerequisites

- Node.js version specified in `.nvmrc`
- Yarn package manager
- Docker (for local database)

### Initial Setup

```bash
git clone __PROJECT_GIT_URL__
cd __PROJECT_NAME__
nvm use
yarn install
docker-compose up -d  # Start local database
yarn dev             # Start development server
```

### Environment Variables

Copy `.env.template` to `.env.local` and configure:

- Database connection strings
- API keys and secrets
- Feature flags

## CI/CD Pipeline

### Automated Checks

- ESLint validation
- TypeScript compilation
- Unit and integration tests
- Build verification
- Security scanning

### Branch Protection

- Require PR for all changes to **PRIMARY_DEV_BRANCH**
- Require all checks to pass
- Require up-to-date branches
- Require review from CODEOWNERS

### Deployment

- Automatic deployment to staging on **PRIMARY_DEV_BRANCH** merge
- Manual promotion to production
- Rollback capabilities maintained

## Getting Help

### Escalation Path

1. **Technical Issues**: System Architect agent
2. **Process Issues**: Technical Delivery Manager
3. **Business Questions**: Product Owner/Product Manager

### Resources

- `AGENTS.md`: Complete agent role descriptions
- `patterns_library/`: Reusable code patterns
- `specs_templates/`: Planning and specification templates
- Linear workspace: **TICKET_URL_PREFIX**
- Project repository: **PROJECT_GIT_URL**

## Success Metrics

### Individual Contributions

- All PRs pass CI/CD checks
- Evidence consistently attached to tickets
- Pattern reuse over new code creation
- Atomic commits with clear messages

### Team Performance

- Velocity maintained or improved
- Quality metrics within targets
- Security vulnerabilities minimized
- Documentation kept current

Remember: Quality is not negotiable. Take time to do it right the first time.
