# مَلفى (MALFA) — CLAUDE.md

MALFA is a single-HTML-file, RTL Arabic, client-only prototype of a reading app.
There is no backend, no build step, no dependencies — everything (markup, CSS,
data, and JS) lives in one file: [v4/index.html](v4/index.html).

## Rules

- **Preserve existing working functionality.** This is a working prototype —
  don't break the router, the sheet drag physics, the tab transitions, or any
  screen that isn't explicitly in scope for the current task.
- **Run the build after every change**, and confirm it prints `JS OK` before
  considering an edit done:
  ```bash
  bash v4/build.sh
  ```
  This extracts the inline `<script>` and syntax-checks it (parse-only, never
  executed, so DOM/window references don't trip it). It does not check CSS or
  markup — visually verify those changes yourself (open the file in a browser).
- **Never touch secrets or introduce a backend without asking first.** This
  project is intentionally client-only. Adding network calls, storage backends,
  auth providers, or API keys is out of scope unless explicitly requested.
- **Don't expand scope.** Only make the changes actually asked for. Don't
  redesign screens, rename things, or "clean up" areas that weren't part of
  the request.

## Architecture (as it exists in v4/index.html)

- One `<style>` block (design tokens in `:root`, then component CSS), one
  `<script>` block — everything else is a couple of `<div>`s (`.stage >
  .phone#phone > .statusbar, .app#app, .tabbar#tabbar, .sheet#sheet,
  .backdrop#backdrop, .toast#toast`).
- The script is a single IIFE (`(function(){"use strict"; ... })();`).
- Screens are plain functions that return HTML strings — e.g. `homeHTML()`,
  `communityHTML()`, `libraryHTML()`, `discoverHTML()`, `accountHTML()`,
  `bookHTML()`, `profileHTML()`. They're registered in the `VIEWS` map.
- `TABS` drives the bottom tab bar; `VIEWS` maps a screen name to its render
  function; `PUSHED` marks screens that are pushed on top of a tab (hide the
  tab bar) rather than being a tab root themselves.
- `mount(name, mode)` swaps the screen in `#app`. `goTab(k)` switches tabs.
  `push(n)` / `back()` handle the pushed-screen stack (`STATE.stack`).
- All interaction is delegated through one click handler on `#phone` via
  `data-*` attributes (`data-tab`, `data-open`, `data-person`, `data-book`,
  `data-toast`, `data-sheet`, `data-back`, `data-seg`, `data-play`,
  `data-step`, `data-closesheet`).
- Content data (books `B`, stock/paper palettes `ST`, people `PEOPLE`/`PMAP`,
  topics `TOPICS`, picks `PICKS`, collections `COLLECTIONS`, library buckets
  `LIB`, journey entries `JOURNEY`, community feed `FEED`, authors `AUTHORS`)
  are plain arrays/objects near the top of the script.
- Motion: a spring primitive (`springTo`) drives the voice-sheet drag; screen
  transitions are CSS transform/opacity transitions gated by
  `prefers-reduced-motion`. Keep new motion **extremely subtle** — this is a
  calm, premium product, not a flashy one.

## Design language

- Dark ground (`--ground:#0B0A0D`), white ink, one accent purple (`--khz`)
  reserved for the single filled CTA per screen — everything else is a plain
  arrow-link (`.lnk`).
- Display serif `Alyamama` for headlines/titles, `Thmanyah Sans`/`IBM Plex
  Sans Arabic` for UI text.
- Book covers are illustrated "printed objects" (paper grain, spine shadow,
  fore-edge highlight), not flat UI cards.
- Straight, structured composition — no unnecessary rotation/skew on layout
  elements. (`v3` had a fanned rotate() on `.plate.shelf .sh-c`; this was
  flattened per an explicit product decision — see the handoff doc.)
- Tone of the Arabic copy: clear, modern, warm, natural — not overly formal,
  not heavily dialectal (Najdi), not broken/casual. Read every new string out
  loud before committing to it.

## Where things are documented

See [CLAUDE_CODE_HANDOFF.md](CLAUDE_CODE_HANDOFF.md) for the active task
history and the reasoning behind product decisions made during development.
