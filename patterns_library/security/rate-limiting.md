# Rate Limiting Pattern

## What It Does

Implements API rate limiting using a sliding window algorithm to protect endpoints from abuse, brute-force attacks, and resource exhaustion. Supports per-user limits (for authenticated requests), IP-based fallback (for unauthenticated requests), and configurable time windows. Provides both an in-memory implementation for single-instance deployments and a Redis-backed implementation for distributed environments.

## When to Use

- Public-facing API endpoints (login, registration, password reset)
- Authenticated endpoints with expensive operations (reports, exports, AI calls)
- Webhook receivers that could be flooded by misconfigured external systems
- Any endpoint where abuse could degrade service for other users
- File upload endpoints to prevent storage exhaustion
- Search or autocomplete endpoints with database-intensive queries

## Code Pattern

### 1. Rate Limiter Interface and Types

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/rate-limit/types.{{EXT}}

interface RateLimitConfig {
  /** Maximum number of requests allowed within the window */
  maxRequests: number;
  /** Time window in seconds */
  windowSeconds: number;
  /** Prefix for storage keys (e.g., "api:login", "api:upload") */
  keyPrefix: string;
}

interface RateLimitResult {
  /** Whether the request is allowed */
  allowed: boolean;
  /** Number of remaining requests in the current window */
  remaining: number;
  /** Unix timestamp (seconds) when the window resets */
  resetAt: number;
  /** Total limit for this window */
  limit: number;
}

interface RateLimiter {
  /** Check and consume one request for the given identifier */
  consume(identifier: string): Promise<RateLimitResult>;
  /** Check remaining capacity without consuming */
  peek(identifier: string): Promise<RateLimitResult>;
  /** Reset the counter for a given identifier (e.g., after successful auth) */
  reset(identifier: string): Promise<void>;
}
```

### 2. In-Memory Sliding Window (Single Instance)

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/rate-limit/memory-limiter.{{EXT}}

/**
 * In-memory sliding window rate limiter.
 * Suitable for single-instance deployments or development.
 *
 * WARNING: State is lost on restart. Not shared across instances.
 * Use Redis-backed limiter for production multi-instance deployments.
 */

interface WindowEntry {
  timestamps: number[];
}

function createMemoryRateLimiter(config: RateLimitConfig): RateLimiter {
  const store = new Map<string, WindowEntry>();

  // Periodic cleanup to prevent memory leaks
  const CLEANUP_INTERVAL_MS = 60_000;
  const cleanupTimer = setInterval(() => {
    const cutoff = Date.now() - config.windowSeconds * 1000;
    for (const [key, entry] of store.entries()) {
      entry.timestamps = entry.timestamps.filter((t) => t > cutoff);
      if (entry.timestamps.length === 0) {
        store.delete(key);
      }
    }
  }, CLEANUP_INTERVAL_MS);

  // Allow garbage collection if the limiter is discarded
  if (typeof cleanupTimer === 'object' && 'unref' in cleanupTimer) {
    cleanupTimer.unref();
  }

  function getKey(identifier: string): string {
    return `${config.keyPrefix}:${identifier}`;
  }

  function getWindowedTimestamps(key: string): number[] {
    const now = Date.now();
    const cutoff = now - config.windowSeconds * 1000;
    const entry = store.get(key);

    if (!entry) return [];

    // Slide the window: keep only timestamps within the window
    entry.timestamps = entry.timestamps.filter((t) => t > cutoff);
    return entry.timestamps;
  }

  return {
    async consume(identifier: string): Promise<RateLimitResult> {
      const key = getKey(identifier);
      const now = Date.now();
      const timestamps = getWindowedTimestamps(key);

      const resetAt = Math.ceil((now + config.windowSeconds * 1000) / 1000);

      if (timestamps.length >= config.maxRequests) {
        return {
          allowed: false,
          remaining: 0,
          resetAt,
          limit: config.maxRequests,
        };
      }

      // Record this request
      if (!store.has(key)) {
        store.set(key, { timestamps: [] });
      }
      store.get(key)!.timestamps.push(now);

      return {
        allowed: true,
        remaining: config.maxRequests - timestamps.length - 1,
        resetAt,
        limit: config.maxRequests,
      };
    },

    async peek(identifier: string): Promise<RateLimitResult> {
      const key = getKey(identifier);
      const now = Date.now();
      const timestamps = getWindowedTimestamps(key);
      const resetAt = Math.ceil((now + config.windowSeconds * 1000) / 1000);

      return {
        allowed: timestamps.length < config.maxRequests,
        remaining: Math.max(0, config.maxRequests - timestamps.length),
        resetAt,
        limit: config.maxRequests,
      };
    },

    async reset(identifier: string): Promise<void> {
      store.delete(getKey(identifier));
    },
  };
}
```

### 3. Redis-Backed Sliding Window (Distributed)

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/rate-limit/redis-limiter.{{EXT}}

/**
 * Redis-backed sliding window rate limiter using sorted sets.
 * Suitable for multi-instance production deployments.
 *
 * Requires a Redis client compatible with your runtime.
 * Replace {{REDIS_CLIENT}} with your Redis library (e.g., ioredis, redis, upstash).
 */

function createRedisRateLimiter(
  config: RateLimitConfig,
  redisClient: {{REDIS_CLIENT_TYPE}}
): RateLimiter {

  function getKey(identifier: string): string {
    return `ratelimit:${config.keyPrefix}:${identifier}`;
  }

  return {
    async consume(identifier: string): Promise<RateLimitResult> {
      const key = getKey(identifier);
      const now = Date.now();
      const windowStart = now - config.windowSeconds * 1000;
      const resetAt = Math.ceil((now + config.windowSeconds * 1000) / 1000);

      // Atomic pipeline: remove expired entries, count, and add new entry
      const pipeline = redisClient.pipeline();
      pipeline.zremrangebyscore(key, 0, windowStart);  // Remove expired
      pipeline.zcard(key);                               // Count current
      pipeline.zadd(key, now, `${now}:${Math.random()}`); // Add this request
      pipeline.expire(key, config.windowSeconds);        // Set TTL for cleanup

      const results = await pipeline.exec();
      const currentCount = results[1][1] as number;

      if (currentCount >= config.maxRequests) {
        // Over limit: remove the entry we just added
        await redisClient.zpopmax(key);
        return {
          allowed: false,
          remaining: 0,
          resetAt,
          limit: config.maxRequests,
        };
      }

      return {
        allowed: true,
        remaining: config.maxRequests - currentCount - 1,
        resetAt,
        limit: config.maxRequests,
      };
    },

    async peek(identifier: string): Promise<RateLimitResult> {
      const key = getKey(identifier);
      const now = Date.now();
      const windowStart = now - config.windowSeconds * 1000;
      const resetAt = Math.ceil((now + config.windowSeconds * 1000) / 1000);

      await redisClient.zremrangebyscore(key, 0, windowStart);
      const currentCount = await redisClient.zcard(key);

      return {
        allowed: currentCount < config.maxRequests,
        remaining: Math.max(0, config.maxRequests - currentCount),
        resetAt,
        limit: config.maxRequests,
      };
    },

    async reset(identifier: string): Promise<void> {
      await redisClient.del(getKey(identifier));
    },
  };
}
```

### 4. Rate Limit Middleware / Route Helper

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/rate-limit/middleware.{{EXT}}

/**
 * Extracts the rate limit identifier from a request.
 * Uses authenticated user ID when available, falls back to IP address.
 */
function getRateLimitIdentifier(request: {{REQUEST_TYPE}}): string {
  // 1. Try authenticated user ID (preferred - cannot be spoofed)
  const userId = getCurrentUserId(request); // Replace with your auth helper
  if (userId) {
    return `user:${userId}`;
  }

  // 2. Fall back to IP address
  const forwarded = request.headers.get('x-forwarded-for');
  const ip = forwarded?.split(',')[0]?.trim() || 'unknown';
  return `ip:${ip}`;
}

/**
 * Sets standard rate limit response headers.
 */
function setRateLimitHeaders(
  response: {{RESPONSE_TYPE}},
  result: RateLimitResult
): void {
  response.headers.set('X-RateLimit-Limit', String(result.limit));
  response.headers.set('X-RateLimit-Remaining', String(result.remaining));
  response.headers.set('X-RateLimit-Reset', String(result.resetAt));
}

/**
 * Example: Apply rate limiting in an API route handler.
 *
 * const loginLimiter = createMemoryRateLimiter({
 *   maxRequests: 5,
 *   windowSeconds: 900,  // 5 attempts per 15 minutes
 *   keyPrefix: 'auth:login',
 * });
 *
 * async function handleLogin(request) {
 *   const identifier = getRateLimitIdentifier(request);
 *   const result = await loginLimiter.consume(identifier);
 *
 *   if (!result.allowed) {
 *     const response = createErrorResponse(429, 'Too many requests. Try again later.');
 *     setRateLimitHeaders(response, result);
 *     response.headers.set('Retry-After', String(result.resetAt - Math.floor(Date.now() / 1000)));
 *     return response;
 *   }
 *
 *   // ... proceed with login logic
 *   const response = createSuccessResponse(loginResult);
 *   setRateLimitHeaders(response, result);
 *   return response;
 * }
 */
```

### 5. Recommended Limit Configurations

```{{LANGUAGE}}
// {{SOURCE_DIR}}/lib/rate-limit/presets.{{EXT}}

/**
 * Standard rate limit presets. Adjust these values based on your
 * application's load profile and security requirements.
 */
const RATE_LIMIT_PRESETS = {
  /** Authentication: strict limits to prevent brute force */
  auth: {
    login:         { maxRequests: 5,   windowSeconds: 900,  keyPrefix: 'auth:login' },
    register:      { maxRequests: 3,   windowSeconds: 3600, keyPrefix: 'auth:register' },
    passwordReset: { maxRequests: 3,   windowSeconds: 3600, keyPrefix: 'auth:reset' },
  },

  /** Standard API: moderate limits for normal usage */
  api: {
    read:          { maxRequests: 100, windowSeconds: 60,   keyPrefix: 'api:read' },
    write:         { maxRequests: 30,  windowSeconds: 60,   keyPrefix: 'api:write' },
    search:        { maxRequests: 20,  windowSeconds: 60,   keyPrefix: 'api:search' },
  },

  /** Expensive operations: tight limits to protect resources */
  expensive: {
    export:        { maxRequests: 5,   windowSeconds: 3600, keyPrefix: 'exp:export' },
    upload:        { maxRequests: 10,  windowSeconds: 3600, keyPrefix: 'exp:upload' },
    aiGenerate:    { maxRequests: 10,  windowSeconds: 60,   keyPrefix: 'exp:ai' },
  },
} as const;
```

## Customization Guide

1. **Replace template placeholders**:
   - `{{LANGUAGE}}` with your language (e.g., `typescript`, `python`, `go`)
   - `{{EXT}}` with your file extension (e.g., `ts`, `py`, `go`)
   - `{{SOURCE_DIR}}` with your source directory (e.g., `src`, `app`, `lib`)
   - `{{REDIS_CLIENT_TYPE}}` with your Redis client type (e.g., `Redis` from ioredis, `RedisClient`)
   - `{{REQUEST_TYPE}}` with your request type (e.g., `NextRequest`, `Request`, `FastifyRequest`)
   - `{{RESPONSE_TYPE}}` with your response type (e.g., `NextResponse`, `Response`, `FastifyReply`)

2. **Choose your storage backend**: Use the in-memory limiter for development and single-instance deployments. Switch to the Redis-backed limiter for production multi-instance environments. Both implement the same `RateLimiter` interface so the calling code does not change.

3. **Tune the preset limits** based on your application's usage patterns. Monitor 429 responses in production and adjust if legitimate users are being throttled.

4. **Add endpoint-specific limiters** for routes with unique requirements. Each route can use a different `RateLimitConfig` with its own key prefix.

5. **Implement graduated responses** if needed: warn at 80% capacity (via response headers), block at 100%, and temporarily ban at repeated 100% violations.

6. **Wire into your authentication flow**: Call `limiter.reset(identifier)` after a successful login to clear the counter, preventing lockout after earlier failed attempts.

## Security Checklist

- [ ] **Authenticated identifier preferred** - user ID used over IP when available
- [ ] **IP extraction safe** - `X-Forwarded-For` parsing handles multiple proxies correctly
- [ ] **Response headers set** - `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` included
- [ ] **Retry-After header** - included in 429 responses to guide clients
- [ ] **Auth endpoints strictly limited** - login, register, password reset have tight limits
- [ ] **Redis TTL set** - keys expire automatically to prevent storage leak
- [ ] **Memory cleanup active** - in-memory limiter has periodic cleanup timer
- [ ] **No sensitive data in keys** - rate limit keys use IDs/IPs, not tokens or passwords
- [ ] **Distributed deployment tested** - Redis limiter verified across multiple instances
- [ ] **Monitoring configured** - 429 responses tracked in application metrics

## Validation Commands

```bash
# Run unit tests for rate limiter logic
{{TEST_UNIT_COMMAND}} --grep "rate.limit"

# Run linting
{{LINT_COMMAND}}

# Type-check all rate limit modules
{{TYPE_CHECK_COMMAND}}

# Integration test with Redis (if applicable)
{{TEST_INTEGRATION_COMMAND}} --grep "rate.limit"

# Full CI validation
{{CI_VALIDATE_COMMAND}}
```

## Related Patterns

- [Input Sanitization](./input-sanitization.md) - Sanitize input before processing
- [Secrets Management](./secrets-management.md) - Securely configure Redis credentials
- [User Context API](../api/user-context-api.md) - Authenticated API where rate limiting applies
- [Webhook Handler](../api/webhook-handler.md) - Rate limit incoming webhook floods
- [Structured Logging](../config/structured-logging.md) - Log rate limit events for monitoring
- [Environment Config](../config/environment-config.md) - Configure rate limit thresholds per environment

---

**Pattern Source**: Template baseline | **Last Updated**: 2026-03 | **Validated By**: System Architect
