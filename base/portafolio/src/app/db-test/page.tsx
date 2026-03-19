// src/app/db-test/page.tsx
// DELETE THIS FILE before deploying to production
import { db } from "@/db/neon/client";
import { sql } from "drizzle-orm";

export const dynamic = "force-dynamic";

export default async function DbTestPage() {
  let response_message = undefined;
  try {
    const result = await db.execute(sql`
      SELECT role_name, description FROM roles ORDER BY id
    `);
    response_message = JSON.stringify(result.rows, null, 2);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unknown database error";
    response_message = JSON.stringify(
      {
        ok: false,
        source: "neon-http",
        reason: "Database connection failed before the SQL query completed.",
        hint: "Review local TLS/certificate trust for Node.js or corporate proxy interception.",
        message,
      },
      null,
      2,
    );
  }
  return <pre>{response_message}</pre>;
}
