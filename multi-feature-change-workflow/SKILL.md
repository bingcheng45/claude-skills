---
name: multi-feature-change-workflow
description: Deliver one or many feature changes, each as its own poteto-mode run on its own branch, worktree, device and PR, in parallel when they are independent and as a stack when one builds on another. Includes an optional decision page before building, recorded proof before merging, and a landing sequence that handles CI and conflicts. Use this whenever the user lists several features or changes to build, wants to split work across subagents, says "one agent and one branch per change", wants features stacked on top of each other, wants to audit an area and then pick what to change, record a simulator or browser video of each change, review changes on an artifact before merge, hold merging until they approve, or land a batch of PRs. Works for any number of features, including one or two. Every agent goes through /pstack:poteto-mode.
---

# Multi-feature change workflow

You coordinate. Agents build. Features that are independent run in parallel, and features that
build on each other run as a stack. The user judges on pages and approves before anything merges.
This workflow came from a real session that audited an iOS app, let the user pick changes on a
review page, built eight changes in parallel with recorded proof, and landed nine PRs.

## Non-negotiables

1. **Every unit runs through poteto-mode.** Spawn every subagent as `subagent_type: "pstack:poteto-agent"`,
   including read-only audit and verification agents. Start every brief with the line in
   `references/brief-template.md`. Reject any report that lacks the playbook, todolist and
   principles (`scripts/check-report.py`). Turn on the guard hook (below) so a wrong spawn is blocked.
   Why this is first: poteto-mode carries the planning, TDD, review and verification discipline.
   Without it, an agent follows only the standing orders, which is thinner.
2. **One feature, one branch, one worktree, one agent, one device, one PR.** Never edit or change git
   state in the user's main checkout. It usually holds uncommitted work.
3. **Proof before merge.** Each change is recorded on a real simulator or browser. Merge is held
   until the user approves. The form of approval scales with size (see below).
4. **Land safely.** Check main's CI first. Merge only on green CI and with the user's permission.
   On any merge conflict, stop and ask before resolving it.
5. **Check claims against the code.** A preview or a summary is a claim. When the user disagrees
   with one, send a verification agent to read the code and show what it found, even if the code
   says the user is wrong.

## Pick the size

Count the changes, then decide whether decisions are still open.

| Changes | Build | Proof and approval |
|---|---|---|
| 1 | One poteto-agent in its own worktree | A recording and the PR with a Hold line. Approval in chat is fine. |
| 2 | Two poteto-agents in parallel | One short proof page with both clips and approve controls, or both clips in chat |
| 3 or more | Waves, tracker, standing orders | Full proof page with approve controls stored in the artifact database |

Two independent switches apply at any size.
- **Discover** (read-only audit): run it only when the user does not yet know what is there.
- **Decide** (review page): run it only when the user still has to choose between options.
  If they already know the changes, skip both and go to Plan.

## Features that depend on each other

Not every feature can run in parallel. Before spawning, write the dependency graph as a
`depends` column in the tracker, one row per feature.
- **Independent features** go in the same wave. Each branches from the base and its PR targets the base.
- **A feature that builds on another** starts only after its parent's PR is up. It branches from
  the parent's branch, its PR targets the parent's branch, and its brief includes the parent's
  report (what it added, quirks, anything that does not work). Chains are fine: if C builds on B,
  C's base is B.
- **Respect what the user said.** "Parallel" means independent branches. "Stack" or "on top of"
  means a chain. If it is unclear, infer from the files each feature touches, say what you
  inferred in one line, and continue unless the user objects.
- **Keep chains healthy.** If a parent changes after its children started (a rebase, a review
  fix), update the children and tell their agents. Merge from the root of each chain upward and
  retarget each child to the base once its parent merges (`references/landing.md`).
- **Cap concurrent builds at three** across all branches, whichever shape the graph has.

## Phases

1. **Discover.** Partition the files, one read-only poteto-agent per partition, one JSON schema.
   Exclude stale worktrees and build output before trusting a count. List zero-hit files too so
   coverage can be checked.
2. **Decide.** Build a review page the user can act on. See `references/review-artifact.md`.
3. **Plan.** One unit per feature, then the dependency graph (above). Independent units form wave 1
   from the base branch. Units that build on another are spawned when their parent PR is up.
   Write standing orders, one brief per unit, and a tracker. See `references/standing-orders.md`
   and `references/brief-template.md`.
4. **Build and prove.** Spawn the wave. Cap concurrent builds at three on one machine. Each agent
   implements, tests, records, pushes and opens its PR. A feature that builds on another starts when
   its parent's PR is up.
5. **Approve.** Compile the proof page. See `references/proof-artifact.md`. Read approvals from
   the artifact database.
6. **Land.** See `references/landing.md`.

## Start-up checklist

Ask these once, then proceed without further questions. Put the answers in the briefs.
1. Scope: what area, which changes, and are decisions still open.
2. How to run and record: simulator, browser, or test build, and the exact command.
3. Base branch, and the branch naming prefix.
4. Test commands, and the CI check names that must be green.
5. Merge rules: who merges, in what order, and whether stacked PRs are allowed.

Then run `scripts/pcw-on.sh <scratchpad-dir>` to turn the guard on for this session (pass the
scratchpad directory from your system prompt, or the session id), and `scripts/pcw-off.sh` when
the workflow ends, including if it stops early.

## The guard hook

`~/.claude/hooks/pcw-guard.py` enforces non-negotiable 1 while a workflow is active in a session.
- **Block.** Before an Agent call, if the subagent type is not `pstack:poteto-agent`, the call is blocked.
- **Inject.** When any subagent starts, the poteto-mode requirement is added to its context.
It acts only for the session id stored in `~/.claude/state/pcw-active` (the working directory is
not used, because it changes as a session moves around). The marker expires after 12 hours.
Set `PCW_GUARD=off` to bypass. If the hook is missing, follow rule 1 by hand.

## Reports

Every agent finishes with a report of at most 150 words: branch, PR URL, head SHA, test counts
(from the result bundle, not log greps), recording path, what to watch in the video, risks, the
poteto-mode playbook used, and the principles that changed a decision. Pipe it through
`scripts/check-report.py`. If it fails, respawn the agent fresh with the missing items listed,
rather than resuming a chain of messages.

## Style for pages

Artifacts follow `~/.claude/design/` (Geist and Open Sans, no text under 12px, designed dark
theme). The style hook checks them before publishing. Mock screens of the user's own app must
match the real app, so use its existing screenshots.

## Lessons from the session this came from

- The first two review pages missed the intent. Keep the data, change the view.
- Several previews were wrong until an agent read the code. Verify before drawing.
- Five concurrent builds overloaded one machine. Cap at three.
- CI was already red on main. Fix it in its own small PR, then update the branches, since a
  rerun reuses the old merge commit and cannot see the fix.
- A clean rebase is not a passing rebase. Rerun the suites after every rebase.

## When not to use it

Skip the waves, tracker and pages when one agent can finish a small change on one branch. For
one change, use poteto-mode directly plus a recording and a Hold line.
