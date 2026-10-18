# Review page

One artifact page. Load the `artifact-design` skill first. The user's `~/.claude/design/*.md` files set fonts, tokens, spacing and dark mode, so follow them and don't restate them here. This file sets only the content and its order.

## Shape

A reading page, single column about 760 px. Title is the site's name plus "site review" (two to four words in `<title>`). Under the `h1`, one `meta` line naming every source and its date range ("GA4 to 17 Oct, Search Console 28 days to 18 Oct, lab runs 18 Oct").

Write headings as claims, not topics. "Most visitors never start a round" beats "Funnel". "Clicks are up 25%. The next gains are a few page titles" beats "SEO".

## Order

1. **Do these first.** About 6 items from Phase 2's ranking. Each is a short `h3` naming the change, two or three sentences on why with the key number, and tags for impact, effort and risk. Mark items you re-checked yourself ("re-checked 18 Oct").
2. **One section per area**: players, search, speed, reliability. Open each with the one number that frames it. Each finding is a `<details>` whose `<summary>` is the claim plus its tags. Inside go the evidence (numbers, source, date range, measured or inferred), the suggested change, effort, and "already planned in <doc>" when it is.
3. **Screenshots.** Real ones from the players lane, copied into an `img/` folder next to the page and published through `files`. Put each beside the finding it proves, with a caption that says what to look at. Never mock a screen the lane didn't capture.
4. **Funnel visual** in the players section. Plain HTML bars or a small inline SVG, one row per step (visit, first action, completed, second action, commit, return), the count and the percent of the step before, and the biggest drop called out in text. Per the `dataviz` skill, label values directly, no legend.
5. **Content ideas**, 3 to 5, each with the data signal behind it.
6. **Already fine.** One line each, grouped by area, so the owner knows what was checked.
7. **Only you can do.** Owner steps in the order they must happen, each with where to click or what to run and which finding it unblocks.

## Tags

Impact (high, medium, low), effort (S, M, L), and "planned" when a doc already covers it. Show state with text plus colour, never colour alone.

## Before publishing

- Every number on the page appears in a lane report or your own re-check. Search the page for each one.
- Stale items from Phase 2 are gone, not struck through.
- Check the page at about 400 px wide: no horizontal scroll, screenshots scale down.
- `description` on publish is one sentence: what was reviewed and that nothing on the site changed.
