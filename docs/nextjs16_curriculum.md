# Next.js 16 — Complete Curriculum: Zero to Master

> **Target version:** Next.js 16.x · React 19.2 · Node 20.9+  
> **Structure:** 15 days · 90 hours · 6 hours per day  
> **Student prerequisites:** JavaScript, TypeScript, React, Node.js with Express  
> **Last updated:** October 2025 (based on official Next.js 16 documentation)

---

## Context for the Agent

This document is the student's Next.js 16 learning curriculum. Use it as a reference to:

- Know which day and topic the student is currently working on
- Contextualize technical questions within the expected level of progress
- Suggest the next topic when the student finishes one
- Detect if a question belongs to a future day's topic and clarify that
- Use the correct Next.js 16 terminology (e.g. `proxy.ts` instead of `middleware.ts`, `"use cache"` instead of implicit caching)

### Key Next.js 16 changes to keep in mind

- `middleware.ts` was replaced by `proxy.ts` (Node.js runtime). `middleware.ts` is still available for Edge runtime use cases but is deprecated.
- Caching is **100% opt-in** via the `"use cache"` directive. There is no more implicit caching as in v14/v15.
- **Cache Components** + **Partial Pre-Rendering (PPR)** are enabled with `cacheComponents: true` in `next.config.ts`.
- **Turbopack** is the default bundler for all new projects.
- **React Compiler** is stable and built-in (opt-in).
- **React 19.2** includes View Transitions, `useEffectEvent()`, and the `<Activity>` component.
- `forbidden()` and `unauthorized()` are new functions, with their special files `forbidden.js` and `unauthorized.js`.
- `instrumentation-client.ts` is new for client-side telemetry.
- `updateTag()` is a new API exclusive to Server Actions for cache invalidation (read-your-writes pattern).

---

## Phase Overview

| Days  | Phase                              | Main Topics                                |
| ----- | ---------------------------------- | ------------------------------------------ |
| 01–03 | Fundamentals and architecture      | App Router, rendering, data fetching       |
| 04–06 | Full Stack with Next.js            | Server Actions, Route Handlers, databases  |
| 07–09 | UI, styles, SEO and authentication | Tailwind, animations, Auth.js v5, proxy.ts |
| 10–11 | Advanced caching and performance   | Cache Components, PPR, Turbopack, testing  |
| 12–13 | i18n, deploy and CI/CD             | next-intl, Vercel, Docker, GitHub Actions  |
| 14–15 | Advanced architecture and AI       | Turborepo, production patterns, AI SDK     |

---

## Day 1 — Next.js 16 Architecture and App Router

**Duration:** 6 hours

### Setup and tooling (1h)

- Installation with `create-next-app@latest` (Turbopack enabled by default)
- CLI options: `--typescript`, `--tailwind`, `--app`, `--src-dir`
- Folder structure: `app/`, `public/`, `src/` (optional)
- `next.config.ts` — native TypeScript configuration (new in v16)
- Commands: `next dev`, `next build`, `next start`, `next lint`
- Environment variables: `.env.local`, `.env.production`, `NEXT_PUBLIC_` prefix
- DevTools MCP: setup for AI-assisted debugging

### File Conventions — App Router special files (1.5h)

- `page.tsx` — defines a publicly accessible route
- `layout.tsx` — shared layout and nested layouts (does not re-mount)
- `template.tsx` — like layout but re-mounts on navigation (when to use it)
- `loading.tsx` — automatic Suspense with skeleton UI
- `error.tsx` — per-route error boundary with retry button
- `not-found.tsx` — custom 404 page per route
- `default.tsx` — fallback for Parallel Routes
- `route.ts` — Route Handler (API endpoint inside the App Router)
- `proxy.ts` — replaces `middleware.ts` in Next.js 16 (Node.js runtime)
- Metadata files: `favicon.ico`, `opengraph-image`, `robots.txt`, `sitemap.xml`

### Complete routing system (2h)

- Static routes: `app/about/page.tsx` → `/about`
- Dynamic routes: `[slug]`, `[id]` — accessed via `params`
- Optional dynamic routes: `[[...slug]]`
- Catch-all routes: `[...slug]` — captures multiple segments
- Route Groups: `(folder)` — organizes without affecting the URL
- Route Groups for multiple root layouts
- Parallel Routes: `@folder` — render multiple pages in one layout
- Intercepting Routes: `(.)` `(..)` `(...)` — modals with their own URL
- `<Link>` component — navigation with automatic prefetching
- Incremental prefetching in Next.js 16 (layout deduplication)
- `useRouter()` — programmatic navigation from Client Components
- `usePathname()`, `useParams()`, `useSearchParams()`
- `redirect()` and `permanentRedirect()` from Server Components
- `notFound()` — throw a 404 from code

### Server Components vs Client Components (1.5h)

- Mental model: everything is a Server Component by default
- `"use client"` directive — when and why to add it
- `"use server"` directive — Server Actions and server-side functions
- What each type can do: DB access, hooks, events, state
- Composition rules: passing Server Components as `children`
- Pattern: Client Component wrapper + Server Component as `children`
- `import 'server-only'` — prevent accidental client-side imports
- Serialization boundary: what data can cross the server/client boundary
- React Compiler in Next.js 16 — automatic memoization (opt-in)

---

## Day 2 — Data Fetching and Rendering Strategies

**Duration:** 6 hours

### Data fetching in Server Components (2h)

- `async/await` directly in `page.tsx` and `layout.tsx` (no `useEffect`)
- Native `fetch` extended by Next.js — built-in cache and revalidation
- Parallel fetching with `Promise.all` and `Promise.allSettled`
- Sequential vs parallel fetching — when to use each
- Automatic request deduplication with `React.cache()`
- Sharing data between Server Components: props vs `React.cache`
- Fetching from local JSON files (useful for portfolios and simple CMS)
- SWR and React Query for fetching in Client Components

### Rendering strategies (1.5h)

- Static Rendering — generated at build time (default without dynamic data)
- Dynamic Rendering — generated on each request
- Streaming with Suspense — progressively load parts of the UI
- Partial Pre-Rendering (PPR) — static + dynamic on the same page
- `generateStaticParams` — pre-render dynamic routes at build time
- `dynamicParams: true/false` — behavior with slugs not pre-generated
- `force-dynamic`, `force-static` in Route Segment Config
- `connection()` — force render at request time (Next.js 16)

### Caching in Next.js 16 (2h)

- Caching is **100% opt-in** in Next.js 16 (no longer implicit)
- `"use cache"` directive — cache pages, components, and functions
  - `"use cache"` in `page.tsx` — full route-level caching
  - `"use cache"` in an async component — granular caching
  - `"use cache"` in a function — cache results of expensive functions
- Automatic cache keys — the compiler generates them based on arguments
- `cacheLife()` — define cache lifetime (profiles: `'seconds'`, `'minutes'`, `'hours'`, `'days'`, `'weeks'`, `'max'`)
- `cacheTag()` — tag cache entries for targeted invalidation
- `revalidatePath(path)` — invalidate cache for a route
- `revalidateTag(tag)` — invalidate by tag (stale-while-revalidate)
- `updateTag()` — new API exclusive to Server Actions (read-your-writes pattern)
- ISR (Incremental Static Regeneration) with `cacheLife`
- Enable Cache Components: `cacheComponents: true` in `next.config.ts`
- `<Activity>` component — preserve state between navigations

### Error handling and states (0.5h)

- `error.tsx` with `useError()` to access the error object
- Nested error boundaries — errors caught at the closest level
- Errors in layouts vs errors in pages
- `forbidden()` and `unauthorized()` — new functions in Next.js 16
- `forbidden.js` and `unauthorized.js` — special pages for 401/403

---

## Day 3 — Full Stack: Server Actions and Route Handlers

**Duration:** 6 hours

### Server Actions (2.5h)

- What Server Actions are and how they work internally
- Declare with `"use server"` directive — inline vs separate file
- Forms with Server Actions — `action={serverFn}` without `onSubmit`
- Next.js `<Form>` component (`next/form`) — automatic prefetching
- `useActionState` (React 19) — state, pending, error from the action
- `useFormStatus` — pending state in child components
- Server-side validation with Zod or manual validation
- Error handling: returning error objects vs throwing
- Redirecting after an action with `redirect()`
- Revalidating cache after mutations: `revalidatePath`, `revalidateTag`, `updateTag`
- Security: Server Actions are POST endpoints — always validate and authenticate
- Progressive enhancement — forms work without JavaScript
- Server Actions in Client Components — import from a `"use server"` file

### Route Handlers (1.5h)

- Create `route.ts`: `export function GET/POST/PUT/DELETE/PATCH`
- `NextRequest` and `NextResponse` — read headers, cookies, body, searchParams
- When to use a Route Handler vs a Server Action vs a separate Express backend
- Route Handlers with Cache Components in Next.js 16
- Streaming responses with `ReadableStream`
- CORS in Route Handlers — manual headers
- Basic rate limiting in Route Handlers
- Webhooks with Route Handlers — verifying signatures

### Database and ORM (1.5h)

- Free serverless DB options: Neon, Supabase, PlanetScale, Turso
- Connecting Neon (PostgreSQL) directly from Server Components
- **Drizzle ORM** — setup, schema, migrations (recommended lightweight option)
- **Prisma ORM** — setup, schema, Prisma Client in Next.js
- Data Access Layer (DAL) — separate DB logic from components
- Service Layer — business logic between Actions and DAL
- Avoid DB queries in Client Components — `import 'server-only'`
- Full flow: form → Server Action → DAL → DB → revalidate → UI

### Environment variables and data security (0.5h)

- Hierarchy: `.env`, `.env.local`, `.env.development`, `.env.production`
- Public variables `NEXT_PUBLIC_` — available on the client
- Private variables — only accessible on the server
- Validate environment variables at runtime with Zod
- Data Transfer Objects (DTOs) — never expose the raw DB model

---

## Day 4 — Styles, UI and Asset Optimization

**Duration:** 6 hours

### Tailwind CSS in Next.js 16 (1.5h)

- Tailwind v4 integrated — configured in `globals.css` (no `tailwind.config.js`)
- `@theme` in CSS — define custom design tokens
- Essential utility classes — layout, typography, colors, spacing
- Responsive design with Tailwind breakpoints
- Dark mode with `dark:` prefix and `next-themes`
- `clsx` and `cn()` — conditional class names
- Tailwind Merge (`twMerge`) — avoid class conflicts
- `shadcn/ui` — unstyled components built on Radix UI

### CSS Modules and other styling options (0.5h)

- CSS Modules — component-scoped styles (`.module.css`)
- Sass with Next.js — installation and usage
- CSS-in-JS in the App Router — limitations with Server Components
- styled-components and emotion in client-only mode

### Image and font optimization (1.5h)

- `<Image>` component from `next/image` — essential to know
  - Props: `src`, `alt`, `width`, `height`, `fill`, `priority`
  - Automatic lazy loading, WebP/AVIF formats
  - Remote images — configure `remotePatterns` in `next.config.ts`
  - Aspect ratio with `fill` + positioning
  - Blur placeholder with `blurDataURL`
- `next/font` — fonts with zero layout shift (zero CLS)
  - Google Fonts: Inter, Geist — loaded at build time
  - Local fonts with `localFont()`
  - Variable fonts and CSS variables
- New `next/image` defaults in Next.js 16 (breaking change)

### Scripts and lazy loading (0.5h)

- `<Script>` component — strategies: `beforeInteractive`, `afterInteractive`, `lazyOnload`
- `dynamic()` from `next/dynamic` — lazy loading Client Components
  - `ssr: false` for components that require `window`/`document`
  - Suspense with `dynamic()` — loading UI
- Lazy loading heavy third-party libraries

### Animations in Next.js (1.5h)

- View Transitions API — native integration in React 19.2
- Framer Motion with Next.js — setup and patterns for the App Router
  - `AnimatePresence` for page transitions
  - `useReducedMotion` — accessibility
- React Spring — alternative to Framer Motion
- CSS animations with Tailwind: `animate-*`, `transition-*`
- GSAP with Next.js — usage inside Client Components

---

## Day 5 — Authentication and Authorization with Auth.js v5

**Duration:** 6 hours

### Authentication fundamentals (0.5h)

- Authentication vs Authorization — differences and layers
- Strategies: JWT vs Session-based — when to use each
- OAuth 2.0 — basic flow (GitHub, Google as providers)
- Credentials provider — custom email/password
- Ecosystem options: Auth.js v5, Clerk, Supabase Auth, Lucia

### Auth.js v5 (NextAuth.js v5) — full setup (2h)

- Installation and key differences from v4
- `auth.ts` file — central configuration with `NextAuth()`
- `auth.config.ts` file — config without adapter dependencies (for `proxy.ts`)
- Exports: `auth`, `handlers`, `signIn`, `signOut`
- Route Handler at `app/api/auth/[...nextauth]/route.ts`
- Environment variables: `AUTH_SECRET` (required), `AUTH_URL` (optional)
- Auto-inferred variables: `AUTH_GITHUB_ID`, `AUTH_GITHUB_SECRET`
- OAuth providers: GitHub, Google — configuration
- Credentials provider — custom validation with `authorize()`
- Callbacks: `jwt()`, `session()`, `signIn()`, `redirect()`
- Extending the `Session` type with TypeScript
- Database adapter with Drizzle or Prisma

### Route protection with proxy.ts (1.5h)

- `proxy.ts` — the new Next.js 16 middleware (Node.js runtime)
- Integrating Auth.js with `proxy.ts` — exporting `auth` as `proxy`
- `matcher` config — which routes to protect
- Redirect to `/login` if no session exists
- Distinguishing between public and protected routes
- `authorized` callback in `auth.config.ts`
- Protecting Route Handlers with `auth()` server-side
- Protecting Server Actions — verify session before operating
- Protecting Server Components with `auth()` inside the component

### Role-based authorization (RBAC) (1h)

- Adding a `role` field to the JWT token and session
- Checking role in `proxy.ts` for admin routes
- Data Access Layer (DAL) with authorization checks
- DTOs that filter fields based on the user's role
- Pattern: optimistic vs pessimistic authorization

### Sessions and security (1h)

- JWT vs Database sessions strategy — configuration
- Session expiration and refresh token rotation
- Cookies: `httpOnly`, `secure`, `sameSite` — configuration
- CSRF — how Auth.js handles it automatically
- Rate limiting on login routes with `proxy.ts`
- Email verification with the Email provider
- `signIn()` and `signOut()` from Client Components
- `useSession()` — session state on the client

---

## Day 6 — State Management and Advanced React Patterns

**Duration:** 6 hours

### Server state vs client state (1h)

- URL as state — `searchParams` for shareable state
- `useSearchParams()` to read, `router.push` to update
- `nuqs` — library to sync state with URL params
- When you actually need global client state
- Context API in the App Router — Client Components only
- Provider pattern with Server Components as `children`

### Zustand — lightweight state management (1h)

- Installation and basic setup
- Stores — create and access from any Client Component
- Slices pattern for large stores
- Persistence with `zustand/middleware` persist
- Integration with Server Actions — update store after a mutation
- SSR hydration — Zustand in Next.js App Router

### React Query / TanStack Query (1.5h)

- When to use React Query vs direct fetch in Server Components
- Setup: `QueryClient`, `QueryClientProvider` in layout
- `useQuery` — fetching with cache, loading, error states
- `useMutation` — mutations with `onSuccess`, `onError`
- Cache invalidation with `queryClient.invalidateQueries()`
- Prefetching in Server Components with `dehydrate`/`HydrationBoundary`
- Optimistic updates with `useMutation`
- Infinite scroll with `useInfiniteQuery`

### Advanced forms (1.5h)

- React Hook Form + Zod — type-safe validation
- Integrating RHF with Server Actions
- `useActionState` for Server Action feedback
- Multi-step forms with persisted state
- File uploads — FormData with Server Actions
- Uploading files to external services (Cloudinary, Uploadthing, S3)
- Client-side + server-side validation with the same Zod schema

### Advanced React 19 hooks and patterns (1h)

- `use()` — read promises and context in Client Components
- `useOptimistic()` — optimistic UI before confirming the mutation
- `useEffectEvent()` — new in React 19.2 (stable)
- `<Activity>` component — preserve state of hidden routes (Next.js 16)
- Advanced composition: Compound Components, Render Props in the App Router
- Container/Presenter pattern with Server and Client Components

---

## Day 7 — SEO, Metadata and Accessibility

**Duration:** 6 hours

### Full Metadata API (2h)

- Static `metadata` object — exported from `page.tsx` and `layout.tsx`
- `generateMetadata()` — dynamic metadata with async data
- Metadata inheritance and merging — layouts → pages
- `title: string` vs `title: { template, default, absolute }`
- `description`, `keywords`, `authors`, `creator`, `publisher`
- Open Graph: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`
- Twitter/X Cards: `card`, `site`, `creator`, `images`
- `generateViewport()` — viewport, themeColor, colorScheme
- `alternates` — canonical URLs, hreflang for i18n
- `robots` — index/noindex, follow/nofollow per page
- `manifest.json` — PWA manifest
- JSON-LD with `next/script` for structured data (schema.org)

### Dynamic OG images (1h)

- `opengraph-image.tsx` — special file for dynamic OG images
- `ImageResponse` from `next/og` — render React → PNG image
- Recommended dimensions: 1200x630
- Fonts in `ImageResponse` — load from Google Fonts
- `generateImageMetadata` — multiple OG image variants
- `twitter-image.tsx` — Twitter-specific image

### Sitemap, robots and metadata files (1h)

- `sitemap.ts` — generate dynamic sitemap with `generateSitemaps()`
- `robots.ts` — configure crawling rules
- Sitemap for dynamic routes — generate URLs for products/posts
- Multiple sitemaps with `generateSitemaps` for large sites
- `favicon.ico`, `icon.png`, `apple-icon.png` — file conventions
- `manifest.ts` — configure PWA manifest from code

### Accessibility (a11y) in Next.js (1h)

- Route announcements — Next.js announces route changes to screen readers
- Focus management — managing focus on programmatic navigation
- Images: required alt text, decorative images with `alt=""`
- Headings hierarchy — correct semantic structure
- ARIA attributes — when and how to use them
- Color contrast — WCAG 2.1 minimums
- Keyboard navigation — visible focus, tab order
- `eslint-plugin-jsx-a11y` — detect issues during development

### Core Web Vitals and performance (1h)

- LCP (Largest Contentful Paint) — optimize the hero image
- CLS (Cumulative Layout Shift) — `next/font`, image dimensions
- INP (Interaction to Next Paint) — replaces FID
- TTFB (Time to First Byte) — caching and edge deployment
- `useReportWebVitals` — send metrics to analytics
- PageSpeed Insights and Lighthouse in Next.js
- Bundle analyzer — `next-bundle-analyzer` to detect bloat

---

## Day 8 — proxy.ts, Security and Advanced Routing Patterns

**Duration:** 6 hours

### proxy.ts in depth (2h)

- `proxy.ts` vs `middleware.ts` — differences in Next.js 16
- Runtime: Node.js (`proxy.ts`) vs Edge (`middleware.ts` deprecated)
- Anatomy: `export default function proxy(request: NextRequest)`
- `NextRequest` — read URL, headers, cookies, geo, IP
- `NextResponse` — redirect, rewrite, next, json with headers
- `matcher` config — regex patterns to select routes
- Use cases: auth guard, A/B testing, i18n redirect, feature flags
- Conditional redirects based on headers (User-Agent, Accept-Language)
- Modifying headers on requests/responses
- Reading and writing cookies in `proxy.ts`
- Logic chaining — multiple checks in one proxy
- Rate limiting with header counters or Redis

### Parallel Routes and Intercepting Routes (2h)

- Parallel Routes (`@folder`) — when they make sense
  - Use case: dashboard with multiple independent sections
  - Independent `loading.tsx` and `error.tsx` per slot
  - `default.tsx` — what to show when the slot has no active route
- Intercepting Routes — modals with their own URL
  - `(.)` — intercept at the same level
  - `(..)` — intercept one level up
  - `(...)` — intercept from the root
- Modal pattern: open `/photos/[id]` as a modal over `/feed`
- Preserving the modal in the browser history
- Combining Parallel + Intercepting Routes for galleries

### Redirects and rewrites in next.config.ts (1h)

- `redirects()` — permanent (308) and temporary (307)
- `rewrites()` — transparent proxy to other domains/paths
- Rewrites for gradual migration from another platform
- `headers()` — add global HTTP headers (CORS, CSP, HSTS)
- Basic Content Security Policy (CSP) with nonce
- `basePath` — subpath deployment (`/app/...`)
- `trailingSlash` — URL consistency

### Security in Next.js (1h)

- Server Actions — always validate input and session
- SQL Injection — use ORM or parameterized queries
- XSS — Next.js escapes automatically in JSX
- SSRF — validate URLs in server-side fetch
- Exposed environment variables — `NEXT_PUBLIC_` vs private
- Dependency security — run `npm audit` regularly
- Secrets in server-only files — `import 'server-only'`
- `next/headers` — secure cookies and headers on the server

---

## Day 9 — External API Integration and Services

**Duration:** 6 hours

### Patterns for external API integration (1.5h)

- Backend for Frontend (BFF) — Next.js as an aggregation layer
- Calling REST APIs from Server Components — without exposing tokens
- API proxy in Route Handlers — forward requests to a backend
- Authenticating external requests with authorization headers
- HTTP error handling — status codes, timeouts, retries
- Data transformation between external API and UI
- Caching external responses with `"use cache"` + `cacheLife`

### Databases and advanced ORM (1.5h)

- Advanced Drizzle ORM — relations, joins, transactions
- Migrations with `drizzle-kit`
- Prisma — relations, middleware, transactions
- Prisma Accelerate — connection pooling for serverless
- Supabase — PostgreSQL + Auth + Storage + Realtime
- Row Level Security (RLS) in Supabase
- Turso (SQLite at the edge) — use cases
- MongoDB with Mongoose from Server Components

### File storage (1h)

- Uploadthing — the most Next.js-integrated option
- Cloudinary — cloud image transformations
- AWS S3 with presigned URLs — direct upload from the client
- Vercel Blob — Vercel's native storage
- Validate file type and size on the server

### Email and notifications (1h)

- Resend — the recommended email service for Next.js in 2025
- React Email — email templates with React components
- Sending email from Server Actions or Route Handlers
- Transactional vs marketing — differences
- Email webhooks — processing replies and bounces

### Real-time in Next.js (1h)

- Server-Sent Events (SSE) with Route Handlers — one-way streaming
- WebSockets — serverless limitations, solutions: Pusher, Ably, Soketi
- Supabase Realtime — real-time subscriptions
- Smart polling vs WebSockets — when to use each
- Vercel AI SDK — streaming AI responses

---

## Day 10 — Advanced Performance and Turbopack

**Duration:** 6 hours

### Turbopack in depth (1.5h)

- Turbopack vs Webpack — architectural differences
- Turbopack stable in Next.js 16 — enabled by default
- Turbopack File System Caching (beta) — persistent startup between restarts
  - Enable: `experimental.turbopackFileSystemCacheForDev: true`
- Webpack plugin compatibility — which ones Turbopack supports
- `turbopack.resolveAlias` — replace Node.js modules on the client
- Force Webpack: `next dev --webpack` / `next build --webpack`
- Bundle analyzer with Turbopack
- Improved build logging in Next.js 16 — Compile vs Render timing

### Cache Components and advanced PPR (2h)

- Partial Pre-Rendering (PPR) — full architecture
- Static shell + dynamic holes — how it works internally
- Enable: `cacheComponents: true` in `next.config.ts`
- Uncached data outside `<Suspense>` — dev/build error and how to fix it
- `"use cache"` in Server Components — different levels of granularity
- Cache boundaries — how the compiler determines them
- `React.cache()` inside `"use cache"` — scope isolation
- Passing promises as props from static to dynamic
- Sharing data with context in PPR
- `connection()` — explicitly mark as request-time
- Comparing PPR in Next.js 15 (`ppr: true`) vs Cache Components in Next.js 16
- Debugging PPR with DevTools MCP

### Code splitting and advanced lazy loading (1.5h)

- Automatic code splitting per route — how it works in the App Router
- `dynamic()` — manual lazy loading of heavy components
- Strategic Suspense boundaries — what goes in which boundary
- Prefetching with `<Link prefetch={true|false}>`
- Incremental prefetching in Next.js 16 — layout deduplication
- Heavy third parties — load with `lazyOnload` strategy
- `React.lazy()` with Suspense in Client Components
- Reducing JavaScript payload — identifying components to split

### Runtime optimization (1h)

- React Compiler — when to enable it and when not to
- Automatic vs manual memoization (`useMemo`, `useCallback`, `memo`)
- Avoid unnecessary re-renders through correct composition
- Suspense to avoid waterfalls — render without blocking
- `next/third-parties` — official library to integrate Google Analytics, etc.
- Lighthouse CI — automate performance audits in CI

---

## Day 11 — Testing in Next.js

**Duration:** 6 hours

### Testing strategy for Next.js (0.5h)

- Testing pyramid: unit → integration → E2E
- What to test: Server Components, Client Components, Actions, Route Handlers
- Recommended tools: Vitest + Testing Library + Playwright
- Jest vs Vitest — Vitest is the modern choice (faster, native ESM)

### Vitest and React Testing Library (2h)

- Setup: `vitest` + `@testing-library/react` + `@testing-library/user-event`
- Configure `vitest.config.ts` for Next.js
- Testing Client Components — render, events, state
- Testing hooks with `renderHook`
- Mocking Next.js modules: `next/navigation`, `next/headers`, `next/image`
- Testing Server Components — limited, use integration tests
- Testing Server Actions — invoke directly with DB mocks
- Testing Route Handlers with a Request mock
- Snapshot testing — when it makes sense
- Coverage with v8 — recommended minimum thresholds

### Playwright — E2E Testing (2h)

- Setup with `npx create-playwright`
- Configure for Next.js — `webServer` in `playwright.config.ts`
- Writing E2E tests — navigation, forms, authentication
- Page Object Model (POM) — organize tests at scale
- Authentication in tests — `storageState` to reuse sessions
- Mocking APIs in Playwright with `route.fulfill()`
- Visual testing — screenshots and image comparison
- Testing across multiple browsers and mobile viewports
- Playwright CI — running in GitHub Actions
- Playwright Trace Viewer — debug failing tests

### Cypress (alternative) and advanced Testing Library (1h)

- When to choose Cypress vs Playwright
- Cypress Component Testing for Client Components
- Accessibility testing with `jest-axe` or `@axe-core/playwright`
- MSW (Mock Service Worker) — intercept fetch in tests
- Testing multi-step forms with Testing Library
- Continuous testing in development with watch mode

### Debugging in Next.js (0.5h)

- Next.js 16 DevTools MCP — connect AI to the dev server
- Improved logs in Next.js 16 — Compile time vs Render time
- Source maps in production — configure in `next.config.ts`
- Debugging Server Components in VS Code
- `next-logger` — structured logging on the server

---

## Day 12 — Internationalization (i18n) and Multi-tenancy

**Duration:** 6 hours

### i18n in the Next.js App Router (2.5h)

- The App Router has no built-in i18n — requires manual implementation or a library
- Route structure: `app/[lang]/page.tsx`
- Detect language in `proxy.ts` and redirect
- `next-intl` — the most popular i18n library for App Router in 2025
  - Setup: `createNextIntlPlugin` in `next.config.ts`
  - Message files: `messages/en.json`, `messages/es.json`
  - `useTranslations()` in Client Components
  - `getTranslations()` in Server Components and metadata
  - Localized links with `next-intl/link`
  - Date, number and currency formatting with next-intl
- Alternative: `next-i18next` (more compatible with Pages Router)
- Localized routes: `/en/about` vs `/es/acerca`
- `hreflang` in metadata for multilingual SEO
- Language selection — language switcher and persistence

### Multi-tenancy with Next.js (2h)

- Multi-tenant architecture — one deployment, multiple domains/subdomains
- Subdomain routing with `proxy.ts` — reading hostname and redirecting
- Wildcard DNS and multi-tenant SSL certificates
- Identifying the tenant from `proxy.ts` — extracting from hostname
- Passing tenant context to Server Components via headers
- DB per tenant vs schema per tenant vs row-level isolation
- Vercel multi-zones — multiple Next.js apps under one domain
- Custom domains — allowing users to add their own domains

### Feature flags and A/B testing (1.5h)

- Feature flags in `proxy.ts` — activate features by user/region/percentage
- Cookies to persist A/B test assignment
- Integration with LaunchDarkly, Vercel Feature Flags, Statsig
- Vercel Edge Config — configuration without redeploying
- Revalidate when a feature flag changes — `revalidateTag`
- Experiments with middleware — split traffic at the edge

---

## Day 13 — Deploy, CI/CD and Self-hosting

**Duration:** 6 hours

### Deploy on Vercel (1.5h)

- Connecting a GitHub repo to Vercel — basic configuration
- Environment variables in the Vercel dashboard
- Preview Deployments — each PR gets its own URL
- Vercel Edge Config — configuration without redeploying
- Vercel Blob, KV, Postgres — native services
- Vercel Cron Jobs — scheduled tasks with Route Handlers
- Custom domains and automatic HTTPS
- Instant rollbacks — revert to any deployment
- Vercel Analytics — built-in Web Vitals
- Hobby vs Pro plan limits — when to upgrade

### CI/CD with GitHub Actions (1.5h)

- Basic workflow: lint + test + build on every PR
- Dependency caching in GitHub Actions — `node_modules`, `.turbo`
- Playwright in CI — running E2E tests
- Turbopack File System Cache in CI — accelerate builds
- Environment secrets in GitHub Actions
- Automatic preview deploy on Vercel from GitHub Actions
- Branch protection rules — required checks before merging
- Semantic versioning and automatic changelog with `semantic-release`

### Self-hosting Next.js (2h)

- Output modes: standalone (Node server), static export, custom server
- Standalone output — Docker-ready, minimal dependencies
- Optimized Dockerfile for Next.js standalone
- Docker Compose — Next.js + PostgreSQL + Redis locally
- Environment variables in Docker
- Railway, Render, Fly.io — platforms with a free tier for Next.js
- VPS with PM2 — Node.js process management
- Nginx as a reverse proxy — SSL, gzip, security headers
- OpenNext — adapter for deployment on Cloudflare Workers, AWS Lambda
- Build Adapters API (alpha) in Next.js 16 — create custom adapters

### Monitoring and observability (1h)

- OpenTelemetry in Next.js — instrumentation with `instrumentation.ts`
- `instrumentation-client.ts` — client-side telemetry (Next.js 16)
- Sentry — error tracking for Next.js
- Datadog, New Relic — APM for large applications
- Structured logging with Pino or Winston on the server
- Health check endpoint with a Route Handler
- Alerts for Web Vitals degradation

---

## Day 14 — Advanced Architecture and Production Patterns

**Duration:** 6 hours

### Code architecture in Next.js (1.5h)

- Feature-based vs type-based folder structure — when to use each
- Barrel files (`index.ts`) — advantages and performance pitfalls
- Path aliases in `tsconfig.json` — `@/components`, `@/lib`, `@/server`
- Basic Domain-Driven Design in Next.js
- Clear separation: UI → Actions → Services → DAL → DB
- Colocation — keep code close to where it is used
- Shared components vs page-specific components
- `next/server` vs `next/client` — when to import each

### Turborepo and Monorepos (2h)

- When you need a monorepo
- Turborepo — setup with `create-turbo`
- Workspace structure: `apps/` and `packages/`
- `@repo/ui` package — shared components between apps
- `@repo/db` package — shared Drizzle/Prisma
- Task pipeline: `build`, `test`, `lint` with smart caching
- Turborepo Remote Cache — share cache between CI and local
- Multiple Next.js apps in one monorepo
- Deploying a monorepo on Vercel — configure root directory

### Advanced App Router patterns (1.5h)

- MDX in Next.js — technical blog with React components
  - `@next/mdx` or `next-mdx-remote`
  - `MDXComponents` — customize Markdown rendering
- Draft Mode — preview unpublished CMS content
- Headless CMS integration — Contentful, Sanity, Strapi with Next.js
- Incremental Migration — Pages Router to App Router gradually
- Static Exports — `next export` for serverless hosting
- PWA with Next.js — service worker, offline, manifest
- SPA mode in Next.js 16 — fully disable SSR

### Performance at scale (1h)

- Edge Runtime vs Node.js Runtime — when to use each
- Vercel Edge Functions — deploy in 40+ regions
- Redis / Upstash for external cache — session store, rate limiting
- CDN and stale-while-revalidate at the CDN level
- Database connection pooling in serverless — PgBouncer, Prisma Accelerate
- Reducing cold starts — optimize function bundle size

---

## Day 15 — AI Integration and Final Project

**Duration:** 6 hours

### Next.js with AI/LLMs (2h)

- Vercel AI SDK — the standard library for AI in Next.js
  - `useChat`, `useCompletion`, `useObject` — AI UI hooks
  - `streamText`, `streamObject` — streaming responses
  - Route Handlers as AI endpoints
- Streaming text with Server-Sent Events from a Route Handler
- OpenAI, Anthropic, Google Gemini — integration with the AI SDK
- File uploads for AI analysis — FormData + multipart
- Rate limiting AI endpoints
- Saving conversation history to the DB
- DevTools MCP — interact with AI from the Next.js dev server

### Real project patterns and review (2h)

- SaaS starter pattern — auth + billing + dashboard + onboarding
- E-commerce pattern — static catalog + dynamic cart + checkout
- Blog/CMS pattern — MDX or Headless CMS + ISR
- Dashboard pattern — real-time data + URL filters
- Portfolio pattern — Static Export + animations + contact form
- Full curriculum review — what to combine for each use case
- Recommended reading: official docs, Next.js changelog, RFC discussions
- Communities: Next.js Discord, Twitter/X #nextjs, GitHub Discussions

### Final review and next steps (2h)

- Key concept recap: rendering, caching, authentication, performance
- Production checklist — what you cannot forget before launching
  - Security headers, CSP, CORS, rate limiting
  - Error monitoring, logging, alerts
  - Database backups
  - Separate environment variables per environment
  - E2E tests in CI before every deploy
- How to stay up to date — follow the Vercel blog and the changelog
- Contributing to Next.js — reporting bugs, proposing RFCs
- Recommended resources: roadmap.sh, The Road to Next, nextjscourse.dev

---

## Quick Reference — Next.js 16 Terminology

| Concept                | Next.js 16                         | Previous version         |
| ---------------------- | ---------------------------------- | ------------------------ |
| Request interceptor    | `proxy.ts`                         | `middleware.ts`          |
| Caching                | Opt-in with `"use cache"`          | Implicit in `fetch`      |
| PPR                    | `cacheComponents: true`            | `experimental.ppr: true` |
| Immediate invalidation | `updateTag()`                      | Only `revalidateTag()`   |
| Default bundler        | Turbopack                          | Webpack                  |
| 401/403 pages          | `unauthorized.js` / `forbidden.js` | Did not exist            |
| Client telemetry       | `instrumentation-client.ts`        | Did not exist            |
| React version          | 19.2                               | 18.x / 19.0              |

## Official Resources

- Documentation: https://nextjs.org/docs
- Blog (changelogs): https://nextjs.org/blog
- GitHub: https://github.com/vercel/next.js
- Upgrade guide to v16: https://nextjs.org/docs/app/guides/upgrading/version-16
