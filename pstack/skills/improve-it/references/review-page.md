# Review page

One artifact page. This file sets only its content and order. The design files set the look.

## Shape

A reading page, single column about 760 px. Title is the product's name plus "review" (two to four words in `<title>`, e.g. "Acme site review", "Clearing app review"). When an earlier review page exists, publish a new one and link the earlier one under the meta line. Under the `h1`, one `meta` line naming every source and its date range ("code at 0b64122, App Store Connect 28 days to 18 Oct, launch timings 18 Oct", or "GA4 to 17 Oct, Search Console 28 days to 18 Oct, lab runs 18 Oct"). List each lab run's window against production (start and end time, user agent) under the meta line.

Write headings as claims, not topics. "Most visitors never reach the first action" beats "Funnel". "Clicks are up 25%. The next gains are a few page titles" beats "SEO".

## Order

1. **Do these first.** About 6 items from Phase 2's ranking. Each is a short `h3` naming the change, two or three sentences on why with the key number, and tags for impact, effort and risk. Mark items you re-checked yourself ("re-checked 18 Oct").
2. **One section per lane** of the surface (apps: audience, store, speed, reliability; web: audience, search, speed, reliability). Open each with the one number that frames it. Each finding is a `<details>` whose `<summary>` is the claim plus its tags. Inside go the evidence (numbers, source, date range, measured or inferred), the suggested change, effort, and "already planned in <doc>" when it is.
3. **Screenshots.** Real ones from the audience lane (browser, simulator, or the app's render lever), copied into an `img/` folder next to the page and published through `files`. Put each beside the finding it proves, with a caption that says what to look at. Never mock a screen the lane didn't capture.
4. **Funnel visual** in the audience section, when the lane had funnel data. Plain HTML bars or a small inline SVG, one row per `FUNNEL_EVENTS` step, then return, the count and the percent of the step before, and the biggest drop called out in text. Per the `dataviz` skill, label values directly, no legend.
5. **Content ideas**, 3 to 5, each with the data signal behind it.
6. **Already fine.** One line each, grouped by area, so the owner knows what was checked.
7. **Only you can do.** Owner steps in the order they must happen, each with where to click or what to run and which finding it unblocks.

## Tags

Impact (high, medium, low), effort (S, M, L), and "planned" when a doc already covers it. Show state with text plus colour, never colour alone.

## Before publishing

- Every number on the page appears in a lane report or your own re-check. Search the page for each one.
- Stale items from Phase 2 are gone, not struck through.
- A claim built on fewer than about 20 events shows its raw counts. A before/after comparison uses the same filter on both sides.
- Check the page at about 400 px wide: no horizontal scroll, screenshots scale down.
- `description` on publish is one sentence: what was reviewed and that nothing in the product changed.
