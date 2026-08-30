import { createClient } from "npm:@supabase/supabase-js@2.112.4";
import jpeg from "npm:jpeg-js@0.4.4";

const url = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
const allowedOrigins = new Set(["https://malfaapp.vercel.app", "http://localhost:4173", "http://127.0.0.1:4173"]);
const maxUploadBytes = 5 * 1024 * 1024;
const maxDimension = 1800;

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return { ...(allowedOrigins.has(origin) ? { "Access-Control-Allow-Origin": origin } : {}),
    "Access-Control-Allow-Headers": "authorization, apikey, content-type", "Access-Control-Allow-Methods": "POST, OPTIONS", "Vary": "Origin" };
}
function json(req: Request, body: unknown, status: number) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors(req), "Content-Type": "application/json", "Cache-Control": "no-store" } });
}
function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin") || "";
  if (origin && !allowedOrigins.has(origin)) return json(req, { error: "forbidden" }, 403);
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST" || Number(req.headers.get("content-length") || 0) > maxUploadBytes + 65536) {
    return json(req, { error: "invalid_request" }, 400);
  }

  const jwt = (req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "");
  const { data: authData, error: authError } = await admin.auth.getUser(jwt);
  if (authError || !authData.user) return json(req, { error: "unauthorized" }, 401);
  const userId = authData.user.id;

  let form: FormData;
  try { form = await req.formData(); } catch { return json(req, { error: "invalid_image" }, 400); }
  const file = form.get("file");
  const userBookId = String(form.get("user_book_id") || "");
  if (!(file instanceof File) || !isUuid(userBookId) || file.size < 4 || file.size > maxUploadBytes) {
    return json(req, { error: "invalid_image" }, 400);
  }

  const { data: book, error: bookError } = await admin.from("user_books")
    .select("id,owner_id,cover_path").eq("id", userBookId).maybeSingle();
  if (bookError || !book || book.owner_id !== userId) return json(req, { error: "not_found" }, 404);
  if (book.cover_path) return json(req, { error: "cover_exists" }, 409);

  const { data: folders, error: quotaError } = await admin.storage.from("book-covers").list(userId, { limit: 26 });
  if (quotaError) return json(req, { error: "upload_failed" }, 500);
  if ((folders || []).length >= 25) return json(req, { error: "cover_quota" }, 429);

  const source = new Uint8Array(await file.arrayBuffer());
  if (source[0] !== 0xff || source[1] !== 0xd8 || source[2] !== 0xff) {
    return json(req, { error: "invalid_image" }, 400);
  }

  let encoded: Uint8Array;
  try {
    const decoded = jpeg.decode(source, {
      useTArray: true,
      formatAsRGBA: true,
      maxResolutionInMP: 4,
      maxMemoryUsageInMB: 64,
    });
    if (!decoded.width || !decoded.height || decoded.width > maxDimension || decoded.height > maxDimension ||
        decoded.width * decoded.height > maxDimension * maxDimension) {
      return json(req, { error: "invalid_dimensions" }, 400);
    }
    // Decoding to pixels and writing a new JPEG removes EXIF, comments, ICC,
    // thumbnails, scripts, and every other original metadata segment.
    encoded = jpeg.encode({ data: decoded.data, width: decoded.width, height: decoded.height }, 84).data;
  } catch (_error) {
    return json(req, { error: "invalid_image" }, 400);
  }
  if (!encoded.length || encoded.length > maxUploadBytes) return json(req, { error: "invalid_image" }, 400);

  const path = `${userId}/${userBookId}/cover.jpg`;
  const upload = await admin.storage.from("book-covers").upload(path, encoded, {
    upsert: false,
    contentType: "image/jpeg",
    cacheControl: "3600",
  });
  if (upload.error) return json(req, { error: "upload_failed" }, 500);

  const update = await admin.from("user_books").update({ cover_path: path, cover_mime: "image/jpeg" })
    .eq("id", userBookId).eq("owner_id", userId).select("id").single();
  if (update.error) {
    await admin.storage.from("book-covers").remove([path]);
    return json(req, { error: "upload_failed" }, 500);
  }
  const signed = await admin.storage.from("book-covers").createSignedUrl(path, 3600);
  return json(req, { path, signed_url: signed.data?.signedUrl || null }, 200);
});
