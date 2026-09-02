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
