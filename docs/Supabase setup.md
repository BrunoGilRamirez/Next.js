# Supabase Setup — Instructivo completo

## Contexto en esta arquitectura

Supabase cumple dos roles: **Auth** y **perfil de usuario**.

- `auth.users` — gestionado por Supabase, fuente de verdad de identidad y autenticación
- `public.profiles` — tabla propia con datos de contacto y rol, enlazada a `auth.users`
- Neon `user_profile` — ancla del UUID en el sistema de proyectos/descargas

El proyecto puede quedar pausado por inactividad — aceptable porque el portal
de clientes se usa pocas veces al año. El portafolio público (Neon) no depende
de Supabase para nada.

### Modelo de acceso

| Operación                                             | Admin (tú)                   | Cliente                      |
| ----------------------------------------------------- | ---------------------------- | ---------------------------- |
| INSERT — dar de alta                                  | ✅                           | ❌                           |
| SELECT — leer perfiles                                | Todos                        | Solo el suyo                 |
| UPDATE campos críticos (`email`, `role`)              | ✅                           | ❌                           |
| UPDATE campos propios (`company`, `phone`, `country`) | ✅                           | ✅                           |
| DELETE — dar de baja                                  | ✅                           | ❌                           |
| Reset de contraseña                                   | Dispara el email de recovery | Solo el usuario la establece |

---

## Parte 1 — Configuración en Supabase Dashboard

### Paso 1: Crear el proyecto

1. Ve a [database.new](https://database.new) e inicia sesión
2. Configura:
   - **Name:** `portfolio-auth`
   - **Database Password:** genera una contraseña fuerte y guárdala
   - **Region:** la más cercana a tu ubicación
3. Click en **"Create new project"**
4. Espera ~2 minutos mientras aprovisiona la instancia

### Paso 2: Obtener las credenciales

Ve al **Connect dialog** del proyecto (**Project → Connect → Frameworks → Next.js**)
y copia las variables directo a tu `.env.local`. O manualmente desde
**Project Settings → API Keys**:

| Variable                               | Dónde encontrarla              | Notas                                       |
| -------------------------------------- | ------------------------------ | ------------------------------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`             | Project URL                    |                                             |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | API Keys tab → Publishable key | `sb_publishable_xxx`, bajo privilegio       |
| `SUPABASE_SECRET_KEY`                  | API Keys tab → Secret key      | `sb_secret_xxx`, bypasea RLS, solo servidor |

### Paso 3: Configurar Auth — Email provider

Ve a **Authentication → Providers → Email**:

- Desactiva **"Confirm email"** durante desarrollo
- Activa **"Secure email change"** — requiere confirmación en el email nuevo antes de aplicar cambios
- Reactiva **"Confirm email"** antes de ir a producción

### Paso 4: Configurar URLs de redirección

Ve a **Authentication → URL Configuration**:

- **Site URL:** `http://localhost:3000`
- **Redirect URLs:**

  ```plain
  http://localhost:3000/**
  https://tu-dominio.vercel.app/**
  ```

### Paso 5: JWT expiration

Ve a **Authentication → JWT Settings**:

- **JWT expiry:** `3600` (1 hora)

---

## Parte 2 — DDL en Supabase

Ejecuta este script completo en el **SQL Editor** de Supabase.

```sql
-- ═══════════════════════════════════════════════════════════════
-- SUPABASE DDL
-- Run as: postgres (owner role) in the SQL Editor
-- ═══════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────
-- TABLE: profiles
-- One row per user, PK = auth.users.id.
-- email is stored here for easy querying but
-- auth.users is always the source of truth.
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
    id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       VARCHAR(255) NOT NULL,   -- mirrors auth.users.email, admin-only update
    role        VARCHAR(20)  NOT NULL DEFAULT 'client'
                             CHECK (role IN ('admin', 'client')),
    company     VARCHAR(100),
    phone       VARCHAR(30),
    country     VARCHAR(60),
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- TRIGGER: auto-update updated_at
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ─────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy 1: Admin reads all profiles
-- Checks role in raw_app_meta_data — written only by service role, safe to trust
CREATE POLICY "admin_read_all_profiles"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    );

-- Policy 2: Client reads only their own profile
CREATE POLICY "client_read_own_profile"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id
    );

-- Policy 3: Admin full write access (INSERT, UPDATE, DELETE)
-- Only reachable via service role in Server Actions — not from the client
CREATE POLICY "admin_full_write"
    ON public.profiles
    FOR ALL
    TO authenticated
    USING (
        (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    )
    WITH CHECK (
        (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    );

-- Policy 4: Client updates only their own non-critical fields
-- Critical fields (email, role, is_active) are enforced at the
-- application layer — the Server Action never includes them in
-- client-facing update operations.
CREATE POLICY "client_update_own_profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);


-- ─────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_email
    ON public.profiles(email);

CREATE INDEX IF NOT EXISTS idx_profiles_role
    ON public.profiles(role);

CREATE INDEX IF NOT EXISTS idx_profiles_active
    ON public.profiles(is_active) WHERE is_active = TRUE;


-- ─────────────────────────────────────────────
-- VERIFY
-- ─────────────────────────────────────────────
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'profiles';
-- Expected: profiles | t
```

---

## Parte 3 — Configuración en Next.js

### Paso 6: Instalar dependencias

```bash
npm install @supabase/supabase-js @supabase/ssr
```

### Paso 7: Variables de entorno

```bash
# .env.local — NUNCA subir a Git

# Neon
DATABASE_URL="postgresql://app_user:password@host/dbname?sslmode=require"
DATABASE_URL_MIGRATION="postgresql://owner:password@host/dbname?sslmode=require"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="https://xxxxxxxxxxxx.supabase.co"
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY="sb_publishable_xxxxxxxxxxxx"
SUPABASE_SECRET_KEY="eyJhbGci..."
```

### Paso 8: Crear los clientes de Supabase

**`src/lib/supabase/client.ts`** — Client Components

```typescript
// src/lib/supabase/client.ts
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
  );
}
```

**`src/lib/supabase/server.ts`** — Server Components, Server Actions, Route Handlers

```typescript
// src/lib/supabase/server.ts
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Called from a Server Component — expected, proxy handles refresh
          }
        },
      },
    },
  );
}
```

**`src/lib/supabase/proxy.ts`** — helper para el proxy

```typescript
// src/lib/supabase/proxy.ts
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // Validates JWT signature against Supabase public keys on every request.
  // Never use getSession() here — it does not revalidate the token.
  await supabase.auth.getClaims();

  return supabaseResponse;
}
```

**`src/lib/supabase/admin.ts`** — service role, solo servidor

```typescript
// src/lib/supabase/admin.ts
// Never import this from Client Components.
import { createClient } from "@supabase/supabase-js";

export function createAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SECRET_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}
```

### Paso 9: Proxy (Next.js 16)

```typescript
// src/proxy.ts
import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/proxy";

export async function proxy(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

---

## Parte 4 — Server Actions de gestión de usuarios

### Dar de alta un cliente

Crea el usuario en Supabase Auth, inserta su perfil en `public.profiles`,
y crea el `user_profile` en Neon — todo en una sola operación.
Si cualquier paso falla, se hace rollback manual.

```typescript
// src/app/admin/clients/actions.ts
"use server";

import { createAdminClient } from "@/lib/supabase/admin";
import { db } from "@/db/client";
import { sql } from "drizzle-orm";
import { generateRandomPassword } from "@/lib/utils";

interface CreateClientInput {
  email: string;
  company?: string;
  phone?: string;
  country?: string;
}

export async function createClientUser(input: CreateClientInput) {
  const supabaseAdmin = createAdminClient();

  // Generate a temporary password — client will reset it on first login
  const tempPassword = generateRandomPassword();

  // 1. Create user in Supabase Auth
  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email: input.email,
    password: tempPassword,
    email_confirm: true, // skip email confirmation
    app_metadata: { role: "client" }, // written to raw_app_meta_data in DB
  });

  if (error || !data.user) {
    throw new Error(`Supabase user creation failed: ${error?.message}`);
  }

  const userId = data.user.id; // UUID — bridge between Supabase and Neon

  try {
    // 2. Insert profile in Supabase public.profiles
    await supabaseAdmin.from("profiles").insert({
      id: userId,
      email: input.email,
      role: "client",
      company: input.company ?? null,
      phone: input.phone ?? null,
      country: input.country ?? null,
    });

    // 3. Create user_profile in Neon with the same UUID
    await db.execute(sql`
      INSERT INTO user_profile (id, company, country)
      VALUES (${userId}, ${input.company ?? null}, ${input.country ?? null})
    `);

    // 4. Assign 'client' role in Neon
    await db.execute(sql`
      INSERT INTO user_profile_has_roles (user_profile_id, role_id)
      SELECT ${userId}, id FROM roles WHERE role_name = 'client'
    `);
  } catch (err) {
    // Rollback: delete Supabase user if downstream operations fail
    await supabaseAdmin.auth.admin.deleteUser(userId);
    throw new Error(`User creation rollback triggered: ${err}`);
  }

  // 5. Force password reset email — client sets their own password
  await supabaseAdmin.auth.resetPasswordForEmail(input.email);

  return { userId, tempPassword };
}
```

### Dar de baja un cliente

```typescript
// Deactivate a client — sets is_active = false and disables Auth access
export async function deactivateClientUser(userId: string) {
  const supabaseAdmin = createAdminClient();

  // 1. Ban user in Supabase Auth — blocks login immediately
  const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
    ban_duration: "none", // 'none' = permanent ban
  });

  if (error) throw new Error(`Failed to ban user: ${error.message}`);

  // 2. Mark as inactive in profiles
  await supabaseAdmin
    .from("profiles")
    .update({ is_active: false })
    .eq("id", userId);

  // 3. Optionally mark as inactive in Neon too
  // (if you add an is_active field to user_profile in Neon)
}
```

### Forzar reset de contraseña

```typescript
// Trigger a password reset email — user sets their own new password.
// You never see or set the password directly.
export async function forcePasswordReset(email: string) {
  const supabaseAdmin = createAdminClient();

  const { error } = await supabaseAdmin.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/portal/reset-password`,
  });

  if (error) throw new Error(`Failed to send reset email: ${error.message}`);
}
```

### Actualización de perfil por el cliente

El cliente solo puede tocar `company`, `phone`, y `country`.
`email`, `role`, e `is_active` nunca aparecen en esta acción.

```typescript
// src/app/portal/profile/actions.ts
"use server";

import { createClient } from "@/lib/supabase/server";

interface UpdateProfileInput {
  company?: string;
  phone?: string;
  country?: string;
}

export async function updateOwnProfile(input: UpdateProfileInput) {
  const supabase = await createClient();

  // getClaims() validates the JWT — safe to trust
  const {
    data: { claims },
  } = await supabase.auth.getClaims();
  if (!claims) throw new Error("Unauthorized");

  // RLS policy "client_update_own_profile" enforces auth.uid() = id
  // on the DB side — this is a second layer of protection
  const { error } = await supabase
    .from("profiles")
    .update({
      company: input.company,
      phone: input.phone,
      country: input.country,
    })
    .eq("id", claims.sub);

  if (error) throw new Error(`Profile update failed: ${error.message}`);
}
```

---

## Parte 5 — SQL de administración (solo SQL Editor)

Para operaciones manuales puntuales desde el dashboard:

```sql
-- Assign or correct role for an existing user
-- raw_app_meta_data in SQL = app_metadata in the SDK and JWT
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'),
  '{role}',
  '"client"'
)
WHERE email = 'cliente@example.com';

-- Verify user + profile are in sync
SELECT
  u.id,
  u.email,
  u.raw_app_meta_data->>'role'  AS auth_role,
  p.role                         AS profile_role,
  p.company,
  p.is_active,
  u.last_sign_in_at
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE u.email = 'cliente@example.com';
```

> `auth.users` solo es accesible desde el SQL Editor con credenciales de owner.
> Nunca crees vistas sobre `auth.users` en el schema `public` — PostgREST
> lo expone a los roles `anon` y `authenticated`.

---

## Parte 6 — Verificación

### Smoke test de auth + perfil

```typescript
// src/app/auth-test/page.tsx
// DELETE THIS FILE before deploying to production
import { createClient } from '@/lib/supabase/server'

export default async function AuthTestPage() {
  const supabase = await createClient()
  const { data: { claims } } = await supabase.auth.getClaims()

  if (!claims) return <div>Not authenticated</div>

  // Fetch own profile — RLS ensures only own row is returned
  const { data: profile } = await supabase
    .from('profiles')
    .select('email, role, company, country, is_active')
    .eq('id', claims.sub)
    .single()

  return (
    <pre>{JSON.stringify({ claims, profile }, null, 2)}</pre>
  )
}
```

---

## Resumen de archivos

```plain
src/
├── proxy.ts                              ← session refresh + route protection
├── lib/
│   └── supabase/
│       ├── client.ts                     ← browser client (Client Components)
│       ├── server.ts                     ← server client (Server Components / Actions)
│       ├── proxy.ts                      ← updateSession helper
│       └── admin.ts                      ← service role (server-only)
└── app/
    ├── admin/clients/actions.ts          ← createClientUser, deactivateClientUser
    └── portal/profile/actions.ts         ← updateOwnProfile
```

## Sincronización Supabase ↔ Neon — reglas de consistencia

```plain
CREATE user   → Supabase Auth + public.profiles + Neon user_profile (en una sola Server Action)
UPDATE perfil → Supabase public.profiles (admin o cliente según campo)
               → Neon user_profile (si los campos coinciden, actualizar también)
DEACTIVATE    → Supabase Auth ban + profiles.is_active = false
               → Neon: opcional, depende de si agregas is_active a user_profile
DELETE        → Supabase auth.users (CASCADE elimina public.profiles automáticamente)
               → Neon user_profile: eliminar manualmente en la misma Server Action
```
