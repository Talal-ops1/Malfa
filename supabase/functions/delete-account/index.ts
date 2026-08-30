import { createClient } from "npm:@supabase/supabase-js@2.112.4";

const url = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
const allowedOrigins = new Set(["https://malfaapp.vercel.app", "http://localhost:4173", "http://127.0.0.1:4173"]);
function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return { ...(allowedOrigins.has(origin) ? { "Access-Control-Allow-Origin": origin } : {}),
    "Access-Control-Allow-Headers": "authorization, apikey, content-type", "Access-Control-Allow-Methods": "POST, OPTIONS", "Vary": "Origin" };
}
function json(req: Request, body: unknown, status: number) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors(req), "Content-Type": "application/json", "Cache-Control": "no-store" } });
}
async function removeFolder(bucket: string, prefix: string) {
  const { data } = await admin.storage.from(bucket).list(prefix, { limit: 1000 });
  if (!data?.length) return;
  const files = data.filter((item) => item.id).map((item) => `${prefix}/${item.name}`);
  if (files.length) await admin.storage.from(bucket).remove(files);
  for (const folder of data.filter((item) => !item.id)) await removeFolder(bucket, `${prefix}/${folder.name}`);
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin") || "";
  if (origin && !allowedOrigins.has(origin)) return json(req, { error: "forbidden" }, 403);
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST" || Number(req.headers.get("content-length") || 0) > 256) return json(req, { error: "invalid_request" }, 400);
  const jwt = (req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "");
  const { data, error } = await admin.auth.getUser(jwt);
  if (error || !data.user) return json(req, { error: "unauthorized" }, 401);
  let confirmation = ""; try { confirmation = (await req.json())?.confirmation || ""; } catch { /* generic failure */ }
  if (confirmation !== "حذف") return json(req, { error: "invalid_confirmation" }, 400);
  const { data: profile } = await admin.from("profiles").select("is_admin").eq("id", data.user.id).maybeSingle();
  if (profile?.is_admin) return json(req, { error: "admin_account_requires_operator" }, 403);
  const deletion = await admin.auth.admin.deleteUser(data.user.id, false);
  if (deletion.error) return json(req, { error: "delete_failed" }, 500);
  // Auth deletion cascades the user's database rows first. Private media is
  // then removed with the service role so a transient Auth failure can never
  // leave an otherwise-active account with missing books or recordings.
  await Promise.all([removeFolder("book-covers", data.user.id), removeFolder("journey-audio", data.user.id)]);
  return json(req, { deleted: true }, 200);
});
