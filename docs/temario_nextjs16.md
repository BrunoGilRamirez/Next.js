# Next.js 16 — Temario Completo: de Cero a Maestro

> **Versión objetivo:** Next.js 16.x · React 19.2 · Node 20.9+  
> **Estructura:** 15 días · 90 horas · 6 horas por jornada  
> **Prerrequisitos del estudiante:** JavaScript, TypeScript, React, Node.js con Express  
> **Fecha de actualización:** Octubre 2025 (basado en documentación oficial de Next.js 16)

---

## Contexto para el agente

Este documento es el temario de aprendizaje de Next.js 16 del estudiante. Úsalo como referencia para:

- Saber en qué día y tema está trabajando actualmente
- Contextualizar preguntas técnicas dentro del nivel de avance esperado
- Sugerir el siguiente tema cuando el estudiante termina uno
- Detectar si una pregunta corresponde a un tema de días futuros y aclararlo
- Usar la terminología correcta de Next.js 16 (ej: `proxy.ts` en lugar de `middleware.ts`, `use cache` en lugar de caching implícito)

### Cambios clave de Next.js 16 a tener en cuenta

- `middleware.ts` fue reemplazado por `proxy.ts` (Node.js runtime). `middleware.ts` sigue disponible para Edge runtime pero está deprecado.
- El caching es **100% opt-in** con la directiva `"use cache"`. Ya no hay caching implícito como en v14/v15.
- **Cache Components** + **Partial Pre-Rendering (PPR)** se habilitan con `cacheComponents: true` en `next.config.ts`.
- **Turbopack** es el bundler por defecto para todos los proyectos nuevos.
- **React Compiler** está estable e integrado (opt-in).
- **React 19.2** incluye View Transitions, `useEffectEvent()`, y el componente `<Activity>`.
- `forbidden()` y `unauthorized()` son nuevas funciones, con sus archivos especiales `forbidden.js` y `unauthorized.js`.
- `instrumentation-client.ts` es nuevo para telemetría en el cliente.
- `updateTag()` es una nueva API exclusiva de Server Actions para invalidación de caché (read-your-writes pattern).

---

## Mapa de fases

| Días  | Fase                             | Temas principales                              |
| ----- | -------------------------------- | ---------------------------------------------- |
| 01–03 | Fundamentos y arquitectura       | App Router, rendering, data fetching           |
| 04–06 | Full Stack con Next.js           | Server Actions, Route Handlers, bases de datos |
| 07–09 | UI, estilos, SEO y autenticación | Tailwind, animaciones, Auth.js v5, proxy.ts    |
| 10–11 | Caching avanzado y performance   | Cache Components, PPR, Turbopack, testing      |
| 12–13 | i18n, deploy y CI/CD             | next-intl, Vercel, Docker, GitHub Actions      |
| 14–15 | Arquitectura avanzada e IA       | Turborepos, patrones de producción, AI SDK     |

---

## Día 1 — Arquitectura de Next.js 16 y App Router

**Duración:** 6 horas

### Setup y herramientas (1h)

- Instalación con `create-next-app@latest` (Turbopack activado por defecto)
- Opciones del CLI: `--typescript`, `--tailwind`, `--app`, `--src-dir`
- Estructura de carpetas: `app/`, `public/`, `src/` (opcional)
- `next.config.ts` — configuración con TypeScript nativo (nuevo en v16)
- Comandos: `next dev`, `next build`, `next start`, `next lint`
- Variables de entorno: `.env.local`, `.env.production`, prefijo `NEXT_PUBLIC_`
- DevTools MCP: configuración para debugging asistido por IA

### File Conventions — archivos especiales del App Router (1.5h)

- `page.tsx` — define una ruta pública accesible
- `layout.tsx` — layout compartido y layouts anidados (no se re-monta)
- `template.tsx` — igual que layout pero sí se re-monta (cuándo usarlo)
- `loading.tsx` — Suspense automático con skeleton UI
- `error.tsx` — error boundary por ruta con botón de retry
- `not-found.tsx` — página 404 personalizada por ruta
- `default.tsx` — fallback para Parallel Routes
- `route.ts` — Route Handler (API endpoint dentro del App Router)
- `proxy.ts` — reemplaza a `middleware.ts` en Next.js 16 (Node.js runtime)
- Archivos de metadata: `favicon.ico`, `opengraph-image`, `robots.txt`, `sitemap.xml`

### Sistema de enrutamiento completo (2h)

- Rutas estáticas: `app/about/page.tsx` → `/about`
- Rutas dinámicas: `[slug]`, `[id]` — acceso con `params`
- Rutas dinámicas opcionales: `[[...slug]]`
- Catch-all routes: `[...slug]` — captura múltiples segmentos
- Route Groups: `(carpeta)` — organiza sin afectar la URL
- Route Groups para múltiples layouts raíz
- Parallel Routes: `@folder` — renderizar múltiples páginas en un layout
- Intercepting Routes: `(.)` `(..)` `(...)` — modales con URL propia
- Componente `<Link>` — navegación, prefetching automático
- Prefetching incremental en Next.js 16 (layout deduplication)
- `useRouter()` — navegación programática desde Client Components
- `usePathname()`, `useParams()`, `useSearchParams()`
- `redirect()` y `permanentRedirect()` desde Server Components
- `notFound()` — lanzar 404 desde código

### Server Components vs Client Components (1.5h)

- Modelo mental: todo es Server Component por defecto
- Directiva `"use client"` — cuándo y por qué agregarla
- Directiva `"use server"` — Server Actions y funciones de servidor
- Qué puede hacer cada tipo: acceso a DB, hooks, eventos, estado
- Reglas de composición: pasar Server Components como `children`
- Patrón: Client Component wrapper + Server Component como `children`
- `import 'server-only'` — prevenir imports accidentales en cliente
- Boundary de serialización: qué datos se pueden pasar entre límites
- React Compiler en Next.js 16 — memoización automática (opt-in)

---

## Día 2 — Data Fetching y Estrategias de Rendering

**Duración:** 6 horas

### Fetching de datos en Server Components (2h)

- `async/await` directo en `page.tsx` y `layout.tsx` (sin `useEffect`)
- `fetch` nativo extendido por Next.js — cache y revalidación integrada
- Fetching en paralelo con `Promise.all` y `Promise.allSettled`
- Fetching secuencial vs paralelo — cuándo usar cada uno
- Deduplicación automática de requests con `React.cache()`
- Pasar datos entre Server Components con props vs `React.cache`
- Fetching desde archivos JSON/locales (útil para portafolios y CMS simples)
- SWR y React Query para fetching en Client Components

### Estrategias de rendering (1.5h)

- Static Rendering — generado en build time (default sin datos dinámicos)
- Dynamic Rendering — generado en cada request
- Streaming con Suspense — cargar partes de la UI progresivamente
- Partial Pre-Rendering (PPR) — estático + dinámico en la misma página
- `generateStaticParams` — pre-renderizar rutas dinámicas en build time
- `dynamicParams: true/false` — comportamiento con slugs no pre-generados
- `force-dynamic`, `force-static` en Route Segment Config
- `connection()` — forzar render en request time (Next.js 16)

### Caching en Next.js 16 (2h)

- Caching es **100% opt-in** en Next.js 16 (ya no implícito)
- Directiva `"use cache"` — cachear páginas, componentes y funciones
  - `"use cache"` en `page.tsx` — caching a nivel de ruta completa
  - `"use cache"` en componente async — caching granular
  - `"use cache"` en función — cachear resultados de funciones costosas
- Cache keys automáticas — el compilador las genera basado en argumentos
- `cacheLife()` — definir tiempo de vida del caché (perfiles: `'seconds'`, `'minutes'`, `'hours'`, `'days'`, `'weeks'`, `'max'`)
- `cacheTag()` — etiquetar entradas de caché para invalidación
- `revalidatePath(path)` — invalidar caché de una ruta
- `revalidateTag(tag)` — invalidar por etiqueta (stale-while-revalidate)
- `updateTag()` — nueva API exclusiva de Server Actions (read-your-writes)
- ISR (Incremental Static Regeneration) con `cacheLife`
- Habilitar Cache Components: `cacheComponents: true` en `next.config.ts`
- `<Activity>` component — preservar estado entre navegaciones

### Manejo de errores y estados (0.5h)

- `error.tsx` con `useError()` para acceder al error
- Boundary de errores anidados — errores capturados al nivel más cercano
- Errores en layouts vs errores en pages
- `forbidden()` y `unauthorized()` — nuevas funciones de Next.js 16
- `forbidden.js` y `unauthorized.js` — páginas especiales para 401/403

---

## Día 3 — Full Stack: Server Actions y Route Handlers

**Duración:** 6 horas

### Server Actions (2.5h)

- Qué son las Server Actions y cómo funcionan internamente
- Declarar con directiva `"use server"` — inline vs archivo separado
- Formularios con Server Actions — `action={serverFn}` sin `onSubmit`
- Componente `<Form>` de Next.js (`next/form`) — prefetching automático
- `useActionState` (React 19) — estado, pending, error del action
- `useFormStatus` — estado de pending en componentes hijo
- Validación en servidor con Zod o validación manual
- Manejo de errores: return de objetos error vs throw
- Redirigir después de un action con `redirect()`
- Revalidar caché después de mutaciones: `revalidatePath`, `revalidateTag`, `updateTag`
- Seguridad: Server Actions son endpoints POST — siempre validar y autenticar
- Progressive enhancement — formularios funcionan sin JS
- Server Actions en Client Components — import desde archivo `"use server"`

### Route Handlers (1.5h)

- Crear `route.ts`: `export function GET/POST/PUT/DELETE/PATCH`
- `NextRequest` y `NextResponse` — leer headers, cookies, body, searchParams
- Cuándo usar Route Handler vs Server Action vs backend Express
- Route Handlers con Cache Components en Next.js 16
- Streaming responses con `ReadableStream`
- CORS en Route Handlers — headers manuales
- Rate limiting básico en Route Handlers
- Webhooks con Route Handlers — verificar signatures

### Base de datos y ORM (1.5h)

- Opciones de DB serverless gratuitas: Neon, Supabase, PlanetScale, Turso
- Conectar Neon (PostgreSQL) directamente desde Server Components
- **Drizzle ORM** — setup, schema, migraciones (opción ligera recomendada)
- **Prisma ORM** — setup, schema, Prisma Client en Next.js
- Data Access Layer (DAL) — separar lógica de DB del componente
- Service Layer — lógica de negocio entre Actions y DAL
- Evitar DB queries en Client Components — `import 'server-only'`
- Flujo completo: form → Server Action → DAL → DB → revalidate → UI

### Variables de entorno y seguridad de datos (0.5h)

- Jerarquía: `.env`, `.env.local`, `.env.development`, `.env.production`
- Variables públicas `NEXT_PUBLIC_` — disponibles en cliente
- Variables privadas — solo accesibles en servidor
- Validar variables de entorno en runtime con Zod
- Data Transfer Objects (DTOs) — nunca exponer el modelo de DB directo

---

## Día 4 — Estilos, UI y Optimización de Assets

**Duración:** 6 horas

### Tailwind CSS en Next.js 16 (1.5h)

- Tailwind v4 integrado — configuración en `globals.css` (sin `tailwind.config.js`)
- `@theme` en CSS — definir design tokens personalizados
- Utility classes esenciales — layout, tipografía, colores, spacing
- Responsive design con breakpoints de Tailwind
- Dark mode con `dark:` prefix y `next-themes`
- `clsx` y `cn()` — clases condicionales
- Tailwind Merge (`twMerge`) — evitar conflictos de clases
- `shadcn/ui` — componentes sin estilos propios sobre Radix UI

### CSS Modules y otras opciones de estilos (0.5h)

- CSS Modules — scope por componente (`.module.css`)
- Sass con Next.js — instalación y uso
- CSS-in-JS en App Router — limitaciones con Server Components
- styled-components y emotion en modo client-only

### Optimización de imágenes y fuentes (1.5h)

- Componente `<Image>` de `next/image` — obligatorio conocerlo
  - Props: `src`, `alt`, `width`, `height`, `fill`, `priority`
  - Lazy loading automático, formatos WebP/AVIF
  - Imágenes remotas — configurar `remotePatterns` en `next.config.ts`
  - Aspect ratio con `fill` + posición
  - Placeholder blur con `blurDataURL`
- `next/font` — fuentes sin layout shift (CLS cero)
  - Google Fonts: Inter, Geist — cargado en build time
  - Fuentes locales con `localFont()`
  - Variable fonts y CSS variables
- Nuevos defaults de `next/image` en Next.js 16 (breaking change)

### Scripts y lazy loading (0.5h)

- Componente `<Script>` — estrategias: `beforeInteractive`, `afterInteractive`, `lazyOnload`
- `dynamic()` de `next/dynamic` — lazy loading de Client Components
  - `ssr: false` para componentes que requieren `window`/`document`
  - Suspense con `dynamic()` — loading UI
- Lazy loading de librerías pesadas

### Animaciones en Next.js (1.5h)

- View Transitions API — integración nativa en React 19.2
- Framer Motion con Next.js — instalación y patrones con App Router
  - `AnimatePresence` para transiciones de página
  - `useReducedMotion` — accesibilidad
- React Spring — alternativa a Framer Motion
- CSS animations con Tailwind: `animate-*`, `transition-*`
- GSAP con Next.js — uso en Client Components

---

## Día 5 — Autenticación y Autorización con Auth.js v5

**Duración:** 6 horas

### Conceptos base de autenticación (0.5h)

- Autenticación vs Autorización — diferencias y capas
- Estrategias: JWT vs Session-based — cuándo usar cada una
- OAuth 2.0 — flujo básico (GitHub, Google como proveedores)
- Credentials provider — email/password custom
- Opciones del ecosistema: Auth.js v5, Clerk, Supabase Auth, Lucia

### Auth.js v5 (NextAuth.js v5) — setup completo (2h)

- Instalación y diferencias clave respecto a v4
- Archivo `auth.ts` — configuración central con `NextAuth()`
- Archivo `auth.config.ts` — config sin dependencias de adapter (para `proxy.ts`)
- Exportar: `auth`, `handlers`, `signIn`, `signOut`
- Route Handler en `app/api/auth/[...nextauth]/route.ts`
- Variables de entorno: `AUTH_SECRET` (obligatoria), `AUTH_URL` (opcional)
- Auto-inferencia de variables: `AUTH_GITHUB_ID`, `AUTH_GITHUB_SECRET`
- Proveedores OAuth: GitHub, Google — configuración
- Credentials provider — validación custom con `authorize()`
- Callbacks: `jwt()`, `session()`, `signIn()`, `redirect()`
- Extender el tipo `Session` con TypeScript
- Database adapter con Drizzle o Prisma

### Protección de rutas con proxy.ts (1.5h)

- `proxy.ts` — el nuevo middleware de Next.js 16 (Node.js runtime)
- Integrar Auth.js con `proxy.ts` — export de `auth` como `proxy`
- `matcher` config — qué rutas proteger
- Redirección a `/login` si no hay sesión
- Distinción entre rutas públicas y protegidas
- `authorized` callback en `auth.config.ts`
- Proteger Route Handlers con `auth()` server-side
- Proteger Server Actions — verificar sesión antes de operar
- Proteger Server Components con `auth()` en el componente

### Autorización basada en roles (RBAC) (1h)

- Añadir campo `role` al token JWT y a la sesión
- Verificar rol en `proxy.ts` para rutas de admin
- Data Access Layer (DAL) con verificación de autorización
- DTOs que filtran campos según el rol del usuario
- Patrón: optimistic vs pessimistic authorization

### Sesiones y seguridad (1h)

- Estrategia JWT vs Database sessions — configuración
- Expiración de sesión y refresh token rotation
- Cookies: `httpOnly`, `secure`, `sameSite` — configuración
- CSRF — cómo Auth.js lo maneja automáticamente
- Rate limiting en rutas de login con `proxy.ts`
- Verificación de email con Email provider
- `signIn()` y `signOut()` desde Client Components
- `useSession()` — estado de sesión en el cliente

---

## Día 6 — State Management y Patrones Avanzados de React

**Duración:** 6 horas

### Estado del servidor vs estado del cliente (1h)

- URL como estado — `searchParams` para estado compartible
- `useSearchParams()` para leer, `router.push` para actualizar
- `nuqs` — librería para sincronizar estado con URL params
- Cuándo necesitas realmente estado global del cliente
- Context API en App Router — solo en Client Components
- Provider pattern con Server Components como `children`

### Zustand — state management ligero (1h)

- Instalación y setup básico
- Stores — crear y acceder desde cualquier Client Component
- Slices pattern para stores grandes
- Persistencia con `zustand/middleware` persist
- Integración con Server Actions — actualizar store después de mutación
- Hidratación SSR — zustand en Next.js App Router

### React Query / TanStack Query (1.5h)

- Cuándo usar React Query vs fetch directo en Server Components
- Setup: `QueryClient`, `QueryClientProvider` en layout
- `useQuery` — fetching con cache, loading, error states
- `useMutation` — mutaciones con `onSuccess`, `onError`
- Invalidación de caché con `queryClient.invalidateQueries()`
- Prefetching en Server Components con `dehydrate`/`HydrationBoundary`
- Optimistic updates con `useMutation`
- Infinite scroll con `useInfiniteQuery`

### Formularios avanzados (1.5h)

- React Hook Form + Zod — validación type-safe
- Integrar RHF con Server Actions
- `useActionState` para feedback de Server Actions
- Formularios multi-step con estado persistido
- File uploads — FormData con Server Actions
- Subida de archivos a servicios externos (Cloudinary, Uploadthing, S3)
- Validación client-side + server-side con el mismo schema Zod

### Hooks y patrones avanzados de React 19 (1h)

- `use()` — leer promesas y contexto en Client Components
- `useOptimistic()` — UI optimista antes de confirmar la mutación
- `useEffectEvent()` — nuevo en React 19.2 (stable)
- `<Activity>` component — preservar estado de rutas ocultas (Next.js 16)
- Composición avanzada: Compound Components, Render Props en App Router
- Patrón Container/Presenter con Server y Client Components

---

## Día 7 — SEO, Metadata y Accesibilidad

**Duración:** 6 horas

### Metadata API completa (2h)

- Objeto `metadata` estático — exportado desde `page.tsx` y `layout.tsx`
- `generateMetadata()` — metadata dinámica con datos async
- Herencia y merge de metadata — layouts → pages
- `title: string` vs `title: { template, default, absolute }`
- `description`, `keywords`, `authors`, `creator`, `publisher`
- Open Graph: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`
- Twitter/X Cards: `card`, `site`, `creator`, `images`
- `generateViewport()` — viewport, themeColor, colorScheme
- `alternates` — canonical URLs, hreflang para i18n
- `robots` — index/noindex, follow/nofollow por página
- `manifest.json` — PWA manifest
- JSON-LD con `next/script` para datos estructurados (schema.org)

### Imágenes OG dinámicas (1h)

- `opengraph-image.tsx` — archivo especial para imagen OG dinámica
- `ImageResponse` de `next/og` — renderizar React → imagen PNG
- Dimensiones recomendadas: 1200x630
- Fuentes en `ImageResponse` — cargar desde Google Fonts
- `generateImageMetadata` — múltiples variantes de imagen OG
- `twitter-image.tsx` — imagen específica para Twitter

### Sitemap, robots y archivos de metadata (1h)

- `sitemap.ts` — generar sitemap dinámico con `generateSitemaps()`
- `robots.ts` — configurar reglas de crawling
- Sitemap para rutas dinámicas — generar URLs de productos/posts
- Múltiples sitemaps con `generateSitemaps` para sitios grandes
- `favicon.ico`, `icon.png`, `apple-icon.png` — convenciones de archivos
- `manifest.ts` — configurar PWA manifest desde código

### Accesibilidad (a11y) en Next.js (1h)

- Route announcements — Next.js anuncia cambios de ruta a lectores de pantalla
- Focus management — gestionar foco en navegación programática
- Imágenes: alt text obligatorio, decorativas con `alt=""`
- Headings hierarchy — estructura semántica correcta
- ARIA attributes — cuándo y cómo usarlos
- Contraste de color — mínimos WCAG 2.1
- Keyboard navigation — focus visible, tab order
- `eslint-plugin-jsx-a11y` — detectar problemas en desarrollo

### Core Web Vitals y performance (1h)

- LCP (Largest Contentful Paint) — optimizar imagen principal
- CLS (Cumulative Layout Shift) — `next/font`, dimensiones de imágenes
- INP (Interaction to Next Paint) — reemplaza a FID
- TTFB (Time to First Byte) — caching y edge deployment
- `useReportWebVitals` — enviar métricas a analytics
- PageSpeed Insights y Lighthouse en Next.js
- Bundle analyzer — `next-bundle-analyzer` para detectar bloat

---

## Día 8 — proxy.ts, Seguridad y Patrones Avanzados de Routing

**Duración:** 6 horas

### proxy.ts en profundidad (2h)

- `proxy.ts` vs `middleware.ts` — diferencias en Next.js 16
- Runtime: Node.js (`proxy.ts`) vs Edge (`middleware.ts` deprecado)
- Anatomía: `export default function proxy(request: NextRequest)`
- `NextRequest` — leer URL, headers, cookies, geo, IP
- `NextResponse` — redirect, rewrite, next, json con headers
- `matcher` config — patrones con regex para seleccionar rutas
- Casos de uso: auth guard, A/B testing, i18n redirect, feature flags
- Redirecciones condicionales según headers (User-Agent, Accept-Language)
- Modificar headers en requests/responses
- Leer y escribir cookies en `proxy.ts`
- Chaining de lógica — múltiples verificaciones en un proxy
- Rate limiting con contadores en headers o Redis

### Parallel Routes y Intercepting Routes (2h)

- Parallel Routes (`@folder`) — cuándo tiene sentido usarlos
  - Caso de uso: dashboard con múltiples secciones independientes
  - `loading.tsx` y `error.tsx` independientes por slot
  - `default.tsx` — qué mostrar cuando el slot no tiene ruta activa
- Intercepting Routes — modales con URL propia
  - `(.)` — interceptar en el mismo nivel
  - `(..)` — interceptar un nivel arriba
  - `(...)` — interceptar desde la raíz
- Patrón modal: abrir `/photos/[id]` como modal sobre `/feed`
- Preservar el modal en el historial del navegador
- Combinar Parallel + Intercepting Routes para galerías

### Redirects y rewrites en next.config.ts (1h)

- `redirects()` — permanentes (308) y temporales (307)
- `rewrites()` — proxy transparente a otros dominios/paths
- Rewrites para migración gradual desde otra plataforma
- `headers()` — añadir headers HTTP globales (CORS, CSP, HSTS)
- Content Security Policy (CSP) básico con nonce
- `basePath` — subpath deployment (`/app/...`)
- `trailingSlash` — consistencia de URLs

### Seguridad en Next.js (1h)

- Server Actions — validar siempre entrada y sesión
- SQL Injection — usar ORM o queries parametrizadas
- XSS — Next.js escapa automáticamente en JSX
- SSRF — validar URLs en fetch server-side
- Exposed environment variables — `NEXT_PUBLIC_` vs privadas
- Dependency security — `npm audit` regularmente
- Secretos en `server-only` — `import 'server-only'`
- `next/headers` — cookies y headers seguros en servidor

---

## Día 9 — Integración con APIs Externas y Servicios

**Duración:** 6 horas

### Patrones de integración con APIs externas (1.5h)

- Backend for Frontend (BFF) — Next.js como capa de agregación
- Llamadas a APIs REST desde Server Components — sin exponer tokens
- Proxy de API en Route Handlers — reenviar requests al backend
- Autenticar requests externos con headers de autorización
- Manejo de errores HTTP — status codes, timeouts, retries
- Transformación de datos entre API externa y UI
- Caching de respuestas externas con `"use cache"` + `cacheLife`

### Bases de datos y ORM avanzado (1.5h)

- Drizzle ORM avanzado — relaciones, joins, transacciones
- Migrations con `drizzle-kit`
- Prisma — relaciones, middleware, transacciones
- Prisma Accelerate — connection pooling para serverless
- Supabase — PostgreSQL + Auth + Storage + Realtime
- Row Level Security (RLS) en Supabase
- Turso (SQLite en edge) — casos de uso
- MongoDB con Mongoose desde Server Components

### Almacenamiento de archivos (1h)

- Uploadthing — la opción más integrada con Next.js
- Cloudinary — transformaciones de imágenes en la nube
- AWS S3 con presigned URLs — upload directo desde cliente
- Vercel Blob — almacenamiento nativo de Vercel
- Validar tipo y tamaño de archivo en servidor

### Email y notificaciones (1h)

- Resend — el servicio de email recomendado para Next.js 2025
- React Email — templates de email con componentes React
- Enviar email desde Server Actions o Route Handlers
- Transaccional vs marketing — diferencias
- Webhook de email — procesar respuestas y bounces

### Tiempo real en Next.js (1h)

- Server-Sent Events (SSE) con Route Handlers — streaming unidireccional
- WebSockets — limitaciones en serverless, soluciones: Pusher, Ably, Soketi
- Supabase Realtime — suscripciones en tiempo real
- Polling inteligente vs WebSockets — cuándo usar cada uno
- Vercel AI SDK — streaming de respuestas de IA

---

## Día 10 — Performance Avanzada y Turbopack

**Duración:** 6 horas

### Turbopack en profundidad (1.5h)

- Turbopack vs Webpack — diferencias arquitectónicas
- Turbopack estable en Next.js 16 — activado por defecto
- Turbopack File System Caching (beta) — startup persistente entre reinicios
  - Habilitar: `experimental.turbopackFileSystemCacheForDev: true`
- Compatibilidad con plugins de Webpack — cuáles soporta Turbopack
- `turbopack.resolveAlias` — reemplazar módulos Node.js en cliente
- Forzar Webpack: `next dev --webpack` / `next build --webpack`
- Bundle analyzer con Turbopack
- Logging de build mejorado en Next.js 16 — Compile vs Render timing

### Cache Components y PPR avanzado (2h)

- Partial Pre-Rendering (PPR) — arquitectura completa
- Static shell + dynamic holes — cómo funciona internamente
- Habilitar: `cacheComponents: true` en `next.config.ts`
- Uncached data outside `<Suspense>` — error en dev/build y cómo resolverlo
- `"use cache"` en Server Components — distintos niveles de granularidad
- Cache boundaries — cómo el compilador determina los límites
- `React.cache()` dentro de `"use cache"` — aislamiento de scope
- Pasar promesas como props desde estático a dinámico
- Compartir datos con context en PPR
- `connection()` — marcar explícitamente como request-time
- Comparar PPR Next.js 15 (`ppr: true`) vs Cache Components Next.js 16
- Depurar PPR con DevTools MCP

### Code splitting y lazy loading avanzado (1.5h)

- Automatic code splitting por ruta — cómo funciona en App Router
- `dynamic()` — lazy loading manual de componentes pesados
- Suspense boundaries estratégicos — qué va en qué boundary
- Prefetching con `<Link prefetch={true|false}>`
- Prefetching incremental en Next.js 16 — layout deduplication
- Terceros pesados — cargar con estrategia `lazyOnload`
- `React.lazy()` con Suspense en Client Components
- Reducing JavaScript payload — identificar componentes a dividir

### Optimización de runtime (1h)

- React Compiler — cuándo activarlo y cuándo no
- Memoización automática vs manual (`useMemo`, `useCallback`, `memo`)
- Evitar re-renders innecesarios con composición correcta
- Suspense para evitar waterfalls — renderizar sin bloquear
- `next/third-parties` — librería oficial para integrar Google Analytics, etc.
- Lighthouse CI — automatizar auditorías de performance en CI

---

## Día 11 — Testing en Next.js

**Duración:** 6 horas

### Estrategia de testing para Next.js (0.5h)

- Pirámide de tests: unitarios → integración → E2E
- Qué testear: Server Components, Client Components, Actions, Route Handlers
- Herramientas recomendadas: Vitest + Testing Library + Playwright
- Jest vs Vitest — Vitest es la opción moderna (más rápido, ESM nativo)

### Vitest y React Testing Library (2h)

- Setup: `vitest` + `@testing-library/react` + `@testing-library/user-event`
- Configurar `vitest.config.ts` para Next.js
- Testear Client Components — render, eventos, estado
- Testear hooks con `renderHook`
- Mockear módulos de Next.js: `next/navigation`, `next/headers`, `next/image`
- Testear Server Components — limitado, usar integración
- Testear Server Actions — invocar directamente con mocks de DB
- Testear Route Handlers con Request mock
- Snapshot testing — cuándo tiene sentido
- Coverage con v8 — umbrales mínimos recomendados

### Playwright — E2E Testing (2h)

- Setup con `npx create-playwright`
- Configurar para Next.js — `webServer` en `playwright.config.ts`
- Escribir tests E2E — navegación, formularios, autenticación
- Page Object Model (POM) — organizar tests a escala
- Autenticación en tests — `storageState` para reutilizar sesión
- Mockear APIs en Playwright con `route.fulfill()`
- Visual testing — screenshots y comparación de imágenes
- Test en múltiples browsers y mobile viewports
- Playwright CI — correr en GitHub Actions
- Playwright Trace Viewer — debuggear tests fallidos

### Cypress (alternativa) y Testing Library avanzado (1h)

- Cuándo elegir Cypress vs Playwright
- Cypress Component Testing para Client Components
- Accessibility testing con `jest-axe` o `@axe-core/playwright`
- MSW (Mock Service Worker) — interceptar fetch en tests
- Testing de formularios multi-step con Testing Library
- Continuous testing en desarrollo con watch mode

### Debugging en Next.js (0.5h)

- DevTools MCP de Next.js 16 — conectar IA al servidor de desarrollo
- Logs mejorados en Next.js 16 — Compile time vs Render time
- Source maps en producción — configurar en `next.config.ts`
- Debuggear Server Components en VS Code
- `next-logger` — logging estructurado en servidor

---

## Día 12 — Internacionalización (i18n) y Multi-tenant

**Duración:** 6 horas

### i18n en Next.js App Router (2.5h)

- App Router no tiene i18n built-in — necesita implementación manual o librería
- Estructura de rutas: `app/[lang]/page.tsx`
- Detectar idioma en `proxy.ts` y redirigir
- `next-intl` — la librería i18n más popular para App Router 2025
  - Setup: `createNextIntlPlugin` en `next.config.ts`
  - Archivos de mensajes: `messages/en.json`, `messages/es.json`
  - `useTranslations()` en Client Components
  - `getTranslations()` en Server Components y metadata
  - Link localizado con `next-intl/link`
  - Formateo de fechas, números y monedas con next-intl
- Alternativa: `next-i18next` (más compatible con Pages Router)
- Rutas localizadas: `/en/about` vs `/es/acerca`
- `hreflang` en metadata para SEO multilingüe
- Selección de idioma — switcher de idioma y persistencia

### Multi-tenant con Next.js (2h)

- Arquitectura multi-tenant — un deployment, múltiples dominios/subdomains
- Subdomain routing con `proxy.ts` — leer hostname y redirigir
- Wildcard DNS y certificados SSL multi-tenant
- Identificar tenant desde `proxy.ts` — extraer desde hostname
- Pasar tenant context a Server Components vía headers
- Base de datos por tenant vs schema por tenant vs row-level isolation
- Vercel multi-zones — múltiples Next.js apps bajo un dominio
- Custom domains — permitir que usuarios agreguen sus dominios

### Feature flags y A/B testing (1.5h)

- Feature flags en `proxy.ts` — activar features por usuario/región/porcentaje
- Cookies para persistir assignment de A/B test
- Integración con LaunchDarkly, Vercel Feature Flags, Statsig
- Edge Config de Vercel — configuración sin redeploy
- Revalidar cuando cambia un feature flag — `revalidateTag`
- Experiments con middleware — split traffic en el edge

---

## Día 13 — Deploy, CI/CD y Self-hosting

**Duración:** 6 horas

### Deploy en Vercel (1.5h)

- Conectar repo GitHub a Vercel — configuración básica
- Variables de entorno en Vercel dashboard
- Preview Deployments — cada PR tiene su propio URL
- Vercel Edge Config — config sin redeploy
- Vercel Blob, KV, Postgres — servicios nativos
- Vercel Cron Jobs — tareas programadas con Route Handlers
- Dominios custom y HTTPS automático
- Rollbacks instantáneos — volver a cualquier deployment
- Analytics de Vercel — Web Vitals integrados
- Límites del plan Hobby vs Pro — cuándo pagar

### CI/CD con GitHub Actions (1.5h)

- Workflow básico: lint + test + build en cada PR
- Caché de dependencias en GitHub Actions — `node_modules`, `.turbo`
- Playwright en CI — correr E2E con Playwright
- Turbopack File System Cache en CI — accelerate builds
- Environment secrets en GitHub Actions
- Deploy preview automático en Vercel desde GitHub Actions
- Branch protection rules — required checks antes de merge
- Semantic versioning y changelog automático con `semantic-release`

### Self-hosting de Next.js (2h)

- Output modes: standalone (servidor Node), static export, custom server
- Standalone output — Docker-ready, mínimas dependencias
- Dockerfile optimizado para Next.js standalone
- Docker Compose — Next.js + PostgreSQL + Redis local
- Variables de entorno en Docker
- Railway, Render, Fly.io — plataformas con tier gratuito para Next.js
- VPS con PM2 — gestión de procesos Node.js
- Nginx como reverse proxy — SSL, gzip, headers de seguridad
- OpenNext — adaptador para deploy en Cloudflare Workers, AWS Lambda
- Build Adapters API (alpha) en Next.js 16 — crear adaptadores custom

### Monitoreo y observabilidad (1h)

- OpenTelemetry en Next.js — instrumentación con `instrumentation.ts`
- `instrumentation-client.ts` — telemetría en el cliente (Next.js 16)
- Sentry — error tracking para Next.js
- Datadog, New Relic — APM para aplicaciones grandes
- Logging estructurado con Pino o Winston en servidor
- Health check endpoint con Route Handler
- Alertas por degradación de Web Vitals

---

## Día 14 — Arquitectura Avanzada y Patrones de Producción

**Duración:** 6 horas

### Arquitectura de código en Next.js (1.5h)

- Feature-based folder structure vs type-based — cuándo usar cada una
- Barrel files (`index.ts`) — ventajas y problemas de performance
- Path aliases en `tsconfig.json` — `@/components`, `@/lib`, `@/server`
- Domain-Driven Design básico en Next.js
- Separación clara: UI → Actions → Services → DAL → DB
- Colocation — poner código cerca de donde se usa
- Shared components vs page-specific components
- `next/server` vs `next/client` — cuándo importar cada uno

### Turborepo y Monorepos (2h)

- Cuándo necesitas un monorepo
- Turborepo — setup con `create-turbo`
- Workspace structure: `apps/` y `packages/`
- Paquete `@repo/ui` — componentes compartidos entre apps
- Paquete `@repo/db` — Drizzle/Prisma compartido
- Pipeline de tareas: `build`, `test`, `lint` con caché inteligente
- Turborepo Remote Cache — compartir caché entre CI y local
- Múltiples apps Next.js en un monorepo
- Deploying monorepo en Vercel — configurar root directory

### Patrones avanzados del App Router (1.5h)

- MDX en Next.js — blog técnico con componentes React
  - `@next/mdx` o `next-mdx-remote`
  - `MDXComponents` — personalizar rendering de Markdown
- Draft Mode — previsualizar contenido no publicado de CMS
- Headless CMS integration — Contentful, Sanity, Strapi con Next.js
- Incremental Migration — Pages Router a App Router gradualmente
- Static Exports — `next export` para hosting sin servidor
- PWA con Next.js — service worker, offline, manifest
- SPA mode en Next.js 16 — deshabilitar SSR completamente

### Rendimiento a escala (1h)

- Edge Runtime vs Node.js Runtime — cuándo usar cada uno
- Vercel Edge Functions — deploy en más de 40 regiones
- Redis / Upstash para caché externo — session store, rate limiting
- CDN y stale-while-revalidate a nivel de CDN
- Database connection pooling en serverless — PgBouncer, Prisma Accelerate
- Reducir cold starts — optimizar tamaño de bundle de funciones

---

## Día 15 — Integración con IA y Proyecto Final

**Duración:** 6 horas

### Next.js con AI/LLMs (2h)

- Vercel AI SDK — la librería estándar para IA en Next.js
  - `useChat`, `useCompletion`, `useObject` — hooks para UI de IA
  - `streamText`, `streamObject` — streaming de respuestas
  - Route Handlers como AI endpoints
- Streaming de texto con Server-Sent Events desde Route Handler
- OpenAI, Anthropic, Google Gemini — integración con AI SDK
- File uploads para análisis con IA — FormData + multipart
- Rate limiting de endpoints de IA
- Guardar historial de conversación en DB
- DevTools MCP — interactuar con IA desde el servidor de Next.js

### Patrones de proyecto real y revisión (2h)

- SaaS starter pattern — auth + billing + dashboard + onboarding
- E-commerce pattern — catálogo estático + carrito dinámico + checkout
- Blog/CMS pattern — MDX o Headless CMS + ISR
- Dashboard pattern — datos en tiempo real + filtros en URL
- Portafolio pattern — Static Export + animaciones + contacto
- Revisión de todo el temario — qué combinar para cada caso de uso
- Lecturas recomendadas: docs oficiales, changelog de Next.js, RFC discussions
- Comunidades: Next.js Discord, Twitter/X #nextjs, GitHub Discussions

### Revisión final y next steps (2h)

- Repaso de conceptos clave: renderizado, caching, autenticación, performance
- Checklist de producción — lo que no se puede olvidar antes de lanzar
  - Security headers, CSP, CORS, rate limiting
  - Error monitoring, logging, alertas
  - Backup de base de datos
  - Variables de entorno separadas por ambiente
  - Tests E2E en CI antes de cada deploy
- Cómo mantenerse actualizado — seguir el blog de Vercel y el changelog
- Contribuir a Next.js — reportar bugs, proponer RFCs
- Recursos recomendados: roadmap.sh, The Road to Next, nextjscourse.dev

---

## Referencia rápida — Terminología Next.js 16

| Concepto                | Next.js 16                         | Versión anterior         |
| ----------------------- | ---------------------------------- | ------------------------ |
| Interceptor de requests | `proxy.ts`                         | `middleware.ts`          |
| Caching                 | Opt-in con `"use cache"`           | Implícito en `fetch`     |
| PPR                     | `cacheComponents: true`            | `experimental.ppr: true` |
| Invalidación inmediata  | `updateTag()`                      | Solo `revalidateTag()`   |
| Bundler por defecto     | Turbopack                          | Webpack                  |
| Páginas 401/403         | `unauthorized.js` / `forbidden.js` | No existían              |
| Telemetría cliente      | `instrumentation-client.ts`        | No existía               |
| React                   | 19.2                               | 18.x / 19.0              |

## Recursos oficiales

- Documentación: https://nextjs.org/docs
- Blog (changelogs): https://nextjs.org/blog
- GitHub: https://github.com/vercel/next.js
- Guía de upgrade a v16: https://nextjs.org/docs/app/guides/upgrading/version-16
