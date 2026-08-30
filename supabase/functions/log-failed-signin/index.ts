import { createClient } from "npm:@supabase/supabase-js@2.112.4";

const url = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const hashSecret = Deno.env.get("AUDIT_HASH_SECRET") || serviceKey;
const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
const allowedOrigins = new Set(["https://malfaapp.vercel.app", "http://localhost:4173", "http://127.0.0.1:4173"]);

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    ...(allowedOrigins.has(origin) ? { "Access-Control-Allow-Origin": origin } : {}),
    "Access-Control-Allow-Headers": "content-type, apikey",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
}
function empty(req: Request, status = 204) {
  return new Response(null, { status, headers: { ...cors(req), "Cache-Control": "no-store" } });
}
async function fingerprint(value: string) {
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(hashSecret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(value)));
  return Array.from(sig).map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function findUserIdByEmail(email: string) {
  const perPage = 200;
  for (let page = 1; page <= 50; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage });
    if (error) return null;
    const match = data.users.find((candidate) => candidate.email?.toLowerCase() === email);
    if (match) return match.id;
    if (data.users.length < perPage) return null;
  }
  return null;
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin") || "";
  if (origin && !allowedOrigins.has(origin)) return empty(req, 403);
  if (req.method === "OPTIONS") return empty(req);
  if (req.method !== "POST" || Number(req.headers.get("content-length") || 0) > 512) return empty(req);

  let email = "";
  try {
    const body = await req.json();
    email = typeof body?.email === "string" ? body.email.trim().toLowerCase() : "";
  } catch { return empty(req); }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) return empty(req);

  const forwarded = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim();
  const ip = forwarded || req.headers.get("cf-connecting-ip") || "unknown";
  const [emailHash, ipHash] = await Promise.all([fingerprint(email), fingerprint(ip)]);
  const since = new Date(Date.now() - 15 * 60 * 1000).toISOString();
  const [{ count: emailCount }, { count: ipCount }] = await Promise.all([
    admin.from("failed_login_attempts").select("id", { count: "exact", head: true }).eq("email_fingerprint", emailHash).gte("created_at", since),
    admin.from("failed_login_attempts").select("id", { count: "exact", head: true }).eq("ip_fingerprint", ipHash).gte("created_at", since),
  ]);
  if ((emailCount || 0) >= 5 || (ipCount || 0) >= 30) return empty(req);

  await admin.from("failed_login_attempts").insert({ email_fingerprint: emailHash, ip_fingerprint: ipHash });
  const userId = await findUserIdByEmail(email);
  if (userId) await admin.from("auth_events").insert({ user_id: userId, event_type: "sign_in_failed", status: "failed", failure_reason: "invalid_credentials" });
  return empty(req);
});
