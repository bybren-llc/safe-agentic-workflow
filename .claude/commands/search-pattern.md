---
description: Search for code patterns across codebase
argument-hint: <pattern> [file-type]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

Search codebase for patterns using optimized tools. Useful for refactoring, finding usage, or understanding patterns.

## Usage

```bash
/search-pattern "prisma\." ts     # Find direct Prisma usage in TypeScript
/search-pattern "withUserContext" # Find RLS context usage
/search-pattern "import.*icons"  # Find icon imports
```

## Search Workflow

### 1. Parse Arguments

- $1 = Pattern to search (required)
- $2 = File type filter (optional: ts, tsx, js, md, etc.)

### 2. Execute Search

Use the Grep tool with these parameters:

**With file type filter** (recommended for large codebases):

| Parameter     | Value                     | Example                 |
| ------------- | ------------------------- | ----------------------- |
| `pattern`     | The regex pattern to find | `"withUserContext"`     |
| `type`        | File type to search       | `"ts"`, `"tsx"`, `"md"` |
| `output_mode` | `"files_with_matches"`    | Shows matching files    |

**Without file type** (searches all files):

| Parameter     | Value                     | Example              |
| ------------- | ------------------------- | -------------------- |
| `pattern`     | The regex pattern to find | `"prisma\."`         |
| `output_mode` | `"content"`               | Shows matching lines |
| `head_limit`  | Limit results (optional)  | `50`                 |

**With context** (show surrounding lines):

| Parameter     | Value                      | Example                     |
| ------------- | -------------------------- | --------------------------- |
| `pattern`     | The regex pattern          | `"withUserContext"`         |
| `-C`          | Context lines before/after | `3`                         |
| `output_mode` | `"content"`                | Required for context output |

### 3. Analyze Results

Report:

- Total matches found
- Files affected
- Common patterns noticed
- Potential refactoring opportunities

### 4. Categorize Findings

Group by:

- **Usage patterns**: How pattern is used
- **Contexts**: Where pattern appears
- **Variations**: Different uses of pattern
- **Outliers**: Unusual usage

## Common Search Patterns

### Find Direct Database Access

```bash
/search-pattern "prisma\.(user|payment|subscription)" ts
```

Identifies: Direct Prisma calls that should use RLS context helpers

### Find Icon Library Usage

```bash
/search-pattern "from.*react-icons"
```

Identifies: Which icon libraries are used where

### Find TODO Comments

```bash
/search-pattern "TODO:|FIXME:|HACK:"
```

Identifies: Technical debt markers

### Find Deprecated Patterns

```bash
/search-pattern "deprecated|@deprecated"
```

Identifies: Code marked for removal

### Find Error Handling

```bash
/search-pattern "try\s*\{|catch\s*\(" ts
```

Identifies: Error handling patterns

### Find Environment Variables

```bash
/search-pattern "process\.env\."
```

Identifies: All environment variable usage

### Find API Routes

```bash
/search-pattern "export.*GET|POST|PUT|DELETE" ts
```

Identifies: All API endpoints

### Find Test Files

```bash
/search-pattern "describe\(|it\(|test\(" ts
```

Identifies: Test coverage

## Advanced Patterns

### Multiline Search

For patterns spanning multiple lines (e.g., finding function bodies):

| Parameter   | Value                                   | Purpose                   |
| ----------- | --------------------------------------- | ------------------------- |
| `pattern`   | `"async function.*\\{[\\s\\S]*?return"` | Cross-line pattern        |
| `multiline` | `true`                                  | Enable multiline matching |
| `type`      | `"ts"`                                  | Optional file type filter |

Example: Find async functions that return Prisma results

### Context Search

Show surrounding lines for understanding usage context:

| Parameter     | Purpose                  | When to Use                     |
| ------------- | ------------------------ | ------------------------------- |
| `-A 3`        | 3 lines after match      | See what happens after          |
| `-B 3`        | 3 lines before match     | See imports, function signature |
| `-C 5`        | 5 lines before and after | Full context around match       |
| `output_mode` | Must be `"content"`      | Required for context output     |

Example: See function signature with implementation context

### Regex Patterns

Complex patterns:

- `\bfunction\s+(\w+)` - Function names
- `import.*from\s+['"](.*)['"]` - Import sources
- `interface\s+(\w+)` - Interface names

## Output Format

### Summary

```text
Pattern: {search-pattern}
Files: {count} files
Matches: {count} occurrences
```

### Grouped Results

```text
Category: {category-name}
- file1:line - context
- file2:line - context

Category: {category-name}
- file3:line - context
```

### Recommendations

Based on findings:

- Refactoring opportunities
- Pattern consistency issues
- Missing patterns
- Best practice violations

## Use Cases

### 1. Pre-Refactoring

Before refactoring, find all usage:

```bash
/search-pattern "oldFunctionName"
```

Creates checklist of files to update.

### 2. Pattern Enforcement

Verify pattern usage:

```bash
/search-pattern "withUserContext|withAdminContext"
```

Ensures RLS patterns followed.

### 3. Dependency Analysis

Find imports:

```bash
/search-pattern "from '@/lib/prisma'"
```

Understand module dependencies.

### 4. Migration Tracking

Find old patterns:

```bash
/search-pattern "OldComponent"
```

Track migration to new patterns.

### 5. Documentation

Find undocumented code:

```bash
/search-pattern "export (function|class|interface)" ts
```

Cross-reference with documentation.

## Integration with Refactoring

After search:

1. Create Linear ticket for refactoring
2. List all affected files
3. Estimate effort
4. Plan incremental changes
5. Track progress

## Success Criteria

- ✅ Pattern found and categorized
- ✅ Usage context understood
- ✅ Refactoring opportunities identified
- ✅ Actionable insights provided

This command accelerates code understanding and refactoring planning.
