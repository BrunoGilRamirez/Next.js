import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";

function enableInsecureLocalTlsIfRequested() {
  const allowInsecureTls =
    process.env.NODE_ENV !== "production" &&
    process.env.NEON_ALLOW_INSECURE_LOCAL_TLS === "true";

  if (allowInsecureTls) {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
  }
}

function getNeonHttpConnectionString() {
  const connectionString = process.env.DATABASE_URL;

  if (!connectionString) {
    throw new Error("DATABASE_URL is not configured");
  }

  const url = new URL(connectionString);

  // `channel_binding` is relevant for direct Postgres connections, but it does
  // not help the HTTP driver used by `neon()` and can complicate local TLS diagnostics.
  //url.searchParams.delete("channel_binding");

  return url.toString();
}

enableInsecureLocalTlsIfRequested();
const sql = neon(getNeonHttpConnectionString());
export const db = drizzle(sql);
