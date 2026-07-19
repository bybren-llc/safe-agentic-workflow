---
type: guide
title: "Linting Configs"
description: "Shipped ESLint and Prettier configs whose no-restricted-syntax rules machine-enforce the RLS discipline."
tags: [subsystems, security, ci, patterns]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "linting_configs/eslint.config.mjs"
  - "linting_configs/.prettierrc"
  - "scripts/apply-workflow.sh"
  - "docs/guides/OPTIONAL-FEATURES.md"
verified_against: "fd0fc6a"
---

# Linting Configs

Exactly two files — `eslint.config.mjs` and `.prettierrc` — copied into adopter repos by
`scripts/apply-workflow.sh`. Read this before assuming the RLS rule is only prose: one block turns
it into a build failure. Read it also before assuming that block is running.

## Shipped, Not Executed Here

The ESLint file is a flat config importing `FlatCompat` from `@eslint/eslintrc` and calling
`compat.extends('next/core-web-vitals', 'next/typescript')`. None of those packages is installed
here, so nothing lints with it in this repo. It is a distributable artifact — the exemplar *is* the
product, as with the [Pattern Library](pattern-library.md).

## The Load-Bearing Block

`no-restricted-syntax` sits at `error` severity, scoped to `**/*.{ts,tsx}` with `ignores` for
`prisma/**`, `scripts/**`, `__tests__/**` and `e2e/**`. Its six selectors ban any `prisma.<method>`
member call other than `$queryRaw`, `$executeRaw` and `$disconnect`; calls to
`requireAuthWithContext` or `getOptionalAuthWithContext`; and member access of `setRLSContext`,
`clearRLSContext` or `withRLSContext`. Those errors machine-enforce the `withUserContext` /
`withAdminContext` / `withSystemContext` rule that `CLAUDE.md` and the
[RLS Patterns](../skills/rls-patterns.md) skill otherwise state only as prose.

## Where The Enforcement Leaks

The global `ignores` array is broad — build output, `public`, every `*.config.js|mjs`, tests, specs,
`scripts`, `utils`, `hooks`, several `lib/*` modules including `lib/prisma.ts` and `lib/auth.ts`,
the `components/analytics|ui|v0` trees, `middleware.ts`, and `app/api`. That last entry matters
most: with `app/api/**` ignored, the Prisma restriction never reaches API route files — precisely
where the RLS helpers matter most. The rule guards everywhere except its intended target.

Four TypeScript rules are deliberately downgraded to `warn` with "temporarily disable" comments —
`no-unused-vars`, `no-explicit-any`, `no-require-imports`, `no-non-null-asserted-optional-chain`.
Both `react-hooks` rules are warnings too and `@next/next/no-img-element` is off; deprecation
messages embed the `{{TICKET_PREFIX}}-207` token. `.prettierrc` sets `semi`, `trailingComma`,
`singleQuote`, `printWidth`, `tabWidth`, `useTabs`, `bracketSpacing`, `arrowParens` and `endOfLine`,
plus a `plugins` array containing `prettier-plugin-tailwindcss` — also not installed.

## Next Steps

- [OPTIONAL-FEATURES.md](../../guides/OPTIONAL-FEATURES.md) line 329 documents the RLS-block
  opt-out; [apply-workflow](../operations/scripts/apply-workflow.md) shows how these files ship.
