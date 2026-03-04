# Environment Configuration Pattern

## What It Does

Provides a typed, validated environment configuration system using a schema validation library. Validates all environment variables at application startup with type coercion, default values, and descriptive error messages. Ensures the application fails fast with actionable diagnostics rather than encountering cryptic runtime errors from missing or malformed configuration values.

## When to Use

- Application startup configuration for any environment (development, staging, production)
- Projects with more than a handful of environment variables
- Teams where multiple developers need consistent local configuration
- Microservices or serverless functions that require validated runtime configuration
- Any project that has experienced bugs caused by missing or misconfigured environment variables

## Code Pattern

### 1. Configuration Schema Definition

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/schema.{{EXT}}

/**
 * Environment configuration schema.
 *
 * This is the SINGLE SOURCE OF TRUTH for all configuration values.
 * Every environment variable the application uses must be declared here.
 *
 * Replace the validation library syntax below with your preferred library:
 * - Zod (TypeScript): z.object({ ... })
 * - Pydantic (Python): class Settings(BaseSettings): ...
 * - Viper (Go): viper.SetDefault(...)
 * - Joi (Node.js): Joi.object({ ... })
 * - Yup (JavaScript): yup.object({ ... })
 */

// Using a generic validation library syntax (adapt to your preferred library)
const configSchema = defineSchema({
  // ── Application ────────────────────────────────────────────────
  NODE_ENV: {
    type: 'enum',
    values: ['development', 'staging', 'production', 'test'],
    default: 'development',
    description: 'Application runtime environment',
  },

  APP_URL: {
    type: 'url',
    required: true,
    description: 'Public-facing application URL (no trailing slash)',
    // Example: 'https://myapp.example.com'
  },

  PORT: {
    type: 'integer',
    default: 3000,
    min: 1,
    max: 65535,
    description: 'HTTP server listen port',
  },

  // ── Database ───────────────────────────────────────────────────
  DATABASE_URL: {
    type: 'string',
    required: true,
    sensitive: true,
    description: 'Primary database connection string',
    // Example: 'postgresql://user:pass@host:5432/dbname'
  },

  DATABASE_POOL_SIZE: {
    type: 'integer',
    default: 10,
    min: 1,
    max: 100,
    description: 'Maximum database connection pool size',
  },

  // ── Authentication ─────────────────────────────────────────────
  AUTH_PUBLIC_KEY: {
    type: 'string',
    required: true,
    description: 'Authentication provider public key',
  },

  AUTH_SECRET_KEY: {
    type: 'string',
    required: true,
    sensitive: true,
    description: 'Authentication provider secret key',
  },

  // ── External Services ──────────────────────────────────────────
  REDIS_URL: {
    type: 'string',
    required: false,
    sensitive: true,
    description: 'Redis connection URL (optional, enables distributed caching)',
  },

  // ── Observability ──────────────────────────────────────────────
  LOG_LEVEL: {
    type: 'enum',
    values: ['debug', 'info', 'warn', 'error'],
    default: 'info',
    description: 'Minimum log level to output',
  },

  LOG_FORMAT: {
    type: 'enum',
    values: ['json', 'pretty'],
    default: 'json',
    description: 'Log output format (json for production, pretty for development)',
  },

  // ── Feature Flags ──────────────────────────────────────────────
  ENABLE_ANALYTICS: {
    type: 'boolean',
    default: false,
    description: 'Enable analytics event tracking',
  },

  MAINTENANCE_MODE: {
    type: 'boolean',
    default: false,
    description: 'Enable maintenance mode (returns 503 for all requests)',
  },
});
```

### 2. Type-Safe Configuration Parser

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/parser.{{EXT}}

/**
 * Parses and validates environment variables against the schema.
 * Returns a fully typed configuration object or throws with
 * a detailed error listing ALL validation failures.
 */

interface ParsedConfig {
  // Application
  env: 'development' | 'staging' | 'production' | 'test';
  appUrl: string;
  port: number;

  // Database
  database: {
    url: string;
    poolSize: number;
  };

  // Authentication
  auth: {
    publicKey: string;
    secretKey: string;
  };

  // External Services
  redis: {
    url: string | null;
  };

  // Observability
  logging: {
    level: 'debug' | 'info' | 'warn' | 'error';
    format: 'json' | 'pretty';
  };

  // Feature Flags
  features: {
    analyticsEnabled: boolean;
    maintenanceMode: boolean;
  };

  // Computed helpers
  isDevelopment: boolean;
  isProduction: boolean;
  isTest: boolean;
}

function parseConfig(envSource: Record<string, string | undefined>): ParsedConfig {
  // 1. Validate all variables against schema
  //    Replace this with your validation library's parse method:
  //    Zod:     configSchema.parse(envSource)
  //    Joi:     configSchema.validate(envSource, { abortEarly: false })
  //    Pydantic: Settings() (reads from environment automatically)
  const validated = validateAgainstSchema(configSchema, envSource);

  // 2. Construct typed configuration object
  return {
    env: validated.NODE_ENV,
    appUrl: validated.APP_URL.replace(/\/$/, ''), // Strip trailing slash
    port: validated.PORT,

    database: {
      url: validated.DATABASE_URL,
      poolSize: validated.DATABASE_POOL_SIZE,
    },

    auth: {
      publicKey: validated.AUTH_PUBLIC_KEY,
      secretKey: validated.AUTH_SECRET_KEY,
    },

    redis: {
      url: validated.REDIS_URL || null,
    },

    logging: {
      level: validated.LOG_LEVEL,
      format: validated.LOG_FORMAT,
    },

    features: {
      analyticsEnabled: validated.ENABLE_ANALYTICS,
      maintenanceMode: validated.MAINTENANCE_MODE,
    },

    isDevelopment: validated.NODE_ENV === 'development',
    isProduction: validated.NODE_ENV === 'production',
    isTest: validated.NODE_ENV === 'test',
  };
}
```

### 3. Singleton Configuration Export

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/index.{{EXT}}

/**
 * Application configuration singleton.
 *
 * Validated once at import time. Subsequent imports return the same object.
 * If validation fails, the application will not start.
 *
 * Usage:
 *   import { config } from '{{SOURCE_DIR}}/lib/config';
 *   console.log(config.port);           // number
 *   console.log(config.database.url);   // string
 *   console.log(config.isProduction);   // boolean
 */

let _config: ParsedConfig | null = null;

function getConfig(): ParsedConfig {
  if (!_config) {
    try {
      _config = parseConfig(process.env);
    } catch (error) {
      console.error('\n========================================');
      console.error(' CONFIGURATION ERROR - APPLICATION CANNOT START');
      console.error('========================================\n');
      console.error(error instanceof Error ? error.message : String(error));
      console.error('\nFix: Copy .env.template to .env.local and fill in required values.\n');
      process.exit(1);
    }
  }
  return _config;
}

// Export as a getter to enable lazy initialization
export const config: ParsedConfig = getConfig();
```

### 4. Environment-Specific Overrides

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/overrides.{{EXT}}

/**
 * Apply environment-specific configuration overrides.
 * Use sparingly - prefer configuring via environment variables.
 *
 * This is useful for defaults that differ between environments
 * but are not worth creating separate environment variables for.
 */

function applyOverrides(config: ParsedConfig): ParsedConfig {
  // Development overrides
  if (config.isDevelopment) {
    return {
      ...config,
      logging: {
        ...config.logging,
        format: 'pretty',  // Human-readable logs in development
      },
    };
  }

  // Production overrides
  if (config.isProduction) {
    return {
      ...config,
      logging: {
        ...config.logging,
        format: 'json',  // Machine-parseable logs in production
      },
    };
  }

  // Test overrides
  if (config.isTest) {
    return {
      ...config,
      logging: {
        ...config.logging,
        level: 'error',  // Only log errors during tests
      },
      features: {
        ...config.features,
        analyticsEnabled: false,  // Never track during tests
      },
    };
  }

  return config;
}
```

### 5. Configuration Diagnostics

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/config/diagnostics.{{EXT}}

/**
 * Logs a sanitized summary of the active configuration.
 * Call during application startup for operational visibility.
 *
 * NEVER logs sensitive values (database URLs, API keys, etc.).
 */

function logConfigSummary(config: ParsedConfig, logger: Logger): void {
  logger.info('Application configuration loaded', {
    env: config.env,
    appUrl: config.appUrl,
    port: config.port,
    database: {
      poolSize: config.database.poolSize,
      connected: '****', // Never log the URL
    },
    auth: {
      provider: config.auth.publicKey.substring(0, 8) + '...',
    },
    redis: {
      enabled: config.redis.url !== null,
    },
    logging: config.logging,
    features: config.features,
  });
}
```

## Customization Guide

1. **Replace template placeholders**:
   - `{{LANGUAGE}}` with your language (e.g., `typescript`, `python`, `go`)
   - `{{EXT}}` with your file extension (e.g., `ts`, `py`, `go`)
   - `{{SOURCE_DIR}}` with your source directory (e.g., `src`, `app`, `lib`)

2. **Swap in your validation library**:
   - **TypeScript/JavaScript**: Zod (`z.object({})`), Joi, Yup, io-ts, ArkType
   - **Python**: Pydantic (`BaseSettings`), python-decouple, environs
   - **Go**: Viper, envconfig, kelseyhightower/envconfig
   - **Rust**: config-rs, envy

3. **Add your project-specific variables** to the schema. Every variable the application uses should be declared in the schema with a type, description, and whether it is required.

4. **Update the `ParsedConfig` interface** to match your schema. Group related variables into nested objects for cleaner access patterns.

5. **Configure environment-specific overrides** for defaults that genuinely differ between environments. Prefer environment variables over code-based overrides.

6. **Wire the diagnostics** into your application startup sequence. Call `logConfigSummary` immediately after configuration loads.

## Security Checklist

- [ ] **Sensitive values marked** - all secrets, keys, and URLs flagged as `sensitive: true` in schema
- [ ] **Sensitive values never logged** - diagnostics function masks all sensitive configuration
- [ ] **`.env` files gitignored** - `.env`, `.env.local`, `.env.production` in `.gitignore`
- [ ] **`.env.template` committed** - serves as documentation, contains no real values
- [ ] **Fail-fast on invalid config** - application exits immediately with actionable error
- [ ] **All failures reported** - error message lists every missing/invalid variable, not just the first
- [ ] **Type coercion explicit** - string-to-number and string-to-boolean conversions are intentional
- [ ] **No fallback for secrets** - required secrets have no default values
- [ ] **Client-safe variables separated** - public variables explicitly prefixed (e.g., `NEXT_PUBLIC_`, `VITE_`)
- [ ] **Config object immutable** - exported configuration is read-only after initialization

## Validation Commands

```bash
# Verify configuration loads without errors
{{DEV_COMMAND}} & sleep 5 && kill $!

# Type-check configuration module
{{TYPE_CHECK_COMMAND}}

# Lint configuration files
{{LINT_COMMAND}}

# Verify .env.template is committed and .env is gitignored
git ls-files --error-unmatch .env.template && git check-ignore .env .env.local

# Run unit tests for configuration parsing
{{TEST_UNIT_COMMAND}} --grep "config"

# Full CI validation
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Secrets Management](../security/secrets-management.md) - Complementary pattern focused on secret lifecycle
- [Structured Logging](./structured-logging.md) - Uses configuration for log level and format
- [GitHub Actions Workflow](../ci/github-actions-workflow.md) - CI environment variable configuration
- [Deployment Pipeline](../ci/deployment-pipeline.md) - Environment-specific deployment configuration
- [Input Sanitization](../security/input-sanitization.md) - Validate config values like any external input

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
