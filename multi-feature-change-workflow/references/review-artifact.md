# Decision page (Discover and Decide)

Use when the user has not yet chosen what to change. Skip it when they already know.

## Discover

- Size the surface with grep. Exclude stale worktrees and build output first, or counts inflate
  (this session: 3,831 hits became 139 after excluding 24 old worktrees).
- Partition files into 3 to 5 groups with no overlap. One read-only poteto-agent per group.
- One shared JSON schema and one output file per agent in the scratchpad. Suggested fields:
  id, area, files (path:line), trigger, what changes, mechanism, resolved numbers, constants,
  guards, notes. Also write a files-scanned list that includes zero-hit files so coverage is provable.
- Fold the raw entries into things the user recognises. This session folded 129 entries into 60.

## The page

Build one HTML page per `~/.claude/design/artifacts.md`. Declare the `db` capability.

Each numbered item shows:
- a plain name and one or two plain sentences,
- where it lives in the product,
- a looping preview that looks like the real product (use its screenshots, never a generic style),
- Keep, Change and Remove buttons plus a short note, stored in the artifact database.

Store one document per item in a `feedback` collection: `{v, note, pick, n, name, at}`.
Read them with the ArtifactData tool. Write back anything the user says in chat so the page and
the conversation agree. Offer filters or tabs for Change, Remove and Keep once marks exist.

For each Change item, show what happens today on top and three options below, each with a
bug-risk rating (low, medium, high) and a build note. For each Remove item, show the real impact
and a suggestion. A shared effect that several items could use (this session: a pulse) gets its
own view, so the user chooses it once.

## Preview engine (if you animate)

Describe each preview as tracks of `[element, property, from, to, start, duration, easing]`.
Compute springs and cubic beziers in JavaScript with one deterministic frame function. Pause when
scrolled out of view, respect reduced motion, and add a slow-motion toggle. Fade the whole
stage at loop boundaries so there is no visible jump.

## Verify disputes

When the user says a preview is wrong, send a poteto-agent to read the code and write findings
with file:line to the scratchpad. Put the result on the card as a "Heads up", including when the
code contradicts the user. Mark claims that come from a static read as unconfirmed on a device.

## Check before publishing

Smoke-test the page with jsdom (it should build all items and throw nothing). Take one real look
by serving it over localhost in the browser pane, since local files do not render there.
