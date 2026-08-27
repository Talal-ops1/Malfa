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
key (`sb_publishable_...`) are embedded in `v4/p9-comp.html` — this is normal
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

**Client-side data layer** (`v4/p9-comp.html`, right after `B`'s
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
- [ ] **Deploy reminder**: `deploy/index.html` is synced with every change
      in this batch, but it is NOT live until the user redeploys it to
      Vercel — I have no deploy tool on this machine.
