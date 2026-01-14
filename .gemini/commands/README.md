# WTFB Commands

These slash commands are part of the **Words To Film By** multi-agent harness for Gemini CLI.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [Bybren LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The command architecture and workflow methodology are the intellectual property of J. Scott Graham and Bybren LLC.

## Commands Included (22 total)

### Workflow Commands (`/workflow:*`)

| Command | Purpose |
|---------|---------|
| `/workflow:start-work` | Begin work on Linear ticket |
| `/workflow:pre-pr` | Run validation before PR |
| `/workflow:end-work` | Complete work session |
| `/workflow:check-workflow` | Check workflow status |
| `/workflow:update-docs` | Update documentation |
| `/workflow:retro` | Session retrospective |
| `/workflow:sync-linear` | Sync with Linear ticket |
| `/workflow:quick-fix` | Fast-track small fixes |

### Local Operations (`/local:*`)

| Command | Purpose |
|---------|---------|
| `/local:sync` | Sync after git pull |
| `/local:deploy` | Deploy locally |

### Remote Operations (`/remote:*`)

| Command | Purpose |
|---------|---------|
| `/remote:status` | Check remote Docker status |
| `/remote:deploy` | Deploy to remote staging |
| `/remote:health` | Remote health dashboard |
| `/remote:logs` | View remote container logs |
| `/remote:rollback` | Rollback remote deployment |

### Media Commands (`/media:*`)

| Command | Purpose |
|---------|---------|
| `/media:analyze-images` | Analyze images using vision |
| `/media:extract-pdf` | Extract structured data from PDFs |
| `/media:sketch-to-code` | Generate code from UI sketches |
| `/media:organize-files` | Organize files based on content |

### Other Commands

| Command | Purpose |
|---------|---------|
| `/test-pr-docker` | Test PR Docker workflow |
| `/audit-deps` | Dependency audit |
| `/search-pattern` | Search code patterns |

## TOML Format

Gemini CLI commands use TOML format with these fields:

```toml
description = "What this command does"

prompt = """
Command instructions here.
Use {{args}} for user input.
Use !{command} for shell injection.
Use @{path} for file injection.
"""
```

## Namespacing

Commands in subdirectories become namespaced:
- `workflow/start-work.toml` → `/workflow:start-work`
- `media/analyze-images.toml` → `/media:analyze-images`

For complete documentation, see [/.gemini/README.md](../README.md).
