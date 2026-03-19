// src/proxy.ts
import { type NextRequest } from "next/server";
import { updateSession } from "./utils/supabase/proxy";

export async function proxy(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    // Keep auth refresh away from the Neon smoke test while TLS is being verified.
    "/((?!_next/static|_next/image|favicon.ico|db-test|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
