---
name: frontend-patterns
description: Consistent frontend development patterns using Next.js App Router, WorkOS AuthKit, shadcn/ui components, and PostHog analytics.
---

# Frontend Patterns

## Purpose
Ensure consistent frontend development using Next.js App Router, WorkOS AuthKit, shadcn/ui, and PostHog.

## When to Use
- Building new pages or components
- Implementing authentication flows
- Adding analytics events
- Creating forms with validation

## Server vs Client Components

### Server Components (Default)
Use for data fetching, auth checks, and static rendering:

```typescript
// app/dashboard/page.tsx (Server Component)
import { getSignedInUser } from "@workos-inc/authkit-nextjs";

export default async function DashboardPage() {
  const user = await getSignedInUser();
  
  return <Dashboard user={user} />;
}
```

### Client Components
Use for interactivity, browser APIs, and hooks:

```typescript
"use client";

import { useConvexAuth } from "convex/react";
import { useQuery } from "convex/react";

export function UserDashboard() {
  const { isAuthenticated, isLoading } = useConvexAuth();
  const data = useQuery(api.data.get, isAuthenticated ? {} : "skip");
  
  if (isLoading) return <Skeleton />;
  return <div>{/* ... */}</div>;
}
```

## Protected Pages Pattern

**CRITICAL**: Use middleware for route protection, not page-level checks.

```typescript
// middleware.ts
import { authkitMiddleware } from "@workos-inc/authkit-nextjs";

export default authkitMiddleware({
  middlewareAuth: {
    enabled: true,
    unauthenticatedPaths: [
      "/",
      "/pricing",
      "/about",
      "/blog(.*)",
    ],
  },
});

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
```

## WorkOS AuthKit Integration

### Getting Current User (Server)

```typescript
import { getSignedInUser, signOut } from "@workos-inc/authkit-nextjs";

export async function getUser() {
  const user = await getSignedInUser();
  if (!user) {
    redirect("/login");
  }
  return user;
}
```

### Auth State (Client)

```typescript
"use client";

import { useConvexAuth } from "convex/react";

export function AuthAwareComponent() {
  const { isAuthenticated, isLoading } = useConvexAuth();
  
  if (isLoading) {
    return <LoadingSpinner />;
  }
  
  if (!isAuthenticated) {
    return <SignInPrompt />;
  }
  
  return <AuthenticatedContent />;
}
```

### Query Gating (CRITICAL)

**ALWAYS** gate authenticated queries:

```typescript
"use client";

import { useConvexAuth } from "convex/react";
import { useQuery } from "convex/react";
import { api } from "@repo/backend/convex/_generated/api";

export function DataComponent() {
  const { isAuthenticated } = useConvexAuth();
  
  // CORRECT: Query gated
  const data = useQuery(
    api.records.getRecords,
    isAuthenticated ? {} : "skip"
  );
  
  // WRONG: Query runs before auth ready
  // const data = useQuery(api.records.getRecords);
}
```

## shadcn/ui Forms

Use React Hook Form with Zod validation:

```typescript
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const formSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
});

export function MyForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: { name: "", email: "" },
  });
  
  async function onSubmit(values: z.infer<typeof formSchema>) {
    // Handle submission
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
                <Input placeholder="Enter name" {...field} />
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

## PostHog Analytics

### Event Naming Convention

Use snake_case with category prefixes:

| Category | Examples |
|----------|----------|
| User events | `user_signed_up`, `user_logged_in` |
| Feature events | `feature_dark_mode_toggled` |
| Payment events | `payment_completed`, `subscription_started` |
| Navigation | `page_viewed`, `button_clicked` |

### Tracking Events

```typescript
"use client";

import { usePostHog } from "posthog-js/react";

export function FeatureButton() {
  const posthog = usePostHog();
  
  const handleClick = () => {
    posthog.capture("feature_button_clicked", {
      feature_name: "dark_mode",
      location: "settings",
    });
    
    // Do the thing
  };
  
  return <Button onClick={handleClick}>Toggle</Button>;
}
```

### Feature Flags

```typescript
import { useFeatureFlagEnabled } from "posthog-js/react";

export function NewFeature() {
  const showNewUI = useFeatureFlagEnabled("new-dashboard-ui");
  
  if (showNewUI) {
    return <NewDashboard />;
  }
  
  return <LegacyDashboard />;
}
```

## Accessibility Checklist

Before completing UI work:

- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Focus indicators visible
- [ ] Color contrast ratio >= 4.5:1
- [ ] All images have alt text
- [ ] Form inputs have labels
- [ ] ARIA labels on interactive elements
- [ ] Error messages announced to screen readers

## Route Organization

```
app/
├── (marketing)/        # Public pages
│   ├── page.tsx        # Home
│   ├── pricing/
│   └── about/
├── (auth)/             # Auth pages
│   ├── login/
│   └── callback/
├── (dashboard)/        # Protected pages
│   ├── layout.tsx      # Auth wrapper
│   ├── page.tsx        # Dashboard home
│   └── settings/
└── api/                # API routes
    ├── auth/
    └── webhooks/
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `"use client"` | Add directive for hooks/interactivity |
| Using hooks in server components | Move to client component |
| Query without auth gating | Use `isAuthenticated ? {} : "skip"` |
| Inline styles | Use Tailwind classes |
| Direct DOM manipulation | Use React state |
