# GitHub CLI reference

Exact commands for the mechanics. `OWNER`, `REPO` and `N` are the repo owner, repo name and
PR number throughout.

## Contents

- [Fetching feedback](#fetching-feedback)
- [Finding the reviewed commit](#finding-the-reviewed-commit)
- [Replying to a thread](#replying-to-a-thread)
- [Resolving a thread](#resolving-a-thread)
- [CI status and logs](#ci-status-and-logs)
- [Updating the PR](#updating-the-pr)
- [Gotchas](#gotchas)

## Fetching feedback

Three separate surfaces. Fetch all three — findings hide in whichever one you skip.

```bash
# Inline review comments (the ones anchored to a line of code)
gh api repos/OWNER/REPO/pulls/N/comments --paginate \
  --jq '.[] | "─────\n#\(.id) [\(.user.login)] \(.path):\(.line // .original_line)\n\(.body)"'

# Issue-level comments (the general conversation)
gh api repos/OWNER/REPO/issues/N/comments --paginate \
  --jq '.[] | "─── [\(.user.login)] \(.created_at)\n\(.body)"'

# Review summaries (APPROVED / CHANGES_REQUESTED / COMMENTED)
gh api repos/OWNER/REPO/pulls/N/reviews --paginate \
  --jq '.[] | "─── [\(.user.login)] \(.state) \(.submitted_at)\n\(.body)"'
```

Unresolved threads only, with their node IDs — this is the list you actually work through:

```bash
gh api graphql -f query='
{ repository(owner:"OWNER", name:"REPO") {
    pullRequest(number:N) {
      reviewThreads(first:100) {
        nodes {
          id isResolved isOutdated
          comments(first:1){ nodes { databaseId author{login} path body } }
        } } } } }' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved==false)
        | "\(.id)\t\(.comments.nodes[0].databaseId)\t\(.comments.nodes[0].path)"'
```

`isOutdated: true` means the anchored line has changed since — a strong hint the finding may
already be handled, but confirm by reading the code, not by trusting the flag.

## Finding the reviewed commit

Review bots state it in the body, e.g. `**Reviewed commit:** 7aaf7c10c0`. Extract it, then
measure the gap:

```bash
gh api repos/OWNER/REPO/pulls/N/reviews --jq '.[].body' | grep -io 'reviewed commit[^`]*`\([0-9a-f]\{7,\}\)`'
git log --oneline <reviewed-sha>..HEAD          # what landed since
git diff <reviewed-sha>..HEAD -- <path>         # what changed in the flagged file
```

## Replying to a thread

Replies go to a dedicated endpoint keyed by the **first comment's `databaseId`**, not the
thread node ID:

```bash
gh api repos/OWNER/REPO/pulls/N/comments/COMMENT_ID/replies -f body="$(cat <<'BODY'
Fixed in `abc1234`. <mechanism in a sentence or two>

Covered by `testName`.
BODY
)"
```

Heredoc rather than `-f body="..."` with inline text: it survives backticks, quotes and
newlines without escaping.

## Resolving a thread

GraphQL only — the REST API cannot resolve threads. Needs the thread **node ID**
(`PRRT_...`), not the comment ID:

```bash
gh api graphql -f query='mutation {
  resolveReviewThread(input:{threadId:"PRRT_xxx"}) { thread { id isResolved } } }' \
  --jq '.data.resolveReviewThread.thread.isResolved'
```

Unresolve with `unresolveReviewThread`, same shape.

Verify the end state rather than assuming the mutations landed:

```bash
gh api graphql -f query='
{ repository(owner:"OWNER", name:"REPO") {
    pullRequest(number:N) { reviewThreads(first:100){ nodes{ isResolved } } } } }' \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[].isResolved]
        | "threads: \(length), resolved: \(map(select(.))|length)"'
```

## CI status and logs

```bash
gh pr checks N                                   # summary
gh pr checks N --watch                           # block until complete
gh run list --branch "$(git branch --show-current)" --limit 5
gh run view <run-id> --log-failed                # only the failing steps
gh run rerun <run-id> --failed                   # re-run failed jobs (use for suspected flakes)
```

Is it broken on the base branch too? Answer before absorbing a failure into your PR:

```bash
gh run list --branch main --limit 5 --json conclusion,headSha,displayTitle
```

## Updating the PR

```bash
gh pr view N --json title,state,mergeable,headRefOid,isDraft
gh pr edit N --title "..." --body "$(cat <<'BODY'
...
BODY
)"
gh pr create --base main --head "$(git branch --show-current)" --title "..." --body "..."
```

`gh pr create` fails when a PR already exists for the branch — it prints the existing URL.
Check first and `gh pr edit` instead of creating a duplicate:

```bash
gh pr list --head "$(git branch --show-current)" --json number,title
```

## Gotchas

- **Comment ID vs thread node ID.** Replies need the comment `databaseId`; resolving needs
  the thread `PRRT_` node ID. They are not interchangeable.
- **Transient TLS failures.** `gh api graphql` occasionally returns
  `TLS handshake timeout`. Retry two or three times before treating it as real.
- **Bot comment bodies contain markdown badges and `<details>` blocks.** Strip or ignore
  them; the finding is the prose.
- **`--paginate` matters.** A PR with many comments silently truncates without it.
- **Resolving does not notify.** Reply first — a resolve on its own is invisible to the
  reviewer.
