# Day 1 --- Next.js App Router Foundations

## 1. What Next.js Actually Is (App Router Mental Model)

Next.js (App Router) is not just a React framework. It is:

- A React compiler layer
- A server runtime
- A routing system
- A build system
- An RPC abstraction layer (Server Actions)

The key architectural shift:

> The server is the default execution environment.

In the App Router: - Components are **Server Components by default** -
Client Components are opt-in with `"use client"`

### Setup

```bash
npx create-next-app@latest my-portfolio --typescript --tailwind --app
```

**Turbopack** comes by default in development for super fast HMR.

The initial file structure aim to understand where your code lives:

```plain
app/                  ← root directory for your code and routes
├── layout.tsx        ← layout global for all the app
├── page.tsx          ← root route "/"
├── about/
│   └── page.tsx      ← "/about" route
└── projects/
    ├── page.tsx      ← "/projects" route
    └── [slug]/
        └── page.tsx  ← "/projects/:slug" dynamic route
public/               ← static assets (images, fonts, etc.)
next.config.ts        ← global configuration for Next.js (build and runtime)
```

`next.config.ts` — it is not any more js, since Next.js 16 is TypeScript.

---

## 2. `next.config.ts` / `next.config.js`

### Purpose

Global configuration for the framework at build-time and runtime.

It configures: - Image domains - Environment exposure - Redirects /
rewrites - Experimental flags - Bundle behavior

### Example

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    domains: ["example.com"],
  },
  reactStrictMode: true,
};

export default nextConfig;
```

### Important Nuance

- This file runs in Node (never in the browser).
- It affects build output.
- It is not runtime business logic.

---

## 3. File Conventions (App Router)

Next.js uses filesystem-based routing with special filenames.

### Special Files in Route Folders

The App Router uses naming conventions. Each file has a fixed role:

| File            | What it does                                                                        |
| --------------- | ----------------------------------------------------------------------------------- |
| `page.tsx`      | Defines the route. Without this file, the folder is not a public route              |
| `layout.tsx`    | Wraps the page. **Does not re-mount** when navigating between child routes          |
| `template.tsx`  | Same as layout but **does re-mount**. Use sparingly — entry animations, state reset |
| `loading.tsx`   | Automatic loading UI. Next.js wraps it in `<Suspense>` for you                      |
| `error.tsx`     | Error boundary per route. Receives the error and a retry button                     |
| `not-found.tsx` | Custom 404 page per segment                                                         |

**Important gotcha — `layout.tsx` vs `template.tsx`:** The difference is not just conceptual. Since `layout` does not re-mount, the state living in it persists between navigations. If you have a counter or a form in a layout, it does not reset when navigating. `template` does reset it. For a portfolio you’ll almost always use `layout`.

#### Complete Routing System

- **Static routes:** the folder defines the URL.

  ```plain
  app/about/page.tsx → /about
  app/projects/page.tsx → /projects
  ```

- **Dynamic routes:** brackets capture the variable segment.

  ```plain
  app/projects/[slug]/page.tsx → /projects/my-project
  ```

### The `page.tsx`

Defines a route segment. Executed as a Server Component by default.

```tsx
export default function Page() {
  return <div>Hello</div>;
}
```

---

### `layout.tsx`

Wraps all child routes inside its folder. Persists between navigations
inside that segment.

Used for: - Providers - Navigation - Persistent UI

Key behavior: - It does NOT remount when navigating between sibling
routes.

---

### `template.tsx`

Same as layout, but: - Remounts on navigation - State resets

Use when you need fresh lifecycle execution.

---

### `loading.tsx`

Suspense fallback for the route segment.

Automatically shown during async rendering.

---

### `error.tsx`

Error boundary for the route segment.

Must be a Client Component.

---

### `not-found.tsx`

Rendered when `notFound()` is triggered.

---

## 4. Rendering & Re-rendering Mental Model

In traditional React: - Parent renders → children render.

In Next App Router: - Server renders tree - Sends serialized payload -
Client hydrates only Client Components

Important distinction:

Component Type Where It Executes

---

Server Component Node (server)
Client Component Browser

Layouts persist. Templates remount. Pages re-execute on navigation.

---

## 5. Routing

### Static Routes

app/dashboard/page.tsx
→ /dashboard

---

### Dynamic Routes

app/blog/[slug]/page.tsx

Access params:

```tsx
export default function Page({ params }) {
  return params.slug;
}
```

---

### Catch-All

[...slug]

Matches multiple segments.

---

### Route Groups

(group)/dashboard

Used for organization. Does NOT affect URL.

---

## 6. Navigation

### `<Link>`

Client-side navigation. Preloads automatically.

---

### Hooks (Client Only)

- `useRouter()` → navigation control
- `usePathname()` → current path
- `useParams()` → dynamic params
- `useSearchParams()` → query string

These require `"use client"`.

---

## 7. Server vs Client Components

### Server Components (Default)

Use when: - Fetching data - Accessing DB - Using secrets - Heavy
computation

Advantages: - No JS sent to client - Smaller bundles - Better security

```tsx
// Server Component (default) — no "use client"
// ✅ it can use: async/await, fetch, DB access, secrets
// ❌ it cannot use: useState, useEffect, event handlers, browser APIs

export default async function ProjectList() {
  const projects = await getProjectsFromDB(); // allowed in Server Components
  return (
    <ul>
      {projects.map((p) => (
        <li key={p.id}>{p.title}</li>
      ))}
    </ul>
  );
}
```

---

### Client Components (`"use client"`)

Use when: - Using state (`useState`) - Using effects (`useEffect`) -
Handling events - Accessing browser APIs

Anti-pattern: Fetching sensitive data in Client Components when it could
be done on the server.

```tsx
// Client Component
"use client";
// ✅ It can use: useState, useEffect, onClick, hooks
// ❌ it cannot use: async/await, fetch (without polyfill), DB access, secrets, server-only modules

import { useState } from "react";

export function ContactForm() {
  const [name, setName] = useState("");
  return <input value={name} onChange={(e) => setName(e.target.value)} />;
}
```

---

## 8. Composition: Server → Client

Valid:

```tsx
// Server Component
import ClientWidget from "./ClientWidget";

export default async function Page() {
  const data = await getData();
  return <ClientWidget data={data} />;
}
```

Invalid: Passing server functions directly as props to Client
Components.

---

## 9. Server Actions

### What They Are

Functions marked with:

```ts
"use server";

export async function userUpdate() {
  if (condition) {
    throw new Error("Unauthorized");
  }
  await db.user.update(...);
}
```

They are transformed by Next into RPC endpoints.

Not normal functions.

---

### What Actually Happens

When called from a Client Component:

1. Next generates a hidden POST endpoint.
2. Arguments are serialized.
3. Browser sends request.
4. Server executes function.

It is HTTP under the hood.

---

### Example of Server Action

```ts
"use server"

export async function updateUserName(id: string, name: string) {
  await db.user.update(...)
}
```

Client:

```tsx
"use client";

await updateUserName(id, name);
```

This is not direct execution. It is remote invocation.

---

## 10. Server Actions vs API Routes

Server Actions API Routes

---

UI-driven mutations Public APIs
Internal only External consumption
Auto RPC Explicit REST
Simpler More control

Use API Routes when: - Mobile apps consume backend - External services
call your API - Webhooks - Public integrations

---

## 11. Architectural Principle

Server Actions are:

- RPC abstraction
- Not shared execution
- Not code transfer

Client invokes. Server executes.

This preserves: - Security - Separation of concerns - Predictable
architecture

---

## 12. Core Mental Model to Keep

The server is the source of truth. The client triggers mutations. The
server re-renders authoritative UI.

This is the modern React server-first model.
