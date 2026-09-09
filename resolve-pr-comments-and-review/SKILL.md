---
name: resolve-pr-comments-and-review
description: Work through pull request review comments end to end — fetch every thread, verify each claim against current HEAD before touching anything, fix what is genuinely broken with a validated regression test, repair failing CI, then reply with evidence and resolve the threads. Use this whenever the user mentions PR comments, review feedback, reviewer suggestions, Codex/CodeRabbit/Copilot review bots, "resolve the comments", "address the review", "the PR checks are failing", "CI is red on my PR", or points you at a pull request URL — even if they only say "look at my PR" without naming comments specifically.
---

# Resolving PR comments

## The one rule that matters

**Verify every claim against current HEAD before you change anything.**

Review comments are filed against a specific commit. On any PR with follow-up work, a
large share of the findings are already fixed. Acting on the list as given produces
redundant commits, re-breaks working code, and buries the findings that are still real.

A real session that motivated this skill:

```
  4 bot findings, filed against the PR's first commit
  12 commits of follow-up work had landed since
  ────────────────────────────────────────────────
  P1  snoozed reminders deleted        ->  ALREADY FIXED   (verified: prefix list)
  P2  rebuilds not serialised          ->  ALREADY FIXED   (verified: queue in place)
  P2  grouped notification dead buttons->  STILL REAL      <- the only one worth acting on
  P2  translations missing             ->  REAL, deferred  (930 strings, tone-sensitive)
```

One of four needed code. Three needed a reply with evidence. Finding that out took about
five minutes of grepping and saved a day of churn.

## Workflow

```
  1  GATHER      every thread + the commit each was filed against
       |
  2  VERIFY      check each claim against HEAD -- grep, read, run
       |         classify: FIXED / REAL / WRONG / DEFERRED
       |
  3  FIX         only the REAL ones. one commit per coherent finding
       |
  4  TEST        write the test, then prove it fails without the fix
       |
  5  SWEEP       same defect class elsewhere in the codebase?
       |
  6  CI          green before you reply
       |
  7  REPLY       evidence per thread: commit sha, mechanism, test name
       |
  8  RESOLVE     on decision -- change made OR reasoned no-change
       |
  9  PUSH        and refresh the PR body if scope moved
```

## 1. Gather

Pull inline review comments, issue comments, and review summaries. See
`references/github-cli.md` for exact commands.

Capture the **reviewed commit** from the review body — bots state it. Then check how far
HEAD has moved:

```bash
git log --oneline <reviewed-sha>..HEAD | wc -l
```

If that number is not zero, treat every finding as unverified until you check it.

## 2. Verify — the phase people skip

For each finding, answer one question: **is this true of the code as it stands right now?**

Read the actual code path. Do not reason from the comment's description of it.

Classify into four buckets:

| Verdict | Meaning | Action |
| --- | --- | --- |
| **FIXED** | A later commit resolved it | Reply with the SHA + how you confirmed |
| **REAL** | Reproduces on HEAD | Fix it |
| **WRONG** | The reviewer misread the code | Reply with the counter-evidence |
| **DEFERRED** | Real but out of scope | Reply with scope, cost, and why |

Reviewers — human and bot — are sometimes wrong. When a finding conflicts with what you
read, trust the code and say so plainly, with the evidence. A worked example of pushing
back correctly is in `references/verification-playbook.md`.

Prove the REAL ones before fixing. A three-line script beats an argument:

```
  claimed: short estimates fire too close to the deadline to snooze
  check:   est  5m -> fires due -300s; snooze needs 600s -> ALWAYS REFUSED
           est 20m -> fires due -1200s -> fine
  verdict: REAL
```

## 3. Fix

One commit per coherent finding, so a revert is surgical.

Write the commit message so the reviewer does not have to re-derive the problem: what was
broken, the concrete failure it caused, and why this fix rather than the obvious one. When
you decline a finding, say so in the message with reasoning — that is where a future reader
will look.

## 4. Test — and prove the test works

A test that passes both before and after the fix is worse than no test: it makes the suite
look like it covers the bug.

```
  write the test        -> should FAIL on unfixed code
  reintroduce the bug   -> confirm RED
  restore the fix       -> confirm GREEN
```

Do this literally. Stash the fix, or re-add the bad line temporarily, run the test, restore.
It takes one extra run and it is the only thing that distinguishes a guard from decoration.

**Watch for stale assertions that encode the bug.** When a fix makes an existing test fail,
read it before editing. The test may have been asserting the buggy behaviour, in which case
the suite was actively protecting the defect.

**Prefer a property to a case.** If the same bug has now returned more than once in
different forms, each case test is pinning one input that happens to work. Assert the
invariant instead — sweep a range of inputs and assert the property holds across all of
them. See `references/verification-playbook.md`.

## 5. Sweep for the defect class

This is where a review pass earns more than it cost.

When you fix a bug, ask: **what is the general shape of this mistake, and does it appear
elsewhere?** Then grep for that shape.

In the motivating session, one shape — *offering a UI action the code cannot honour* —
turned up three separate times: a snooze button on a notification too close to its deadline,
the same button on a re-armed notification, and action buttons on a grouped notification
carrying no target. Fixing them one at a time across three review rounds took far longer
than one sweep would have.

Other shapes worth grepping once found: identifier or key mismatches between a producer and
its consumer, absence treated as proof of an event, values derived from "now" where they
should derive from data, and comments that no longer describe the code.

Report what the sweep found even when it found nothing — that is a result.

## 6. CI

If checks are red, they are part of this job. Get the failing logs, fix the cause, push,
confirm green. Commands in `references/github-cli.md`.

Distinguish three cases, because the right response differs:

- **Your change broke it** — fix it.
- **Already broken on the base branch** — say so, with the evidence, and do not absorb it
  silently into this PR.
- **Flake** — re-run once. If it passes, note which test flaked rather than moving on; a
  flaky test on a PR is a finding in its own right.

## 7. Reply with evidence

Reply to every thread, including the ones needing no change. A thread closed without a
reason forces the reviewer to re-derive your reasoning.

Each reply carries:

- **the verdict** — fixed, already fixed, declined, deferred
- **the commit SHA** when code changed
- **the mechanism** — what was actually wrong, in one or two sentences
- **the test name** that now guards it
- **what you checked** for a decline or a defer, so the reasoning is auditable

Confirming a good catch is worth saying out loud, especially when it survived earlier review
passes. It tells the reviewer their attention landed somewhere useful.

### Not every comment lives in a thread

Bots file findings in two places, and only one of them can be resolved:

| Where | Resolvable? | How to close it out |
| --- | --- | --- |
| Inline review thread | yes | reply, then resolve |
| Review **summary** body (`pulls/N/reviews`) | **no** | reply with a PR comment |
| Issue comment (`issues/N/comments`) | **no** | reply with a PR comment |

GitHub has no resolve action for a review summary or an issue comment. If you only work the
threads, the PR still *looks* unaddressed: resolved threads collapse out of view in the web
UI, while the un-resolvable summary stays expanded at the top of the conversation. A reader
opening the PR then sees nothing but the original findings.

So after resolving the threads, post one PR comment that answers the summary directly --
verdict per finding, and a pointer to the threads where the detail lives:

```bash
gh pr comment <N> --body-file reply.md
```

Check both endpoints when gathering. `reviewThreads` alone will miss the summary.

## 8. Resolve

Resolve a thread once a **decision** exists — a change made, or a reasoned no-change posted.
An open thread should mean an open question, not an answered one.

Always reply before resolving. Never resolve silently.

## 9. Push and refresh the PR

Push, then re-read the PR description. If the work changed scope, materially altered
behaviour, or added a known limitation, update the body. A stale description is the first
thing a merge reviewer reads.

Call out anything that changes behaviour for existing users on upgrade — a default that
flips, a migration, a new prompt. Reviewers routinely miss these in a diff.

## Reporting back

Lead with the count that matters, then the detail:

```
  4 threads: 1 needed code, 2 already fixed, 1 deferred
```

Then per finding: verdict, evidence, and what changed. Use short sentences and a table or
ASCII diagram wherever the structure is not linear. Close with anything still open and any
decision you need from the user.

## References

- `references/github-cli.md` — exact commands for fetching threads, replying, resolving via
  GraphQL, and reading CI logs. Read this when you need the API mechanics.
- `references/verification-playbook.md` — worked examples of verifying, declining, property
  tests, and the defect-class sweep. Read this when a finding is contested or the fix is
  not obvious.
