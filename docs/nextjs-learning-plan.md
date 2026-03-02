# Next.js Learning Plan — Sprint + Continuous Growth

> **Goal:** Build a production-ready portfolio while mastering Next.js 16 progressively.
> **Structure:** 4-day intensive sprint → continuous learning alongside portfolio development.
> **Target version:** Next.js 16.x · React 19.2 · TypeScript · App Router

---

## ⚡ Key Next.js 16 Changes to Know from Day 1

| Concept             | Next.js 16                         | Previous                     |
| ------------------- | ---------------------------------- | ---------------------------- |
| Request interceptor | `proxy.ts`                         | `middleware.ts` (deprecated) |
| Caching             | Opt-in with `"use cache"`          | Implicit in `fetch`          |
| Default bundler     | Turbopack                          | Webpack                      |
| 401/403 pages       | `unauthorized.js` / `forbidden.js` | Did not exist                |
| React version       | 19.2                               | 18.x                         |

---

## 🔥 Phase 1 — 4-Day Sprint (6h/day)

> Build the MVP of your portfolio. Learn only what you need right now.

---

### Day 1 — Architecture, Routing & Components

**Portfolio goal:** Repo up, 4 routes working, Server/Client components in action.

**Setup (1h):**

- `create-next-app@latest` with `--typescript --tailwind --app` (Turbopack enabled by default in v16)
- Folder structure: `app/`, `public/`, `src/` optional
- `next.config.ts` — native TypeScript config (new in v16)
- `.env.local` basics and `NEXT_PUBLIC_` prefix

**File Conventions (1.5h):**

- `page.tsx` — publicly accessible route
- `layout.tsx` — shared layout, does NOT re-mount on navigation
- `template.tsx` — like layout but DOES re-mount (use rarely)
- `loading.tsx` — automatic Suspense skeleton
- `error.tsx` — per-route error boundary with retry
- `not-found.tsx` — custom 404 per route

**Routing System (2h):**

- Static routes: `app/about/page.tsx` → `/about`
- Dynamic routes: `[slug]` → accessed via `params`
- Route Groups: `(group)` — organizes without affecting the URL (great for portfolio sections)
- `<Link>` component — navigation with auto-prefetching
- `useRouter()`, `usePathname()`, `useParams()`, `useSearchParams()`
- `redirect()` and `notFound()` from Server Components

**Server vs Client Components (1.5h):**

- Everything is a Server Component by default
- `"use client"` — when and why: state, hooks, browser events
- `"use server"` — preview for Day 3
- Composition pattern: Server Component wrapping Client Component via `children`
- `import 'server-only'` — prevent accidental client-side imports

**✅ Minimum deliverable:** Repo created. Routes `/`, `/projects`, `/about`, `/contact` working. One Server Component and one Client Component coexisting.

**🎯 Day 1 closure test:** Can you explain the difference between `layout`, `template`, and `page` — and when to use `"use client"`?

---

### Day 2 — Data Fetching, Rendering & Caching

**Portfolio goal:** Projects list rendered from local JSON, dynamic route `/projects/[slug]` pre-rendered.

**Data Fetching in Server Components (2h):**

- `async/await` directly in `page.tsx` — no `useEffect` needed
- Parallel fetching with `Promise.all`
- Reading from local JSON files (perfect for portfolio projects)
- `React.cache()` — deduplicate requests across Server Components

**Rendering Strategies (1.5h):**

- Static Rendering — generated at build time (default, use for portfolio pages)
- Dynamic Rendering — per-request (use for personalized or real-time data)
- Streaming with `<Suspense>` — progressively load parts of the UI
- `generateStaticParams` — pre-render dynamic routes at build time
- `dynamicParams: true/false` — what happens with slugs not pre-generated

**Caching in Next.js 16 (2h):**

> ⚠️ Big change from v14/v15: caching is now **100% opt-in** via `"use cache"` directive.

- `"use cache"` in `page.tsx` — full route-level caching
- `"use cache"` in a function — cache results of expensive operations
- `cacheLife()` — define cache lifetime: `'minutes'`, `'hours'`, `'days'`, `'weeks'`
- `cacheTag()` — tag cache entries for targeted invalidation
- `revalidatePath(path)` — invalidate cache for a specific route
- `revalidateTag(tag)` — invalidate by tag (stale-while-revalidate)

**Error Handling (0.5h):**

- `error.tsx` with retry button
- `notFound()` — throw 404 from code
- `redirect()` and `permanentRedirect()`

**✅ Minimum deliverable:** Projects list from local JSON. `/projects/[slug]` pre-rendered with `generateStaticParams`. One cache strategy documented in the repo.

**🎯 Day 2 closure test:** Can you justify whether a given page should be static, dynamic, or hybrid?

---

### Day 3 — Server Actions, Route Handlers & Database

**Portfolio goal:** Working contact form connected to server logic. Data persisted in Neon/Supabase or local fallback.

**Server Actions (2.5h):**

- Declare with `"use server"` — inline or in a separate file
- Forms with Server Actions: `action={serverFn}` without `onSubmit`
- `<Form>` from `next/form` — automatic prefetching
- `useActionState` (React 19) — state, pending, error from the action
- `useFormStatus` — pending state in child form components
- Server-side validation (manual or with Zod)
- `redirect()` after a successful action
- Revalidating after mutations: `revalidatePath`, `revalidateTag`
- `updateTag()` — new in v16, exclusive to Server Actions for read-your-writes pattern

**Route Handlers (1.5h):**

- Create `route.ts`: `export function GET/POST/PUT/DELETE`
- `NextRequest` and `NextResponse` — read headers, cookies, body, searchParams
- When to use Route Handler vs Server Action vs separate Express backend
- Basic CORS headers in Route Handlers

**Database Connection (1.5h):**

- Free serverless options: **Neon** (PostgreSQL) or **Supabase:**- Connect directly from Server Components and Server Actions
- Data Access Layer (DAL) pattern — separate DB logic from components
- Full flow: form → Server Action → DAL → DB → revalidate → UI
- Environment variables: `.env.local`, private server-only vs `NEXT_PUBLIC_`

**✅ Minimum deliverable:** Contact form functional, connected to server logic. A `route.ts` endpoint for a complementary operation. Data persisted (or local fallback well-documented).

**🎯 Day 3 closure test:** You have a full end-to-end flow running without a separate Express backend.

---

### Day 4 — UI, Optimization, SEO & MVP Closure

**Portfolio goal:** Responsive UI, metadata implemented, portfolio navigable as MVP.

**Styling (1.5h):**

- Tailwind v4 — configured in `globals.css` (no `tailwind.config.js` needed)
- `@theme` in CSS — define custom design tokens
- `clsx` and `cn()` — conditional class names
- `twMerge` — avoid class conflicts
- Dark mode with `next-themes`
- CSS Modules as fallback for complex component styles

**Asset Optimization (1.5h):**

- `<Image>` from `next/image` — automatic WebP/AVIF, lazy loading, responsive
  - Key props: `src`, `alt`, `width`, `height`, `fill`, `priority`
  - Remote images: configure `remotePatterns` in `next.config.ts`
- `next/font` — Google Fonts and local fonts with zero layout shift
- `<Script>` — strategies: `afterInteractive`, `lazyOnload`
- `dynamic()` — lazy load Client Components, `ssr: false` for browser-only libs

**SEO & Metadata (2h):**

- Static `metadata` object exported from `page.tsx` / `layout.tsx`
- `generateMetadata()` — dynamic metadata with async data
- `title`, `description`, Open Graph, Twitter Cards
- `generateViewport()` — viewport, themeColor
- `robots.ts` and `sitemap.ts` — generated from code
- `opengraph-image.tsx` — dynamic OG image with `ImageResponse`
- JSON-LD with `next/script` for structured data

**proxy.ts basics (0.5h):**

> In Next.js 16, `middleware.ts` is replaced by `proxy.ts` for the Node.js runtime.

- `proxy.ts` — intercept requests, redirect, rewrite
- `matcher` config — which routes to apply it to
- Simple redirect pattern for portfolio (e.g., old URLs → new ones)

**✅ Minimum deliverable:** Home and key pages responsive. Metadata base implemented. Prioritized improvement list for next week.

**🎯 Day 4 closure test:** Portfolio is navigable, understandable, and presentable as MVP.

---

## 🗺️ Phase 2 — Design Week (After the Sprint)

Before continuing with deep technical learning, spend one week defining the architecture:

- **Definitive section map:** Home, Projects, About, Contact, Blog (optional), Admin (optional)
- **Functional & non-functional requirements** per section
- **Technical structure:** routes, components, data schema, rendering strategy per page
- **Prioritized backlog by phase:** - Phase A: Public MVP
  - Phase B: Content depth + SEO
  - Phase C: Automation/admin and improvements

---

## 📚 Phase 3 — Continuous Learning (Alongside Portfolio Building)

> Learn each topic when the portfolio feature demands it. Each topic maps to a real portfolio need.

---

### When you're ready to add authentication (admin panel, draft mode)

**From curriculum Days 5 & 8:**

- Auth.js v5 (NextAuth v5) — setup with `auth.ts` and `auth.config.ts`
- OAuth providers (GitHub, Google) + Credentials provider
- Route protection with `proxy.ts` — redirect to `/login` if no session
- Role-based authorization (RBAC) — admin routes protection
- `useSession()`, `signIn()`, `signOut()` from Client Components

---

### When you need richer client state (filters, URL state, complex UI)

**From curriculum Day 6:**

- URL as state — `useSearchParams()` + `router.push` for shareable filters
- `nuqs` — sync state with URL params (great for project filters)
- Zustand — lightweight global state for complex Client Component trees
- React Query / TanStack Query — when Server Components aren't enough
- `useOptimistic()` — optimistic UI before server confirms mutation

---

### When you're ready to add a blog or content section

**From curriculum Days 7 & 14:**

- Full Metadata API — `generateMetadata`, Open Graph, Twitter Cards, JSON-LD
- Dynamic OG images with `opengraph-image.tsx` and `ImageResponse`
- `sitemap.ts` for dynamic routes (generate URLs for blog posts/projects)
- MDX in Next.js with `@next/mdx` or `next-mdx-remote`
- Draft Mode — preview unpublished CMS content
- Headless CMS integration — Contentful, Sanity, or Strapi

---

### When you want animations and polished interactions

**From curriculum Day 4:**

- View Transitions API — native in React 19.2, zero dependencies
- Framer Motion — `AnimatePresence` for page transitions, `useReducedMotion` for a11y
- CSS animations with Tailwind: `animate-*`, `transition-*`

---

### When you're serious about performance

**From curriculum Days 10 & 11:**

- Cache Components with `cacheComponents: true` in `next.config.ts`
- Partial Pre-Rendering (PPR) — static shell + dynamic islands on the same page
- React Compiler — automatic memoization (opt-in, built into v16)
- Bundle analyzer — `next-bundle-analyzer` to detect bloat
- Core Web Vitals: LCP, CLS, INP — what they are and how to fix them
- `<Activity>` component — preserve state between navigations

---

### When you're ready to deploy seriously

**From curriculum Days 12 & 13:**

- Vercel deployment — environment variables, Preview Deployments, instant rollbacks
- CI/CD with GitHub Actions — lint + test + build on every PR
- `instrumentation.ts` and `instrumentation-client.ts` — telemetry (new in v16)
- Self-hosting with Docker standalone output
- Monitoring: Sentry for error tracking, OpenTelemetry

---

### When the portfolio grows into a larger system

**From curriculum Days 14 & 15:**

- Feature-based folder structure — services, DAL, actions clearly separated
- Turborepo monorepo — if you add multiple apps (portfolio + admin + shared UI)
- Vercel AI SDK — `useChat`, `streamText` for an AI-powered portfolio feature
- Advanced App Router: Parallel Routes, Intercepting Routes (modals with own URL)
- i18n with `next-intl` — if you need multilingual portfolio

---

## 📅 Daily Execution Template (Sprint Days)

1. **Planning (20 min):** 1 daily objective + max 3 key tasks.
2. **Build block 1 (90 min):** Main feature.
3. **Build block 2 (90 min):** Integration or logic.
4. **Build block 3 (90 min):** UI / adjustments / tests.
5. **Close (30 min):** Technical log entry + next step defined.

**Rules:**

- If a task grows, split it — don't drag it out of control.
- No more than one big architectural decision per day.
- Every day must leave a visible artifact in the repo.

---

## ✅ Sprint Success Signals

- Functional base of the portfolio in Next.js (TypeScript + App Router).
- Clear architectural map for the next phases.
- Q1 resumed with higher focus and lower friction.

## ⚠️ Sprint Limits

- No chasing visual perfection in these 4 days.
- No opening new study lines outside Next.js.
- No adding unplanned features to the initial MVP.

---

## 📖 Key Resources

- Official docs: <https://nextjs.org/docs>
- Upgrade guide to v16: <https://nextjs.org/docs/app/guides/upgrading/version-16>
- Blog (changelogs): <https://nextjs.org/blog>
- Community: Next.js Discord, GitHub Discussions
