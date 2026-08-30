import { createClient } from "npm:@supabase/supabase-js@2.112.4";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const allowedOrigins = new Set([
  "https://malfaappl.vercel.app",
  "http://localhost:4173",
  "http://127.0.0.1:4173",
]);

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    ...(allowedOrigins.has(origin) ? { "Access-Control-Allow-Origin": origin } : {}),
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Vary": "Origin",
  };
}

function json(req: Request, body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors(req), "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
  });
}

async function requireAdmin(req: Request) {
  const authHeader = req.headers.get("Authorization") || "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "");
  if (!jwt) return { error: json(req, { error: "unauthorized" }, 401) };

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData?.user) return { error: json(req, { error: "unauthorized" }, 401) };

  const { data: profile, error: profErr } = await admin
    .from("profiles")
    .select("id,is_admin,name")
    .eq("id", userData.user.id)
    .single();
  if (profErr || !profile?.is_admin) return { error: json(req, { error: "forbidden" }, 403) };

  return { user: userData.user, profile };
}

function startOfDayUTC(d = new Date()) {
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate())).toISOString();
}
function startOfMonthUTC(d = new Date()) {
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), 1)).toISOString();
}
function minusDays(n: number) {
  return new Date(Date.now() - n * 86400000).toISOString();
}
function boundedInt(value: string | null, fallback: number, min: number, max: number) {
  const parsed = Number.parseInt(value || "", 10);
  return Number.isFinite(parsed) ? Math.min(max, Math.max(min, parsed)) : fallback;
}
function oneOf(value: string | null, allowed: readonly string[], fallback = "") {
  return value && allowed.includes(value) ? value : fallback;
}
function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

async function allAuthUsers() {
  const users: any[] = [];
  const perPage = 200;
  for (let page = 1; page <= 500; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage });
    if (error) throw error;
    users.push(...data.users);
    if (data.users.length < perPage) return users;
  }
  throw new Error("user_page_limit");
}

async function actionStats() {
  const users = await allAuthUsers();
  const { data: profiles } = await admin.from("profiles").select("id,last_seen_at");
  const profileById = new Map((profiles || []).map((p: any) => [p.id, p]));

  const today = startOfDayUTC();
  const monthStart = startOfMonthUTC();
  const activeThreshold = new Date(Date.now() - 5 * 60000).toISOString(); // "active now" = seen in last 5 min
  const inactive7 = minusDays(7);

  let activeNow = 0, newToday = 0, newMonth = 0, inactive7d = 0;
  for (const u of users) {
    const p = profileById.get(u.id);
    if (p?.last_seen_at && p.last_seen_at >= activeThreshold) activeNow++;
    if (u.created_at >= today) newToday++;
    if (u.created_at >= monthStart) newMonth++;
    if (!p?.last_seen_at || p.last_seen_at < inactive7d) inactive7d++;
  }

  const { count: signinsToday } = await admin
    .from("auth_events")
    .select("id", { count: "exact", head: true })
    .eq("event_type", "sign_in")
    .eq("status", "success")
    .gte("created_at", today);

  const { count: failedToday } = await admin
    .from("auth_events")
    .select("id", { count: "exact", head: true })
    .eq("event_type", "sign_in_failed")
    .gte("created_at", today);

  const { count: paidUsers } = await admin
    .from("user_plans")
    .select("id", { count: "exact", head: true })
    .eq("status", "active");

  // growth: signups per day, last 14 days
  const since = minusDays(13);
  const growthBuckets: Record<string, number> = {};
  for (let i = 0; i < 14; i++) {
    const d = new Date(Date.now() - i * 86400000);
    growthBuckets[d.toISOString().slice(0, 10)] = 0;
  }
  for (const u of users) {
    if (u.created_at >= since) {
      const day = u.created_at.slice(0, 10);
      if (day in growthBuckets) growthBuckets[day]++;
    }
  }
  const growth = Object.keys(growthBuckets).sort().map((day) => ({ day, count: growthBuckets[day] }));

  return {
    total_users: users.length,
    active_now: activeNow,
    active_now_window_minutes: 5,
    new_today: newToday,
    new_month: newMonth,
    free_users: users.length - (paidUsers || 0),
    paid_users: paidUsers || 0,
    signins_today: signinsToday || 0,
    failed_signins_today: failedToday || 0,
    inactive_7d: inactive7d,
    growth,
    has_plans_configured: (await admin.from("plans").select("id", { count: "exact", head: true })).count! > 0,
  };
}

async function actionUsers(params: URLSearchParams) {
  const page = boundedInt(params.get("page"), 1, 1, 100000);
  const perPage = boundedInt(params.get("per_page"), 25, 1, 100);
  const search = (params.get("search") || "").trim().toLowerCase().slice(0, 80);
  const filter = oneOf(params.get("filter"), ["active_now","online_recently","free","paid","trial","expired","suspended","never_signed_in","inactive_7","inactive_14","inactive_30"]);
  const sort = oneOf(params.get("sort"), ["created_desc","name_asc","last_seen_desc"], "created_desc");

  const users = await allAuthUsers();
  const { data: profiles } = await admin.from("profiles").select("id,name,is_admin,last_seen_at");
  const profileById = new Map((profiles || []).map((p: any) => [p.id, p]));

  const { data: userPlans } = await admin.from("user_plans").select("user_id,status,plan_id").eq("status", "active");
  const planByUser = new Map((userPlans || []).map((p: any) => [p.user_id, p]));

  const activeThreshold = new Date(Date.now() - 5 * 60000).toISOString();
  const dayAgo = minusDays(1);

  let rows = users.map((u: any) => {
    const p = profileById.get(u.id);
    const plan = planByUser.get(u.id);
    return {
      id: u.id,
      name: p?.name || "",
      email: u.email,
      phone: u.phone || null,
      created_at: u.created_at,
      last_sign_in_at: u.last_sign_in_at || null,
      last_seen_at: p?.last_seen_at || null,
      is_online: !!(p?.last_seen_at && p.last_seen_at >= activeThreshold),
      is_admin: !!p?.is_admin,
      account_status: u.banned_until && new Date(u.banned_until) > new Date() ? "suspended" : "active",
      plan_status: plan ? plan.status : "free",
      auth_method: u.app_metadata?.provider || "email",
    };
  });

  if (search) {
    rows = rows.filter((r) => r.name.toLowerCase().includes(search) || (r.email || "").toLowerCase().includes(search));
  }
  if (filter === "active_now") rows = rows.filter((r) => r.is_online);
  else if (filter === "online_recently") rows = rows.filter((r) => r.last_seen_at && r.last_seen_at >= dayAgo);
  else if (filter === "free") rows = rows.filter((r) => r.plan_status === "free");
  else if (filter === "paid") rows = rows.filter((r) => r.plan_status === "active");
  else if (filter === "trial") rows = rows.filter((r) => r.plan_status === "trial");
  else if (filter === "expired") rows = rows.filter((r) => r.plan_status === "expired");
  else if (filter === "suspended") rows = rows.filter((r) => r.account_status === "suspended");
  else if (filter === "never_signed_in") rows = rows.filter((r) => !r.last_sign_in_at);
  else if (filter === "inactive_7") rows = rows.filter((r) => !r.last_seen_at || r.last_seen_at < minusDays(7));
  else if (filter === "inactive_14") rows = rows.filter((r) => !r.last_seen_at || r.last_seen_at < minusDays(14));
  else if (filter === "inactive_30") rows = rows.filter((r) => !r.last_seen_at || r.last_seen_at < minusDays(30));

  rows.sort((a, b) => {
    if (sort === "name_asc") return a.name.localeCompare(b.name, "ar");
    if (sort === "last_seen_desc") return (b.last_seen_at || "").localeCompare(a.last_seen_at || "");
    return (b.created_at || "").localeCompare(a.created_at || ""); // created_desc default
  });

  const total = rows.length;
  const start = (page - 1) * perPage;
  const pageRows = rows.slice(start, start + perPage);

  return { rows: pageRows, total, page, per_page: perPage };
}

async function actionUserDetail(userId: string) {
  const { data: authUser, error } = await admin.auth.admin.getUserById(userId);
  if (error || !authUser?.user) return null;
  const u = authUser.user;

  const { data: profile } = await admin.from("profiles").select("*").eq("id", userId).single();
  const { data: plans } = await admin
    .from("user_plans")
    .select("*, plans(name)")
    .eq("user_id", userId)
    .order("start_date", { ascending: false });
  const { data: events } = await admin
    .from("auth_events")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(50);
  const { count: libraryCount } = await admin
    .from("library_entries")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId);

  return {
    id: u.id,
    name: profile?.name || "",
    email: u.email,
    phone: u.phone || null,
    created_at: u.created_at,
    last_sign_in_at: u.last_sign_in_at || null,
    last_seen_at: profile?.last_seen_at || null,
    is_admin: !!profile?.is_admin,
    auth_method: u.app_metadata?.provider || "email",
    library_book_count: libraryCount || 0,
    plans: plans || [],
    events: events || [],
  };
}

async function actionEvents(params: URLSearchParams) {
  const page = boundedInt(params.get("page"), 1, 1, 100000);
  const perPage = boundedInt(params.get("per_page"), 30, 1, 100);
  const eventType = oneOf(params.get("event_type"), ["sign_in","sign_in_failed","sign_out","register","password_reset","session_expired","plan_change","account_suspended","account_reactivated"]);
  const search = (params.get("search") || "").trim().toLowerCase().slice(0, 80);

  let query = admin.from("auth_events").select("*", { count: "exact" }).order("created_at", { ascending: false });
  if (eventType) query = query.eq("event_type", eventType);

  const { data: rows, count, error } = await query.range((page - 1) * perPage, page * perPage - 1);
  if (error) throw error;

  const userIds = [...new Set((rows || []).map((r: any) => r.user_id).filter(Boolean))];
  const emailById = new Map<string, string>();
  for (const id of userIds) {
    const { data } = await admin.auth.admin.getUserById(id);
    if (data?.user) emailById.set(id, data.user.email || "");
  }

  let out = (rows || []).map((r: any) => ({ ...r, user_email: r.user_id ? emailById.get(r.user_id) || "" : "" }));
  if (search) out = out.filter((r) => (r.user_email || "").toLowerCase().includes(search));

  return { rows: out, total: count || 0, page, per_page: perPage };
}

async function actionPlans() {
  const { data: plans } = await admin.from("plans").select("*").order("created_at", { ascending: true });
  const { data: userPlans } = await admin.from("user_plans").select("plan_id,status");
  const counts: Record<string, number> = {};
  for (const up of userPlans || []) {
    counts[up.plan_id] = (counts[up.plan_id] || 0) + (up.status === "active" ? 1 : 0);
  }
  const { data: recent } = await admin
    .from("user_plans")
    .select("*, plans(name)")
    .order("created_at", { ascending: false })
    .limit(20);
  return {
    plans: (plans || []).map((p: any) => ({ ...p, active_users: counts[p.id] || 0 })),
    recent: recent || [],
  };
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin") || "";
  if (origin && !allowedOrigins.has(origin)) return json(req, { error: "forbidden" }, 403);
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "GET" || req.url.length > 2048) return json(req, { error: "invalid_request" }, 400);

  const url = new URL(req.url);
  const action = oneOf(url.searchParams.get("action"), ["stats","users","user_detail","events","plans"]);
  if (!action) return json(req, { error: "invalid_request" }, 400);

  const auth = await requireAdmin(req);
  if ("error" in auth) return auth.error;

  const targetId = action === "user_detail" ? (url.searchParams.get("id") || "") : null;
  if (targetId && !isUuid(targetId)) return json(req, { error: "invalid_request" }, 400);
  const { error: auditError } = await admin.from("admin_actions").insert({
    admin_id: auth.user.id,
    action: "admin_api_access",
    target_type: action,
    target_id: targetId || null,
    metadata: { page: boundedInt(url.searchParams.get("page"), 1, 1, 100000) },
  });
  if (auditError) return json(req, { error: "audit_unavailable" }, 503);

  try {
    if (action === "stats") return json(req, await actionStats());
    if (action === "users") return json(req, await actionUsers(url.searchParams));
    if (action === "user_detail") {
      const detail = await actionUserDetail(targetId!);
      if (!detail) return json(req, { error: "not_found" }, 404);
      return json(req, detail);
    }
    if (action === "events") return json(req, await actionEvents(url.searchParams));
    if (action === "plans") return json(req, await actionPlans());
    return json(req, { error: "invalid_request" }, 400);
  } catch (_error) {
    return json(req, { error: "server_error" }, 500);
  }
});
