# Search Pattern Command

Search codebase for patterns using shell tools. Useful for refactoring, finding usage, or understanding patterns.

## Usage

```bash
codex --instructions .codex/commands/search-pattern.md "prisma\." ts
codex --instructions .codex/commands/search-pattern.md "withUserContext"
codex --instructions .codex/commands/search-pattern.md "import.*icons"
```

## Search Workflow

### 1. Parse Arguments

- First argument = Pattern to search (required)
- Second argument = File type filter (optional: ts, tsx, js, md, etc.)

### 2. Execute Search

Search for the pattern using grep or ripgrep:

**With file type filter** (recommended for large codebases):

```bash
grep -rn "PATTERN" --include="*.ts" --include="*.tsx" . | head -50
```

**Without file type** (searches all files):

```bash
grep -rn "PATTERN" . | head -50
```

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
grep -rn "prisma\.\(user\|payment\|subscription\)" --include="*.ts" .
```
Identifies: Direct Prisma calls that should use RLS context helpers

### Find TODO Comments
```bash
grep -rn "TODO:\|FIXME:\|HACK:" .
```
Identifies: Technical debt markers

### Find Deprecated Patterns
```bash
grep -rn "deprecated\|@deprecated" .
```
Identifies: Code marked for removal

### Find Error Handling
```bash
grep -rn "try\s*{" --include="*.ts" .
```
Identifies: Error handling patterns

### Find Environment Variables
```bash
grep -rn "process\.env\." .
```
Identifies: All environment variable usage

### Find API Routes
```bash
grep -rn "export.*GET\|POST\|PUT\|DELETE" --include="*.ts" .
```
Identifies: All API endpoints

### Find Test Files
```bash
grep -rn "describe(\|it(\|test(" --include="*.ts" .
```
Identifies: Test coverage

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
Before refactoring, find all usage to create checklist of files to update.

### 2. Pattern Enforcement
Verify pattern usage (e.g., RLS patterns followed).

### 3. Dependency Analysis
Find imports to understand module dependencies.

### 4. Migration Tracking
Find old patterns to track migration to new patterns.

### 5. Documentation
Find undocumented code and cross-reference with documentation.

## Success Criteria

- Pattern found and categorized
- Usage context understood
- Refactoring opportunities identified
- Actionable insights provided
