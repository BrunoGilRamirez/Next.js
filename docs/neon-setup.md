# Neon Setup — Instructivo completo

## Requisitos previos
- Cuenta en [neon.tech](https://neon.tech) (free tier)
- Node.js 18+ instalado
- Proyecto Next.js inicializado

---

## Parte 1 — Configuración en Neon Console

### Paso 1: Crear el proyecto en Neon

1. Ve a [console.neon.tech](https://console.neon.tech) e inicia sesión
2. Click en **"New Project"**
3. Configura:
   - **Name:** `portfolio` (o el nombre que prefieras)
   - **Region:** elige la más cercana a tu ubicación (ej. `US East` o `EU Central`)
   - **PostgreSQL version:** `16`
4. Click en **"Create Project"**
5. Neon te mostrará tu connection string. **Cópiala y guárdala**, la necesitarás pronto:
   ```
   postgresql://[user]:[password]@[host]/[dbname]?sslmode=require
   ```

### Paso 2: Crear los branches

Neon maneja **branches** como Git — cada branch tiene su propia DB aislada.
Crea dos branches desde la consola:

1. En el panel izquierdo, click en **"Branches"**
2. El branch `main` ya existe — este será **producción**
3. Click en **"New Branch"**
   - **Name:** `development`
   - **Parent:** `main`
   - Click **"Create Branch"**

> Usa `development` para todo el trabajo local. `main` solo se toca en deploy.

### Paso 3: Obtener las connection strings por branch

1. En **Branches**, selecciona `development`
2. Click en **"Connection Details"**
3. Copia la connection string — esta es tu `DATABASE_URL` local
4. Repite para `main` — esta será tu `DATABASE_URL` en Vercel

---

## Parte 2 — Configuración en el proyecto Next.js

### Paso 4: Instalar dependencias

```bash
# Driver de PostgreSQL para Neon (serverless, optimizado para edge/serverless)
npm install @neondatabase/serverless

# Drizzle ORM + herramientas de migración
npm install drizzle-orm
npm install -D drizzle-kit
```

### Paso 5: Configurar variables de entorno

Crea o edita tu archivo `.env.local` en la raíz del proyecto:

```bash
# .env.local — NUNCA subir a Git
DATABASE_URL="postgresql://[user]:[password]@[host]/[dbname]?sslmode=require"
```

Verifica que `.env.local` esté en tu `.gitignore`:
```bash
# .gitignore
.env.local
.env*.local
```

### Paso 6: Configurar Drizzle

Crea el archivo `drizzle.config.ts` en la raíz del proyecto:

```typescript
// drizzle.config.ts
import type { Config } from 'drizzle-kit'

export default {
  schema: './src/db/schema',       // donde vivirán tus schemas
  out: './src/db/migrations',      // donde se guardan las migraciones
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
} satisfies Config
```

Crea el cliente de DB en `src/db/client.ts`:

```typescript
// src/db/client.ts
import { neon } from '@neondatabase/serverless'
import { drizzle } from 'drizzle-orm/neon-http'

// This file runs only on the server — never import from Client Components
const sql = neon(process.env.DATABASE_URL!)
export const db = drizzle(sql)
```

Agrega los scripts a `package.json`:

```json
{
  "scripts": {
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:studio": "drizzle-kit studio",
    "db:push": "drizzle-kit push"
  }
}
```

---

## Parte 3 — Roles y permisos en Neon (DB-level security)

### Paso 7: Crear un rol de aplicación en Neon

Neon te crea un rol por defecto (owner) con acceso total. Para producción,
la aplicación debe conectarse con un rol de **permisos mínimos** — solo lo
que necesita, nada más.

Conéctate a la consola SQL de Neon (panel **"SQL Editor"**) y ejecuta:

```sql
-- ─────────────────────────────────────────────────────────────
-- APPLICATION ROLE
-- This role is used by the Next.js app at runtime.
-- It has no DDL privileges (cannot CREATE/DROP/ALTER tables).
-- ─────────────────────────────────────────────────────────────

-- Create the role (replace 'app_user' and password as needed)
CREATE ROLE app_user WITH LOGIN PASSWORD 'your_strong_password_here';

-- Grant connection access to the database
GRANT CONNECT ON DATABASE neondb TO app_user;

-- Grant usage on the public schema
GRANT USAGE ON SCHEMA public TO app_user;

-- Grant only DML operations (SELECT, INSERT, UPDATE, DELETE)
-- on all current tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;

-- Ensure the same grants apply to future tables automatically
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

-- Grant usage on all sequences (needed for SERIAL / auto-increment PKs)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE ON SEQUENCES TO app_user;
```

Luego actualiza tu `DATABASE_URL` en `.env.local` para usar `app_user` en lugar
del owner. El owner solo lo usas para migraciones.

Agrega una segunda variable para migraciones:

```bash
# .env.local
DATABASE_URL="postgresql://app_user:your_password@[host]/[dbname]?sslmode=require"
DATABASE_URL_MIGRATION="postgresql://[owner]:[owner_password]@[host]/[dbname]?sslmode=require"
```

Y actualiza `drizzle.config.ts` para usar el owner en migraciones:

```typescript
// drizzle.config.ts
dbCredentials: {
  url: process.env.DATABASE_URL_MIGRATION!, // owner para DDL
}
```

---

## Parte 4 — DDL completo (ejecutar en orden)

Ejecuta este script completo en el **SQL Editor de Neon** (branch `development`).
Puedes pegarlo en un solo bloque — PostgreSQL respeta el orden de las sentencias.

```sql
-- ═══════════════════════════════════════════════════════════════
-- PORTFOLIO DATABASE — Full DDL
-- Target: Neon PostgreSQL 16 (development branch)
-- Run as: owner role
-- ═══════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────
-- 1. EXTENSIONS
-- ─────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ─────────────────────────────────────────────
-- 2. USER PROFILE
-- PK = UUID from Supabase auth.users.
-- No real FK across DBs — validation happens
-- in Next.js by reading the signed JWT.
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profile (
    id          UUID        PRIMARY KEY,
    company     VARCHAR(100),
    phone       VARCHAR(30),
    country     VARCHAR(60),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 3. ROLES
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS roles (
    id          SERIAL      PRIMARY KEY,
    role_name   VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO roles (role_name, description) VALUES
    ('admin',          'Full system access'),
    ('client',         'Access to assigned projects and private downloads'),
    ('viewer',         'Read-only access to public projects'),
    ('project_editor', 'Can create, edit, and delete projects'),
    ('blog_editor',    'Can create, edit, and delete blog posts');


-- ─────────────────────────────────────────────
-- 4. PERMISSIONS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS permissions (
    id          SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO permissions (name, description) VALUES
    ('download', 'Can generate signed URLs and download private resources'),
    ('preview',  'Can view public resources and project metadata'),
    ('manage',   'Can create, edit, and delete projects and resources');


-- ─────────────────────────────────────────────
-- 5. ROLES <-> PERMISSIONS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS roles_has_permissions (
    role_id       INT NOT NULL REFERENCES roles(id)       ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- admin gets all permissions
INSERT INTO roles_has_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_name = 'admin';

-- client gets download + preview
INSERT INTO roles_has_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_name = 'client' AND p.name IN ('download', 'preview');

-- viewer gets preview only
INSERT INTO roles_has_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_name = 'viewer' AND p.name = 'preview';

-- project_editor gets manage + preview
INSERT INTO roles_has_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_name = 'project_editor' AND p.name IN ('manage', 'preview');


-- ─────────────────────────────────────────────
-- 6. USER PROFILE <-> ROLES
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profile_has_roles (
    user_profile_id UUID NOT NULL REFERENCES user_profile(id) ON DELETE CASCADE,
    role_id         INT  NOT NULL REFERENCES roles(id)        ON DELETE CASCADE,
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_profile_id, role_id)
);


-- ─────────────────────────────────────────────
-- 7. PROJECTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(120) NOT NULL,
    slug            VARCHAR(120) NOT NULL UNIQUE,
    description     TEXT,
    tech_stack      JSONB,
    repository_link VARCHAR(500),
    thumbnail_ref   VARCHAR(500),
    is_publishable  BOOLEAN     NOT NULL DEFAULT FALSE,
    is_featured     BOOLEAN     NOT NULL DEFAULT FALSE,
    version         VARCHAR(30),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 8. PROJECT TAGS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS project_tags (
    id   SERIAL      PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS projects_has_tags (
    project_id UUID NOT NULL REFERENCES projects(id)      ON DELETE CASCADE,
    tag_id     INT  NOT NULL REFERENCES project_tags(id)  ON DELETE CASCADE,
    PRIMARY KEY (project_id, tag_id)
);


-- ─────────────────────────────────────────────
-- 9. LICENSE
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS license (
    id              SERIAL      PRIMARY KEY,
    user_profile_id UUID        NOT NULL REFERENCES user_profile(id) ON DELETE CASCADE,
    project_id      UUID        NOT NULL REFERENCES projects(id)     ON DELETE CASCADE,
    license_key     VARCHAR(100) NOT NULL UNIQUE DEFAULT gen_random_uuid()::TEXT,
    seats           INT         NOT NULL DEFAULT 1,
    issued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ,            -- NULL = no expiration
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE
);


-- ─────────────────────────────────────────────
-- 10. USER PROFILE <-> PROJECTS (access table)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profile_has_projects (
    user_profile_id UUID NOT NULL REFERENCES user_profile(id) ON DELETE CASCADE,
    project_id      UUID NOT NULL REFERENCES projects(id)     ON DELETE CASCADE,
    granted_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    license_id      INT         REFERENCES license(id)        ON DELETE SET NULL,
    PRIMARY KEY (user_profile_id, project_id)
);


-- ─────────────────────────────────────────────
-- 11. PUBLIC RESOURCES
-- (images, demos, docs — freely accessible)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects_public_resources (
    id              SERIAL       PRIMARY KEY,
    project_id      UUID         NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    storage_ref     VARCHAR(500) NOT NULL,
    resource_type   VARCHAR(30)  NOT NULL, -- 'image' | 'video' | 'doc' | 'demo'
    label           VARCHAR(120),
    file_size_bytes BIGINT,
    version         VARCHAR(30),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 12. PRIVATE RESOURCES
-- (installers, executables — signed URL only)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects_private_resources (
    id              SERIAL       PRIMARY KEY,
    project_id      UUID         NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    storage_ref     VARCHAR(500) NOT NULL, -- path in R2, NEVER a direct URL
    platform        VARCHAR(20)  NOT NULL DEFAULT 'all',
    label           VARCHAR(120),
    file_size_bytes BIGINT,
    checksum        VARCHAR(64),           -- SHA-256 for integrity verification
    version         VARCHAR(30),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 13. DOWNLOAD RECORD (audit log)
-- Store the event, never the signed URL.
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS download_record (
    id              SERIAL      PRIMARY KEY,
    user_profile_id UUID        NOT NULL REFERENCES user_profile(id)                 ON DELETE CASCADE,
    resource_id     INT         NOT NULL REFERENCES projects_private_resources(id)   ON DELETE CASCADE,
    ip_address      INET,
    user_agent      TEXT,
    requested_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL  -- when the generated signed URL expired
);


-- ─────────────────────────────────────────────
-- 14. NOTIFICATIONS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id              SERIAL      PRIMARY KEY,
    user_profile_id UUID        NOT NULL REFERENCES user_profile(id) ON DELETE CASCADE,
    project_id      UUID        REFERENCES projects(id)              ON DELETE SET NULL,
    type            VARCHAR(50) NOT NULL, -- 'new_version' | 'expiry_warning' | 'custom'
    message         TEXT        NOT NULL,
    is_read         BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    read_at         TIMESTAMPTZ
);


-- ─────────────────────────────────────────────
-- 15. INDEXES
-- ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_projects_slug
    ON projects(slug);

CREATE INDEX IF NOT EXISTS idx_projects_publishable
    ON projects(is_publishable) WHERE is_publishable = TRUE;

CREATE INDEX IF NOT EXISTS idx_projects_featured
    ON projects(is_featured) WHERE is_featured = TRUE;

CREATE INDEX IF NOT EXISTS idx_user_profile_has_projects_user
    ON user_profile_has_projects(user_profile_id);

CREATE INDEX IF NOT EXISTS idx_license_active
    ON license(user_profile_id, project_id) WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_download_record_user
    ON download_record(user_profile_id);

CREATE INDEX IF NOT EXISTS idx_download_record_resource
    ON download_record(resource_id);

CREATE INDEX IF NOT EXISTS idx_notifications_unread
    ON notifications(user_profile_id) WHERE is_read = FALSE;


-- ─────────────────────────────────────────────
-- 16. TRIGGER: auto-update updated_at
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_profile_updated_at
    BEFORE UPDATE ON user_profile
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_public_resources_updated_at
    BEFORE UPDATE ON projects_public_resources
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_private_resources_updated_at
    BEFORE UPDATE ON projects_private_resources
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ─────────────────────────────────────────────
-- 17. VERIFY — quick sanity check
-- Run after the DDL to confirm everything exists
-- ─────────────────────────────────────────────
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

---

## Parte 5 — Verificación

Después de ejecutar el DDL, corre estas queries para confirmar que todo quedó bien:

```sql
-- Verify tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Verify roles and their permissions
SELECT r.role_name, p.name AS permission
FROM roles r
JOIN roles_has_permissions rp ON r.id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
ORDER BY r.role_name, p.name;

-- Verify indexes
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Verify triggers
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;
```

Resultado esperado de la primera query — 12 tablas:

```
download_record
license
notifications
permissions
project_tags
projects
projects_has_tags
projects_private_resources
projects_public_resources
roles
roles_has_permissions
user_profile
user_profile_has_projects
user_profile_has_roles
```

---

## Parte 6 — Conectar desde Next.js (smoke test)

Una vez configurado, crea un Server Component temporal para verificar la conexión:

```typescript
// src/app/db-test/page.tsx
// DELETE THIS FILE before deploying to production
import { db } from '@/db/client'
import { sql } from 'drizzle-orm'

export default async function DbTestPage() {
  const result = await db.execute(sql`
    SELECT role_name, description FROM roles ORDER BY id
  `)

  return (
    <pre>{JSON.stringify(result.rows, null, 2)}</pre>
  )
}
```

Navega a `http://localhost:3000/db-test`. Si ves los roles listados, la conexión funciona.
Elimina este archivo antes de hacer deploy.

---

## Resumen de archivos creados

```
proyecto/
├── .env.local                  ← DATABASE_URL + DATABASE_URL_MIGRATION
├── drizzle.config.ts           ← configuración de Drizzle Kit
└── src/
    └── db/
        ├── client.ts           ← instancia del cliente Neon + Drizzle
        ├── schema/             ← schemas de Drizzle (próximo paso)
        └── migrations/         ← generado automáticamente por drizzle-kit
```
