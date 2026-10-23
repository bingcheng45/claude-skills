# Landing

## Order of operations

1. **Check the base branch's CI before anything else.** If it is red for a reason outside your
   units, fix it in its own small PR (spawn a poteto-agent for it) and merge that first. In the
   source session every PR inherited one compile error that was already on main.
2. **Refresh branches with `gh pr update-branch`, not `gh run rerun`.** A rerun reuses the old
   merge commit, so it cannot see a fix that landed on the base afterwards. Update-branch gives
   each PR a new head and a fresh run. Tell the user the heads changed.
3. **Wait for green.** Use `gh pr checks <n> --watch`. Read the state with
   `gh pr checks <n> --json name,state`. Do not parse the plain output with awk, since check
   names contain spaces.
4. **Merge in dependency order.** The root of each chain first, then independent PRs. After a
   parent merges, retarget its child to the base with `gh pr edit <n> --base <base>`, refresh it with
   `gh pr update-branch <n>`, wait for green, and merge it. Repeat down the chain. A child can show
   conflicts only after its parent merges, so check mergeability each time (see Conflicts).
5. **Check mergeability after each merge.** `gh pr view <n> --json mergeable,mergeStateStatus`.
   The first value can read `UNKNOWN` for a few seconds. Re-read it.

## Permissions

If a merge command is blocked, stop and explain what you were trying to do. Do not route around
the block by splitting the command, using another tool, or another route. Ask the user to allow
it or to merge themselves. Once they say so in chat, retry.

## Conflicts

Stop and ask before resolving any merge or rebase conflict. Say which files conflict
(`git merge-tree --write-tree --name-only origin/<base> origin/<branch>` shows them without
touching anything). If the user says to rebase, spawn one poteto-agent per branch with this brief:
- rebase that branch only onto the base,
- keep both sides' intent, and never drop lines you do not understand,
- push with `--force-with-lease` to that branch only,
- rerun the full unit tests and the UI suites for the touched area,
- re-record the trigger and any trigger the conflicting change affects,
- wait for CI, and report new head, merge state, counts, clips and exactly how the conflict was resolved.

Rerun the suites even when the textual conflict was easy. In the source session a clean rebase
hid a regression: a fast paging test dropped from 9 of 9 on main to 6 of 12 on the branch.

## After landing

Run `scripts/pcw-off.sh`. Report the final base commit, the PR list and anything left open.
Remove the worktree of every unit whose PR merged with `git worktree remove --force <path>`, then
`git worktree prune`. Branches stay, so nothing is lost. Keep a worktree whose PR is still open or
that holds uncommitted edits, and say why in the report. Offer cleanup of branches and devices
rather than deleting them unasked. A daily `worktree-reaper` launchd job removes anything missed:
merged-PR worktrees after 3 idle days, the rest after 7.
