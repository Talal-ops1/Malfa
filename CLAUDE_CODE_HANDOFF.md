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

- [ ] 1. Opening flow (Welcome → Login/Sign-up → Home)
- [ ] 2. Home reorder + remove كيف يقرأ from Home
- [ ] 3. كيف يقرأ moved to مَلفى tab
- [ ] 4. Flatten `.sh-c` rotate
- [ ] 5. Tone pass
- [ ] 6. QA pass
