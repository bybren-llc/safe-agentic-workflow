# Structured Logging Pattern

## What It Does

Implements a structured logging system that outputs machine-parseable JSON logs with consistent fields, correlation IDs for request tracing, log level filtering, and request context propagation. Enables effective log aggregation, searching, and alerting in production monitoring systems while remaining human-readable during development.

## When to Use

- Any application that runs in production and needs operational visibility
- APIs and services that handle concurrent requests requiring trace correlation
- Microservices architectures where requests span multiple services
- Applications using log aggregation systems (Datadog, ELK, CloudWatch, Loki)
- Debugging production issues where structured fields enable precise filtering
- Projects transitioning from `console.log` to production-grade logging

## Code Pattern

### 1. Logger Interface and Types

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/logger/types.{{EXT}}

/**
 * Log levels ordered by severity.
 * Each level includes all levels above it (e.g., 'warn' includes 'warn' and 'error').
 */
type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LOG_LEVEL_PRIORITY: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

/**
 * Structured log entry. Every log line includes these base fields.
 */
interface LogEntry {
  /** ISO 8601 timestamp */
  timestamp: string;
  /** Log severity level */
  level: LogLevel;
  /** Human-readable log message */
  message: string;
  /** Unique request/correlation identifier for tracing */
  correlationId?: string;
  /** Service or module that produced the log */
  service?: string;
  /** Additional structured context (key-value pairs) */
  context?: Record<string, unknown>;
  /** Error details (if applicable) */
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
}

/**
 * Logger interface. All application code uses this interface,
 * never calls console.log/warn/error directly.
 */
interface Logger {
  debug(message: string, context?: Record<string, unknown>): void;
  info(message: string, context?: Record<string, unknown>): void;
  warn(message: string, context?: Record<string, unknown>): void;
  error(message: string, error?: Error, context?: Record<string, unknown>): void;

  /** Create a child logger with additional default context */
  child(defaultContext: Record<string, unknown>): Logger;

  /** Create a child logger bound to a specific correlation ID */
  withCorrelationId(correlationId: string): Logger;
}
```

### 2. Logger Implementation

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/logger/logger.{{EXT}}

/**
 * Structured logger implementation.
 *
 * Outputs JSON in production for machine parsing.
 * Outputs formatted text in development for human readability.
 */

interface LoggerOptions {
  /** Minimum log level to output */
  level: LogLevel;
  /** Output format: 'json' for production, 'pretty' for development */
  format: 'json' | 'pretty';
  /** Service name included in every log entry */
  service: string;
  /** Default context included in every log entry */
  defaultContext?: Record<string, unknown>;
  /** Default correlation ID */
  correlationId?: string;
}

function createLogger(options: LoggerOptions): Logger {
  const minPriority = LOG_LEVEL_PRIORITY[options.level];

  function shouldLog(level: LogLevel): boolean {
    return LOG_LEVEL_PRIORITY[level] >= minPriority;
  }

  function formatEntry(entry: LogEntry): string {
    if (options.format === 'json') {
      return JSON.stringify(entry);
    }

    // Pretty format for development
    const time = entry.timestamp.split('T')[1]?.replace('Z', '') || entry.timestamp;
    const levelPad = entry.level.toUpperCase().padEnd(5);
    const correlation = entry.correlationId ? ` [${entry.correlationId.substring(0, 8)}]` : '';
    const ctx = entry.context ? ` ${JSON.stringify(entry.context)}` : '';
    const err = entry.error ? `\n  Error: ${entry.error.message}\n  ${entry.error.stack || ''}` : '';

    return `${time} ${levelPad}${correlation} ${entry.message}${ctx}${err}`;
  }

  function writeLog(level: LogLevel, message: string, context?: Record<string, unknown>, error?: Error): void {
    if (!shouldLog(level)) return;

    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: options.service,
      correlationId: options.correlationId,
      context: {
        ...options.defaultContext,
        ...context,
      },
    };

    // Remove empty context
    if (entry.context && Object.keys(entry.context).length === 0) {
      delete entry.context;
    }

    // Serialize error if present
    if (error) {
      entry.error = {
        name: error.name,
        message: error.message,
        stack: options.format === 'json' ? error.stack : error.stack?.split('\n').slice(0, 5).join('\n'),
      };
    }

    const output = formatEntry(entry);

    // Route to appropriate console method
    switch (level) {
      case 'error':
        console.error(output);
        break;
      case 'warn':
        console.warn(output);
        break;
      default:
        console.log(output);
        break;
    }
  }

  const logger: Logger = {
    debug(message, context) {
      writeLog('debug', message, context);
    },
    info(message, context) {
      writeLog('info', message, context);
    },
    warn(message, context) {
      writeLog('warn', message, context);
    },
    error(message, error, context) {
      writeLog('error', message, context, error);
    },
    child(defaultContext) {
      return createLogger({
        ...options,
        defaultContext: {
          ...options.defaultContext,
          ...defaultContext,
        },
      });
    },
    withCorrelationId(correlationId) {
      return createLogger({
        ...options,
        correlationId,
      });
    },
  };

  return logger;
}
```

### 3. Application Logger Singleton

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/logger/index.{{EXT}}

/**
 * Application logger singleton.
 *
 * Usage:
 *   import { logger } from '{{SOURCE_DIR}}/lib/logger';
 *
 *   logger.info('User logged in', { userId: 'abc123' });
 *   logger.error('Payment failed', error, { orderId: 'ord_456' });
 *
 *   // Create a scoped logger for a module
 *   const dbLogger = logger.child({ module: 'database' });
 *   dbLogger.info('Query executed', { table: 'users', durationMs: 45 });
 */

// Import config for log level and format (see Environment Config pattern)
// import { config } from '{{SOURCE_DIR}}/lib/config';

const logger = createLogger({
  level: (process.env.LOG_LEVEL as LogLevel) || 'info',
  format: process.env.NODE_ENV === 'production' ? 'json' : 'pretty',
  service: '{{PROJECT_NAME}}',
});

export { logger };
```

### 4. Correlation ID Middleware

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/logger/correlation.{{EXT}}

/**
 * Generates or extracts a correlation ID for request tracing.
 *
 * The correlation ID follows a request through the entire processing pipeline,
 * making it possible to filter logs for a single request across all services.
 *
 * Reads from incoming headers (for cross-service tracing) or generates a new one.
 */

// Standard header names for correlation IDs
const CORRELATION_HEADERS = [
  'x-correlation-id',
  'x-request-id',
  'traceparent',  // W3C Trace Context
] as const;

/**
 * Generates a unique correlation ID.
 * Format: timestamp prefix + random suffix for chronological sorting.
 */
function generateCorrelationId(): string {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substring(2, 10);
  return `${timestamp}-${random}`;
}

/**
 * Extracts correlation ID from request headers or generates a new one.
 */
function getCorrelationId(headers: Headers | Record<string, string | string[] | undefined>): string {
  for (const headerName of CORRELATION_HEADERS) {
    const value = typeof headers.get === 'function'
      ? headers.get(headerName)
      : (headers as Record<string, string | string[] | undefined>)[headerName];

    if (value && typeof value === 'string') {
      return value;
    }
  }

  return generateCorrelationId();
}

/**
 * Example: Request logging middleware (framework-agnostic pseudocode).
 *
 * function requestLoggingMiddleware(request, next) {
 *   const correlationId = getCorrelationId(request.headers);
 *   const requestLogger = logger.withCorrelationId(correlationId);
 *   const start = Date.now();
 *
 *   requestLogger.info('Request started', {
 *     method: request.method,
 *     path: request.url,
 *     userAgent: request.headers.get('user-agent'),
 *   });
 *
 *   // Attach logger to request context for downstream use
 *   request.logger = requestLogger;
 *
 *   const response = await next(request);
 *
 *   requestLogger.info('Request completed', {
 *     method: request.method,
 *     path: request.url,
 *     status: response.status,
 *     durationMs: Date.now() - start,
 *   });
 *
 *   // Propagate correlation ID in response headers
 *   response.headers.set('x-correlation-id', correlationId);
 *
 *   return response;
 * }
 */
```

### 5. Common Logging Patterns

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/logger/patterns.{{EXT}}

/**
 * Standardized logging patterns for common operations.
 * Use these to maintain consistent log structure across the application.
 */

// ── Database Operations ──────────────────────────────────────────
function logDatabaseQuery(logger: Logger, operation: string, table: string, durationMs: number): void {
  logger.debug('Database query executed', {
    operation,  // 'SELECT', 'INSERT', 'UPDATE', 'DELETE'
    table,
    durationMs,
  });

  // Warn on slow queries
  if (durationMs > 1000) {
    logger.warn('Slow database query detected', {
      operation,
      table,
      durationMs,
      threshold: 1000,
    });
  }
}

// ── Authentication Events ────────────────────────────────────────
function logAuthEvent(logger: Logger, event: string, userId: string, metadata?: Record<string, unknown>): void {
  logger.info(`Auth: ${event}`, {
    event,        // 'login', 'logout', 'token_refresh', 'login_failed'
    userId,
    ...metadata,
  });
}

// ── External API Calls ───────────────────────────────────────────
function logExternalApiCall(
  logger: Logger,
  service: string,
  method: string,
  url: string,
  status: number,
  durationMs: number,
): void {
  const level = status >= 500 ? 'error' : status >= 400 ? 'warn' : 'info';
  logger[level](`External API: ${service}`, {
    service,
    method,
    url,
    status,
    durationMs,
  });
}

// ── Business Events ──────────────────────────────────────────────
function logBusinessEvent(logger: Logger, event: string, data: Record<string, unknown>): void {
  logger.info(`Event: ${event}`, {
    eventType: event,
    ...data,
  });
}

// Example usage:
// logBusinessEvent(logger, 'subscription_created', { planId: 'pro', userId: 'abc' });
// logBusinessEvent(logger, 'payment_processed', { amount: 4999, currency: 'usd' });
```

## Customization Guide

1. **Replace template placeholders**:
   - `{{LANGUAGE}}` with your language (e.g., `typescript`, `python`, `go`)
   - `{{EXT}}` with your file extension (e.g., `ts`, `py`, `go`)
   - `{{SOURCE_DIR}}` with your source directory (e.g., `src`, `app`, `lib`)
   - `{{PROJECT_NAME}}` with your project/service name

2. **Choose your logging library** (or use the built-in implementation above):
   - **Node.js**: pino, winston, bunyan (all support structured JSON output)
   - **Python**: structlog, python-json-logger, loguru
   - **Go**: zerolog, zap, logrus
   - **Rust**: tracing, slog
   - The implementation above is framework-agnostic; swap it for a library if you prefer.

3. **Integrate correlation ID middleware** with your HTTP framework:
   - **Express**: app.use(correlationMiddleware)
   - **Next.js**: middleware.ts or API route wrapper
   - **FastAPI**: @app.middleware("http")
   - **Go net/http**: http.Handler wrapper

4. **Configure log aggregation** for your production environment:
   - JSON output (the default for production) is compatible with all major log aggregators
   - Set up log parsing rules to index `correlationId`, `level`, `service`, and `context` fields
   - Create alerts on `error` level logs and slow query warnings

5. **Add domain-specific logging patterns** following the examples in Section 5. Standardize field names across the team to enable consistent log queries.

6. **Wire the logger into your configuration system** by importing the log level and format from the Environment Config pattern instead of reading `process.env` directly.

## Security Checklist

- [ ] **No secrets in logs** - passwords, API keys, tokens, and connection strings are never logged
- [ ] **PII minimized** - personally identifiable information logged only when necessary, with justification
- [ ] **User IDs over emails** - use opaque identifiers rather than email addresses or names
- [ ] **Error stacks truncated** - stack traces limited to avoid leaking internal paths in production
- [ ] **Log level configurable** - debug logs can be disabled in production without code changes
- [ ] **Correlation IDs propagated** - headers forwarded to downstream services for distributed tracing
- [ ] **Request bodies not logged** - form data, file uploads, and request payloads excluded by default
- [ ] **Response bodies not logged** - API response data excluded to prevent data leakage
- [ ] **Log rotation configured** - production logs rotated and retained per data retention policy
- [ ] **Access to production logs restricted** - only authorized personnel can access log aggregation systems

## Validation Commands

```bash
# Verify logger module compiles
{{TYPE_CHECK_COMMAND}}

# Run linting (will catch direct console.log usage if configured)
{{LINT_COMMAND}}

# Run unit tests for logging utilities
{{TEST_UNIT_COMMAND}} --grep "log"

# Verify JSON output format
{{DEV_COMMAND}} & sleep 3 && curl -s http://localhost:{{PORT}}/api/health | head -1 && kill $!

# Full CI validation
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Environment Config](./environment-config.md) - Configure log level and format per environment
- [Secrets Management](../security/secrets-management.md) - Ensure secrets are never logged
- [Rate Limiting](../security/rate-limiting.md) - Log rate limit events for monitoring
- [User Context API](../api/user-context-api.md) - Attach correlation ID to API request context
- [Deployment Pipeline](../ci/deployment-pipeline.md) - Log deployment events for operational visibility

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
