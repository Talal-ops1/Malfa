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
