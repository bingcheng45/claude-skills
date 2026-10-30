# PR review page

One artifact page per fix program, for every time Phase 4 asks the user to review, approve or merge PRs. This file sets only its content and order. The design files set the look. Never ask for a PR review in chat alone. The chat message carries the link and the question.

## Reuse or create

- One page per program, at `$SCRATCH/program/pr-review/index.html`. Write its URL to `$SCRATCH/program/pr-review-url.txt` on first publish.
- Every later review request in the same program updates that page and republishes it to the same URL: the same file path in this session, or `url` from `pr-review-url.txt` after a context reset or in a new session (read it with `action: "read"` first). New PRs get a new section. A PR whose head changed gets its section rewritten for the new head. Merged PRs move to "Merged".
- A new program (a new improve-it run, or PRs unrelated to this program's queue) gets a new page, linked under the meta line to the previous one.
- Save the page's URL to the product's memory with the program date, so a later session finds it.

## Shape

A review page, up to about 1120 px, readable at 400 px. Title is the product name plus "fixes" or "PR review" (two to four words). Under the `h1`, one meta line: trunk SHA, the date, how many PRs wait on the user, and a link to the Phase 3 review page.

## Order

1. **Waiting on you.** One line per PR that needs the user: the PR link, what it changes for users, and the action (approve, merge, run an owner step). Then the merge order, and which PRs conflict and need a rebase after another merges.
2. **One section per PR**, open by default for PRs waiting on the user, collapsed `<details>` for the rest. Each has:
   - **What changes for users.** One or two plain sentences.
   - **Why.** The finding it fixes, with the key number and its source from the review page (link the finding). Say what happens if it isn't merged.
   - **Before and after.** Side by side on desktop, stacked on a phone, each labelled "Before (trunk <sha>)" and "After (PR head <sha>)". Use the owner's proof: screenshots at the same size and state for visible changes; for changes users don't see, a short before/after of what does change (response headers, status codes, a request count, a JSON field, a test's output, rendered HTML). Never mock either side. When no before/after exists, say why ("deletes dead config, nothing observable").
   - **The diff in brief.** The files changed and the main change in a sentence each. Link the PR's files tab. No full diffs.
   - **Checks.** The verified head SHA, the verdict per verifier lane, gates, and anything not verified, in plain words.
   - **Owner steps.** Before or after merge, with where to click.
   - **Scope changes.** Anything cut or changed from the original finding, and why.
3. **Merged.** One line each with the merge SHA and the date, plus any owner step still open.
4. **Not in this set.** Findings left out of the program and why.

## Before publishing

- Every before/after image is a real capture from an owner or verifier proof folder, copied into `img/` next to the page and published through `files`.
- Each PR's head SHA on the page matches `gh pr view <n> --json headRefOid`.
- Check the page at about 400 px wide: no horizontal scroll, the before/after pairs stack.
- `description` on publish is one sentence: which PRs it covers and what the user needs to do.
