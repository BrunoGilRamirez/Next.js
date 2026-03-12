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