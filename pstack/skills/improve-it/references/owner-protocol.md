# PR owner protocol (<PRODUCT_NAME> /improve-it program)

You own one PR from build to merge. The root coordinator owns verification and gives the merge signal. Read this whole file before you start.

## Repo and setup

- Repo: `<REPO>` (GitHub `<GH_OWNER>/<GH_REPO>`, trunk `<TRUNK>`). <STACK, e.g. "SwiftUI and SwiftData, iOS 17+, String Catalogs", "SwiftUI menu bar app, macOS 14+, Sparkle", or "Next.js 15 App Router, next-intl with 24 locales, Supabase, Vercel Hobby">. <DEPLOY_NOTE, e.g. "Merging to main ships nothing until the owner releases a build." or "Merging to main deploys to production.">
- Do not work in the main checkout. Create your own worktree. Use `OWNER=<your id>`, `ROOT=<SCRATCH>/program`, and run `git -C <REPO> fetch origin && git -C <REPO> worktree add -b <branch> $ROOT/owners/$OWNER/repo origin/<TRUNK>`.
- Run `<INSTALL, e.g. `xcodebuild -resolvePackageDependencies`, or `npm ci`>` inside your worktree. Never symlink dependency folders to another checkout.
- Copy `<REPO>/<ENV_FILE>` into your worktree for local runs, when the product has one. It is gitignored. Never print its values.
- <UNTRACKED_DOCS, e.g. "The plan docs docs/plans/*.md are untracked in the main checkout only. Read them there.">
- Your run slot (port or simulator) is in your brief. Never use another owner's slot. Stop your servers and shut down your simulators when you finish a turn.

## Hard limits

- <RELEASE_LIMITS> Never change <SERVICES, e.g. "App Store Connect, TestFlight or Polar", or "Vercel, Supabase, Google Analytics or Search Console"> settings or data. Anything a merge ships happens only through merges after the root's signal.
- Never write to the production database. Never submit to live public forms or lists (<LIVE_SURFACES>).
- Never force-push anything but your own branch, and only with `git push --force-with-lease` after `git ls-remote`.
- Never merge until the root sends you a message that says "clean verdict, merge". For a PR with a `before-merge` operator gate, the root sends it only after the user confirms the step.
- Touch only the files your brief scopes. If you must touch a file outside it, say so in your report.

## Lifecycle

1. Start a decision trail at `$ROOT/owners/$OWNER/decisions.tsv` per the pstack **show-me-your-work** skill (helper `scripts/log.sh` next to it). Keep it out of the repo. Log forks, verified units, pivots and blockers.
2. Name the data shape first. Then write a failing behaviour test for each change you can test (`<TEST_CMD> <paths>`) and make it pass. Call the code the way its users do and assert literal expected values. A test that still passes when the code returns undefined is not a test.
3. Within about 15 minutes of starting, push your branch and open the PR as ready (not draft) with `gh pr create --base <TRUNK>`. Push again after every verified unit.
4. Commits use Conventional Commits and end with the co-author line the session's attribution names. The PR body says what changes for users first, then the cause, the fix and a test plan, and ends with the session's PR attribution line. No long dashes in PR text.
5. <I18N_RULE, e.g. "New user-facing strings go into Localizable.xcstrings with real translations for every shipped language.", or "New user-facing strings go into messages/en.json with real translations in all other locale files. Run npm run validate:messages."> UI follows the product's existing design system (its styles or `DesignSystem.swift`), and `~/.claude/design/*.md` for web pages when present.
6. Apply the **no-comments** skill to your diff and run the `/simplify` skill: remove dead code, needless helpers and comments that restate code.
7. Rebase onto current `origin/<TRUNK>`.
8. Gates on your committed head, all required:
   - <GATES, e.g. "xcodebuild build with zero new warnings", "swiftlint", or "npm run build", "npx tsc --noEmit", "npm run lint">
   - `<TEST_CMD>` for the folders you touched, and one full run. <FLAKY_TESTS, e.g. "Tests in X time out under load on trunk too. Re-run them alone and compare with trunk before blaming your change.">
   The head is now code-ready: diff final, gates green, rebased onto current trunk.
9. Push. If the repo has CI, run the babysit watcher `<WATCH_PR> --pr <n>` until it reports checks green. Fix any red check and return to step 8.
10. Self-proof on the real app under the live-run rules below: <PROOF_RUN>. Prove the behaviour your PR changes with screenshots or a script. <VERIFY_SKILL, e.g. "The repo skill .claude/skills/verify-<app>/SKILL.md shows how to drive it."> Save evidence under `$ROOT/owners/$OWNER/proof/`.
11. The head is now merge-ready: code-ready, CI green, self-proof done, trunk-current. After `git fetch origin`, if `git merge-base --is-ancestor origin/<TRUNK> HEAD` fails, return to step 7. End your turn with the report below. The root verifies that exact SHA.

## Live runs

<LIVE_RUN_RULES>
- If a proof needs a real write, a real purchase, or acting on the user's real data, stop and report `STATE blocked` with what you would need.

## Fix rounds

The root may message you findings. Fix every finding, add a red test where the defect is testable, re-run steps 7 to 11, and report the new merge-ready head SHA.

## Merge, only on "clean verdict, merge"

1. `git fetch origin`, rebase onto `origin/<TRUNK>`, re-run the gates, and push with `--force-with-lease`. Run `<WATCH_PR> --pr <n>` until checks are green on the pushed head. If the repo has no CI, re-run <GATES> on the pushed head instead.
2. Run `git fetch origin` again, then check that `git merge-tree --write-tree origin/<TRUNK> HEAD` is clean, and that no file in `git diff --name-only $(git merge-base HEAD origin/<TRUNK>) origin/<TRUNK>` is a file your PR changes. If either fails, rebase again and report the new head instead of merging.
3. If the patch changed during the rebase (`git patch-id` differs from the verified head), report the new head and wait. Otherwise `gh pr merge <n> --squash`.
4. Report the merge commit SHA. Remove your worktree with `git worktree remove` once merged.

## Report format (your final message each turn)

```
OWNER <id>  PR <url>  STATE merge-ready|merged|blocked
HEAD <sha>
GATES <gate>=<pass|fail> ... tests-touched=<n passed/n> tests-full=<summary>
PROOF <what you proved live, and the file paths>
DECISIONS $ROOT/owners/<id>/decisions.tsv
OUT-OF-SCOPE FILES <list or none>
OPERATOR STEPS <anything only the owner can do, or none>
NOTES <anything the verifiers should look hard at>
```
