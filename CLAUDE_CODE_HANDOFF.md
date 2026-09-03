# مَلفى (MALFA) — Claude Code Handoff

## 0. Provenance note

This handoff doc and the git repo it lives in were (re)created on 2026-08-27.
The original `CLAUDE.md` / `CLAUDE_CODE_HANDOFF.md` referenced when this task
was assigned could not be located on this machine — no git repo, no `v4/`
folder, and no `p9-comp.html` existed prior to this session. What did exist
was a set of standalone HTML exports in `~/Downloads` (`malfa.html` through
`malfa_5.html`, internally labelled `MALFA v3`), plus a `LOGOS/` folder at
`~/Desktop/malfa/LOGOS`. `malfa_5.html` (the latest/largest of the five) was
adopted as the baseline and copied to [v4/p9-comp.html](v4/p9-comp.html); a
fresh git repo was initialized around it. This doc reconstructs the working
conventions from reading that file, plus the task brief given directly by the
user. If you find an older, more complete version of this doc, prefer it and
reconcile.

## 1. What MALFA is

A single-file, RTL Arabic prototype of a reading app: a warm, calm, book-first
reading companion. Client-only, no backend, no dependencies. See
[CLAUDE.md](CLAUDE.md) for architecture and rules.

## 2. Baseline (2026-08-27)

Commit `Import MALFA v3 prototype as v4/p9-comp.html baseline` established the
starting point: home-first navigation (`home`, `library`, `community`
[مَلفى], `discover`, `account` tabs, no auth/onboarding flow), with a
`.plate.shelf .sh-c` fanned book-stack using `rotate()`.

## 13. Active task — the 6-point override

Given directly by the user on 2026-08-27. Apply on top of the existing
product only — no scope expansion, no redesign of anything not listed here.

1. **Opening flow.** Welcome page (subtle logo motion → "مكان كل القراء"
   fade/slide in → optional "صُنع بحب") → Login/Sign-up → Home. Extremely
   subtle, premium, calm — no flashy animation.
2. **Home order.** Header, Hero/greeting, وش تقرأ اليوم؟ / وين وصلت في
   كتابك؟, current reading / continue journey, اختيار مَلفى, من مَلفى.
   Remove "كيف يقرأ..." from Home.
3. **Relocate "كيف يقرأ...".** Move it to the مَلفى tab, alongside possible
   sections: مجموعاتي, تواريخ مهمة, توصيات الأصدقاء.
4. **Layout/composition fix.** Remove tilted/slanted/leaning elements; prefer
   clean, straight, structured alignment. The only rotate() found in this
   codebase was `.plate.shelf .sh-c` (fanned book stack in editorial/topic
   plates). Confirmed with the user 2026-08-27: flatten it. (`.au-c` and
   `.pick .fan`, mentioned in the original brief, do not exist in this
   snapshot — likely from a later iteration not present here.)
5. **Tone pass.** Clear, modern, natural, warm Arabic across all copy — not
   overly formal, not heavily Najdi, not broken/casual.
6. **QA.** Verify opening flow, Home order, كيف يقرأ relocation, and layout
   stability; remove any remaining crooked/awkward deviations. Run
   `bash v4/build.sh` and confirm `JS OK` after every change.

### Progress

- [x] 1. Opening flow (Welcome → Login/Sign-up → Home). Added `welcomeHTML()`
      and `authHTML()`/`authBodyHTML()` screens, `welcome`/`auth` in `VIEWS`
      and `PUSHED`. Boot is `mount('welcome')` → auto-advance via
      `setTimeout(enterAuth, REDUCE?700:2600)` (or tap-to-skip via
      `data-skip`) → login/sign-up toggle via `data-authtoggle` → `data-enter`
      (submit or "متابعة كضيف") calls `enterApp()`, which sets `STATE.tab`,
      calls `renderTabs()`, and `mount('home','fade')`. The 'fade' mode has no
      dedicated CSS (deliberately) — with no `.screen.ent-fade` transform
      rule, the existing `.screen`/`.screen.on` opacity transition alone
      produces a plain cross-fade, which reads calmer than the tab-style
      translateX push/pop used elsewhere. No backend, no persistence — the
      submit buttons are frictionless (any input, or none, advances).
- [x] 2. Home reorder + remove كيف يقرأ from Home. New order in `homeHTML()`:
      header → hero/greeting → "وش تقرأ اليوم؟" + "وين وصلت في كتابك؟" →
      current reading (كمل من وين وقفت) + reflection clip → بعدها rail →
      اختيار مَلفى → من مَلفى → مَلفى الشهر. كيف يقرأ block removed entirely
      (and the now-unused `who=PEOPLE[0]` local dropped).
- [x] 3. كيف يقرأ moved to `communityHTML()` (مَلفى tab), placed after "قرّاء
      تكتشفهم". Added a "مجموعاتي" section right after it, rendering the full
      `COLLECTIONS` array via `collHTML` — since `COLLECTIONS` already
      contains a "توصيات الأصدقاء" entry and a "تاريخ مهم" entry, this single
      section naturally covers all three requested topics without
      fabricating new data or duplicating headers.
- [x] 4. Flattened `.plate.shelf .sh-c` — removed the
      `rotate()/translateY()` transform, kept the overlap margin. Affects
      every `edPlate()` usage (Home "من مَلفى", مَلفى tab, account's "مَلفى
      2026" archive button) uniformly.
- [x] 5. Tone pass. All new copy (welcome, login/sign-up, "وين وصلت في
      كتابك؟") written in the same warm/modern/colloquial-leaning MSA voice
      already used throughout the file. Scanned existing copy for
      broken/placeholder text — none found; the established voice already
      matches the brief, so no rewrite of pre-existing strings was needed.
- [x] 6. QA pass. `bash v4/build.sh` → `JS OK` after every edit. Verified in
      a real browser (local static server, since `file://` in this tool
      renders as a non-interactive snapshot): opening flow end-to-end
      (welcome → auth → toggle signup/login → enter app), Home section order,
      كيف يقرأ + مجموعاتي on the مَلفى tab, flattened shelf, and a full
      tab-navigation sweep (library/discover/account/community/home) with a
      clean console (no errors).

## 14. Active task — real accounts, isolation, functional flows (2026-08-27)

Given directly by the user, expanding well beyond the 6-point override. When
asked whether "accounts" should be a client-only localStorage simulation or a
real backend, the user explicitly chose a **real backend**: Supabase. This
authorizes introducing a backend, which [CLAUDE.md](CLAUDE.md) otherwise
requires asking about first.

**Supabase project:** `ntpwnrsckacwqzvgoysb` (org "Malfa", already existed,
was empty) — `https://ntpwnrsckacwqzvgoysb.supabase.co`. URL + publishable
key (`sb_publishable_...`) are embedded in `v4/index.html` — this is normal
for Supabase's client model (protected by RLS), not a leaked secret.
`supabase-js@2` is loaded from a CDN `<script>` tag — the app's only external
JS dependency (previously zero).

**Schema** (`public`, RLS on every table, migrations applied via MCP):
`profiles` (auto-created by a `handle_new_user()` trigger on `auth.users`
insert; its RPC execute grant was revoked from `anon`/`authenticated` per the
security advisor — triggers still fire regardless), `books` (shared
read-only catalog, seeded 1:1 from the existing `B` JS object plus a `genre`
column — one of رواية/تاريخ/أدب/ثقافة/سيرة/فكر, hand-assigned), 
`library_entries` (`user_id, book_id, status, page`, unique per user+book),
`journey_entries` (`user_id, book_id, note, duration_sec, page_from,
page_to, is_start`), `collections` + `collection_books`. `get_advisors`
(security) is clean.

**Client-side data layer** (`v4/index.html`, right after `B`'s
declaration): `ME`, `MY_NAME`, `MY_CREATED_AT`, `MY_LIB` (replaces the old
static `LIB`), `MY_PROGRESS` (book_id → page, replaces reading `B[id].page`
for the real user), `MY_JOURNEY` (book_id → rows, replaces the old static
`JOURNEY`), `MY_COLLECTIONS` (replaces the old static `COLLECTIONS`).
`loadAll()` fetches everything in one `Promise.all` right after
login/signup/session-restore — the whole catalog + one user's data is small,
so there's no per-screen lazy fetching; `VIEWS[name]()` stays fully
synchronous exactly like before. `myBookView(id)` / `myJourneyView(id)`
adapt the static catalog + real per-user rows into the shapes the existing
render functions (`cover()`, `journeyHTML()`, ...) already expect, rather
than rewriting the render layer. **Important:** `B[id].page` must never be
read directly for the current user's progress anymore — use `myBookView(id)`
or `MY_PROGRESS[id]`; `B[id].page` is stale leftover-shape data now unused
for that purpose (kept only because the object literal still has the key).

**Bottom sheet generalized** (`sheetHTML(mode)`/`openSheet(mode,ctx)`):
`'log'` (the original voice-note flow — now a real `journey_entries` insert
+ `library_entries` upsert instead of mutating `B[id].page`; also used for
onboarding via `ctx.onboard:true`, which changes copy, skips
`page_from`/sets `is_start`, and routes completion to `finishOnboarding()`
instead of a toast), `'addbook'` (search + pick, inserts `library_entries`
with a status from `ctx.status`), `'newcollection'` (title input, inserts
`collections`).

**Onboarding** (item 6, signup only): `authHTML`'s submit
(`data-authsubmit` → `handleAuthSubmit()`) calls real
`signUp`/`signInWithPassword`. On signup with no session back (Supabase's
default "Confirm email" requires clicking a real email link), shows a
"تحقق من بريدك" waiting screen rather than breaking — **the user was asked
to disable "Confirm email" in the dashboard (Authentication → Sign In /
Providers → Email) for the frictionless flow they described; confirm this
was done before trusting the happy-path signup test below.** On a real
session, `startOnboarding()` → `onboardBookHTML` (search/pick a book,
reusing `searchBooks()`) → picking one opens the voice sheet in onboard mode
→ save (or the "تجاوز" skip, which still creates the reading entry without a
journey note) → `finishOnboarding()` → Home. Existing logins skip straight
to Home. Session restore on boot (`sb.auth.getSession()`) also skips
straight to Home with real data loaded — no re-login needed after closing
the app, satisfying the persistence requirement at the session level.

**Guest login removed** (item 2): no code path reaches any screen without
`ME` being set from a real Supabase session.

**مكتبتي / اكتشف / اختيار مَلفى (items 7–9):** `EMPTY_LIB` gives each of
the 4 segments its own empty-state copy + a working "add" CTA
(`data-addbook="<segment>"`), replacing the old bug where every empty
segment showed the 'dropped' copy regardless. مجموعات section same
empty-state-with-CTA treatment, real `MY_COLLECTIONS`. اكتشف's search input
is real and live (`wireDiscoverSearch`, `searchBooks()` — Arabic-normalizing:
strips diacritics, unifies أ/إ/آ/ا and ى/ي and ة/ه — so `discoverResultsHTML`
never depends on exact diacritic/spelling match), with a clean "ولا نتيجة"
state instead of a disabled field. Home's اختيار مَلفى got the 6 genre chips
(`GENRES` const); tapping one jumps to اكتشف pre-filtered
(`STATE.genreFilter`).

**حسابي (item 10):** name/avatar/handle/member-since/book-count now come
from `MY_NAME`/`ME`/`MY_CREATED_AT`/`myBookCount()`. Removed "معاينة ملفك
العام" (it opened a hardcoded *other* simulated person's profile — clearly
wrong once "my" data is real) and the "مَلفى الشهر"/"مَلفى 2026" hardcoded
August recap (would have shown obviously-fake stats next to now-real ones).
Added a real "تسجيل الخروج" row (`data-logout` → `handleLogout()` →
`sb.auth.signOut()` → back to the auth screen, all local caches cleared).
Follow counts (يتابعونك/تتابعهم) stay `0`/simulated — no real social graph
was asked for; only the current user's *own* data needed to be real and
isolated.

**Nav/skew bug (item 1) — real bug, unrelated to Supabase, fixed first:**
in `mount()`, the entering screen's `ent-<mode>` class (e.g. `ent-push`) was
never removed when `.on` got added. `.screen.on{transform:none}` and
`.screen.ent-push{transform:translateX(-26px)}` are equal-specificity
2-class selectors; since `.ent-push` is declared *after* `.on` in the
stylesheet, it kept winning the cascade tie, so pushed/popped screens stayed
visually offset instead of animating to centered. Fixed by stripping
`ent-<mode>` in the same step `.on` is added, and generalizing the old-screen
cleanup to strip `ent-fade` too. Tab switches (`goTab`) were never affected —
`mount(k)` with no mode uses the instant branch, which has no `ent-*` class
at all.

**Font (item 5):** both `--f-d` and `--f-u` point to `'Thick Naskh Swash'`
first (the file the user attached — inspected its `name`/`OS2` tables
directly since `fonttools`/`otfinfo` weren't installed: family "Thick Naskh
Swash", **one weight only, 400/Regular**, TrueType outlines with GSUB/GPOS).
Both `@font-face 'Alyamama'` embeds were removed (that was ~130KB of the old
file on one line) and replaced with one `Thick Naskh Swash` embed
(`format('truetype')`). The `FAMS` console self-check array was updated to
match. Flagged to the user: since the file has only one weight, bold text
using this face renders at native weight rather than synthetic/faux bold
(which distorts Arabic swash letterforms) — "different weights" can't mean
multiple real weights here.

### Progress

- [x] Nav/skew bug fixed (`mount()` ent-class cleanup)
- [x] Supabase schema + RLS + seeded `books` catalog (24→19 books, genre-tagged)
- [x] Font swap (Thick Naskh Swash, both `--f-d`/`--f-u`)
- [x] Guest login removed
- [x] Real signup/login/logout wired to Supabase Auth
- [x] Onboarding (pick book → voice note → auto-add to مكتبتي → Home)
- [x] Home: dynamic user, real current-reading progress, genre chips
- [x] مكتبتي: real per-status data, per-segment empty states + working add,
      real مجموعات + "مجموعة جديدة"
- [x] اكتشف: real live search (Arabic-normalizing), empty "لا نتيجة" state,
      genre-filter entry point from Home chips
- [x] مَلفى tab مجموعاتي: real data (isolation-consistent with مكتبتي)
- [x] حسابي: dynamic identity + real logout; removed now-misleading fake
      "public profile preview" and "August recap" blocks
- [x] User disabled "Confirm email" in the Supabase dashboard — signup now
      goes straight into onboarding with no email step.
- [x] Deployed to a real host: `https://malfaapp.vercel.app` (static
      `deploy/index.html`, no CLI available on this machine — the user did
      the actual Vercel deploy themselves; I only prepared the file). I have
      no tool to deploy myself, so **every future change here needs the
      user to re-drag `deploy/` to Vercel** (or I keep syncing the file and
      remind them) before it's live.
- [x] Two-account isolation test — real signup for two accounts, verified
      both in the UI (`مكتبتي` shows only own book) and via `execute_sql`
      cross-checking `library_entries` joined to `profiles`/`auth.users`:
      each account's row set was exactly its own, zero overlap.
- [x] Persistence-across-reload check — reloaded mid-session, session and
      theme preference both restored without re-authenticating.
- [x] QA test accounts deleted from `auth.users` (cascade-removed their
      `profiles`/`library_entries`). The one remaining `auth.users` row is
      the user's own real account from testing the live site themselves —
      left untouched.
- [ ] Multi-screen-size sweep with a real logged-in session beyond the two
      sizes already checked (390 desktop-emulated phone frame, 375 mobile
      full-bleed) — reasonably covered, not exhaustively swept.
- [x] Committed (this commit).

## 15. Active task — remove the fake social layer, real content, theme, real voice-to-text (2026-08-27)

Given directly by the user as a second large batch, once real accounts were
live. Full plan is (was) in `/Users/talal21/.claude/plans/kind-cuddling-squid.md`.
Summary of what changed:

- **Book catalog replaced wholesale** (DB `books` table truncated + reseeded,
  local `B` object rewritten to match): 10 genuinely public-domain classical
  Arabic works (ألف ليلة وليلة، كليلة ودمنة، البخلاء، حي بن يقظان، رسالة
  الغفران، مقدمة ابن خلدون، تاريخ الطبري، العقد الفريد، السيرة النبوية،
  مقامات الهمذاني) — every author died 600+ years ago, unambiguous under any
  copyright term. Covers are `l:'type'` (flat colour + type, the pre-existing
  no-illustration layout) with no `sc` scene set — no pseudo-cover art.
  `AUTHORS` (اكتشف) is now these same real historical authors.
  `library_entries`/`journey_entries`/`collections`/`collection_books` were
  truncated in the same migration since they FK-referenced the old book ids
  — pre-launch test data only, not real users.
- **Fake social layer deleted outright**, not hidden: `PEOPLE`, `PMAP`,
  `FEED`, `face()`, `actHTML()`, `expHTML()`, `profileHTML()` and their
  `data-person`/`data-open="profile"` handlers are gone from the file.
  `communityHTML()` (مَلفى tab) keeps مجموعاتي (already real) and turns
  قوائم من الناس / تجارب مع الكتب into real (currently empty) states instead
  of hardcoded fictional entries. `bookHTML()` lost "قرّاء آخرون معك".
  `friendHTML()` (مع صديق) now shows the real current book/progress instead
  of a fabricated "فيصل" friend, and a real "ما انضم صديق بعد" empty state
  instead of a fake pending-invite row.
- **Home reorganized**: three real options right under "وش تقرأ اليوم؟" —
  اقرأ من كتابك (`data-open="book"`/`data-tab="library"`), اقرأ الكتاب نفسه
  مع صديق (`push('friend')`), شارك التجربة حول الكتاب نفسه (new
  `shareExperience()` — `navigator.share()` with a clipboard-copy fallback).
  A subtle `.kh-hi` lavender highlight span wraps just the user's first name
  in the greeting (not applied elsewhere, per the user's own example scope).
  "سجّل قراءة" renamed to "سجّل رحلتك" everywhere. "مَلفى الشهر" (hardcoded
  fake August recap) removed from both `homeHTML()` and `accountHTML()`
  (the latter was already stale from before this batch).
- **اختيار مَلفى → real topic pages**: new `TOPIC_PAGES`/`TOPIC_ORDER`/
  `topicHTML()`/`topicRowHTML()` — 4 topics (كيف تقرأ على مهل؟ / شيء خفيف
  لويكند طويل / روايات للي ما يحب الروايات / ليش نشتري أكثر مما نقرأ؟),
  each a real ~5-line essay, no filler (`PICKS`/`TOPICS`/`edHTML`/
  `erowHTML`/`collHTML`/`edPlate` all deleted as dead code once nothing
  referenced them).
- **من مَلفى → plain warm card**: no book imagery, "من مَلفى" itself is the
  dominant type on a `linear-gradient(135deg,#D8553F,#C8912C)` card: tapping
  it is honestly `data-toast="...يُكتب قريبًا"` since there's no real
  editorial content behind it yet.
- **Theme (فاتح/داكن/حسب إعداد الجهاز)**: `applyTheme()`/`setTheme()`/
  `getThemePref()` at the very top of the script (before `mount()` ever
  runs, so no flash of the wrong theme), `localStorage['malfa_theme']`,
  `data-theme` attribute on `<html>`. Light token set + `@media
  (prefers-color-scheme:light)` block mirrored by a `:root[data-theme="light"]`
  block (system vs. explicit). New picker row in `accountHTML()` reusing the
  existing `.chip`/`.chip.on` pattern. **Found and fixed a real bug while
  testing this**: five sticky chrome bars (`.hdr`,`.thead`,`.navbar`,
  `.tabbar`,`.stick`) had their translucent background hardcoded as
  `rgba(11,10,13,...)` (literally the dark ground colour) instead of a
  themed variable — they stayed black in light mode. Introduced
  `--chrome-70`/`--chrome-78`/`--chrome-9` (themed in both light blocks) and
  pointed all five at them. Also swept every *static* (always-visible, not
  `:active`-only) `rgba(255,255,255,.XX)` white-tint — `.bar`, `.search`,
  `.grab`/`.sheet.dragging .grab`, `.field input`, plus the `:active` press
  tints on `.hdr-btn`/`.erow`/`.coll`/`.act`/`.row`/`.chip` — over to
  `color-mix(in srgb,var(--ink) X%,transparent)`, which adapts to either
  theme automatically with no per-theme variable needed. Book covers
  themselves (`.cv`, grain, fore-edge highlight) were deliberately left
  theme-independent — they're "printed colour," not chrome, per the
  existing design comment.
- **Real voice-to-text**: `openSheet('log', ...)`'s mic handler now uses
  `window.SpeechRecognition||window.webkitSpeechRecognition`
  (`lang:'ar-SA'`, `interimResults:true`, `continuous:true`), writing live
  interim+final text into `#vTxt` as the user speaks. `recognition`/
  `recognizing` promoted to module scope (not local to `openSheet`) so
  `closeSheet()` can `.stop()` an in-progress recognition if the sheet is
  dismissed mid-recording. On stop, `#vTxt` becomes `contenteditable="true"`
  (review/edit before saving — new `.v-txt[contenteditable]` focus styling +
  a `:empty::before` placeholder). Where `SpeechRecognition` doesn't exist
  (Safari/Firefox — real feature detection, not UA sniffing): mic button is
  hidden, the subtitle explains why, and `#vTxt` is directly editable from
  the start — same save path (`insertJourneyEntry`) either way, already real
  from the accounts batch. Reused as-is for onboarding (`ctx.onboard`).
  Removed the now-dead canned-line `LINES` array.
- Also fixed in passing: `mono()`'s inline SVG still referenced the removed
  `Alyamama` font family (stale from the font-swap batch last session) —
  avatar monogram letters were silently falling back to generic serif;
  now `Thick Naskh Swash`.

### Progress

- [x] Book catalog replaced (10 public-domain classics), DB migration
      applied, `AUTHORS` updated, old per-user data truncated
- [x] Fake social layer removed (`PEOPLE`/`FEED`/`PMAP`/profile screen/
      friend's fake data) — real empty states in their place
- [x] Home reorganized (3 real options, خزامى name accent, رحلتك rename,
      August-recap block removed)
- [x] اختيار مَلفى → 4 real topic pages; من مَلفى → plain warm card
- [x] Light/dark/system theme, including the chrome-bar bug found during
      testing
- [x] Real Web Speech API voice-to-text with a typing fallback
- [x] Full re-test pass on the live site: onboarding with a real book pick,
      empty→populated مكتبتي via the add flow, search, theme toggle
      (light↔dark, verified no chrome-bar regression), voice sheet opens
      and degrades gracefully without mic permission, logout/login, and the
      two-account isolation check above
- [x] **Deploy reminder**: `deploy/index.html` is synced with every change
      in this batch. The consumer app is live at malfaapp.vercel.app via
      manual Vercel redeploys done by the user (I have no deploy tool). The
      repo is now also pushed to https://github.com/Talal-ops1/Malfa — see
      §16 below for how that's connected going forward.

## 16. Active task — separate private admin dashboard (2026-08-28)

Given directly by the user: a real, separate, private admin web app for
MALFA operators (not a screen inside the consumer app), monitoring users and
authentication activity. Built at [admin/index.html](admin/index.html) —
same single-file-per-surface convention as the consumer app, but a distinct
deployable product with its own login gated to admin accounts.

**Design skills used per the user's instruction**: `ui-ux-pro-max` (its
generic product/color-palette match was a landing-page green scheme — wrong
fit, MALFA's own khuzama/paper/charcoal spec from the user overrides it, but
its chart guidance (line chart for growth, bar for plan distribution, always
show values as text not hover-only) and table guidance (horizontal scroll,
not cards) were applied directly) and `emil-design-eng` (panel slide
easing/duration, restrained motion, no animation on frequent actions).

**Schema additions** (same Supabase project, migration `admin_dashboard_schema`):
`profiles.is_admin` (bool, default false — the real account
`talalmqahtani@gmail.com` is the only one set `true`) and
`profiles.last_seen_at` (heartbeat timestamp); `auth_events` (audit log:
sign_in/sign_in_failed/sign_out/register/password_reset/session_expired/
plan_change/account_suspended/account_reactivated, indexed on user_id/
event_type/created_at, server-timestamped via column default — never
client-supplied); `plans`/`user_plans` (schema only, deliberately seeded with
**zero rows** — there is no real subscription/plan system anywhere in MALFA
yet, so the dashboard's "Plans" section and the KPI's paid/free split show
this honestly — "لا يوجد نظام خطط مُفعّل بعد" — rather than inventing plan
names or pricing the user explicitly said not to fabricate).

**RLS**: `auth_events`/`plans`/`user_plans` are admin-select-only
(`exists(...profiles where id=auth.uid() and is_admin)`). `auth_events` also
allows a signed-in user to insert **only their own** row and **only** for
the self-reportable event types (`sign_in`/`sign_in_failed`/`sign_out`/
`register`) — plan changes/suspensions are not client-insertable, so a
regular user can never forge those.

**Server-side privileged reads — the security-critical piece**: the
service-role key is used *only* inside two Supabase Edge Functions, never in
any browser-shipped code.
- `admin-api` (one function, `?action=stats|users|user_detail|events|plans`
  router) — every request re-verifies the caller's JWT via
  `admin.auth.getUser()` **and** re-checks `profiles.is_admin` itself
  (doesn't trust the frontend's gate) before touching any data; returns 401
  for a missing/invalid/expired token, 403 for a valid-but-non-admin token.
  Reads `auth.users` (email, created_at, last_sign_in_at) via
  `auth.admin.listUsers()`/`getUserById()` — the GoTrue admin API, not raw
  SQL — since `auth` isn't exposed through PostgREST.
- `log-failed-signin` — the one deliberately public (no JWT possible —
  a failed login has no session) endpoint, and it's narrow on purpose: takes
  only `{email}`, looks the user up server-side, inserts one
  `sign_in_failed` row, and **always returns a bare 204 regardless of
  whether the email exists** — so it can't be used to enumerate accounts. A
  tiny in-memory per-isolate debounce blunts naive repeated hits.

**Consumer app hooks** (`v4/index.html`, minimal, per the user's own
carve-out for "strictly required" hooks): `logAuthEvent()` (self-row RLS
insert) fires on real login/register success; `handleLogout()` logs
`sign_out` *before* tearing down the session (has to — the insert needs
`auth.uid()` to still resolve); a failed `signInWithPassword` calls
`logFailedSignin()` (the public function above); `touchLastSeen()` updates
`profiles.last_seen_at` on boot/session-restore and on a 4-minute
heartbeat/visibility-regain — all verified end-to-end with real events
(see Verification below).

**"Active now" and "last seen" — defined, not vibes**: active = `last_seen_at`
within 5 minutes (shown in the KPI card's own subtitle, not left implicit).
Closing the tab is *not* sign-out — sign-out is only logged on the explicit
logout button, matching the user's own caution about this.

**Frontend** (`admin/index.html`): RTL, IBM Plex Sans Arabic throughout (not
the project's Thick Naskh Swash display face — a decorative swash serif
actively hurts legibility at dense operational information density, which
contradicts "calm, intelligent, minimal, operational"; noted here rather
than silently following the letter of "match MALFA's identity" over its
spirit). Alyamama/Thmanyah Sans were requested "if already licensed" —
neither actually is in this project (Alyamama was removed this session;
Thmanyah Sans was never a real loaded font, just a stale fallback name) — so
per the instruction's own fallback, the project's actual current fonts are
used instead. Dark charcoal sidebar (fixed, RTL-start/right-anchored) +
light paper content area, matching "paper should dominate, charcoal is
chrome." Hand-rolled SVG-free bar/line charts (no charting library —
values are always shown as text per the accessibility guidance pulled from
`ui-ux-pro-max`, not hover-only). Users table: search debounced 300ms, 11
filter chips exactly matching the requested filter set, 3 sort orders,
paginated (25/page), horizontal-scroll wrapper (not cards) below ~860px. A
detail side panel slides from the content-start edge. Full UX states:
loading skeletons, empty search/no-users/no-events, network error+retry,
permission-denied (signed in but not admin), and a centralized 401 handler
in `api()` that signs out and returns to login from *any* call site — this
was a real bug caught during testing (see below), not a guess.

### What's connected to live data vs. fixtures

**Nothing in the admin dashboard is a fixture.** Every KPI, table row, and
event is a real Supabase query through the two Edge Functions above. The
only reason `plans`/`user_plans`/`paid_users` show zero is that MALFA has no
real plan system yet — that's the honest state, not a placeholder.

### Verification

1. `bash v4/build.sh admin/index.html` → `JS OK`.
2. `get_advisors` (security) clean except one pre-existing, unrelated
   Auth-settings recommendation (leaked-password protection — a dashboard
   toggle, not something a migration can fix; worth the user turning on).
3. Confirmed both Edge Function auth gates directly: no token → 401; a real
   non-admin account's token → 403.
4. Temporarily granted `is_admin` to a throwaway QA account, logged into the
   dashboard with it, and drove every tab: Overview (real counts + working
   charts), Users (search/filter/sort/pagination + detail panel with real
   account/plan/event data), Events (empty state, then real rows), Plans
   (honest empty state), mobile-width fallback layout.
5. **Caught and fixed a real bug this way**: mid-test, the same QA
   account's session was invalidated (`sb.auth.signOut()`'s default scope is
   `'global'` — signing out of the consumer app on one origin revoked the
   admin dashboard's session on another). The dashboard's individual tab
   loaders didn't all handle a 401 consistently — fixed by centralizing it
   in `api()` once, so every call site benefits automatically.
6. Generated real consumer-app events (wrong password, correct password,
   logout) and confirmed all three appeared correctly in the admin Events
   log with accurate status/device/timestamp — end-to-end pipeline verified,
   not assumed.
7. Cleaned up: QA account's admin flag and the account itself both removed;
   only the user's real account remains, correctly flagged admin.

### How to access it

Not deployed yet — `admin-deploy/index.html` is ready (same drag-and-drop
Vercel flow as the consumer app, but as its **own separate project/URL**,
kept private — nothing links to it from the consumer app, and it isn't
discoverable). Sign in with the real MALFA account
(`talalmqahtani@gmail.com`) — it's the only account with `is_admin=true`.

### Repo / deploy note

The repo is now pushed to https://github.com/Talal-ops1/Malfa (main
branch). No Vercel Git integration is connected yet — both `deploy/` (consumer
app) and `admin-deploy/` (this dashboard) still need a manual drag-and-drop
deploy per change until that's set up.

## 17. Active task — منارة, real friend invites, custom books, IBM font, cleanup (2026-08-28)

*(Since §16: Vercel Git integration was connected for both projects —
`malfaapp.vercel.app` reads `v4/` as its root, `malfaappl.vercel.app` reads
`admin/` — so a push to `main` now auto-deploys both. The `deploy/` and
`admin-deploy/` folders from the manual drag-and-drop era are superseded by
this and no longer kept in sync; they can be deleted in a future cleanup but
weren't touched here to stay in scope.)*

Nine-item request, all in [v4/index.html](v4/index.html) plus three new
Supabase migrations and one new Edge Function. No admin-dashboard changes.

**Font**: the attached `IBMPlexArabic-Text.ttf` is embedded base64 (same
no-network-dependency method as the existing Thick Naskh Swash) as
`--f-u` (secondary/functional — body, buttons, forms, nav). `--f-d`
(headline) stays Thick Naskh Swash, unchanged. `FAMS` console-verification
array updated to list all three families.

**Welcome screen**: added `صُنع بحب من العيينة | الرياض` under the existing
"مكان كل القراء" line; animation/motion untouched (already calm per the
6-point override).

**منارة** (new tab inside a book's journey, alongside the existing full
chronological record): a real LLM call, never a client-side stitch. New
Edge Function `summarize-journey` — takes only the signed-in caller's own
`journey_entries` text for that book, calls the Anthropic API
(`claude-sonnet-4-5`) server-side with a system prompt that explicitly
forbids summarizing the book's own (copyrighted) content or inventing
anything the user didn't say, returns 2-5 paragraphs. **The user still needs
to add `ANTHROPIC_API_KEY` as an Edge Function secret via the Supabase
dashboard (Project Settings → Edge Functions → Secrets) — I have no tool to
set it and, per the credential rule, would never accept it pasted into
chat.** New table `journey_summaries` (owner-only RLS + a public-select
policy scoped to `is_shared=true`, so a shared منارة is what finally
populates the previously-empty "تجارب مع الكتب" section in مَلفى — closing
that loop rather than opening a new fake one). UI: intro line "هنا يقف
الراوي على أطلال رحلته وتلخيصها." → cached summary (regenerated only when
new entries exist since the cache) → one checkbox, `مشاركة منارتي مع
الآخرين`, unchecked by default; checking it opens an editable review step
(the summary text, editable, with a confirm action) before anything is
written as shared — no Yes/No buttons anywhere in that flow, per the brief.

**Friend invites**: replaced the old link-copy flow. New `search_profiles(q
text)` `SECURITY DEFINER` function (id+name only, `execute` revoked from
`anon`/`public`) backs a live search-as-you-type sheet ("اكتب اسم الحساب
اللي تبي تشاركه الكتاب"). New table `reading_invites`
(book_id/user_book_id, from/to, status) with sender-insert / either-side-read
/ recipient-updates-status RLS. `friendHTML()` now shows real state: a
pending invite addressed to the signer renders with قبول/رفض buttons
(`respondInvite()`); a pending invite the signer already sent shows "بانتظار
ردّ {name}" instead of the generic empty state; otherwise the real empty
state plus the search-invite button. (Caught and fixed one bug here during
this pass: after sending an invite, the sheet closed and refreshed the
screen from stale in-memory invite arrays, so the new "بانتظار الرد" state
didn't show until next navigation — fixed by re-fetching invites before the
refresh instead of after.)

**"اختيار مَلفى" removed**: its 4 topic rows now render directly under "من
مَلفى"'s existing orange-card treatment on Home; اكتشف's section is just
relabeled "من مَلفى" (no separate card there — that identity lives on Home
only). "شارك بإثراء مَلفى" / "شارك كتاباتك" added under the same content,
opening a real single-textarea sheet that inserts into a new
`contributions` table (self-insert/self-select RLS) — a real row, not
placeholder theater.

**Books MALFA can't publish / isn't cataloged**: new `user_books` table
(owner-scoped, entirely separate from the curated public `books` catalog so
it never leaks into other users' اكتشف). `library_entries`/`journey_entries`
gained a nullable `user_book_id` alongside the now-nullable `book_id`, with a
one-of check constraint (fixed a follow-up bug: the first uniqueness
constraint on `journey_summaries` used all three of
`user_id,book_id,user_book_id` together, which doesn't dedupe correctly
since NULL≠NULL in Postgres — replaced with two partial unique indexes,
matching the pattern `library_entries` already used). مكتبتي's add-book
sheet gained "ما لقيت الكتاب؟" → photograph the cover (`capture="environment"`
file input) and/or type title + optional author → starts the reading
journey immediately, no catalog dependency. Covers go to a **private**
Storage bucket (`book-covers`, owner-folder-scoped, `createSignedUrl` reads
— never a public URL, since a photographed cover may itself be copyrighted).
منارة sharing for these books still only ever shares the user's own
generated text, never the book's content, same as cataloged books.

**Language cleanup**: خواطر/دردشة removed from all occurrences, replaced
with vocabulary already used elsewhere (محطة/تسجيلات/تجارب) rather than
inventing new terms.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit in this batch, final state
   confirmed clean.
2. `get_advisors` (security): clean except the two intentional
   `SECURITY DEFINER` warnings on `profile_names`/`search_profiles` (both
   deliberately narrow, id+name only, that's the whole point of the
   function) and the pre-existing leaked-password-protection Auth setting
   (unrelated to this batch, a dashboard toggle for the user).
3. `list_tables`: `journey_summaries`, `reading_invites`, `contributions`,
   `user_books` all present with RLS enabled.
4. Grepped the shipped file for خواطر/دردشة (zero hits) and "اختيار مَلفى"
   as user-facing copy (zero — the only remaining occurrence is a code
   comment explaining the removal).
5. **Not yet done**: a live browser QA pass on the deployed site (منارة
   generation end-to-end needs the user's `ANTHROPIC_API_KEY` secret first),
   and confirming a shared منارة actually surfaces in a second test
   account's مَلفى tab.

### Repo / deploy note

Committed on top of the §16 state; `deploy/`/`admin-deploy/` intentionally
left un-synced (see note at the top of this section — they're superseded by
the Git-connected Vercel deploy).

## 18. Active task — welcome timing fix, public accounts, home compaction, category cleanup, light-mode headline (2026-08-28)

Ten-item follow-up request, applied only on top of the existing product.

**Welcome motion**: the sequence (logo → tagline → credit line) was already
coded correctly, but the auto-advance timer (2600ms) fired *before* the
credit line's own fade-in animation finished (it completed at 2650ms) — so
`صُنع بحب من العيينة | الرياض` was visible for at most a few ms before the
screen transitioned away. Fixed by tightening the fade durations slightly
and extending the timer to 3000ms, giving the credit line a full ~550ms
visible hold before advancing. Verified with a scripted timing probe (not
guesswork): logged `.w-love`'s computed opacity every 250ms across a real
page load — confirmed 0 until ~1650ms, fading to 0.75 by ~2450ms, held
through 3000ms. Also fixed the credit line's wording per the user's
correction mid-session: `من عيينة` → `من العيينة`.

**Public accounts**: new `profiles.is_discoverable` column (default `true`,
matching prior de-facto behavior since every account was already globally
searchable with no opt-out). `search_profiles()` now filters on it. The
"الخصوصية" row in حسابي — previously a dead `قريبًا` placeholder — is now a
real toggle (`togglePublicAccount()`), optimistically updated with rollback
on failure.

**Home compaction**: "آخر شيء علق معك" now clamps to 2 lines
(`-webkit-line-clamp`) with a real "عرض المزيد"/"عرض أقل" toggle
(`wireHomeReflection()`), shown only when the text actually overflows.
**Bug caught during QA**: the overflow-check first ran before the screen
element was attached to the DOM, so `scrollHeight` always read 0 and the
button never appeared regardless of text length — fixed by moving the wiring
call to after `app.appendChild(el)` in `mount()`.

**"بعدها" categories + catalog cleanup**: the genre chips
(رواية/تاريخ/أدب/ثقافة/سيرة) moved from "من مَلفى" (where they didn't
belong — book browsing mixed into the editorial/writing section) to directly
under "بعدها", reusing the existing `data-genre` → Discover-filtered handler
unchanged. Removed three catalog books entirely per the user's request
(كليلة ودمنة، البخلاء، حي بن يقظان) — from `B`, `AUTHORS`, and the `books`
table (verified zero real rows referenced them first). `فكر` dropped from
`GENRES` since no remaining book carries that genre (would've been a
dead-end filter chip).

**منارة**: the "not configured" honesty was already correct — the Edge
Function properly returns `not_configured` when its LLM key is unset, and
the client already shows a real toast, never fakes success.

**Provider switch (same conversation, right after this batch): Anthropic → Google
Gemini.** The user wants a free tier (Anthropic has none, only limited trial
credits), so `summarize-journey` was redeployed (v2) calling
`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`
via `x-goog-api-key` instead of `api.anthropic.com`. Same system prompt,
same "only the user's own text, never the book's" constraint, same
`journey_summaries` upsert — only the model call changed. Env var is now
`GEMINI_API_KEY` (get it free at Google AI Studio, no billing required for
the free tier) instead of `ANTHROPIC_API_KEY` — set the same way, as an Edge
Function secret in the Supabase dashboard, never in client code.

**منارة intro**: `هنا يقف الراوي على أطلال رحلته وتلخيصها.` moved from a
small right-aligned `.meta` line to a dedicated `.menara-intro` treatment —
centered, `--f-d` display serif at 20px/600 weight, generous block padding.

**Light mode headline**: added a single, restrained light-mode-only override
— `.open-q` (the "وش تقرأ اليوم؟" flagship headline) renders in `--khz-txt`
(khuzama purple) instead of plain ink when light mode is active, in both the
system-preference and explicit-choice CSS paths. Deliberately scoped to just
this one headline, not `.h1` globally, per "selected major headlines" /
"restrained" — body text, row labels, and other headings are untouched.

**Real bug found and fixed during QA (not part of the 10 items, but blocking
core functionality)**: `library_entries` and `journey_summaries` had *partial*
unique indexes (`... WHERE book_id IS NOT NULL`) from the Batch 3 custom-books
migration — but Supabase's client `upsert(row, {onConflict:'user_id,book_id'})`
cannot target a partial index (PostgREST requires an exact, non-partial
match), so every "add to library" and every منارة generation attempt was
silently failing with a 400 (`42P10: no unique or exclusion constraint
matching the ON CONFLICT specification`). Fixed by replacing both partial
indexes with plain composite `UNIQUE` constraints — functionally identical
(NULL is still never equal to NULL, so rows using the other FK are naturally
exempt) but a valid upsert target. Confirmed fixed with a real signup →
add-book → journey-entry flow in a live browser session.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit.
2. `get_advisors` (security): same three pre-existing/intentional warnings as
   §17, nothing new.
3. Live QA in a real browser against a throwaway signed-up test account
   (`qa-batch4-test@malfa-test.com`, deleted afterward along with its library/
   journey rows): scripted welcome-timing probe: confirmed onboarding book
   list excludes the 3 removed titles; confirmed "بعدها" chips + rail;
   confirmed "من مَلفى" section intact below it; confirmed حسابي's public/
   private toggle flips real DB state both directions; confirmed the
   reflection clamp/expand/collapse cycle against a real long journey entry;
   confirmed منارة's centered intro and its honest "needs the AI key" toast;
   confirmed light mode's `.open-q` purple tint against otherwise-normal body
   text, and dark mode unaffected.
4. Cleaned up: QA account and all its rows deleted; DB back to just the real
   founder account.

## 19. Active task — welcome on every launch + first-person منارة (2026-08-29)

Applied only to the opening flow and منارة.

**Welcome:** boot now mounts `welcome` before checking Supabase Auth, so the
screen appears for signed-in, signed-out, first-time, and returning users.
Auth/session loading runs behind the welcome screen; after a fixed 3200ms hold,
`finishWelcome()` sends a signed-in user to Home and a signed-out user to Auth.
The logo uses a 4px/0.99-scale, 480ms ease-out reveal; the tagline follows with
a 420ms reveal. The bottom credit is visible from the first frame and reads
exactly `صُنع بحب من عيينة | الرياض`. Reduced-motion keeps all three elements
static and fully visible while preserving the same readable hold.

**منارة:** canonical Edge Function source is now tracked at
`supabase/functions/summarize-journey/index.ts`. The browser sends only the
catalog/custom-book identifier — not the title or any book text. The function
queries only that authenticated user's complete chronological
`journey_entries.note` set and optionally their display name. Its writing prompt
requires first person, preserves the reader's vocabulary, disagreement,
uncertainty, and point of view, forbids outside book knowledge and unsupported
claims, and limits the result to 1–5 concise paragraphs based on source volume.

Every candidate then gets a second Gemini quality pass checking support,
first-person voice, voice preservation, disagreement preservation, concision,
and external/AI-narrator tone. A failed candidate is regenerated once using the
specific issues and checked again; a second failure returns
`quality_check_failed` and is never saved. A local deterministic guard also
rejects explicit third-person labels (`القارئ`, `المستخدم`, `صاحب التجربة`).
The same guard runs before rendering a cached summary: a legacy third-person
row is hidden and the user sees `ولّد منارتك` instead, so the old narrator-style
output cannot remain visible after this release.

**Deployment status:** the consumer HTML is ready for the Git-connected Vercel
deploy. The updated Edge Function source is ready but is not yet the active
Supabase version because this Codex browser session is not authenticated to the
Supabase dashboard and no Supabase deployment connector/CLI is available in the
current environment. Do not claim the new first-person behavior is live until
this exact source is deployed as `summarize-journey` with the existing
server-side `GEMINI_API_KEY` secret unchanged.

**Verification:** `bash v4/build.sh` prints `JS OK`; a real local browser timing
probe confirmed logo opacity rises first, tagline second, the exact bottom line
stays at opacity .75 from the first frame, the screen remains `welcome` through
1500ms, and logged-out routing reaches `auth` after 3200ms. Static checks confirm
welcome is mounted before `getSession()`, the signed-in/out destination branch,
no `book_title` in either request or function, and the full generate → QA →
regenerate → QA gate. Live generated-text comparison remains pending the Edge
Function deployment.

## 20. Production hardening + live end-to-end QA (2026-08-31)

The Batch 19 deployment note above is superseded: the current
`summarize-journey` source is deployed live in Supabase and was verified against
the authenticated QA reader's complete journey.

**Security and dependencies:** consumer/admin now vendor exact
`@supabase/supabase-js` 2.112.4 files locally. Vercel configs contain generated
CSP script hashes, frame denial, HSTS, restrictive permissions policies, and
explicit Supabase-only connect/media sources. Stored user-controlled output is
escaped in account, book, collection, invite, journey, Menara, and admin paths.
Admin data remains behind server-side `is_admin` checks and an immutable
`admin_actions` audit insert; unauthenticated live requests return 401.

**Database/backend:** tracked migrations harden RLS and relationship guards,
add atomic Menara/source-map persistence, immutable admin audit rows, secure
custom-book cover/audio ownership, ten verified starter books, and server-
derived invite title snapshots. All Edge Functions authenticate the JWT inside
the function, keep service-role/Gemini secrets server-side, enforce exact CORS
origins, reject oversized/invalid requests, and return no secret material.

**Live Menara:** one free-tier `gemini-3.6-flash` call organizes only the
authenticated reader's `journey_entries.note` text; neither title nor book text
is sent. Server-side deterministic QA rejects external narrator labels, checks
first-person voice, lexical support, concision, completed paragraphs, and
preservation of uncertainty/disagreement. Every paragraph is linked to the
highest-overlap original entry IDs. If the AI omits a required disagreement
category, an exact sentence from that reader's own source entry is restored
before the result is rechecked; no new idea is invented. Provider failures log
only model/status, and quota exhaustion receives an honest retry message.

Live result passed with two complete first-person paragraphs preserving initial
hesitation, uncertainty, disagreement, changed opinion, and final reservation.
The share checkbox was unchecked by default; checking it opened an editable
review sheet before publishing; cancellation restored the private state. No
shared/public write was made during QA.

**Other verified flows:** welcome appeared for signed-in and signed-out launches
with the exact tagline and bottom credit; real signup/login/no-guest behavior;
per-account library isolation; custom private book + secure cover; accepted
account-name invite; real MediaRecorder audio upload/playback/pause/resume;
completion metrics; compact reflection expansion; category-to-Discover routing;
light/dark themes; empty states; and IBM Arabic Text activation. Ten starter
books use locally stored, source-documented public-domain covers; filler titles
remain absent.

**Final automated checks:** `bash v4/build.sh` → `JS OK` after every change;
`test_xss.py`, `test_security_headers.py`, `test_content_integrity.py`, and the
live `test_edge_boundaries.py` all pass. The GitHub `main` branch and live
Supabase function contain the verified source. The only unrelated untracked
workspace items are `gsap-skills-main/` and its zip; they were never staged.

## 21. جلسة القراءة inside مَلفى (2026-08-31)

Added the complete reading-session experience inside the existing `community`
(مَلفى) tab without adding a primary tab or restructuring its other sections.
The compact card uses the current reading book, page/progress, today's minutes,
reading-day streak, one primary start/continue action, and a secondary summary
link. With no current book it shows one honest empty state and opens the existing
book picker; the picker now prioritizes the user's own saved/manual books and can
start a session immediately after a new manual book is created.

Live session state is persisted under a user-scoped localStorage key. The timer
tracks only visible, explicitly resumed time. `visibilitychange` and `pagehide`
pause a running session before the app backgrounds; reload/crash recovery counts
only through the last persisted heartbeat, then shows the exact calm recovery
notice with `متابعة` / `إنهاء الجلسة`. Unknown background/closed time is never
counted. The distraction-free pushed view contains the book, start page,
prominent timer, pause/resume, and finish action only; bottom navigation is
visually and interactively hidden by the existing pushed-view behavior.

The finish sheet validates the end page, calculates actual duration/pages/speed,
accepts one optional note, and saves locally first. Offline writes queue under a
user-scoped key and upsert by client UUID when connectivity returns. A short
opacity/scale success state uses accurate seconds for sub-minute sessions and no
confetti. The reading summary has one four-value summary card, a 28-day calendar,
recent notes, and editable/deletable session rows. Reading-day streak and goal
achievement are separate; each session snapshots its goal so later goal changes
cannot rewrite history. Goals support 10/20/30/custom plus an average-derived
suggestion. Reminders are off by default, request browser permission only after
explicit enablement, suggest the reader's usual time, and can be disabled or
changed in the same settings sheet.

Database migration `202608310002_reading_sessions.sql` is applied live and
tracked. It adds owner-only `reading_sessions` and `reading_preferences`, forced
RLS, owner immutability, custom-book ownership validation, server timestamps,
server-recalculated pages/speed, and user/date/book indexes. No service-role key
or secret was added to the browser.

QA covered RTL dark/light rendering, start/pause/resume, reload recovery and the
background-stop notice, finish sheet, sub-minute/no-page-progress save, success
state, summary calendar, settings, and edit UI. `test_reading_session_logic.sh`
executes the actual timer helpers extracted from the shipped HTML and verifies
elapsed time, background exclusion, crash recovery, page/speed math, zero-page
sessions, streaks, goal snapshots, and forced RLS. Final checks: `v4/build.sh` →
`JS OK`; reading-session logic, security headers, content integrity, XSS, and
live Edge boundary tests all pass. The consumer CSP hash was regenerated and a
pre-existing typo in its Supabase connect/media host was corrected so production
session queries are not blocked.

## 22. مكتبتي / مَلفى reorganization — books vs. reading practice (2026-09-02/03)

Given directly by the user: split what §21 had made a single, growing مَلفى
tab (session card + مجموعاتي + قوائم من الناس + تجارب مع الكتب) into a clean
division — **مكتبتي = my books and their organization**; **مَلفى = my
reading practice, journey, and personal reading record** — with both tabs
reading/writing the same underlying rows (`library_entries`, `journey_entries`,
`reading_sessions`, `journey_summaries`) rather than either holding a second
copy. No new main tab, no new frontend library.

### Selected-book model (new)

`reading_preferences` gained two nullable FK columns and one nullable int,
additively:

- `selected_book_id text references books(id)` / `selected_user_book_id uuid
  references user_books(id)` — exactly one of the two (or neither), enforced
  by `reading_preferences_one_selected_ck`. The `secure_reading_preference()`
  trigger (already existed for `daily_goal_minutes`/`reminder_*`) was
  extended to also validate that a `selected_user_book_id` actually belongs
  to the row's own `user_id` — same ownership-check shape already used by
  `secure_reading_session()`, not a new pattern.
- `weekly_days_goal integer` (1-7, nullable) — "how many days a week", a
  genuinely new concept distinct from the existing per-session
  `goal_minutes_snapshot`. Left `null` until the reader explicitly picks one
  in the settings sheet; `أيام القراءة` shows only the raw day count until
  then, never an invented default.

Client-side, `selectedBookKey()` (`v4/index.html`) implements the exact
priority the user specified: (1) `READING_ACTIVE.bookId` if a session is
running/restored, (2) the saved `selected_book_id`/`selected_user_book_id`
**if it still resolves** via `myBookView()` (a stale pick — e.g. a deleted
manual book — falls through rather than crashing the UI), (3)
`MY_LIB.reading[0]` (already sorted `updated_at desc` from `loadLibrary()`),
(4) `null`. `saveSelectedBook(bookId)` upserts just those two columns
(`onConflict:'user_id'`, partial payload — Postgres's `ON CONFLICT DO UPDATE
SET` only touches the columns actually sent, so an existing goal/reminder
row is never clobbered). Nothing here ever changes the selection as a
side effect of an unrelated library write — the only writers are the
explicit "كمّل القراءة" / "تبديل الكتاب" / "افتح رحلتك في مَلفى" actions.

**Real bug caught and fixed in the same pass**: the pre-existing
`saveReadingPreferences()` fully *reassigned* `READING_PREF` on every call
(`READING_PREF = {daily_goal_minutes:...}`), silently dropping whatever
selected-book/weekly-goal fields were already loaded into it client-side
until the next full reload. Changed it to mutate the existing object's
fields instead of replacing it, and made the new `weeklyGoal` parameter
optional (`arguments.length>3`) so the two pre-existing call sites (goal-only
and reminder-only updates) keep working unchanged.

### «مكتبتي» — books and organization only

- Primary segments reduced to the three the user asked for: **أقرأ الآن /
  أبي أقرأ / قرأتها** (`next`/`finished` renamed in `SEGS`, `dropped`
  removed from the pill row). Dropped books are **not deleted or
  reclassified** — `dropped` is still a real `library_entries.status` value
  — they're reachable through a secondary "كتب متوقفة" link that just sets
  `libSeg='dropped'` and re-renders; no separate screen, no data loss.
- The "أقرأ الآن" segment gets a real detail row per book instead of the
  generic 3-up grid: cover, title, current page/progress with a bar, a
  **calm text-and-color** "تقرأه الآن" indicator (a dot *and* a label —
  never color alone), the count of unique local-calendar reading days for
  *that* book (`readingDaysForBook(id)`, counts only sessions with
  `duration_sec>0`, never leaks another book's sessions), and one primary
  **«كمّل القراءة»** button.
- `chooseAndGoToMalfa(bookId)` is what "كمّل القراءة" (and the simplified
  book screen's "افتح رحلتك في مَلفى" link) actually calls: if a *different*
  book's session is currently running it refuses and toasts instead of
  silently switching (the same running-session guard as `startReadingSession`
  already used, applied here too), otherwise it calls `saveSelectedBook`
  then `goTab('community')` — a real `pushRoute`, so back-navigation behaves
  normally, and the book is never re-asked-for on the other tab.
- **Book detail screen split in two**, to stop مكتبتي from carrying an
  independent reading-session/journey/منارة experience while reusing every
  underlying row: `bookHTML()` (still reached from مكتبتي's grid) is now
  info/organization only — cover, title, progress, facts, "أنهيت الكتاب.",
  and the one link into مَلفى. The old tab-switcher body (التسجيل الكامل /
  منارة, "سجّل رحلتك", the facts footer) moved verbatim into a new
  `bookJourneyHTML()` (`VIEWS.bookJourney`, pushed), reached only from
  مَلفى's "عرض الرحلة"/"عرض المنارة" links — same render functions
  (`fullJourneyHTML`, `menaraHTML`, `journeyHTML`), same `MY_JOURNEY`/
  `MY_SUMMARIES`, nothing duplicated.
- **Collections** ("Can be opened. Support adding and removing..." — they
  couldn't be opened at all before this): `myCollHTML()` is now a real
  button (`data-collection`) into a new `collectionHTML()` screen
  (`VIEWS.collection`, pushed, `STATE.collection`), listing the collection's
  books with a per-book remove (`data-collectionremove`) and an add entry
  point (`data-collectionadd`) opening a new `collectionpick` sheet — every
  one of the user's own catalog *and* manual books, toggle-able, never
  another user's data (RLS was already private-only; unaffected). Migration
  `collection_books_support_user_books`: dropped and re-added the PK as a
  surrogate `id` (existing rows kept, nothing deleted), added a nullable
  `user_book_id`, made `book_id` nullable, added the same one-of check
  pattern already used elsewhere, two partial unique indexes, and an
  `enforce_collection_book_owner()` trigger (execute revoked from
  `anon`/`authenticated` — it's insert/update-trigger-only, matching the
  project's existing lockdown convention for functions like it).

### «مَلفى» — exactly four sections, in this order

`communityHTML()` rewritten to just: **روتين القراءة → منارة → سجّل رحلتك →
أيام القراءة**. مجموعاتي (duplicate of مكتبتي's), قوائم من الناس, and
تجارب مع الكتب are gone from this screen (their tables/loaders are
untouched — `loadSharedMenaras()`/`PUBLIC_MENARAS` still load, simply
nothing here renders them anymore; no rows were deleted).

1. **روتين القراءة** (`readingRoutineCardHTML()`, renamed from
   `readingSessionCardHTML`): selected book + cover, page/progress, the
   daily goal in minutes, the reminder time *only when enabled*, one primary
   button — "ابدأ القراءة" or "كمّل القراءة" depending on whether a session
   is running for *this* book — and two secondary actions, "تبديل الكتاب"
   and "تعديل الروتين" (opens the pre-existing `reading-settings` sheet).
   A finished selected book shows a clear "خلّصت هذا الكتاب" state with
   "اختر كتابًا ثانيًا" instead of ever silently restarting it. Empty state
   is the user's exact copy: "اختر كتابًا من مكتبتك وابدأ أول جلسة."
2. **منارة** (`menaraPreviewHTML()`): a short preview — first paragraph,
   truncated — of the selected book's cached summary, or an honest "ما فيه
   محطات كافية بعد" / "ما ولّدت منارتك بعد" empty state, never a placeholder
   summary. "عرض المنارة" pushes `bookJourneyHTML` with `bookTab='menara'`
   preset — same generation/editing/privacy/sharing UI as before, just
   reached from here now.
3. **سجّل رحلتك** (`journeyRecordCardHTML()`): selected book + page context,
   one primary "سجّل رحلتك" button and a secondary "اكتب ملاحظة بدلها" link
   — both open the existing voice/type sheet (`data-logbook`, which sets
   `STATE.book`/`STATE.page` first since مَلفى root isn't always reached via
   a book push anymore), which already supports typing as a first-class
   path, not a hidden fallback. "عرض الرحلة" pushes `bookJourneyHTML` with
   `bookTab='full'`.
4. **أيام القراءة** (`readingCalendarHTML(27)`): a real day-status line —
   "قرأت اليوم" / "ما قرأت اليوم بعد" as **text**, plus a distinct "X من Y
   أيام هذا الأسبوع" once `weekly_days_goal` is set (otherwise just the raw
   week day-count, never a guessed goal) — under a 28-day calendar grid. A
   "تفاصيل أكثر" link opens the trimmed `readingSummaryHTML()` (week
   stat card + an 84-day calendar + a link to the settings sheet; آخر
   الملاحظات and the standalone الجلسات الأخيرة list are removed from it —
   every session now lives in its own book's «عرض الرحلة» with edit/delete,
   so a second global copy would just be a duplicate view of the same rows).

### Merged per-book journey (new read model, no duplicate storage)

"عرض الرحلة" needed to show reading_sessions *and* journey_entries for one
book, interleaved by time, with the session rows keeping their existing
edit/delete controls — without turning journey_entries into a second place
that duration lives. `mergedJourneyView(bookId)` does exactly that: maps
`myJourneyView()`'s entries (now carrying a `ts` alongside its existing
display fields) and this book's `MY_READING_SESSIONS` rows into one array,
sorted newest-first; `journeyHTML()` renders session items via a new
`journeySessionRowHTML()` (duration, pages, note, the same
`data-readingedit`/`data-readingdelete` handlers already wired) interleaved
with the existing entry rendering. `fullJourneyHTML()`'s empty-state check
now looks at the merged view's length, not `MY_JOURNEY` alone, so a book
with only sessions and no voice/written notes still shows its real timeline
instead of a false "ما بعد سجّلت رحلة" empty state.

### Dead code removed as a direct consequence

`readingRoutineHTML()` (the old always-rendered inline goal/reminder form —
explicitly disallowed now that editing lives only in the settings sheet)
and its now-unreachable wiring (`updateInlineReadingGoal`,
`updateInlineReadingReminder`, `data-readinggoal`, the
`#readingCustomGoal`/`#readingInlineReminder*` change handlers), plus the
now-unused `readingSessionRowHTML()` (superseded by
`journeySessionRowHTML()`) and its CSS (`.rs-routine*`, `.rs-goal*`,
`.rs-toggle`, `.rs-reminder-time`, `.rs-custom-goal`) were deleted outright,
not commented out.

### Database changes (additive, tracked)

- `20260902120525_reading_preferences_selected_book_and_weekly_goal.sql` —
  `selected_book_id`/`selected_user_book_id`/`weekly_days_goal` +
  constraints + the extended `secure_reading_preference()` trigger.
- `20260902120540_collection_books_support_user_books.sql` — surrogate PK,
  nullable `user_book_id`, one-of check, two partial unique indexes, owner
  trigger. Table had 0 rows at migration time, so this was risk-free.
- `20260902120610_lock_down_collection_book_owner_trigger_fn.sql` — revokes
  public execute on the new trigger function (advisor-flagged, matching the
  project's existing convention for trigger-only functions).

All three were applied live via the Supabase MCP first, then written back
as tracked migration files in `supabase/migrations/` to match the project's
existing convention (confirmed by re-reading `202608310002_reading_sessions.sql`
and its sibling files before starting — they're the source of truth this
repo already keeps, so the applied-but-untracked state would have been a
real gap).

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit.
2. `get_advisors` (security): clean except the same pre-existing warnings
   from earlier batches (narrow-by-design `SECURITY DEFINER` RPCs, the
   leaked-password-protection Auth toggle) — nothing new besides the
   collection-owner trigger warning, which was fixed in the same pass.
3. New `tests/test_library_malfa_reorg.{sh,jxa.js}` — extends the existing
   `test_reading_session_logic` pattern (extract pure functions from the
   shipped HTML by source-text brace matching, `eval` them, assert against
   fixtures) to cover: all four selected-book priority tiers including a
   stale saved-pick fallthrough and "unrelated library write doesn't move
   the selection"; per-book reading-day uniqueness (same-day/same-book
   collapses to one day, zero-duration sessions don't count, another book's
   sessions never leak in); the merged journey view's completeness,
   newest-first ordering, and per-book isolation; and static checks that
   the tracked migrations actually encode the one-of/range constraints and
   the ownership-validation error strings. All pass, alongside the
   pre-existing `test_reading_session_logic.sh`, `test_content_integrity.py`,
   `test_xss.py`, and the live (non-mutating) `test_edge_boundaries.py`.
4. `test_security_headers.py` initially failed on a stale inline-script CSP
   hash (expected — the script changed) — regenerated the SHA-256 and
   updated `v4/vercel.json`; passes now.
5. **Live browser QA was attempted but could not be completed with a fresh
   account in this session**: Supabase Auth now rejects `*.test`/known-fake
   email domains (`email_address_invalid`) — a change from an earlier
   batch's assumption that any address would be accepted — and real-domain
   signup attempts then hit `over_email_send_rate_limit` after a few tries,
   which needs real inbox access to clear (confirm-email could not be
   confirmed off from this session). Reusing one of the two pre-existing
   `malfa-qa-*@example.com` fixture accounts would have needed resetting its
   password directly in `auth.users`, which this session's own safety
   controls correctly declined (credential-adjacent write) — that block was
   respected rather than routed around. **What *is* verified**: full static
   logic coverage above, `bash v4/build.sh` clean, and a direct read of the
   rendered markup/handlers for every new screen and state. **What remains
   unverified by an interactive click-through**: the live visual/DOM
   behavior of أقرأ الآن's new row, «كمّل القراءة»'s tab hand-off, the
   collection open/add/remove sheet, the merged عرض الرحلة timeline, and
   منارة/أيام القراءة previews, against a real signed-in session. The next
   session should either use a real, reachable email address for signup, or
   get the user's explicit go-ahead before touching `auth.users` for an
   existing QA fixture.

### Repo / deploy note

Pushed and live (commit `4bbd660`, right after this section was first
written) at the user's explicit request, once live QA above had already
established what could and couldn't be verified in this environment.
`malfaapp.vercel.app` confirmed serving the new مَلفى order post-deploy.

## 23. سجّل رحلتك → منارة activity order + a real responsive web layout (2026-09-03)

Given directly by the user, two changes on top of §22, both to `v4/index.html`
only — no new files, no separate "web" build.

**Activity order.** منارة is *derived from* سجّل رحلتك, so the interface must
never suggest the reverse. `communityHTML()`'s section order changed from
(روتين القراءة، منارة، سجّل رحلتك، أيام القراءة) to **(روتين القراءة، سجّل
رحلتك، منارة، أيام القراءة)** — سجّل رحلتك now comes first. The book-detail
tab order (التسجيل الكامل before منارة) was already correct and untouched.
Added the actual connective tissue the user asked for: a new skippable
`menara-nudge` sheet — "سجّلت رحلتك... تبي تشوفها الحين؟" / **«أنشئ
منارتك»** primary, "لاحقًا" to dismiss — that opens automatically ~260ms
after a non-onboarding journey entry saves successfully (voice or written;
onboarding's first entry is excluded, since a منارة prompt on someone's very
first recording, before they've even reached Home, would be premature). Every
existing "not enough recorded yet" empty state in منارة (already honest from
earlier batches) was reviewed and left as-is — none of them implied the
reverse order.

**A real responsive web layout — not a second app.** This codebase never had
a separate native app; `v4/index.html` *is* the web product, so "build a
complete web version" means making this one file actually adapt to desktop
and tablet instead of floating a fixed 393px phone-simulator in empty space
above ~520px. Confirmed this is the right reading of the request precisely
because the alternative — a second HTML file/build — would recreate the
"duplicate copy of the same experience" problem this project has spent
several batches actively removing (§22 alone was about collapsing exactly
that kind of duplication). Reusing the one file also means every requirement
about shared auth/database/sync between "app and website" is true by
construction, not by extra plumbing: same `VIEWS`, same Supabase project,
same rows, same session — a reader who resizes their browser mid-session
never leaves the page.

Three tiers, purely CSS + one small class toggle, kept last in the cascade
(moved into the file's final `<style>` block specifically so these rules
reliably win over every base component rule they touch — a real bug caught
during this pass, see below):
- `<=520px` (unchanged): edge-to-edge mobile, exactly as before.
- `521–1023px` (tablet/narrow window): the phone frame becomes fluid up to
  640px instead of a fixed 393px, still a single reading column with the
  bottom tab bar — deliberately *not* given a sidebar, since a 264px rail
  would leave an uncomfortably narrow remainder at tablet-portrait widths.
- `>=1024px` (desktop): the bottom tab bar is replaced by a persistent side
  rail (`.phone.with-nav .tabbar`) built from the exact same `TABS` data and
  `data-tab` click delegation — no router or state changes, only where the
  same markup renders. Content sits in a `minmax(0,760px)` column, centered
  in the remaining space next to the rail, instead of stretching edge to
  edge. Bottom sheets become centered ~480px dialogs (`margin-inline:auto`,
  chosen specifically because the sheet's existing drag-to-dismiss code sets
  `sheet.style.transform` directly for the vertical offset — a `transform`
  based centering trick would have been silently overwritten by that same
  code on the first drag). `.grid3` book grids go to 4 columns since there's
  real width to use. The fake iOS status bar (`9:41`, signal/battery icons)
  is hidden outright above 1024px — it's phone-simulator chrome, meaningless
  in an actual desktop browser tab.

**Real bug caught and fixed while verifying this, not left as a demo-only
approximation**: the side-rail grid was initially applied unconditionally at
the desktop breakpoint, which reserved the full 264px sidebar column even on
screens where the tab bar is deliberately hidden (`PUSHED[name]` — welcome,
auth, onboarding, and other pushed/modal-style screens) — leaving a dead, empty
264px gap and off-center content on exactly the first screen every new
visitor sees. Fixed by having `mount()` toggle a `.with-nav` class on
`.phone` using the same `hide`/`PUSHED[name]` signal it already computes for
the tab bar's own opacity (no new state, no duplicated logic), and scoping
the entire sidebar/grid-column CSS under `.phone.with-nav`; a plain,
un-classed `.phone` at desktop width now just centers its single content
column with no reserved sidebar space. Confirmed via direct `getBoundingClientRect()`
checks at 1440px: before the fix, `.app` sat off-center (416px left margin
vs 264px right); after, it's centered to the pixel.

**Accessibility, addressed rather than assumed**: this was a touch-only
interface before — the only existing `:focus` style anywhere in the file was
on text inputs. Added one global `:focus-visible` ring (keyboard/non-pointer
focus only, so touch and mouse stay quiet) covering every button/link/input/
`[tabindex]` element, plus `.cv` (book covers). Book covers themselves were
the one interactive element in the whole app that was a plain, non-focusable
`<div data-book>` — not a `<button>` — so they were entirely unreachable by
keyboard; added `tabindex="0" role="button"` (with a real `aria-label`
combining title+author on the grid/rail cover, relying on the "now reading"
card's own visible title text for the other two spots) plus one small
`keydown` bridge on the existing `#phone` delegation root that turns Enter/
Space on any `[data-book]` into the same synthetic click already handled —
reusing the routing instead of adding a second copy of it.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit.
2. Full existing suite still passes: `test_library_malfa_reorg.sh`,
   `test_reading_session_logic.sh`, `test_content_integrity.py`,
   `test_xss.py`, `test_edge_boundaries.py` (live, non-mutating).
   `test_security_headers.py` failed twice on a stale CSP hash (expected —
   the script changed twice during this pass) and passed both times after
   regenerating it.
3. Live browser verification at three real widths (375px, 820px, 1440px)
   against a local static server: mobile confirmed pixel-identical to
   before; tablet confirmed the fluid 640px frame with the status bar and
   bottom tab bar intact; desktop confirmed via both screenshots and direct
   `getBoundingClientRect()` reads — the sidebar (mock-populated the same
   way `renderTabs()` would, since a real login still couldn't be completed
   in this session, see §22) sits flush to the inline-end edge in RTL, a
   `.grid3` mock renders 4 equal `170px` columns, and an injected `.sheet`
   centers to `480/480/480` in a 1440px viewport.
4. **Still not verified**: an actual authenticated click-through of the new
   سجّل رحلتك → منارة nudge, or of every real screen at desktop width —
   same signup-rate-limit blocker as §22, unchanged since then. Everything
   above was verified either statically (source-level, build/tests) or via
   direct DOM/CSS inspection of the real shipped markup and mock data
   standing in for a live session, not by guessing.

### Repo / deploy note

Pushed and live at the user's request — `malfaapp.vercel.app` serves this
version. `v4/vercel.json`'s CSP hash was regenerated to match the final
script content.

## 24. Pre-login homepage, redesigned auth, post-login subscriptions (2026-09-03)

### Scope

A full pre-login experience — MALFA had none before this: a signed-out
visitor was dropped straight onto the login form with no explanation of
what the product is. This batch adds a real marketing/product homepage
(`landingHTML()`), redesigns the login/signup/reset screen as a split-screen
editorial layout with a password-visibility toggle, and exposes the real
subscription plans both pre- and post-login from one shared data source.

### Pricing data — a real product decision, not an implementation detail

`plans` had zero rows before this batch, which directly blocked "show the
actual configured pricing, never invented prices." Asked the user; they
chose **trial/temporary prices, clearly labeled** over inventing final
prices or hiding the section. Extended `plans` with the columns a pricing UI
actually needs (`price_amount`, `currency`, `billing_period`, `tagline`,
`features` jsonb, `is_recommended`, `sort_order`, `is_trial_pricing`) and
seeded three real rows — مجاني (free), مَلفى+ شهري (19 SAR/month), مَلفى+
سنوي (149 SAR/year, recommended) — every one flagged `is_trial_pricing:true`
so the UI can render a permanent "سعر تجريبي، غير نهائي" tag rather than
silently presenting a placeholder number as final. `plans_anon_select` makes
this table readable signed-out too, so `landingHTML()` and the post-login
`plansHTML()` both call the same `loadPlans()`/`planCardHTML()` — literally
one function rendering both, not two copies that could drift.

**The one honest free/paid differentiator**: منارة is the only feature with
a real per-call cost (Gemini API). Added `menara_generation_log` (service-
role-only insert, owner-select) and a `SECURITY DEFINER` `activate_trial_plan()`
RPC that performs a real database write — never a fake button — while being
honestly labelled as a no-payment trial (`renewal_status:'trial_no_payment'`).
`summarize-journey` now enforces a 3/month free-tier cap server-side before
calling the model, and logs every successful generation. Client mirrors the
same constant (`FREE_MENARA_LIMIT=3`) purely for display; the enforcement
that matters lives in the Edge Function, not the client.

**Recurring gotcha, hit again**: `CREATE FUNCTION` grants `EXECUTE` to the
`PUBLIC` pseudo-role by default; revoking from `anon` alone leaves `anon`
able to call it anyway (`anon` inherits through `PUBLIC`). Caught via
`get_advisors` flagging both new functions as `anon`-executable despite an
explicit `revoke ... from anon` in the same migration; fixed with a
follow-up migration revoking from `PUBLIC` explicitly and re-granting to
`authenticated` only. Same class of bug as §22's
`enforce_collection_book_owner()` — worth checking proactively on every new
`SECURITY DEFINER` function from now on, not just this one.

### Pre-login homepage (`landingHTML()`)

New `landing` view, now the default destination for signed-out visitors
(`finishWelcome()`'s else-branch, previously `mount('auth')`, now
`mount('landing')`). Built entirely from the existing component language —
`.rs-card`, `bar()`, `cover()`, real catalog books — rather than a parallel
marketing-page style system, per the brief's "reuse the design system"
constraint. Sections, in order: sticky nav (logo, كيف يعمل؟/المزايا/الباقات
in-page links, تسجيل الدخول, ابدأ رحلتك — nav-links collapse below 768px,
login stays reachable at every width); hero with the exact required
headline/subhead and a preview widget built from a real catalog book
(رسالة الغفران) rather than a generic device mockup; the 4-step "كيف تعمل"
section in the exact required order (اقرأ بطريقتك → سجل رحلتك → اصنع
منارتك → ارجع لما بقي معك — سجل رحلتك always precedes منارتك, per the
brief's explicit activity-order constraint); a 6-card benefits grid with the
exact required copy points; a widgets showcase (أقرأ الآن، سجل رحلتك،
منارتك، روتين القراءة، أيام القراءة، plus a سجّلتها-كذا→صارت-منارة
before/after pair) using illustrative sample states that are visually
identical to the real in-app widgets but never claim to be the visitor's
own data (there is no visitor data pre-login); the live pricing section;
a closing CTA; and an honest footer — only real destinations (سياسة
الخصوصية via the existing `privacySheetHTML()`, login/signup, in-page nav)
since the product has no social accounts or contact address to link to yet.

New `wide-content` class-toggle on `.phone` (mirrors §23's `with-nav`
pattern exactly) so `landing`/`auth`/`plans` — none of which use the
with-nav sidebar — get a real wide desktop layout (`.app{width:100%}`)
instead of inheriting the signed-in app's 760px reading column.

### Auth redesign

Split-screen at `>=1024px` (form column, fixed-width up to 480px + a
sticky-free brand visual panel with a quiet منارة-style quote — no device
mockup, no live data claims), single column on mobile/tablet exactly as
before. Added: a password-visibility toggle (new `eyeoff` icon paired with
the existing `eye` icon, `data-pwtoggle`), a back-to-landing control
(`data-authback`, falls back to `mount('landing')` directly when there's no
history depth to pop — covers the password-recovery deep-link and
post-logout paths, which still land on `auth` directly rather than
`landing`), and a restyled inline error banner (`.field-err:not(:empty)` — a
tinted chip instead of bare red text) using the exact same `#authErr`
element and `textContent` assignments as before, so none of the existing
validation call sites needed to change.

**Two real bugs caught during live verification, not shipped**:

1. **Stale scroll on every fresh `landing`/`auth` mount.** A brand-new
   `.screen` element was landing with `scrollTop` near its maximum instead
   of `0` — reproduced even in a freshly opened browser tab, so not an
   artifact of manual testing. Root cause: `history.scrollRestoration`
   defaults to `'auto'`, and this app already does its own scroll
   bookkeeping per screen (`navSnapshot`'s `scroll` field, replayed in
   `restoreRoute`) — the browser's native restoration was fighting that.
   Fixed with one line, `history.scrollRestoration='manual'`, set once at
   boot before the first `pushState`.
2. **`position:sticky` inside a `display:flex` row scrolled the whole
   screen to the bottom on mount.** The auth visual panel was `position:
   sticky; height:100dvh` as a flex sibling of the form column, intending
   to pin it while a long form scrolled past. Its sticky containing block
   was actually `.screen` (the nearest scrolling ancestor — `.auth-col`'s
   own `overflow-y:auto` never mattered, since the visual panel isn't
   inside it), and combined with `.screen`'s pre-existing `padding-bottom:
   56px` desktop convention, laying out the sticky element appears to
   trigger a one-time corrective auto-scroll in this environment. Fixed by
   dropping `position:sticky` entirely — the form realistically never
   exceeds one viewport, so a plain `align-items:stretch` flex row (the
   default) does the same visual job without the bug.

Both were caught by checking real `scrollTop` values via script, not by
eyeballing screenshots — this session's screenshot tool intermittently
returned stale/cached frames after `scrollTop` was set programmatically or
right after a transition-triggering click (confirmed via direct DOM
queries returning correct state while the screenshot still showed the
previous screen) — worth remembering for future verification passes in
this same tool: prefer `get_page_text` / `getBoundingClientRect()` /
`scrollTop` reads over trusting a single screenshot when something looks
wrong, especially right after a click or scroll.

### Post-login subscriptions

New `plansHTML()` ("الباقات والاشتراك", pushed screen, reachable from a new
compact row in `accountHTML()` that shows the current plan name or an
"انتهت باقتك" state inline) — a status card (current plan, trial/active/
expired/cancelled state, expiry date, free-tier منارة usage this month with
a progress bar) followed by the same `planCardHTML()` grid the landing page
uses, in `'account'` mode: the current plan's CTA is disabled
("باقتك الحالية"), every other plan's CTA calls `activatePlan()` →
`activate_trial_plan()` RPC → toast + refresh. Handles the lapsed states
(`status` can be `active|trial|expired|cancelled`, or an unexpired row past
its own `expiry_date`) by falling back to the free-tier quota display,
matching what `summarize-journey` actually enforces server-side — no UI
state that isn't backed by real logic.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit, throughout.
2. Full existing suite passes unchanged: `test_library_malfa_reorg.sh`,
   `test_reading_session_logic.sh`, `test_content_integrity.py`,
   `test_xss.py`, `test_edge_boundaries.py`, `test_security_headers.py`
   (CSP hash regenerated once, at the end, to match the final script).
3. `get_advisors` (security) clean after every new migration, including the
   `PUBLIC`-grant follow-up fix.
4. Live browser verification against a local static server at 390px,
   768px, and 1280–1440px: confirmed no horizontal overflow at any width
   (`scrollWidth<=clientWidth` checked directly, not eyeballed), nav-links
   collapse/expand at the 768px breakpoint, steps/bento grids reflow to
   4/3/1 columns correctly, `data-scrollto` in-page navigation lands within
   a few px of its target section, the password toggle and login/signup/
   back interactions all produce the expected DOM state, and the pricing
   section renders the real three `plans` rows with the trial-price tag —
   confirmed identical between the landing page and (by code review, since
   a real signup still couldn't be completed — same blocker as §22) the
   post-login `plansHTML()`, which shares the same render function.
5. **Still not verified**: an actual authenticated run through `plansHTML()`
   /`accountHTML()`'s new plan widget, or `activate_trial_plan()`'s success
   path — same signup-rate-limit blocker as §22/§23. Confirmed instead via
   `get_advisors`, direct SQL reads of `plans`/`user_plans`, and code review
   that `plansHTML()`/`acctPlanWidgetHTML()` use the exact same `PLANS`/
   `MY_PLAN` state and `planCardHTML()` renderer already verified working
   pre-login.

### Repo / deploy note

Not yet pushed — awaiting the user's go-ahead, per this session's standing
practice of asking before every push rather than assuming prior approval
carries forward. `v4/vercel.json`'s CSP hash was regenerated to match the
final script content. `deploy/index.html` was left untouched: its own git
history shows it hasn't tracked `v4/index.html` for several batches now
(last touched at §15, while `v4/` has moved through §16–23 since), and the
repo has a real GitHub→Vercel connection (`origin` →
`github.com/Talal-ops1/Malfa`) — `v4/` is the live-served directory, not
`deploy/`, which looks like a leftover from an earlier manual-drag-and-drop
phase. Left it alone rather than guessing at a cleanup that wasn't asked
for.

## 25. HUMAIN-inspired section, rolling books, real pricing, القراءة مع شخص paywall (2026-09-03)

### Scope

Five requirements landed together this batch: a HUMAIN-structured "رحلات
متعددة. مَلفى واحد." section on the homepage, a continuously rolling
books showcase, a real (not trial-labeled) pricing structure with a
9.66/96.60 SAR nod to +966, a hard server-enforced paywall on القراءة مع
شخص and منارة, and a spelling regression fix for العيينة that had crept
back into the welcome screen.

### العيينة — a regression, not a first-time typo

`grep`-ing the whole project found exactly one live occurrence, in
`welcomeHTML()`, missing the ال: `من عيينة` instead of `من العيينة`. The
handoff log itself shows this was already correct as of §18 and even had an
explicit prior correction logged (`من عيينة → من العيينة`) — §19 then
re-introduced the wrong spelling when it rewrote the welcome screen, and it
shipped that way for several batches. Fixed the live string, and fixed
`tests/test_content_integrity.py` too: it had been asserting the *wrong*
spelling as a regression guard (`assert "صُنع بحب من عيينة | الرياض" in
HTML`) — encoding the bug as the expected behavior. Flipped it to assert
the correct spelling and assert the wrong one is *absent*, so this can't
silently regress a third time. The landing page footer never had this
signature at all before this batch; added it there too, since the brief
requires it on the pre-login homepage specifically.

### Real pricing — no longer trial-labeled

Previous batch (§24) seeded `plans` with clearly-labeled placeholder trial
prices, per an explicit product decision at the time (no exact prices were
available yet). This batch's brief supplied real, final numbers — مجاني
free, مَلفى+ 9.66 SAR/month, 96.60 SAR/year, chosen specifically to echo
Saudi Arabia's +966 — and explicit instructions to keep exactly these two
decimal amounts on the website "whenever technically and commercially
possible." Read as superseding the earlier trial framing rather than
adding to it: updated the three `plans` rows (`price_amount`, `features`,
`tagline`) and set `is_trial_pricing:false` on all of them, so the "سعر
تجريبي، غير نهائي" tag stops rendering.

**Real bug caught while wiring this up**: `fmtPrice()` used
`n.toLocaleString('ar-SA')`, which renders Arabic-Indic numerals with an
Arabic decimal separator (e.g. `٩٦٫٦٠`) — but literally everywhere else in
the app, numbers are plain ASCII digits from direct string concatenation
(`62+'%'`, `ص 210 من 260`, etc.), never `toLocaleString`. The trial prices
happened to be whole numbers (19, 149) so this never showed visually before;
9.66/96.60 would have been the first prices to expose the inconsistency.
Rewrote `fmtPrice()`/`fmtPriceValue()` to always emit plain ASCII with
exactly two decimals when the amount isn't whole (`96.60`, never `96.6`,
per the brief's explicit instruction on that point) and a real Arabic
currency label (`ر.س`) instead of the raw ISO code `SAR`.

Added, all computed from `plans.price_amount` rather than hand-typed twice:
the annual card's "الأكثر توفيرًا" badge (replacing the old "الأنسب
لقارئ منتظم" wording per the brief), a "شهران مجانًا · 8.05 ر.س/شهر" line
(8.05 = 96.60/12, computed, not hardcoded — verified exact: 9.66×12−96.60 =
19.32 = exactly 2× 9.66), a "تُدفع 96.60 ر.س مرة واحدة سنويًا" billing-
clarity line, and — on the monthly card only, once, understated — "اشتراك
سعودي بسعر يحمل رمزه." No flags, no green, no repetition across cards.

Added a real feature-comparison table (`pricingComparisonTableHTML()`,
the exact 8-row list from the brief) as a proper `<table>` inside its own
`overflow-x:auto` wrapper (the project's established convention for wide
content), rendered identically by both `landingPlansHTML()` (pre-login) and
`plansHTML()` (post-login) — same function, same markup, so the two can
never disagree.

### القراءة مع شخص and منارة — real paywalls, not UI theater

**Client**: both entry points to شخص (home's "اقرأ الكتاب نفسه مع صديق"
row, اكتشف's bottom CTA) now show a small `مَلفى+` lock badge when
`!planIsPaidActive(MY_PLAN)`, and clicking them opens a new bottom-sheet
mode (`upgrade`) with the brief's exact copy instead of navigating — unless
the reader already has a pending *received* invite, in which case they can
still reach the شخص screen to see who invited them (required by the brief:
"show the invitation context first"), with the accept button itself gated
instead. منارة generation (`data-genmenara`) is now hidden entirely for
free readers, replaced with the same upgrade-sheet trigger; a منارة already
generated while the reader was on a paid plan stays fully readable after
the plan lapses (existing content is never hidden or deleted), only *new*
generation is blocked. The one shared `upgradeSheetHTML()` branches its
copy by `SHEET_CTX.feature` (`'friend'` uses the brief's exact required
text; `'menara'` gets its own equivalent line) so the same sheet serves
both features honestly instead of showing the شخص copy when the trigger
was actually منارة. `PENDING_RETURN` remembers where the reader was
before the upgrade sheet opened, so a successful `activatePlan()` drops
them back at شخص automatically instead of stranding them on الباقات.

**Server, not just client** (the brief is explicit that a hidden button is
not enforcement): three real changes, none of them optional client-side
checks.
1. `summarize-journey` — removed the previous "3 free/month" metered
   allowance entirely (that was §24's honest differentiator; this batch's
   pricing brief moves منارة to a hard مَلفى+-only feature, not a metered
   free one) and replaced it with a flat `if (!paid) return 402
   plan_required`. The now-unused `menara_generation_log`-quota query and
   `FREE_MONTHLY_LIMIT` constant were deleted rather than left as dead code.
2. `reading_invites` RLS — `invites_sender_insert`'s `with_check` now also
   requires `has_active_paid_plan(auth.uid())`; `invites_recipient_update`'s
   `with_check` allows declining unconditionally (a free recipient can
   always dismiss an invite they can't act on) but requires *both*
   `to_user_id` and `from_user_id` to currently hold a paid plan before
   allowing `status='accepted'` — satisfies the brief's "both participants
   must have an active subscription to enter the shared-reading space."
3. `shared_reading_progress()` — added the same both-sides-paid check to
   its `where` clause. If either side's subscription lapses, that pair's
   row simply stops being returned — `reading_invites` and
   `library_entries`/`journey_entries` rows are never touched, so access
   restores automatically and silently the moment they resubscribe,
   satisfying "preserve existing shared-reading data" and "restore access"
   as one mechanism rather than two.

New `has_active_paid_plan(uuid)` — `SECURITY DEFINER`, returns only a
boolean, needed because checking whether the *other* party in an invite is
paid requires reading past their own `user_plans` row (RLS would otherwise
block it). **Same PUBLIC-grant class of bug as §22/§24, but a new variant
this time**: `revoke ... from public` alone left `anon` still able to
execute it — `information_schema.routine_privileges` showed `anon` with a
direct `EXECUTE` grant untouched by the public-only revoke, meaning this
project also grants `EXECUTE` to `anon` directly on new functions (likely
via `ALTER DEFAULT PRIVILEGES` configured early in the project), separate
from the PUBLIC-pseudo-role inheritance already documented. Fixed with an
explicit `revoke ... from anon` *in addition to* `revoke ... from public`
on both this function and `shared_reading_progress()`; verified via
`information_schema.routine_privileges` (not just `get_advisors`, which
had shown `shared_reading_progress()` as already anon-safe despite the
same missing revoke — the two checks don't always agree, so both are worth
running). **Standing lesson updated**: every new `SECURITY DEFINER`
function in this project needs both `revoke ... from anon` and
`revoke ... from public`, not either alone.

### HUMAIN-inspired رحلات متعددة section

New `landingJourneysHTML()`: small eyebrow ("كل ما تقرأه، يعود إليك"),
one very large headline ("رحلات متعددة.<br>مَلفى واحد.", 40px→64px across
breakpoints), a short supporting line, then four full-width panels in a
1→2→4-column responsive grid, numbered `01`–`04`. The four panels are
**مكتبتي, سجل رحلتك, منارة, أيام القراءة** — that exact set and order,
per the brief, which is also the strictest reading of "سجل رحلتك must
never appear before منارة": this section puts them adjacent and in the
required sequence explicitly, not just avoiding a violation elsewhere.
Deliberately does not reuse HUMAIN's own layout values (their exact type
scale, spacing, panel treatment) — translated the *structure* (eyebrow →
huge headline → short copy → full-width panel row) into مَلفى's existing
tokens (`--f-d`, `--khz`, `.lp-card-ic`, the same panel/border/radius
language already used by `.lp-card` elsewhere on the page).

### Rolling books

New `landingRollingBooksHTML()`, positioned right after the hero per the
required page order. **Real titles and real authors only — no scraped
publisher cover photography.** مَلفى has no license to reproduce cover
art from contemporary Saudi, Arabic, or international books, and the
brief is explicit that covers must be "legally displayable" — so instead
of fetching third-party images (which this session has no vetted, licensed
source for), every book is rendered through مَلفى's own existing
illustrated-cover system (`​.cv.l-type` — paper-stock color, spine rule,
typeset title/author), the exact same component already used for every
real book cover in the product. This keeps every title/author pair
genuine and verifiable (26 books: 8 Saudi authors, 5 Arabic literary
classics, 5 Arabic historical/cultural works, 8 international classics)
while producing zero copyright exposure, since no third-party artwork is
reproduced — only factual bibliographic data, rendered in مَلفى's own
visual language. Two rows scroll in opposite directions
(`rbScrollL`/`rbScrollR` keyframes, physical-axis `translateX` so the
opposite-direction effect holds regardless of the page's RTL flex
direction), each row's content duplicated once and shifted exactly `-50%`
for a mathematically seamless loop with no visible jump. Paused on
`:hover`/`:focus-visible`/`:active` (covers mouse, keyboard, and touch-tap
without a single line of JS). Two full DOM structures ship together — the
animated marquee and a static grid — and a single `prefers-reduced-motion`
media query swaps which one is `display:none`, so it responds live to an
OS-level setting change without any `matchMedia` JS. The marquee's
duplicated second copy of each row is `aria-hidden="true"` to avoid
double-announcing identical `role="img" aria-label="title — author"` covers
to screen readers; the reduced-motion grid needs no such treatment since
it never duplicates.

Two titles from an early draft of this list — كليلة ودمنة and البخلاء —
turned out to be on `test_content_integrity.py`'s forbidden-copy list (both
were cut from the starter catalog during an earlier content-curation pass,
per §-something before this handoff's current numbering, and the test
guards against them silently reappearing anywhere in the shipped file).
Swapped them for العقد الفريد and الأدب الكبير — both already real,
already-verified titles present in the product's own `B` catalog — rather
than arguing with a pre-existing regression guard that's doing its job
correctly.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit, throughout.
2. Full existing suite passes, including the two tests that legitimately
   needed updating for this batch's own changes (not loosened, tightened):
   `test_content_integrity.py`'s العيينة assertion flipped to the correct
   spelling plus a new negative assertion against the old one; its
   forbidden-title list caught a real mistake in the rolling-books draft
   list before it shipped. `test_security_headers.py` passed after the CSP
   hash was regenerated once, at the end, to match the final script.
   `test_library_malfa_reorg.sh`, `test_reading_session_logic.sh`,
   `test_xss.py`, `test_edge_boundaries.py` all pass unchanged.
3. `get_advisors` (security) clean of anything introduced this batch,
   including the anon-direct-grant follow-up fix; cross-checked against
   `information_schema.routine_privileges` directly rather than trusting
   only one signal, per the lesson learned mid-batch.
4. Live browser verification against a local static server at 390px,
   768px, and 1440px: confirmed no horizontal overflow at any width
   (`scrollWidth<=clientWidth`, checked directly), the HUMAIN panel grid
   reflows 1→2→4 columns at the documented breakpoints, the rolling-books
   grid reflows 3→5 columns under reduced motion, pricing renders exactly
   `9.66 ر.س`, `96.60 ر.س`, `شهران مجانًا · 8.05 ر.س/شهر`, and `تُدفع
   96.60 ر.س مرة واحدة سنويًا` (ASCII digits, correct decimals, no
   Arabic-Indic regression), and page composition order matches the brief
   exactly (nav → hero → rolling books → رحلات متعددة → كيف يعمل مَلفى →
   بنتو/widgets → plans → closing → footer with صُنع بحب من العيينة).
   Caught and fixed one real rendering-order confusion during this pass
   (a stale screenshot briefly suggested a large layout gap in the rolling
   books section; `getBoundingClientRect()` on the actual elements showed
   the gap was ~50px, not several hundred — a screenshot-timing artifact
   of this session's tooling, not a real bug, confirmed before moving on
   rather than "fixing" something that wasn't broken).
5. **Still not verified**: an actual authenticated click-through of the
   شخص/منارة paywall UI, `activatePlan()`'s `PENDING_RETURN` round-trip,
   or accepting/declining a real invite as a free vs. paid user — same
   signup-rate-limit blocker as every prior batch. Covered instead by: the
   RLS/RPC changes tested directly via SQL and `information_schema`, the
   Edge Function's new `plan_required` path read against its exact
   deployed source, and code review confirming `friendHTML()`/
   `menaraHTML()`'s free/paid branches both compile and both reference
   real, existing state (`MY_PLAN`, `MY_INVITES_RECEIVED`) rather than
   anything new that could be silently undefined.

### Repo / deploy note

Not yet pushed — awaiting the user's go-ahead. `supabase/functions/
summarize-journey` was deployed live (version 22) since Edge Functions
have no separate "staged" state to preview from. `v4/vercel.json`'s CSP
hash was regenerated to match the final script content.

## 26. HUMAIN row layout for المزايا, pricing-card polish, rolling-books trim (2026-09-03)

Follow-up to §25, from direct user feedback on a screenshot of the shipped
landing page (comparing HUMAIN's real "Unified purpose" section against
مَلفى's own rolling-books row). Three small, targeted changes:

- Dropped the first two rolling-book covers (ترمي بشرر، بنات الرياض) per
  explicit request — 24 titles remain.
- Rebuilt `landingBentoHTML()` (المزايا) from a 3-column card grid into
  HUMAIN's actual layout: full-width rows alternating icon side left/right,
  divided by hairlines, each with a short overline + bold title +
  description — translated into مَلفى's own tokens (`--khz` icon panel,
  `--f-d`/`--f-u` type), not HUMAIN's colors or copy. `.lp-bento`/`.lp-card`
  (the old grid/card classes) removed as dead code; `.lp-card-ic` kept
  since رحلات متعددة's panels (§25) still use it.
- Refined `.plan-card`/`.cmp-table` with restrained "Emil Kowalski"-style
  polish, per explicit reference: subtle hover lift (`translateY(-3px)` +
  layered soft shadow) using the app's own `--t2`/`--ease-out` motion
  tokens rather than new arbitrary values, circular check badges in the
  feature list (had to move the check icon out of `.plan-features li .ic`
  into a dedicated `.feat-check` wrapper, since `ic()` sets width/height as
  an *inline* style that would have overridden any CSS-only circle sizing),
  and a bordered/hover-tinted comparison table.

Verification: `bash v4/build.sh`, full test suite, live check at
390/768/1280px (no overflow, alternating rows confirmed via
`getBoundingClientRect()` left/right positions, not just eyeballed).
Pushed live (commit `3d18087`).

## 27. Post-login web redesign — hero, من مَلفى grid, شارك بإثراء CTA, أيام القراءة (2026-09-03)

### Scope

Unlike §22–26 (all pre-login/landing work), this batch is entirely about
the **signed-in** desktop/web experience: a proper full-width hero on
الرئيسية, a two-column «من مَلفى» grid, a highlighted «شارك بإثراء مَلفى»
CTA, and a real calendar-month «أيام القراءة» with a prominent streak —
using Thmanyah's editorial clarity (generous whitespace, structured
sections, confident headlines) as a reference, translated into مَلفى's
own lavender/literary identity, never copying Thmanyah's components.

### A real visual-QA problem, and how it was solved this time

Every prior batch in this project has had the same honest caveat: no real
signup could be completed in this environment, so authenticated screens
were verified by code review and DOM/CSS inspection of mock-populated
elements, never a live screenshot of the real render. That was an
acceptable trade-off for backend/logic-heavy batches, but this batch is
*purely visual* — shipping it on code review alone would have been
irresponsible.

Fix: added a temporary, clearly-scoped mock-boot branch —
`if(location.search.indexOf('mock=1')>-1){...}` right where
`BOOT_READY=sb.auth.getSession()...` normally runs — that populated `ME`,
`MY_NAME`, `MY_LIB`, `MY_JOURNEY`, `MY_READING_SESSIONS` (a realistic
2-day streak plus one intentionally-skipped day, to exercise all four
calendar day-states), and `MY_PLAN` (paid, to confirm the شخص/منارة
paywall UI correctly shows *unlocked*) directly, then called
`finishWelcome()` — bypassing the network entirely, no real Supabase
session needed. Verified every redesigned section this way at 390/768/
1280px, in **both dark and light mode**, then removed the entire block
before committing (`git diff` on the boot section confirmed byte-identical
to before). The resulting 400 console errors from the mock session's
invalid non-UUID `user_id` (expected — background queries keyed on
`ME.id='mock-user'` fail their `uuid` type check) were confirmed to be
scoped only to that testing tab, not a real regression, by opening a
fresh tab and confirming zero console errors there. Worth reusing this
exact technique for any future purely-visual post-login batch.

### 1–2. Hero and desktop layout

`.phone.with-nav`'s content column widened 760px→860px (1024–1439px) and
→960px at 1440px+ (sidebar itself grows 264px→280px at that tier) — a
system-wide change affecting every post-login screen uniformly, which is
the tractable way to satisfy "redesign and polish all post-login pages...
generous whitespace" without bespoke work on every single screen.

`homeHTML()`'s greeting block becomes a real hero (`.home-hero`): a subtle
radial-glow background wash (same technique as the pre-login `.lp-hero`,
scaled down), the headline bumped 31px→34px (38px at desktop) via a new
`.home-hero-q` modifier stacked onto the existing `.open-q` class (kept
`.open-q` itself unchanged since `onboardBookHTML()` also uses it and
didn't need to grow), and — this is the structural change — the
"اقرأ من كتابك" action promoted from a plain list row to the section's one
filled `.btn`, i.e. an actual primary CTA instead of three visually-equal
rows. The other two actions (اقرأ مع صديق، شارك التجربة) stay as secondary
rows beneath it. No card border anywhere in the hero — full-bleed within
the content column, not a boxed/side-aligned widget, per the explicit
"not a side-aligned card" requirement.

### 3–4. «من مَلفى» grid and «شارك بإثراء» CTA

New `.topic-grid`/`.topic-card` (replacing the old `.erow` list rows,
which are now fully dead — removed) renders `TOPIC_ORDER`'s topics as a
responsive 2-column grid (1 column below 521px, matching the app's
existing tablet-breakpoint convention), used identically in both
`homeHTML()` and `discoverHTML()`'s «من مَلفى» sections so the same
content never looks different in two places. Only 4 real topics exist
(`TOPIC_PAGES`/`TOPIC_ORDER`) — rendered as 2 rows of 2, the same grid
mechanism the brief's "2–2–2" describes; did not invent 2 fake topics
just to hit a literal 3-row count, since honest-content-only is a
standing rule in this project (`test_content_integrity.py`'s own filler
check exists for exactly this reason).

New `.share-cta`: a bordered, softly khz-tinted card (not a hard-color
block) with an icon, a one-line explanation of what to contribute, and a
filled button — visually distinct enough to invite a tap, restrained
enough to still read as editorial rather than an ad banner.

### 5. «أيام القراءة»

`readingCalendarHTML()` rewritten from a rolling N-day strip (callers
passed `27` or `83` as a day count) into a real weekday-aligned calendar
for the *current* month — leading blank cells so الأحد always lands in
the same column, four explicit day states (`.read`, `.today`, `.missed`,
`.future`, plus the existing `.goal` modifier), a header row showing the
month name + year (`AR_MONTHS[month]+' '+year`) beside a prominent streak
block reusing `readingStreaks().current` (already computed, previously
shown nowhere in the UI — only `.best` appeared, in the summary stats
row). Empty state when `current===0`: "ابدأ اليوم عشان تبدأ سلسلتك"
instead of a bare `0`. Both call sites (`communityHTML()`'s مَلفى tab,
`readingSummaryHTML()`'s detail screen) updated to the new no-argument
signature — a single component now, not two different views of the same
data.

### Verification

1. `bash v4/build.sh` → `JS OK` after every edit.
2. Full existing suite passes unchanged: `test_library_malfa_reorg.sh`,
   `test_reading_session_logic.sh`, `test_content_integrity.py`,
   `test_xss.py`, `test_edge_boundaries.py`, `test_security_headers.py`
   (CSP hash regenerated once, at the end).
3. Live mock-session verification (see above) at 390px, 768px, and
   1280px, dark and light: confirmed no horizontal overflow anywhere
   (`scrollWidth<=clientWidth`, checked directly) on الرئيسية, مَلفى،
   مكتبتي، اكتشف، حسابي; the topic grid collapses 2→1 columns at the
   documented breakpoint; all four calendar day-states render with
   visually distinct treatment (confirmed via both `className` inspection
   and screenshot); the streak number and empty state both render
   correctly; the شخص paywall lock badge correctly stays hidden for the
   mock paid plan (confirming the redesign didn't regress §25's paywall
   logic); light mode's `.open-q` color rule still applies through the
   new `.home-hero-q` modifier class.
4. **Still not verified**: a real authenticated session end-to-end
   (mock data stands in, as described above — this is a simulated
   render of the real code paths, not a live account).

### Repo / deploy note

Not yet pushed — awaiting the user's go-ahead. No Supabase/Edge Function
changes this batch (pure client-side layout). `v4/vercel.json`'s CSP hash
was regenerated to match the final script content.

## 28. Fix the empty desktop void, HUMAIN icon vibrancy/closeness (2026-09-03)

Direct follow-up to §27, from the user pointing at a real screenshot of a
post-login screen (not a mock) plus HUMAIN's actual "Data Platform /
Infrastructure" rows side by side.

**The real bug**: at common desktop widths (1440px was the one shown),
`.phone.with-nav`'s three-track grid (`264px minmax(0,860px) 1fr`) left the
whole *third* track — up to ~200px — as flat, undifferentiated empty space
on one side only, because the sidebar (track 1) sits flush against its own
edge while the content column (track 2) has a small fixed cap, dumping all
the slack into a single unstyled void rather than distributing it. Verified
this by reproducing it live (mock harness, see §27) and reading
`.app`'s `getBoundingClientRect()` directly: at 1440px, content spanned only
x:156–1016, leaving x:0–156 dead. Not a "generous margin" — genuinely
unbalanced and looked unfinished, exactly as reported.

Fix: widened the content track so it fills the viewport with zero slack at
the breakpoint's own reference width — `1024–1439px` tier now
`minmax(0,1000px)`, `1440px+` tier now `280px + minmax(0,1160px)` (sums to
exactly 1440, so *at* 1440px specifically there's no leftover void at all;
wider screens still get a reasonable, now much smaller, margin rather than
a jarring 200px gap). Re-verified the same way: `.app` now spans
x:0–1160 at 1440px, sidebar 1160–1440, no gap.

**المزايا row styling**, per the HUMAIN screenshot comparison: two real
gaps from what was shipped in §26 versus the actual reference —
1. Icon color was a pale, transparency-mixed tint (`color-mix(...26%,
   transparent)`) — nothing like HUMAIN's fully-saturated gradient boxes.
   Changed `.lp-row-ic` to a solid `linear-gradient(155deg,var(--khz-lift),
   var(--khz))` fill with a white icon and a soft matching drop shadow —
   vibrant, still مَلفى's own lavender rather than HUMAIN's teal/green.
2. Desktop rows used `justify-content:space-between`, stretching the icon
   and text to the row's two extremes — HUMAIN's actual composition keeps
   icon and text close together as one visual unit (with the *row* only
   using as much width as that unit needs, not the full container).
   Changed to `justify-content:flex-start` with a tighter `28px` gap; the
   existing `.rev` row-reverse class still produces the alternating-side
   effect, just with icon+text grouped instead of pulled apart.

Gave `.share-cta` (شارك بإثراء مَلفى) the same vibrant icon treatment
(`.share-cta-ic`, 52px, same gradient) instead of the old pale
`.lp-card-ic`, for visual consistency with the newly-vibrant المزايا rows
— the user re-supplied its exact copy as confirmation of what to keep; it
was already correct, this batch only improved the icon/spacing around it.

Also removed the rolling-books section's small eyebrow line ("مكتبة تكبر
معك") per explicit "احذف" instruction — kept the section's actual
headline ("كتب سعودية وعربية وعالمية، كلها في مَلفى") since only the
eyebrow was named.

### Verification

Same mock-session technique as §27 (temporarily reinstated, fully removed
before this commit — `git diff` on the boot section confirmed empty).
Checked at 1440px (the width the user's screenshot was taken at) and
390px: void confirmed gone via direct `getBoundingClientRect()` reads (not
just a screenshot), rows confirmed grouped via the same, `bash
v4/build.sh`, full test suite, and `test_security_headers.py` after
regenerating the CSP hash — all pass.

### Repo / deploy note

Not yet pushed — awaiting the user's go-ahead. Pure client-side CSS/copy
change, no Supabase/Edge Function changes. `v4/vercel.json`'s CSP hash
regenerated to match the final script content.

## 29. Full product audit — architecture, navigation, security, legal, a11y, QA (2026-09-03)

### Scope

A five-hat audit request (architect / iOS+UX consultant / legal-compliance
reviewer / QA manager / Saudi product strategist), asking for a genuine
inspect-then-fix pass across the whole product rather than a redesign. Given
this is a single-file client with no native iOS binary, framed every
iOS-native requirement (Sign in with Apple, App Store review, native
haptics/gesture handoff) as "translate to the nearest correct web
equivalent, flag what only a native wrapper can actually satisfy" rather
than pretending to build a native app inside a browser tab. Loaded and
applied `emil-design-eng` and `apple-design` skills throughout, as required.

Delegated the full Supabase security/RLS audit (every table's policies,
every `SECURITY DEFINER` function's grants, all 6 Edge Functions' CORS/JWT
handling, a cross-user data-leak trace) to a background agent so the deep
`information_schema`/advisor querying didn't bloat the main session — its
report is what surfaced both real findings below. Did NOT trust the report
blind: independently re-verified the CORS "mismatch" it flagged and found
it was a non-issue (`malfaapp.vercel.app`/`malfaappl.vercel.app` are two
real separate deployments — consumer app vs. admin dashboard — confirmed
via `CLAUDE_CODE_HANDOFF.md` §17's own record of connecting Vercel Git
integration for both), which the sub-agent had no way to know from SQL
alone. Worth remembering: a sub-agent's DB-level findings can still need a
repo-history cross-check before acting on them.

### Findings fixed this batch

**Security (4th recurrence of a known bug class)**: `enforce_collection_book_owner()`
had `EXECUTE` revoked from `anon`/`authenticated` but never from the
Postgres `PUBLIC` pseudo-role — the exact "revoke from anon ≠ revoke from
PUBLIC" gotcha this project has now hit four times (§22, §24, §25 all
document earlier occurrences on other functions). Fixed:
`revoke execute on function public.enforce_collection_book_owner() from public;`.
Also closed a related, narrower gap the audit surfaced:
`has_active_paid_plan(uuid)` was correctly `authenticated`-only but had no
relationship check, so any signed-in user could probe an arbitrary user's
paid-plan status. Rewrote it to return `false` unless the target is the
caller or an existing `reading_invites` counterpart — checked all three
real call sites (invite-send, invite-accept, `shared_reading_progress()`)
first to confirm none of them needed the removed access.

**Safe areas**: the viewport meta tag already had `viewport-fit=cover`
(opting into edge-to-edge layout) but nothing ever read
`env(safe-area-inset-*)`. The existing hardcoded values (`.tabbar`'s 84px,
`.sheet`'s 34px bottom padding) turned out to already match the standard
home-indicator inset on every current notched iPhone — someone had tuned
these by hand correctly at some point — so this wasn't visibly broken
today, but silently wasted ~34px on an iPhone SE and would clip on any
future device with a taller inset. Fixed with `max(existing-px,
env(safe-area-inset-*))` on `.statusbar`, `.app`'s top offset, `.tabbar`,
and `.sheet` — mathematically a no-op on today's devices
(`max(84px,50+34px)=84px`, verified), only ever grows beyond what's
already correct, never shrinks it.

**VoiceOver could reach content behind an open sheet**: `openSheet()`
already did focus-save/restore and set `aria-hidden` on the sheet itself
correctly (good prior work), but never hid `#app`/`#tabbar` behind it.
Added `inert` + `aria-hidden="true"` on both for the sheet's lifetime,
removed on every close path.

**Real data-loss bug, the most consequential fix this batch**: the سجّل
رحلتك voice/text sheet had four independent dismiss paths — the "مو
الحين" button, a backdrop tap, Escape, and swipe-down — and none of them
checked for an unsaved recording or typed draft first. Built one guard,
`attemptCloseSheet()`, that all four now route through: if there's an
unsaved recording (`recordedBlob`) or non-empty `#vTxt` text, it shows
"تتجاهل اللي سجّلته؟" instead of closing. The confirm UI is a hidden
*sibling* panel inside the same sheet markup (`#discardConfirm`), toggled
via `display`, deliberately never an `innerHTML` swap of the live form —
swapping would destroy and need to re-wire the mic/save button listeners
that `openSheet()`'s big if-block only attaches once. Verified live: typed
text survives a full close→confirm→"أكمل الكتابة" round trip byte-for-byte,
and `inert` is correctly toggled throughout (on while confirming, off after
either resolution).

**Fake metric removed**: the notification bell's red unread-dot (`.badge`)
had no conditional logic anywhere in the file — it rendered unconditionally
for every user regardless of whether anything had happened, since there is
no notifications table or generator behind it at all. The bell's own tap
handler was already honest (a static "no new notifications" toast); the
badge wasn't. Removed the element and its now-dead CSS.

### Findings traced and confirmed correct, not changed

Single source of truth for reading progress (`MY_PROGRESS`) verified
directly used, unduplicated, by all three surfaces that show it
(الرئيسية's continue card, مَلفى's روتين card, مكتبتي's "تقرأه الآن"
row) — traced each render function rather than assuming. Zero dead
buttons found across all 68 distinct `data-*` actions in the file (2
apparent non-matches were confirmed to be non-click attributes: a CSS
`content:attr()` hook and a form-value carrier read via `.dataset` in a
`change` listener, not orphaned click targets). Button press feedback,
swipe-dismiss momentum projection, and `prefers-reduced-motion` coverage
all independently checked against the Emil Kowalski / Apple
fluid-interfaces references loaded for this task and found already
correct — noted explicitly in the handoff artifact so this existing
quality isn't mistaken for something newly added.

### Findings flagged, not fixed (documented reasoning, not silent gaps)

Dynamic Type / rem migration (every font-size in the file is hardcoded
px) — mechanical but touches hundreds of declarations across a 4,100-line
file; belongs in its own pass with dedicated visual QA, not bundled into
an audit. Deep-link coverage for pushed non-tab screens (`topic`,
`plans`, `collection`, `readingSummary` all silently drop the destination
on a cold hash-load, since `viewFromHash()` only recognizes tabs +
`#book/:id` + `#friend`) — needs a product decision on which pushed
screens should be publicly linkable before writing the fix. Terms of
Use/community guidelines are entirely absent from the repo — flagged as
the top legal-priority gap given `contributions` and shareable منارة
already exist in production. Leaked-password protection is off in
Supabase Auth — a dashboard toggle, not a tool this session has access to.

### Verification

`bash v4/build.sh` after every edit; full existing suite
(`test_library_malfa_reorg.sh`, `test_reading_session_logic.sh`,
`test_content_integrity.py`, `test_xss.py`, `test_edge_boundaries.py`,
`test_security_headers.py` after CSP hash regen) all pass unchanged.
`get_advisors` (security) re-run before/after the DB fix, plus a direct
`information_schema.routine_privileges` query (not just the advisor
cache) confirming zero `anon`/`PUBLIC` grant rows post-fix. Live
verification via a temporary mock-session boot harness (same technique as
§27, fully removed before commit — `git diff` on the boot section
confirmed byte-identical to before) at 390×844, 393×852, and 430×932,
dark and light mode: no horizontal overflow on any tab, the discard-guard
round trip verified working exactly as designed, `inert` toggling
confirmed correct via direct attribute inspection. **Not testable in this
environment**: a real authenticated signup (same standing constraint as
every prior batch), real VoiceOver on an actual device, and real
notched-iPhone safe-area rendering (`mcp__Claude_Code_iOS_Simulator`
requires a full Xcode install this machine doesn't have — confirmed via
the tool's own error, not assumed) — the safe-area fix is verified by CSS
math instead (`max()` provably a no-op at every currently-known inset
value), not an on-device screenshot.

A full audit artifact (executive summary, health score, navigation maps,
screen inventory, the full findings register, legal/compliance risk
register, subscription review, accessibility results, and the complete QA
test matrix with honest pass/fail/not-testable status per row) was
published for the user rather than left in chat scrollback, per this
project's evidence-based handoff practice.

### Repo / deploy note

Not yet pushed — awaiting the user's go-ahead. One new migration
(`20260903090000_close_4th_public_grant_recurrence_and_scope_plan_check.sql`)
already applied live against the Supabase project (DB changes there don't
have a separate "staged" state to hold back). `v4/vercel.json`'s CSP hash
regenerated to match the final script content.
