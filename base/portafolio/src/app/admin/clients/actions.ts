"use server";

import { createAdminClient } from "@/utils/supabase/admin";
import { db } from "@/db/neon/client";
import { sql } from "drizzle-orm";
import generateRandomPassword from "@/utils/security/generateRandomPassword";

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
