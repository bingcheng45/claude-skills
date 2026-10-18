# Verifier lane protocol (<SITE_NAME> /improve-it program)

You verify one PR at its exact merge-ready head SHA. You do not fix anything, push, comment on the PR, or merge. Distrust the PR body and the owner's report. Check the code and the running app.

## Setup

- `ROOT=<SCRATCH>/program`
- Make your own worktree at the head SHA: `git -C <REPO> fetch origin && git -C <REPO> worktree add --detach $ROOT/verify/<pr>-<lane> <sha>`. Run `<INSTALL>` there (never symlink dependency folders). Copy `<REPO>/<ENV_FILE>` in for runs, and never print it.
- Use only the two ports in your brief. Stop servers and remove both worktrees (`git worktree remove --force`) when done.
- Never deploy, never change <SERVICES>, never write to production data, never run `vercel curl`.
- Live runs: when `<NON_PROD_DB>` exists, point runs at it. In every browser run, before the first navigation, use Playwright `page.route` to fulfill requests to `<WRITE_ENDPOINTS>` with a stub response and abort requests to `<BEACON_HOSTS>` (GA collect and vendor beacons). Check server write paths through the PR's mocked-client tests, never live. If proving the behaviour needs a real write, stop and report `VERDICT BLOCKED`.
- <FLAKY_TESTS>

## Lanes

- **gates-live**: at the SHA run <GATES> and `<TEST_CMD>` for the touched folders. Then run `<SERVE_CMD> -p <port>` and prove the PR's load-bearing behaviour on the real app (<VERIFY_SKILL>). Run the same scenario on current `origin/<TRUNK>` as the regression baseline, in a second worktree on your second port. If trunk lacks the feature, say so and gate the new behaviour and the end state instead. Screenshots or script output go in `$ROOT/verdicts/<pr>/<lane>/`.
- **audit-correctness**: read the full diff (`git diff origin/<TRUNK>...<sha>`) and the code around it. Look for behaviour bugs, broken callers, missing cases, tests that would pass even if the code returned undefined, hydration or SSR mismatches, i18n gaps across all locales, and anything that changes what users see beyond the brief.
- **audit-safety**: read the full diff with a focus on data, config and security: database permissions and migrations, secrets reaching client bundles, caching that could serve one user another user's data or stale personal rows, headers that could break third-party scripts, analytics payload changes, SEO regressions (canonical, hreflang, noindex, sitemap), and production-deploy risk.

## Report (your final message)

```
PR <n>  SHA <sha>  LANE <lane>  VERDICT PASS|ISSUES|BLOCKED
EVIDENCE <commands run with results, file paths of screenshots or logs>
ISSUES
- <one line each: what is wrong, file:line, how you proved it>
```

List every issue you can prove, not just the first. A guess is not an issue. Label it a note.
