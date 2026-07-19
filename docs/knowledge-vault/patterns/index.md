# Patterns

**Nothing in this repository executes any of these.** That is the single most important fact about
this directory, and getting it wrong wastes hours. This repo is a harness — prompts, configuration
and templates — not an application. The eighteen patterns below are **reference implementations the
harness distributes to adopting projects**. There is no build that compiles them, no test that
exercises them, no runtime that imports them. The exemplar *is* the artifact.

So read a pattern as a specification of how a thing should be built in a project that adopts this
harness, and judge it on whether it teaches the right shape — not on whether it runs here.

They are worth taking seriously anyway, because the [Pattern Discovery
Protocol](../methodology/pattern-discovery-protocol.md) makes searching this library mandatory
before any new implementation is written. An agent that skips it is out of contract.

The stack is not uniform. The api/, database/, ui/ and testing/ patterns assume Next.js, Prisma,
Clerk and shadcn/ui, with Row Level Security as the non-negotiable data-access discipline. The
security/ and config/ patterns — plus the deployment pipeline — are written language-agnostically
with `{{LANGUAGE}}`, `{{SOURCE_DIR}}` and `{{EXT}}` tokens, and name Python and Go alternatives
(Pydantic alongside Zod, for instance).

## Data access and RLS

The load-bearing group. Every one of these exists to make the same rule concrete: **a request may
only reach rows it owns**, enforced at the database rather than in application `if` statements. The
three context helpers differ only in who they claim to be.

- [User Context API Pattern](user-context-api.md) — the default: `withUserContext`, so an
  authenticated route reaches only that user's rows. Read this one first; the other two are
  deviations from it.
- [Admin Context API Pattern](admin-context-api.md) — elevated access via
  `verifyAdminAndGetUserId` plus `withAdminContext`, for routes that legitimately cross users
- [Webhook Handler Pattern](webhook-handler.md) — signature-verified endpoints writing under
  `withSystemContext`, where there is no user to attribute the request to (Stripe, Clerk, others)
- [Prisma Transaction Pattern](prisma-transaction.md) — multi-step writes that must be atomic
  *without* dropping out of the RLS context to achieve it
- [RLS Migration Pattern](rls-migration.md) — the schema plus migration that adds a user-owned table
  together with its policies. The pattern that makes the others possible.

## API construction

How a route handler is shaped before it ever touches data:

- [Zod Validation API Pattern](zod-validation-api.md) — schemas as the single source of both runtime
  validation and inferred static types
- [Input Sanitization Pattern](input-sanitization.md) — defense in depth at the boundary against
  XSS, SQL injection and path traversal
- [Rate Limiting Pattern](rate-limiting.md) — sliding window, per-user with IP fallback, in-memory or
  Redis backed

## User interface

- [Authenticated Page Pattern](authenticated-page.md) — server-rendered protected page: auth
  redirect, RLS-scoped fetch, forced dynamic rendering. The page-level twin of the user-context
  route.
- [Form with Validation Pattern](form-with-validation.md) — React Hook Form plus the Zod resolver
  plus shadcn/ui primitives, so client and server validate against one schema
- [Data Table Pattern](data-table.md) — server-rendered sortable, filterable table with row action
  menus

## Testing

Three levels, ordered by how much they cost to run and how much they prove:

- [API Integration Test Pattern](api-integration-test.md) — Jest against route handlers with Clerk
  and the database mocked, asserting RLS behaviour rather than assuming it
- [E2E User Flow Pattern](e2e-user-flow.md) — Playwright over a complete authenticated journey
- [GitHub Actions CI Workflow Pattern](github-actions-workflow.md) — the lint, type-check, test and
  build gates that run them, with matrix and caching

## Configuration and operations

- [Environment Configuration Pattern](environment-config.md) — typed, schema-validated config
  checked once at startup, so a missing variable fails loudly at boot instead of quietly in
  production
- [Secrets Management Pattern](secrets-management.md) — the same discipline aimed at credentials,
  with `.env.template` as living documentation of what a deployment needs
- [Structured Logging Pattern](structured-logging.md) — JSON logs with correlation IDs and request
  context propagation, which is what makes an incident reconstructable
- [Deployment Pipeline Pattern](deployment-pipeline.md) — staging, smoke tests, a manual approval
  gate, and a rollback path

## Related

- [Pattern Library](../subsystems/pattern-library.md) — the subsystem view: how these are packaged
  and shipped to adopters
- [Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md) — the rule that makes
  searching here mandatory before implementing
- [RLS Implementation Guide](../knowledge/database/rls-implementation-guide.md) — the source-of-truth
  doc behind the data-access group
- [docs/patterns Redirect](../knowledge/misc/patterns-redirect.md) — why an older docs path points
  here
