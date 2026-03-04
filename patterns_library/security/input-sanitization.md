# Input Sanitization Pattern

## What It Does

Provides a defense-in-depth approach to sanitizing user input against XSS, SQL injection, and path traversal attacks. Combines schema validation, HTML encoding, parameterized queries, and filesystem path normalization into a reusable set of utilities that can be applied at API boundaries before any business logic executes.

## When to Use

- Any API endpoint that accepts user-provided strings (form fields, query parameters, headers)
- Rendering user-generated content in HTML responses or templates
- Constructing file paths from user input (uploads, exports, report generation)
- Building database queries that include dynamic values
- Processing webhook payloads from external systems
- Accepting rich text or markdown content from users

## Code Pattern

### 1. HTML Encoding Utility

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/sanitize/html-encode.{{EXT}}

/**
 * Encodes HTML special characters to prevent XSS when rendering user input.
 * Apply this to ALL user-provided strings before inserting into HTML context.
 */
function encodeHtml(raw: string): string {
  const ENTITY_MAP: Record<string, string> = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
    '`': '&#96;',
  };

  return raw.replace(/[&<>"'`/]/g, (char) => ENTITY_MAP[char] || char);
}

/**
 * Strips all HTML tags from input. Use when you need plain text only.
 */
function stripHtml(raw: string): string {
  return raw.replace(/<[^>]*>/g, '');
}

/**
 * Sanitizes a string for safe inclusion in a URL query parameter.
 */
function encodeQueryParam(raw: string): string {
  return encodeURIComponent(raw);
}
```

### 2. SQL Injection Prevention

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/sanitize/query-safety.{{EXT}}

/**
 * RULE: Never concatenate user input into SQL strings.
 * Always use parameterized queries via your ORM or query builder.
 *
 * BAD  - Direct string interpolation (vulnerable):
 *   `SELECT * FROM users WHERE name = '${userInput}'`
 *
 * GOOD - Parameterized query (safe):
 *   `SELECT * FROM users WHERE name = $1`, [userInput]
 *
 * BEST - ORM with type-safe queries (safe + validated):
 *   {{ORM_CLIENT}}.users.findMany({ where: { name: userInput } })
 */

/**
 * Validates that a dynamic column or table name is in an allowlist.
 * Use this when sort columns or table names come from user input.
 */
function validateIdentifier(
  input: string,
  allowlist: readonly string[]
): string {
  const normalized = input.trim().toLowerCase();

  if (!allowlist.includes(normalized)) {
    throw new Error(
      `Invalid identifier: "${input}". Allowed values: ${allowlist.join(', ')}`
    );
  }

  return normalized;
}

// Example: Safe dynamic sorting
const SORTABLE_COLUMNS = ['created_at', 'updated_at', 'name', 'email'] as const;

function buildSortClause(userSortField: string, userSortOrder: string) {
  const column = validateIdentifier(userSortField, SORTABLE_COLUMNS);
  const order = validateIdentifier(userSortOrder, ['asc', 'desc']);

  return { [column]: order };
}
```

### 3. Path Traversal Defense

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/sanitize/path-safety.{{EXT}}

import path from 'path'; // or equivalent in your runtime

/**
 * Base directory for user-accessible files.
 * All resolved paths MUST stay within this directory.
 */
const UPLOAD_ROOT = process.env.UPLOAD_DIR || '/app/uploads';

/**
 * Resolves a user-provided filename to a safe absolute path.
 * Prevents directory traversal attacks (e.g., "../../etc/passwd").
 *
 * Throws if the resolved path escapes the allowed root directory.
 */
function resolveSafePath(userFilename: string, rootDir: string = UPLOAD_ROOT): string {
  // 1. Strip null bytes (bypass technique)
  const cleaned = userFilename.replace(/\0/g, '');

  // 2. Extract just the filename (remove any directory components)
  const basename = path.basename(cleaned);

  // 3. Reject empty or dot-only filenames
  if (!basename || basename === '.' || basename === '..') {
    throw new Error(`Invalid filename: "${userFilename}"`);
  }

  // 4. Resolve to absolute path
  const resolved = path.resolve(rootDir, basename);

  // 5. Verify the resolved path is within the allowed root
  if (!resolved.startsWith(path.resolve(rootDir) + path.sep) &&
      resolved !== path.resolve(rootDir)) {
    throw new Error(`Path traversal blocked: "${userFilename}"`);
  }

  return resolved;
}

/**
 * Validates file extension against an allowlist.
 */
function validateFileExtension(
  filename: string,
  allowedExtensions: string[]
): boolean {
  const ext = path.extname(filename).toLowerCase();
  return allowedExtensions.includes(ext);
}
```

### 4. Combined Input Sanitization Middleware

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/sanitize/middleware.{{EXT}}

/**
 * Applies sanitization to all string values in a request body (recursive).
 * Place this at the API boundary before validation/business logic.
 */
function sanitizeRequestBody(body: unknown): unknown {
  if (typeof body === 'string') {
    return body
      .trim()                          // Remove leading/trailing whitespace
      .replace(/\0/g, '')             // Strip null bytes
      .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, ''); // Strip control chars
  }

  if (Array.isArray(body)) {
    return body.map(sanitizeRequestBody);
  }

  if (body !== null && typeof body === 'object') {
    const sanitized: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(body)) {
      sanitized[key] = sanitizeRequestBody(value);
    }
    return sanitized;
  }

  return body; // Numbers, booleans, null pass through unchanged
}

/**
 * Example: Apply sanitization in an API route handler.
 *
 * async function handleRequest(request) {
 *   const rawBody = await request.json();
 *   const cleanBody = sanitizeRequestBody(rawBody);
 *   const validated = MySchema.parse(cleanBody); // Then validate with schema
 *   // ... proceed with business logic
 * }
 */
```

## Customization Guide

1. **Replace template placeholders**:
   - `{{LANGUAGE}}` with your language (e.g., `typescript`, `python`, `go`)
   - `{{EXT}}` with your file extension (e.g., `ts`, `py`, `go`)
   - `{{SOURCE_DIR}}` with your source directory (e.g., `src`, `app`, `lib`)
   - `{{ORM_CLIENT}}` with your ORM client name (e.g., `prisma`, `drizzle`, `sequelize`)

2. **Adjust the HTML encoding map** for your rendering context. If you render into XML, SVG, or other markup contexts, add the relevant escape sequences for those formats.

3. **Extend the path safety utilities** for your file storage approach. If using cloud storage (S3, GCS, Azure Blob), adapt `resolveSafePath` to validate object key prefixes rather than filesystem paths.

4. **Add domain-specific sanitization** for fields with known formats (emails, phone numbers, URLs). Use schema validation for structural rules and sanitization for cleaning raw input.

5. **Wire the middleware** into your request pipeline. Place `sanitizeRequestBody` as early as possible, before schema validation, so that validators operate on cleaned data.

6. **Configure Content Security Policy (CSP)** headers as an additional XSS defense layer. Sanitization is one layer; CSP prevents execution even if encoding is missed.

## Security Checklist

- [ ] **HTML encoding applied** before rendering any user-provided string in HTML/templates
- [ ] **Parameterized queries only** - no string concatenation in SQL/database queries
- [ ] **ORM used for all database operations** - raw SQL avoided or wrapped in parameterized helpers
- [ ] **Dynamic identifiers allowlisted** - sort columns, table names validated against explicit lists
- [ ] **Path traversal blocked** - user-provided filenames resolved and verified within allowed root
- [ ] **Null bytes stripped** - `\0` characters removed from all string inputs
- [ ] **Control characters removed** - non-printable characters stripped at API boundary
- [ ] **File extensions validated** - upload filenames checked against an allowlist of permitted types
- [ ] **Content-Type headers set** - responses include correct `Content-Type` to prevent MIME sniffing
- [ ] **CSP headers configured** - `Content-Security-Policy` header set to restrict script sources
- [ ] **Input length limits enforced** - maximum string lengths defined in validation schemas

## Validation Commands

```bash
# Run linting to catch unsafe patterns
{{LINT_COMMAND}}

# Type-check sanitization utilities
{{TYPE_CHECK_COMMAND}}

# Run security-focused tests
{{TEST_UNIT_COMMAND}} --grep "sanitiz"

# Full CI validation
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Zod Validation API](../api/zod-validation-api.md) - Schema validation for structured input
- [User Context API](../api/user-context-api.md) - Authenticated API with RLS (defense-in-depth)
- [Webhook Handler](../api/webhook-handler.md) - Sanitizing external webhook payloads
- [Rate Limiting](./rate-limiting.md) - Throttle abusive input attempts
- [Environment Config](../config/environment-config.md) - Validate configuration inputs at startup

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
