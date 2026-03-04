# Secrets Management Pattern

## What It Does

Establishes a structured approach to managing environment variables and application secrets. Validates all required configuration at application startup, provides typed configuration objects, and fails fast with clear error messages when required variables are missing or malformed. Uses `.env.template` as living documentation of required configuration.

## When to Use

- Application startup configuration (database URLs, API keys, service credentials)
- Third-party service integration (payment providers, auth providers, analytics)
- Environment-specific settings (development, staging, production)
- Feature flags and runtime configuration that varies per deployment
- Any project that uses environment variables for configuration

## Code Pattern

### 1. Environment Template (.env.template)

```bash
# .env.template
# ============================================================================
# ENVIRONMENT CONFIGURATION TEMPLATE
# ============================================================================
# Copy this file to .env.local (development) or configure in your
# deployment platform (staging/production).
#
# REQUIRED variables will cause the application to fail on startup if missing.
# OPTIONAL variables have sensible defaults noted in comments.
# ============================================================================

# --- Application -----------------------------------------------------------
# REQUIRED: Application environment
NODE_ENV=development
# REQUIRED: Base URL for the application (no trailing slash)
{{APP_URL_VAR}}=http://localhost:3000
# OPTIONAL: Application port (default: 3000)
PORT=3000

# --- Database ---------------------------------------------------------------
# REQUIRED: Primary database connection string
{{DATABASE_URL_VAR}}=postgresql://user:password@localhost:5432/dbname
# OPTIONAL: Connection pool size (default: 10)
# DATABASE_POOL_SIZE=10

# --- Authentication ---------------------------------------------------------
# REQUIRED: Auth provider credentials
{{AUTH_PUBLIC_KEY_VAR}}=pk_test_xxxxx
{{AUTH_SECRET_KEY_VAR}}=sk_test_xxxxx

# --- Payments (if applicable) -----------------------------------------------
# REQUIRED for payment features
# {{PAYMENT_SECRET_KEY_VAR}}=sk_test_xxxxx
# {{PAYMENT_WEBHOOK_SECRET_VAR}}=whsec_xxxxx

# --- External Services -------------------------------------------------------
# OPTIONAL: Redis URL for caching/rate limiting (default: none, uses in-memory)
# REDIS_URL=redis://localhost:6379

# --- Observability -----------------------------------------------------------
# OPTIONAL: Log level (default: info). Values: debug, info, warn, error
# LOG_LEVEL=info
# OPTIONAL: Analytics/telemetry key
# {{ANALYTICS_KEY_VAR}}=phc_xxxxx
```

### 2. Configuration Validator

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/env-validator.{{EXT}}

/**
 * Validates environment variables at startup.
 * Fails fast with a clear, actionable error message listing ALL
 * missing or invalid variables (not just the first one found).
 */

interface EnvVarSpec {
  /** Environment variable name */
  name: string;
  /** Whether the variable is required (default: true) */
  required?: boolean;
  /** Default value if not set (implies required: false) */
  defaultValue?: string;
  /** Human-readable description for error messages */
  description: string;
  /** Validation pattern (regex) */
  pattern?: RegExp;
  /** Sensitive value - mask in logs */
  sensitive?: boolean;
}

function validateEnvironment(specs: EnvVarSpec[]): Record<string, string> {
  const errors: string[] = [];
  const config: Record<string, string> = {};

  for (const spec of specs) {
    const value = process.env[spec.name] ?? spec.defaultValue;
    const isRequired = spec.required !== false && spec.defaultValue === undefined;

    if (!value && isRequired) {
      errors.push(
        `  MISSING: ${spec.name} - ${spec.description}`
      );
      continue;
    }

    if (!value) {
      continue; // Optional and not provided
    }

    if (spec.pattern && !spec.pattern.test(value)) {
      errors.push(
        `  INVALID: ${spec.name} - ${spec.description} (does not match expected format)`
      );
      continue;
    }

    config[spec.name] = value;
  }

  if (errors.length > 0) {
    const message = [
      '',
      '========================================',
      ' ENVIRONMENT CONFIGURATION ERROR',
      '========================================',
      '',
      'The following environment variables are missing or invalid:',
      '',
      ...errors,
      '',
      'To fix:',
      '  1. Copy .env.template to .env.local',
      '  2. Fill in the required values',
      '  3. Restart the application',
      '',
      'See .env.template for documentation on each variable.',
      '========================================',
      '',
    ].join('\n');

    throw new Error(message);
  }

  return config;
}
```

### 3. Typed Configuration Object

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/index.{{EXT}}

/**
 * Application configuration - validated and typed.
 *
 * Import this module instead of reading process.env directly.
 * Validation runs once at module load time (application startup).
 *
 * Usage:
 *   import { config } from '{{SOURCE_DIR}}/lib/config';
 *   console.log(config.database.url);
 */

const ENV_SPECS: EnvVarSpec[] = [
  // Application
  {
    name: 'NODE_ENV',
    description: 'Application environment (development, staging, production)',
    pattern: /^(development|staging|production|test)$/,
    defaultValue: 'development',
  },
  {
    name: '{{APP_URL_VAR}}',
    description: 'Base URL for the application',
    pattern: /^https?:\/\/.+/,
  },

  // Database
  {
    name: '{{DATABASE_URL_VAR}}',
    description: 'Primary database connection string',
    sensitive: true,
  },

  // Authentication
  {
    name: '{{AUTH_PUBLIC_KEY_VAR}}',
    description: 'Auth provider public key',
  },
  {
    name: '{{AUTH_SECRET_KEY_VAR}}',
    description: 'Auth provider secret key',
    sensitive: true,
  },

  // Optional
  {
    name: 'PORT',
    description: 'Application port',
    defaultValue: '3000',
    pattern: /^\d+$/,
  },
  {
    name: 'LOG_LEVEL',
    description: 'Logging level',
    defaultValue: 'info',
    pattern: /^(debug|info|warn|error)$/,
  },
];

// Validate at import time (fail-fast on startup)
const validated = validateEnvironment(ENV_SPECS);

// Export typed configuration object
const config = {
  env: validated['NODE_ENV'] as 'development' | 'staging' | 'production' | 'test',
  appUrl: validated['{{APP_URL_VAR}}'],
  port: parseInt(validated['PORT'], 10),

  database: {
    url: validated['{{DATABASE_URL_VAR}}'],
  },

  auth: {
    publicKey: validated['{{AUTH_PUBLIC_KEY_VAR}}'],
    secretKey: validated['{{AUTH_SECRET_KEY_VAR}}'],
  },

  logging: {
    level: validated['LOG_LEVEL'] as 'debug' | 'info' | 'warn' | 'error',
  },

  isDevelopment: validated['NODE_ENV'] === 'development',
  isProduction: validated['NODE_ENV'] === 'production',
  isTest: validated['NODE_ENV'] === 'test',
} as const;

export { config };
```

### 4. Startup Verification

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/verify.{{EXT}}

/**
 * Call this function early in your application startup to verify
 * configuration and log a sanitized summary.
 */
function verifyConfiguration(): void {
  // Importing config triggers validation (fail-fast)
  const { config } = require('./index');

  // Log sanitized configuration summary (never log secrets)
  console.log('Configuration verified:');
  console.log(`  Environment: ${config.env}`);
  console.log(`  App URL:     ${config.appUrl}`);
  console.log(`  Port:        ${config.port}`);
  console.log(`  Log Level:   ${config.logging.level}`);
  console.log(`  Database:    ${maskConnectionString(config.database.url)}`);
  console.log(`  Auth:        ${config.auth.publicKey.substring(0, 10)}...`);
}

/**
 * Masks sensitive parts of a connection string for safe logging.
 * Input:  postgresql://user:s3cret@host:5432/db
 * Output: postgresql://user:****@host:5432/db
 */
function maskConnectionString(url: string): string {
  try {
    const parsed = new URL(url);
    if (parsed.password) {
      parsed.password = '****';
    }
    return parsed.toString();
  } catch {
    return '****'; // If URL parsing fails, mask everything
  }
}
```

## Customization Guide

1. **Replace template placeholders**:
   - `{{LANGUAGE}}` with your language (e.g., `typescript`, `python`, `go`)
   - `{{EXT}}` with your file extension (e.g., `ts`, `py`, `go`)
   - `{{SOURCE_DIR}}` with your source directory (e.g., `src`, `app`, `lib`)
   - `{{APP_URL_VAR}}` with your URL variable name (e.g., `NEXT_PUBLIC_APP_URL`, `APP_URL`)
   - `{{DATABASE_URL_VAR}}` with your database URL variable (e.g., `DATABASE_URL`, `DB_CONNECTION_STRING`)
   - `{{AUTH_PUBLIC_KEY_VAR}}` / `{{AUTH_SECRET_KEY_VAR}}` with your auth variable names
   - `{{PAYMENT_SECRET_KEY_VAR}}` / `{{PAYMENT_WEBHOOK_SECRET_VAR}}` with payment variable names
   - `{{ANALYTICS_KEY_VAR}}` with your analytics variable name

2. **Add environment-specific specs** for variables that only apply in certain environments (e.g., payment webhook secrets only required in production).

3. **Integrate with your framework's config system**. For example, in Next.js use `next.config.js` runtime config; in NestJS use `@nestjs/config`; adapt the validation approach to your framework's idioms.

4. **Extend the `.env.template`** whenever a new environment variable is introduced. This file serves as the canonical documentation for all configuration.

5. **Add validation patterns** for variables with known formats (URLs, keys with known prefixes, numeric ranges).

6. **Configure CI to verify `.env.template` completeness** by checking that every variable referenced in code is documented in the template.

## Security Checklist

- [ ] **`.env` and `.env.local` in `.gitignore`** - secrets never committed to version control
- [ ] **`.env.template` committed** - documents required variables without actual values
- [ ] **Fail-fast on missing variables** - application refuses to start with missing required config
- [ ] **ALL missing variables reported** - error message lists every missing variable, not just the first
- [ ] **Sensitive values masked in logs** - connection strings and keys never logged in full
- [ ] **Typed config object used** - code imports `config` object, never reads `process.env` directly
- [ ] **Validation patterns enforced** - variables with known formats are validated (URLs, enums, numbers)
- [ ] **Production secrets in secure vault** - not stored in CI/CD environment settings alone
- [ ] **Secret rotation plan documented** - process for rotating keys without downtime
- [ ] **No secrets in client bundles** - server-only variables not exposed to frontend code

## Validation Commands

```bash
# Verify configuration loads successfully
{{DEV_COMMAND}} & sleep 5 && kill $!  # Start and check for config errors

# Type-check configuration module
{{TYPE_CHECK_COMMAND}}

# Lint for direct process.env usage (should use config object instead)
{{LINT_COMMAND}}

# Verify .env.template is in version control
git ls-files --error-unmatch .env.template

# Verify .env files are gitignored
git check-ignore .env .env.local

# Full CI validation
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Environment Config](../config/environment-config.md) - Typed configuration with schema validation
- [Structured Logging](../config/structured-logging.md) - Log configuration with masked secrets
- [GitHub Actions Workflow](../ci/github-actions-workflow.md) - CI secrets configuration
- [Deployment Pipeline](../ci/deployment-pipeline.md) - Production secrets management
- [Input Sanitization](./input-sanitization.md) - Validate all external input including config

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
