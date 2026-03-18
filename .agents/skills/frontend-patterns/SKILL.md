---
name: frontend-patterns
description: >
  Frontend patterns for modern web frameworks, component libraries, auth flows,
  and analytics. Use when building UI components, creating pages, implementing
  auth flows, adding analytics events, or working with component libraries.
  Do NOT use for API-only or backend-only changes.
---

# Frontend Patterns Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Ensure consistent frontend development using established patterns for your framework (Next.js App Router, React, etc.), authentication provider, UI component library, and analytics platform.

## When This Skill Applies

- Building new UI components or pages
- Implementing authentication flows
- Adding forms with validation
- Integrating analytics events
- Creating protected/authenticated routes
- Working with component libraries (shadcn/ui, Radix, etc.)

## Server vs Client Components

```typescript
// SERVER COMPONENT (default) - Use for:
// - Data fetching
// - Auth checks
// - SEO-critical content
import { auth } from "{{AUTH_SERVER_IMPORT}}";

export default async function DashboardPage() {
  const { userId } = await auth();
  // Fetch data server-side...
}

// CLIENT COMPONENT - Use for:
// - Interactivity (onClick, onChange)
// - Browser APIs (localStorage, window)
// - Hooks (useState, useEffect)
"use client";

import { useState } from "react";

export function InteractiveWidget() {
  const [count, setCount] = useState(0);
  // Interactive logic...
}
```

## Protected Pages

**CRITICAL**: Always use forced dynamic rendering for authenticated pages:

```typescript
import { auth } from "{{AUTH_SERVER_IMPORT}}";
import { redirect } from "next/navigation";

// REQUIRED - Auth context unavailable at build time
export const dynamic = "force-dynamic";

export default async function ProtectedPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect("/sign-in");
  }

  // Render protected content...
}
```

## Route Organization

```text
app/
+-- (auth)/                    # Auth routes (sign-in, sign-up)
+-- (marketing)/               # Public marketing pages
|   +-- page.tsx               # Homepage
|   +-- pricing/page.tsx
+-- dashboard/                 # Protected user area
|   +-- page.tsx
|   +-- _components/           # Page-specific components
+-- admin/                     # Admin-only area
    +-- page.tsx
```

## Authentication Patterns

### Server Component Auth

```typescript
import { auth } from "{{AUTH_SERVER_IMPORT}}";

export default async function Page() {
  const { userId } = await auth();
  // userId is string | null
}
```

### Client Component Auth

```typescript
"use client";
import { useUser, useAuth } from "{{AUTH_CLIENT_IMPORT}}";

export function UserProfile() {
  const { user, isLoaded, isSignedIn } = useUser();
  const { signOut } = useAuth();

  if (!isLoaded) return <Skeleton />;
  if (!isSignedIn) return <SignInPrompt />;

  return <div>Welcome, {user.firstName}!</div>;
}
```

### Admin Verification

```typescript
import { auth } from "{{AUTH_SERVER_IMPORT}}";
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function AdminPage() {
  const { userId, orgId, orgRole } = await auth();

  if (!userId) {
    redirect("/sign-in");
  }

  // Verify admin role
  const ADMIN_ORG_ID = process.env.{{ADMIN_ORG_ENV_VAR}};
  const ADMIN_ROLE = "org:admin";

  if (orgId !== ADMIN_ORG_ID || orgRole !== ADMIN_ROLE) {
    redirect("/admin-denied");
  }

  // Render admin content...
}
```

## Component Library Patterns

### Import Convention

```typescript
// Always use path alias for components
import { Button } from "{{UI_COMPONENTS_PATH}}/button";
import { Card, CardHeader, CardTitle, CardContent } from "{{UI_COMPONENTS_PATH}}/card";
import { Input } from "{{UI_COMPONENTS_PATH}}/input";
```

### Form Pattern (React Hook Form + Zod)

```typescript
"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "{{UI_COMPONENTS_PATH}}/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "{{UI_COMPONENTS_PATH}}/form";
import { Input } from "{{UI_COMPONENTS_PATH}}/input";

const FormSchema = z.object({
  email: z.string().email("Invalid email"),
  name: z.string().min(1, "Name is required"),
});

type FormData = z.infer<typeof FormSchema>;

export function MyForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(FormSchema),
    defaultValues: { email: "", name: "" },
  });

  async function onSubmit(data: FormData) {
    // Handle submission...
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  );
}
```

## Analytics Patterns

### Event Naming Convention

Use snake_case with category prefix:

```text
user_signed_up, user_signed_in, user_profile_updated
feature_dark_mode_toggled, feature_export_clicked
payment_checkout_started, payment_completed, subscription_upgraded
page_viewed, cta_clicked
```

### Event Tracking

```typescript
"use client";

import { usePostHog } from "{{ANALYTICS_IMPORT}}";

export function TrackableButton() {
  const posthog = usePostHog();

  function handleClick() {
    posthog?.capture("cta_clicked", {
      button_text: "Get Started",
      page: "/pricing",
      variant: "primary",
    });
  }

  return <Button onClick={handleClick}>Get Started</Button>;
}
```

### Feature Flags

```typescript
"use client";

import { useFeatureFlagEnabled } from "{{ANALYTICS_IMPORT}}";

export function FeatureFlaggedComponent() {
  const showNewFeature = useFeatureFlagEnabled("new-checkout-flow");

  if (showNewFeature) {
    return <NewCheckoutFlow />;
  }

  return <LegacyCheckoutFlow />;
}
```

## Accessibility Checklist

Required for all components:

- [ ] **Keyboard Navigation**: All interactive elements focusable via Tab
- [ ] **Focus Indicators**: Visible focus ring
- [ ] **Color Contrast**: 4.5:1 minimum for text
- [ ] **Alt Text**: All images have descriptive alt text
- [ ] **ARIA Labels**: Form inputs have labels or aria-label
- [ ] **Error States**: Form errors announced to screen readers

## Responsive Design Patterns

```typescript
// Mobile-first approach (Tailwind)
<div className="px-4 md:px-6 lg:px-8">

// Responsive grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// Hide/show at breakpoints
<div className="hidden md:block">Desktop only</div>
<div className="md:hidden">Mobile only</div>
```

## Common Mistakes to Avoid

```typescript
// WRONG: Missing 'use client' for interactive components
import { useState } from "react"; // Will error!

// WRONG: Using hooks in server components
export default async function Page() {
  const [state, setState] = useState(); // Will error!
}

// WRONG: Missing force-dynamic on auth pages
export default async function ProtectedPage() {
  const { userId } = await auth(); // May fail at build!
}

// WRONG: Inline styles (use Tailwind or CSS modules)
<div style={{ marginTop: "20px" }}>  // Use className="mt-5"
```

## Authoritative References

- **UI Patterns**: `patterns_library/ui/`
- **Component Library**: `{{UI_COMPONENTS_PATH}}`
- **Analytics Setup**: `{{ANALYTICS_CONFIG_PATH}}`
- **Feature Flags**: `{{FEATURE_FLAGS_CONFIG}}`
