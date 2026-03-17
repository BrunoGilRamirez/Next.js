"use server";

import { createAdminClient } from "../../../utils/supabase/admin";
import { db } from "../../../db/neon/client";
import { sql } from "drizzle-orm";

interface CreateClientInput {
  email: string;
  password: string;
  company?: string;
  country?: string;
}

export async function createClient(input: CreateClientInput) {
  const supabaseAdmin = createAdminClient();

  // 1. Create user in Supabase Auth with role in app_metadata
  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email: input.email,
    password: input.password,
    email_confirm: true,
    app_metadata: { role: "client" },
  });

  if (error || !data.user) {
    throw new Error(`Failed to create Supabase user: ${error?.message}`);
  }

  const userId = data.user.id; // UUID — this is the bridge to Neon

  // 2. Create user_profile in Neon with the same UUID
  await db.execute(sql`
    INSERT INTO user_profile (id, company, country)
    VALUES (${userId}, ${input.company ?? null}, ${input.country ?? null})
  `);

  // 3. Assign 'client' role in Neon
  await db.execute(sql`
    INSERT INTO user_profile_has_roles (user_profile_id, role_id)
    SELECT ${userId}, id FROM roles WHERE role_name = 'client'
  `);

  return { userId };
}
