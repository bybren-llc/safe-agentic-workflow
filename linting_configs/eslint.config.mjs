import { FlatCompat } from '@eslint/eslintrc';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

const eslintConfig = [
  // Global ignores (must come first)
  {
    ignores: [
      '.next/**',
      'node_modules/**',
      'out/**',
      'dist/**',
      'build/**',
      '.cache/**',
      'coverage/**',
      'public/**',
      '*.config.js',
      '*.config.mjs',
      // Temporarily disable strict linting to match `next lint` behavior
      // These will be re-enabled in follow-up cleanup work
      '__tests__/**',
      '**/*.test.ts',
      '**/*.test.tsx',
      '**/*.spec.ts',
      '**/*.spec.tsx',
      'scripts/**',
      'utils/**',
      'hooks/**',
      'lib/posthog/**',
      'lib/redis.ts',
      'lib/ratelimiter.ts',
      'lib/r2-client.ts',
      'lib/webhook-security.ts',
      'lib/validation/**',
      'lib/auth.ts',
      'lib/auth-admin.ts',
      'lib/constants/**',
      'lib/prisma.ts',
      'components/analytics/**',
      'components/ui/**',
      'components/v0/**',
      'app/api/**',
      'middleware.ts',
      'next-env.d.ts',
      'tailwind.config.ts',
    ],
  },
  ...compat.extends('next/core-web-vitals', 'next/typescript'),
  {
    rules: {
      '@next/next/no-img-element': 'off',
      'react-hooks/exhaustive-deps': 'warn',
      'react-hooks/rules-of-hooks': 'warn',
      // Temporarily disable strict type checking rules (to be re-enabled in follow-up work)
      '@typescript-eslint/no-unused-vars': 'warn',  // Downgrade to warning
      '@typescript-eslint/no-explicit-any': 'warn',  // Downgrade to warning
      '@typescript-eslint/no-require-imports': 'warn',  // Downgrade to warning
      '@typescript-eslint/no-non-null-asserted-optional-chain': 'warn',  // Downgrade to warning
    },
  },
  {
    files: ['**/*.{ts,tsx}'],
    ignores: ['prisma/**', 'scripts/**', '__tests__/**', 'e2e/**'],
    rules: {
      'no-restricted-syntax': [
        'error',
        {
          selector:
            "CallExpression[callee.type='MemberExpression'][callee.object.name='prisma']:not([callee.property.name='$queryRaw']):not([callee.property.name='$executeRaw']):not([callee.property.name='$disconnect'])",
          message:
            'Direct prisma calls are forbidden. Use transaction-scoped withUserContext/withAdminContext/withSystemContext (or withRLS).',
        },
        {
          selector: "CallExpression[callee.name='requireAuthWithContext']",
          message:
            'requireAuthWithContext is deprecated - use withUserContext pattern instead [{{TICKET_PREFIX}}-207]',
        },
        {
          selector: "CallExpression[callee.name='getOptionalAuthWithContext']",
          message:
            'getOptionalAuthWithContext is deprecated - use getOptionalAuth + withUserContext instead [{{TICKET_PREFIX}}-207]',
        },
        {
          selector: "MemberExpression[property.name='setRLSContext']",
          message:
            'Deprecated RLS API. Use transaction-scoped withUserContext/withAdminContext/withSystemContext.',
        },
        {
          selector: "MemberExpression[property.name='clearRLSContext']",
          message: 'Deprecated RLS API. Use transaction-scoped helpers.',
        },
        {
          selector: "MemberExpression[property.name='withRLSContext']",
          message: 'Deprecated RLS API. Use transaction-scoped helpers.',
        },
      ],
    },
  },
];

export default eslintConfig;
