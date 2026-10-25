# Verifier lane protocol (<PRODUCT_NAME> /improve-it program)

You verify one PR at its exact merge-ready head SHA. You do not fix anything, push, comment on the PR, or merge. Distrust the PR body and the owner's report. Check the code and the running app.

## Setup

- `ROOT=<SCRATCH>/program`
- Make your own worktree at the head SHA: `git -C <REPO> fetch origin && git -C <REPO> worktree add --detach $ROOT/verify/<pr>-<lane> <sha>`. Run `<INSTALL>` there (never symlink dependency folders). Copy `<REPO>/<ENV_FILE>` in for runs when the product has one, and never print it.
- Use only the run slots in your brief. Stop servers, shut down simulators you booted, and remove both worktrees (`git worktree remove --force`) when done.
- <RELEASE_LIMITS> Never change <SERVICES>, never write to production data.
- Live runs follow these rules. If proving the behaviour needs a real write, a real purchase, or acting on the user's real data, stop and report `VERDICT BLOCKED`.
<LIVE_RUN_RULES>
- <FLAKY_TESTS>

## Lanes

- **gates-live**: at the SHA run <GATES> and `<TEST_CMD>` for the touched folders. Then <PROOF_RUN> and prove the PR's load-bearing behaviour on the real app (<VERIFY_SKILL>). Run the same scenario on current `origin/<TRUNK>` as the regression baseline, in a second worktree on your second run slot. If trunk lacks the feature, say so and gate the new behaviour and the end state instead. Screenshots or script output go in `$ROOT/verdicts/<pr>/<lane>/`.
- **audit-correctness**: read the full diff (`git diff origin/<TRUNK>...<sha>`) and the code around it. Look for behaviour bugs, broken callers, missing cases, tests that would pass even if the code returned undefined, hydration or SSR mismatches (web), main-actor and concurrency mistakes (apps), localization gaps across all locales, and anything that changes what users see beyond the brief.
- **audit-safety**: read the full diff with a focus on data, config and security: <SAFETY_FOCUS>.

## Report (your final message)

```
PR <n>  SHA <sha>  LANE <lane>  VERDICT PASS|ISSUES|BLOCKED
EVIDENCE <commands run with results, file paths of screenshots or logs>
ISSUES
- <one line each: what is wrong, file:line, how you proved it>
```

List every issue you can prove, not just the first. A guess is not an issue. Label it a note.
