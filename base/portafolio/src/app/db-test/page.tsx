// src/app/db-test/page.tsx
// DELETE THIS FILE before deploying to production
import { db } from "@/db/client";
import { sql } from "drizzle-orm";

export default async function DbTestPage() {
  const result = await db.execute(sql`
    SELECT role_name, description FROM roles ORDER BY id
  `);

  return <pre>{JSON.stringify(result.rows, null, 2)}</pre>;
}
