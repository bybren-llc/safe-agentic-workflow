# {{PROJECT_SHORT}} Skills

These skills are part of the **{{PROJECT_NAME}}** multi-agent harness for Gemini CLI.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Skills Included (17)

| Skill | Purpose |
|-------|---------|
| safe-workflow | Branch naming, commits, PR workflow |
| release-patterns | PR creation, CI/CD validation |
| pattern-discovery | Search patterns before implementing |
| agent-coordination | Agent assignment, blockers |
| rls-patterns | Row Level Security enforcement |
| spec-creation | Specs with acceptance criteria |
| orchestration-patterns | Multi-step task orchestration |
| testing-patterns | Jest and Playwright patterns |
| security-audit | RLS validation, vulnerability scanning |
| linear-sop | Linear ticket management |
| migration-patterns | Database migrations with RLS |
| frontend-patterns | Next.js, Clerk, shadcn/ui |
| api-patterns | API routes with Zod validation |
| git-advanced | Rebase, bisect, cherry-pick |
| stripe-patterns | Payment integration, webhooks |
| deployment-sop | Deployment workflows |
| confluence-docs | ADRs, runbooks, docs |

## Claude Code-Specific Skills

The following skills are available only in the Claude Code provider (`.claude/skills/`) and are not included in the Gemini provider:

| Skill | Reason |
|-------|--------|
| team-coordination | Requires Claude Code Agent Teams (experimental feature) |

## Creating New Skills

See [/docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md](/docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md).
