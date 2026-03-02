# Day 2 — Data Fetching, Rendering & Caching

## Data Fetching in Server Components

Server Components are async by default, which means you can fetch data directly in `page.tsx` or `layout.tsx` without `useEffect` or client-side state.

```tsx
export default async function Page() {
  const data = await fetch("https://api.example.com/posts").then((r) =>
    r.json(),
  );
  return <PostList posts={data} />;
}
```

No hydration, no loading state boilerplate — the component waits server-side and renders with data ready.

### Parallel vs Sequential Fetching

**Sequential** — each fetch waits for the previous one. Use only when the second request depends on the first.

```tsx
const user = await getUser(id);
const orders = await getOrders(user.id); // needs user first
```

**Parallel** — fire all requests at once. Default choice when requests are independent.

```tsx
const [user, posts] = await Promise.all([getUser(id), getPosts()]);
```

`Promise.allSettled` if you need to handle partial failures without crashing the whole page.

### Request Deduplication with `React.cache()`

If multiple Server Components call the same function (e.g. `getUser()`), Next.js won't deduplicate it automatically unless you wrap it with `React.cache()`.

```ts
import { cache } from "react";

export const getUser = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});
```

Now any component calling `getUser(id)` with the same argument shares the result within one render pass.

---

## Rendering Strategies

| Strategy  | When rendered                | Use case               |
| --------- | ---------------------------- | ---------------------- |
| Static    | Build time                   | Blogs, marketing pages |
| Dynamic   | Per request                  | Dashboards, auth pages |
| Streaming | Per request, progressively   | Slow data, better UX   |
| PPR       | Static shell + dynamic holes | Best of both           |

**Static** is the default when no dynamic data is involved. **Dynamic** kicks in automatically when you use cookies, headers, or `searchParams`.

### Streaming with Suspense

Lets you ship the page shell immediately and stream in slow parts as they resolve.

```tsx
import { Suspense } from "react";

export default function Page() {
  return (
    <>
      <Header />
      <Suspense fallback={<Spinner />}>
        <SlowDataComponent />
      </Suspense>
    </>
  );
}
```

### `generateStaticParams`

Pre-renders dynamic routes at build time.

```ts
export async function generateStaticParams() {
  const posts = await getPosts();
  return posts.map((p) => ({ slug: p.slug }));
}
```

`dynamicParams: true` (default) — slugs not in the list are rendered on demand.  
`dynamicParams: false` — slugs not in the list return 404.

---

## Caching in Next.js 16

Next.js 16 flips the model: **caching is fully opt-in**. Nothing is cached unless you say so explicitly.

### `"use cache"` Directive

Works at three levels:

**Route level** — cache the entire page.

```tsx
"use cache";
export default async function Page() { ... }
```

**Component level** — cache a specific async component.

```tsx
"use cache";
export async function HeavyWidget() { ... }
```

**Function level** — cache results of expensive operations.

```ts
"use cache";
export async function getExpensiveData() { ... }
```

### Cache Lifetime with `cacheLife()`

```ts
import { cacheLife } from 'next/cache';

"use cache";
export async function getData() {
  cacheLife('hours');
  return fetch(...);
}
```

Profiles available: `'seconds'`, `'minutes'`, `'hours'`, `'days'`, `'weeks'`, `'max'`.

### Cache Invalidation

```ts
revalidatePath("/blog"); // invalidate a route
revalidateTag("posts"); // invalidate by tag
```

Tag your cache entries with `cacheTag()`:

```ts
"use cache";
export async function getPosts() {
  cacheTag("posts");
  return db.post.findMany();
}
```

`updateTag()` is exclusive to Server Actions — use it for read-your-writes (invalidate immediately after a mutation).

---

## Error Handling

### `error.tsx`

Catches errors in its route segment. Must be a Client Component.

```tsx
"use client";
export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <p>{error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  );
}
```

Errors bubble up to the nearest `error.tsx`. Nesting them lets you catch errors at different granularities without crashing the whole page.

### `forbidden()` and `unauthorized()`

New in Next.js 16. Call them inside Server Components or Actions to trigger the corresponding special pages.

```ts
import { forbidden } from "next/navigation";

export default async function AdminPage() {
  const user = await getUser();
  if (user.role !== "admin") forbidden();
}
```

Create `forbidden.tsx` / `unauthorized.tsx` at the app root to customize those pages.

---
