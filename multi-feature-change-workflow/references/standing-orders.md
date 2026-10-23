# Standing orders

Paste these verbatim into every spawn and every respawn. Directives decay across resumes, so
never rely on a message chain. Edit the bracketed parts for the project.

0. **Run poteto-mode.** Read the poteto-mode skill in full. Pick the playbook that matches this
   unit (Feature, Bug fix, Refactoring, Prototype, and so on), copy its steps into your
   todolist before anything else, and name the principles that changed a decision in your report.
1. **One unit, one branch, one worktree.** Work only in the worktree named in your brief. Never
   change git state in the main checkout, which may hold the user's uncommitted work. Never
   touch other worktrees.
2. **Read the project's instructions first** ([CLAUDE.md, AGENT.md]). If they conflict with
   anything here, the project file wins. If you change a documented contract, update that text in
   the same commit.
3. **Smallest change that works.** No refactors outside the unit. Follow the project's file
   size, naming and header-comment conventions.
4. **Tests red first.** Write the failing test, then the code. Run the tests for the affected
   area. Report counts from the result bundle ([xcrun xcresulttool] or the framework's report),
   not by grepping the log. Never weaken or delete existing tests.
5. **Respect accessibility settings.** New motion respects Reduce Motion. New text respects
   dynamic type where the project does.
6. **Prove it on your own device.** Create a device named for your unit. Drive the real user
   path with real touches or clicks. Record the trigger with 1.5s idle before and 2s after. Never
   use a device you did not create.
7. **Evidence lives outside the repo.** Save the recording, 3 to 6 stills taken from it, and
   notes with timestamps in `[scratchpad]/evidence/<unit>/`. Keep each clip under 15 seconds.
8. **Clean commits.** Conventional Commits, small and logical, no narrating comments, no debug
   prints, no skipped hooks. Add attribution lines only if the user's settings ask for them.
9. **One PR with a Hold line.** Push your branch, open one PR against the base in your brief,
   and write: "Hold: do not merge until the review is approved." Never merge, never enable
   auto-merge, never force-push, never push to the base branch.
10. **Never block on a question.** If the brief is ambiguous, choose the option with the least
    bug risk, say so in the PR and your notes, and continue. If something is impossible, stop and
    report why with evidence.
11. **Report in 150 words.** Branch, PR URL, head SHA, test counts, recording path, what to watch
    in the video, residual risks, the playbook you ran and the principles that changed a decision.
12. **Clean up.** Shut down your device. Leave the worktree in place. The coordinator removes it
    once your PR lands.

## Why these exist

- Rule 0 keeps each unit inside the same discipline, so quality does not depend on how good the
  brief is.
- Rules 1 and 9 protect the user's work and the base branch.
- Rule 10 exists because workers cannot ask questions while they run. A vague brief fails
  quietly, and a stalled agent costs more than a documented guess.
- Rule 7 keeps clips out of git history.
