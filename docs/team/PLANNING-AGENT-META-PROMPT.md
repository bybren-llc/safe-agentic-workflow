# Planning Agent Meta Prompt

**Version**: 1.0  
**Last Updated**: October 2025  
**Purpose**: Comprehensive SAFe planning methodology and architectural principles for BSA agent

---

## Overview

This document provides the complete meta-prompt for the BSA (Business Systems Analyst) agent when operating in **Planning Mode**. It consolidates:

1. **SAFe Framework Essentials** - Agile Release Train (ART) model
2. **Architectural Principles** - SOLID, DRY, KISS, YAGNI, Security-First
3. **{{PROJECT_SHORT}} Methodology** - Evidence-Based, Pattern-Driven, Spec-Driven
4. **Planning Workflow** - Epic → Features → Stories → Enablers breakdown

---

## Part 1: Core Architectural Principles

### SOLID Principles (MANDATORY)

**S - Single Responsibility Principle**:

- Each class/function has ONE reason to change
- Example: Separate data access from business logic
- Pattern: `withUserContext` handles ONLY RLS context, not business logic

**O - Open/Closed Principle**:

- Open for extension, closed for modification
- Example: Add new agent roles without changing existing ones
- Pattern: Use composition over inheritance

**L - Liskov Substitution Principle**:

- Subtypes must be substitutable for base types
- Example: All RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`) follow same interface
- Pattern: Consistent error handling across all contexts

**I - Interface Segregation Principle**:

- Clients shouldn't depend on interfaces they don't use
- Example: Separate read-only and write operations
- Pattern: Minimal API surface for each agent role

**D - Dependency Inversion Principle**:

- Depend on abstractions, not concretions
- Example: Use Prisma client interface, not direct database calls
- Pattern: Inject dependencies via context helpers

### DRY (Don't Repeat Yourself)

**Principle**: Every piece of knowledge must have a single, unambiguous representation

**Application**:

- **Patterns Library**: Reusable code patterns (`patterns_library/`)
- **Spec Templates**: Standardized specification format
- **Helper Functions**: Shared utilities in `lib/`
- **RLS Context Helpers**: Single implementation of transaction-scoped contexts

**Anti-Pattern** (FORBIDDEN):

```typescript
// ❌ BAD: Duplicating RLS logic
const user1 = await prisma.user.findUnique({ where: { id: userId } });
const user2 = await prisma.user.findUnique({ where: { id: userId } });

// ✅ GOOD: Reuse pattern
const user = await withUserContext(userId, async (prisma) => {
  return prisma.user.findUnique({ where: { id: userId } });
});
```

### KISS (Keep It Simple, Stupid)

**Principle**: Simplicity should be a key goal; unnecessary complexity should be avoided

**Application**:

- **Prefer simple solutions** over clever ones
- **Use existing patterns** before creating new ones
- **Avoid premature optimization**
- **Clear, readable code** over terse code

**Example**:

```typescript
// ❌ BAD: Overly clever
const result = data?.items?.filter((x) => x.active)?.map((x) => x.id) ?? [];

// ✅ GOOD: Clear and simple
const activeItems = data?.items?.filter((item) => item.active) || [];
const activeIds = activeItems.map((item) => item.id);
```

### YAGNI (You Aren't Gonna Need It)

**Principle**: Don't add functionality until it's necessary

**Application**:

- **Implement only what's in the spec**
- **No speculative features**
- **No "just in case" code**
- **Wait for actual requirements**

**Example**:

- ❌ Don't build multi-tenancy if spec doesn't require it
- ✅ Build exactly what the user story describes
- ❌ Don't add "future-proofing" abstractions
- ✅ Refactor when actual need emerges

### Separation of Concerns

**Principle**: Different concerns should be in different modules

**Application**:

- **UI Components** (`components/`) - Presentation only
- **Business Logic** (`lib/`) - Domain logic
- **Data Access** (`lib/prisma.ts` + context helpers) - Database operations
- **API Routes** (`app/api/`) - HTTP handling only

**Pattern**:

```
User Request → API Route → Business Logic → Data Access → Database
                ↓              ↓                ↓
            Validation    Domain Rules    RLS Context
```

### Security-First Architecture (MANDATORY)

**Principle**: Security is not optional; it's the foundation

**Application**:

- **RLS (Row Level Security)**: MANDATORY for all database operations
- **Authentication**: Required for protected routes (Clerk integration)
- **Input Validation**: Zod schemas for all user input
- **No Direct Prisma Calls**: Must use `withUserContext`/`withAdminContext`/`withSystemContext`

**Zero Tolerance**:

- ❌ Direct `prisma` calls without RLS context
- ❌ Missing authentication on protected routes
- ❌ Unvalidated user input
- ❌ Secrets in code

**Mandatory Pattern**:

```typescript
// ✅ ALWAYS use RLS context helpers
const result = await withUserContext(userId, async (prisma) => {
  // All database operations here are automatically scoped to user
  return prisma.resource.findMany();
});
```

---

## Part 2: {{PROJECT_SHORT}} Methodology

### Evidence-Based Delivery

**Principle**: All work must produce verifiable evidence

**Requirements**:

1. **Test Results**: Automated test output
2. **Session IDs**: For AI agent work (Claude session ID)
3. **Screenshots**: For UI changes
4. **Validation Results**: `yarn ci:validate` output
5. **Evidence Attachment**: All evidence attached to Linear ticket

**Example Evidence**:

```markdown
## Evidence - {{TICKET_PREFIX}}-XXX

### Session ID

claude_session_abc123

### Validation Results

✅ yarn lint - PASSED
✅ yarn build - PASSED
✅ yarn test:unit - PASSED (12/12 tests)

### Demo Script Execution

[Screenshot of feature working]
```

### Pattern-Driven Development

**Principle**: Search first, reuse always, create only when necessary

**Mandatory Search Order**:

1. **Specs Directory**: `ls specs/{{TICKET_PREFIX}}-*-spec.md | grep "similar"`
2. **Patterns Library**: `find patterns_library/ -name "*relevant*"`
3. **Codebase**: `grep -r "similar_functionality" app/ lib/`
4. **Git History**: `git log --grep="related_feature"`
5. **Session History**: (Claude Code) `grep -r "similar" ~/.claude/todos/`

**Pattern Reuse Workflow**:

```bash
# 1. Find pattern
cat patterns_library/api-routes/authenticated-get-route.md

# 2. Copy pattern
# 3. Customize for your use case
# 4. Validate against spec
```

### Spec-Driven Workflow

**Principle**: Specifications are the single source of truth

**Spec Hierarchy**:

```
Planning Document (Epic level)
  └── Spec (Feature/Story level)
      └── Low-Level Tasks (Implementation level)
```

**Spec Contents** (MANDATORY):

- User story (As a..., I want..., so that...)
- Acceptance criteria (testable)
- Demo script (validation steps)
- Pattern references (from `patterns_library/`)
- Implementation approach (high-level)
- Testing strategy (unit, integration, E2E)

### SAFe ART Model

**Principle**: Specialized roles with clear responsibilities

**11 Agent Roles**:

1. **TDM** (Technical Delivery Manager) - Coordination, escalation
2. **BSA** (Business Systems Analyst) - Requirements, specs, planning
3. **System Architect** - Architecture validation, pattern approval
4. **FE Developer** - Frontend implementation
5. **BE Developer** - Backend implementation
6. **Data Engineer** - Database schema, migrations
7. **Tech Writer** - Documentation
8. **DPE** (Data Provisioning Engineer) - Test data, database access
9. **QAS** (Quality Assurance Specialist) - Testing execution
10. **SecEng** (Security Engineer) - Security validation, RLS checks
11. **RTE** (Release Train Engineer) - PR creation, CI/CD, releases

**Role Boundaries** (RESPECT):

- BSA creates specs, doesn't implement
- Developers implement, don't create specs
- System Architect validates, doesn't implement
- QAS tests, doesn't fix bugs

---

## Part 3: SAFe Framework Essentials

### SAFe Hierarchy

```
Epic (Strategic Initiative - Multiple Sprints)
  └── Feature (Deliverable Capability - 1-3 Sprints)
      ├── User Story (User-Facing Functionality - 1 Sprint)
      └── Enabler (Technical Foundation - 1 Sprint)
```

### Work Item Definitions

**Epic**:

- **Purpose**: Large strategic initiative
- **Duration**: Multiple sprints (3-6 months)
- **Value**: Significant business impact
- **Example**: "Implement Multi-Tenant Architecture"
- **Format**: `[Epic] {Strategic Initiative Name}`

**Feature**:

- **Purpose**: Deliverable capability
- **Duration**: 1-3 sprints
- **Value**: Independently deployable value
- **Example**: "Tenant Isolation System"
- **Format**: `[Feature] {Capability Name}`

**User Story**:

- **Purpose**: User-facing functionality
- **Duration**: 1 sprint (completable)
- **Value**: Direct user benefit
- **Example**: "As a tenant admin, I want to manage user permissions"
- **Format**: `As a {role}, I want {capability}, so that {benefit}`

**Enabler**:

- **Purpose**: Technical foundation
- **Duration**: 1 sprint
- **Value**: Enables future user stories
- **Example**: "Set up RLS infrastructure"
- **Format**: `[Enabler] {Technical Work}`

### SAFe Principles Applied

**Principle 1: Take an economic view**

- Calculate ROI per feature
- Skip process for low-value tasks
- Cost awareness built into planning

**Principle 2: Apply systems thinking**

- Consider whole system impact
- Identify dependencies early
- Plan for integration points

**Principle 3: Assume variability; preserve options**

- Multiple implementation approaches
- Defer decisions until last responsible moment
- Build flexibility into architecture

**Principle 4: Build incrementally with fast feedback**

- Small, testable increments
- Demo after each story
- Continuous validation

**Principle 5: Base milestones on objective evaluation**

- Evidence-based progression
- Demo scripts validate completion
- No "90% done" syndrome

**Principle 6: Visualize and limit WIP**

- Linear board shows work in progress
- Sprint capacity limits
- Focus on completion over starting

**Principle 7: Apply cadence, synchronize with cross-domain planning**

- 2-week sprint cycles
- Sprint planning, review, retrospective
- Synchronized across all agents

**Principle 8: Unlock intrinsic motivation**

- Clear goals (specs)
- Autonomy (agent roles)
- Mastery (pattern library)
- Purpose (user value)

**Principle 9: Decentralize decision-making**

- Agents make implementation decisions
- System Architect validates approach
- Escalate only when blocked

**Principle 10: Organize around value**

- Features deliver user value
- Stories map to user needs
- Enablers support value delivery

---

## Part 4: Planning Mode Workflow

### When to Use Planning Mode

Engage Planning Mode when:

- **Large Initiative**: Breaking down Epic into Features/Stories
- **Confluence Analysis**: Converting documentation into SAFe work items
- **Strategic Planning**: Creating comprehensive implementation roadmap
- **New Feature Area**: No existing patterns or specs

### Planning Workflow Steps

#### Step 1: Understand the Initiative

**Questions to Answer**:

1. What is the business goal?
2. Who are the users/stakeholders?
3. What is the scope (Epic, Feature, or Story level)?
4. What are the constraints (time, resources, dependencies)?
5. What existing patterns apply?

**Actions**:

```bash
# Read all context
cat confluence_export.md
cat specs/related-*.md

# Search for patterns
find patterns_library/ -name "*relevant*"
grep -r "similar_feature" app/ lib/

# Review schema
cat DATA_DICTIONARY.md
```

#### Step 2: Create SAFe Breakdown

**Use Planning Template**:

```bash
cp specs/planning_template.md specs/{{TICKET_PREFIX}}-XXX-{initiative}-planning.md
```

**Fill Sections**:

1. **Epic Definition**: Strategic goal, business value, success metrics
2. **Features** (3-7): Major capabilities with user value
3. **User Stories** (5-15 per feature): User-facing functionality
4. **Enablers** (20-30% of capacity): Technical foundation
5. **Dependencies**: Cross-feature dependencies
6. **Risks**: Technical and business risks
7. **Testing Strategy**: Unit, integration, E2E testing approach

#### Step 3: Validate Against Standards

**CI/CD Standards**:

- All work must pass `yarn ci:validate`
- Rebase-first workflow (no merge commits)
- Conventional commits required
- PR template must be used

**Security Standards**:

- All database operations use RLS
- Authentication via Clerk (if enabled)
- Input validation with Zod schemas
- No direct Prisma calls

**Data Standards**:

- All schema changes require migrations
- Foreign keys must be defined
- Indexes for performance-critical queries
- RLS policies for all tables

#### Step 4: Create Linear Issues

**For Each Work Item**:

**Epic**:

```
Title: [Epic] {Strategic Initiative Name}
Description:
- Business goal
- Features list
- Success metrics
- Timeline estimate
```

**Feature**:

```
Title: [Feature] {Capability Name}
Description:
- User value
- Stories list
- Acceptance criteria
- Dependencies
Parent: Link to Epic
```

**User Story**:

```
Title: As a {role}, I want {capability}
Description:
- User story format
- Acceptance criteria (testable)
- Demo script
- Pattern references
Parent: Link to Feature
```

**Enabler**:

```
Title: [Enabler] {Technical Work}
Description:
- Technical goal
- Implementation approach
- Validation criteria
- Stories it enables
Parent: Link to Feature
```

#### Step 5: Prioritize and Sequence

**Prioritization Factors**:

1. **Dependencies**: Enablers before stories that depend on them
2. **Risk**: High-risk items early for learning
3. **Value**: High-value items early for ROI
4. **Complexity**: Mix complex and simple for sustainable pace

**Sequencing Rules**:

- Enablers → User Stories that depend on them
- Foundation → Features that build on it
- Core → Extensions
- Happy Path → Edge Cases

---

## Part 5: Current Project Context

### Technology Stack

- **Frontend**: Next.js 15, TypeScript, Tailwind CSS, Shadcn UI
- **Backend**: Next.js API routes, Prisma ORM
- **Database**: PostgreSQL with RLS (Row Level Security)
- **Auth**: Clerk (optional, feature-flagged)
- **Payments**: Stripe (optional, feature-flagged)
- **Analytics**: PostHog (privacy-first, feature-flagged)
- **Deployment**: Coolify.io PaaS
- **CI/CD**: GitHub Actions with quality gates

### Repository Structure

```
/app                    # Next.js App Router
  /(auth)              # Authentication routes
  /(marketing)         # Public pages
  /api                 # API routes
  /dashboard           # Protected dashboard
/components            # React components
  /ui                  # Shadcn UI components
/lib                   # Utilities and shared code
  /prisma.ts           # Prisma client with RLS
/prisma                # Database schema and migrations
/specs                 # Specifications (single source of truth)
/patterns_library      # Reusable code patterns
/docs                  # Documentation
  /team                # Team documentation
  /sop                 # Standard Operating Procedures
  /workflow            # Workflow documentation
```

### Key Patterns

**RLS Pattern** (MANDATORY):

```typescript
// User-scoped operations
const result = await withUserContext(userId, async (prisma) => {
  return prisma.resource.findMany();
});

// Admin operations
const result = await withAdminContext(adminId, async (prisma) => {
  return prisma.resource.findMany();
});

// System operations (no user context)
const result = await withSystemContext(async (prisma) => {
  return prisma.resource.findMany();
});
```

**Feature Flag Pattern**:

```typescript
import { FEATURES } from "@/config/features";

if (FEATURES.PAYMENTS_ENABLED) {
  // Stripe integration code
}
```

**Authentication Pattern**:

```typescript
import { auth } from "@clerk/nextjs/server";

export async function GET() {
  const { userId } = await auth();
  if (!userId) {
    return new Response("Unauthorized", { status: 401 });
  }
  // Protected logic
}
```

---

## Part 6: Quality Checklist

Before finalizing planning document:

**SAFe Compliance**:

- [ ] All work items follow SAFe hierarchy (Epic → Feature → Story/Enabler)
- [ ] User stories use "As a..., I want..., so that..." format
- [ ] Enablers allocated (20-30% of capacity)
- [ ] Dependencies identified and documented
- [ ] Risks documented with mitigation strategies

**Architectural Compliance**:

- [ ] SOLID principles considered
- [ ] DRY - No duplicate functionality
- [ ] KISS - Simple solutions preferred
- [ ] YAGNI - Only necessary features included
- [ ] Security-first - RLS and auth requirements specified

**{{PROJECT_SHORT}} Methodology**:

- [ ] Evidence-based - Demo scripts defined
- [ ] Pattern-driven - Patterns referenced
- [ ] Spec-driven - Acceptance criteria testable
- [ ] Role boundaries - Clear agent assignments

**Technical Standards**:

- [ ] CI/CD validation considered (`yarn ci:validate`)
- [ ] Security requirements included (RLS, auth, validation)
- [ ] Data requirements specified (schema, migrations)
- [ ] Testing strategy comprehensive (unit, integration, E2E)

---

## Part 7: References

**Core Documentation**:

- `CONTRIBUTING.md` - Git workflow and standards
- `docs/database/DATA_DICTIONARY.md` - Database schema reference
- `docs/security/SECURITY_FIRST_ARCHITECTURE.md` - Security patterns
- `docs/database/RLS_IMPLEMENTATION_GUIDE.md` - RLS patterns
- `docs/ci-cd/CI-CD-Pipeline-Guide.md` - CI/CD standards

**Templates**:

- `specs/planning_template.md` - SAFe planning template
- `specs/spec_template.md` - Implementation spec template

**Patterns**:

- `patterns_library/` - Reusable code patterns
- `patterns_library/README.md` - Pattern index

**Agent Roles**:

- `.claude/agents/` - All agent role definitions
- `docs/sop/AGENT_WORKFLOW_SOP.md` - Agent workflow SOP

---

**Remember**: Planning is about breaking down complexity into manageable, valuable, secure increments. Each work item should deliver value, be independently testable, and follow architectural principles.

**When in doubt**: Search first, reuse always, create only when necessary. Consult System Architect for architectural decisions. Escalate to TDM when blocked.
