# Proof page and approval

## Collect evidence

Each unit writes to `[scratchpad]/evidence/<unit>/`: the recording, a few clips if needed, 3 to 6
stills taken from the clip, and `notes.md` with timestamps. The coordinator uses the agents'
reports (and checks the clip exists), and writes what to watch from the report plus notes.

## Compress

Raw simulator clips are large. Run `scripts/compress-videos.sh <src-dir> <out-dir>`. It compiles
`scripts/export-video.swift` (AVFoundation) and exports each `.mp4` at 1920x1080 max, which took
a 4 MB clip to about 1.7 MB in testing. There is no ffmpeg dependency. Convert stills to JPEG with
`sips -s format jpeg -s formatOptions 72 -Z 1100 in.png --out out.jpg`.

## Publish

- Name files `<unit>--<clip>.mp4` and `f/<unit>--<still>.jpg`, and reference them with relative paths.
- Use the Artifact tool's `files` list with `root` set to the output directory.
- One publish accepts about 64 MB. Split videos across two or more publishes to the same URL.
- Confirm with the artifact file listing that every referenced path exists.

## The page

One section per PR:
- the PR number and link, the base branch and the head SHA,
- a clip switcher (main clip first) with one line under it saying what to watch and when,
- the stills, test counts as reported by the result bundle, and what could go wrong,
- Approve and Needs changes buttons with a note, saved to an `approvals` collection
  `{v, note, pr, item, name, head, at}`.

Add a header that explains stacked PRs, CI state, and the order merges will happen in. Show the
tally of approved and waiting PRs. For two changes, one short page is enough. For one change, the
recording and the PR description are enough.

## Approval

Read the approvals collection with ArtifactData before merging. Treat only `approve` on the
current head SHA as approval. If a head changed after approval (for example from an
update-branch merge of the base), say so when you land.
