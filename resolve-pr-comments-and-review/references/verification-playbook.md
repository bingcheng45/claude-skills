# Verification playbook

Worked examples for the judgement calls. Read this when a finding is contested, when the
fix is not obvious, or when the same bug has come back more than once.

## Contents

- [Classifying a finding](#classifying-a-finding)
- [Declining a finding correctly](#declining-a-finding-correctly)
- [When the suggested fix reintroduces an older bug](#when-the-suggested-fix-reintroduces-an-older-bug)
- [Proving a test actually guards the bug](#proving-a-test-actually-guards-the-bug)
- [Property tests for recurring bugs](#property-tests-for-recurring-bugs)
- [Stale assertions that encode the bug](#stale-assertions-that-encode-the-bug)
- [The defect-class sweep](#the-defect-class-sweep)

## Classifying a finding

Reproduce the claim from the code before deciding. A short script is faster and more
convincing than reading:

```
  claim:  "short estimates offer a snooze that is always refused"

  est   5m -> fires due -300s; snooze needs 600s -> ALWAYS REFUSED
  est  20m -> fires due -1200s -> fine
  est  60m -> fires due -4200s -> fine

  verdict: REAL -- the short-estimate branch reaches a state the author did not consider
```

For a FIXED verdict, name the artifact that proves it — the line, the constant, the test:

```bash
grep -n "rebuiltPrefixes\s*=" -A2 path/to/File.swift
#   69:  static let rebuiltPrefixes = ["task-due-", "deadline.", "start.", "daily-plan."]
#   -> "start-snooze." is absent, so a pass no longer wipes snoozes. Finding is fixed.
```

## Declining a finding correctly

A decline is a real outcome, not a fight. State the mechanism, why the reviewer's reading
does not hold, and what you would change your mind on.

Worked example. A reviewer flagged that one branch lacked the guard its sibling had:

> The late branch guards `lateStart - now >= minimumStartLeadTime` so a pass can never
> deliver a banner as a reaction to the user's tap. The ordinary branch has no such guard.

Checking the actual behaviour showed the two branches are not equivalent:

```
  pass at 11:50 -> schedules 11:55
  pass at 11:52 -> schedules 11:55      <- stable across passes
  pass at 11:54 -> schedules 11:55
```

The reply that followed:

> Not taken. That guard exists because `due - lateStartLead` is a synthetic last-chance
> moment, not a derived one, so delivering it right after a tap carries no information.
> `calculated` is the moment the task should actually be started, and it is stable across
> passes — a five-minute task due at 12:00 schedules 11:55 no matter how many times
> reconciliation runs. Adding the guard there would suppress a correctly timed reminder
> because the user happened to edit the task shortly before it was due to fire.

The pattern: show the behaviour, name the distinction the reviewer missed, state the cost of
doing it their way.

## When the suggested fix reintroduces an older bug

Check a proposed fix against the PR's own history before applying it. Reviewers see the
current diff, not the three commits that got you here.

A reviewer proposed raising a constant to 5 minutes. The arithmetic showed why not:

```
  a snooze after a late banner must clear both edges, so a window exists only while
      gap + runway <= lateStartLead

  gap=5m runway=2m  -> 3-minute window      (current)
  gap=5m runway=5m  -> 0-minute window      (the collapse fixed two commits ago)
```

There was no setting of the two constants that was both honest and non-empty. The tuning was
the wrong axis entirely — the real fix was upstream: stop offering the button on that
notification at all.

When tuning a constant has failed more than once, the constant is not the problem.

## Proving a test actually guards the bug

Reintroduce the bug and watch the test fail. Nothing else establishes this.

```bash
cp path/to/File.ext /tmp/file.bak
# re-apply the bad line
<edit>
<run tests>          # expect: the new test FAILS
cp /tmp/file.bak path/to/File.ext
<run tests>          # expect: everything PASSES
git diff --stat path/to/File.ext    # expect: empty -- restored cleanly
```

Report the result. "Verified to fail when the original fallback is reintroduced" is the
sentence that turns a test from decoration into evidence.

## Property tests for recurring bugs

When the same bug returns in different forms, each case test pinned one input that happened
to still work. Assert the invariant instead.

A reminder system had a bug where fire times were computed relative to the moment a
recalculation ran, so any user interaction produced a notification seconds later. It was
fixed three times and came back twice, each time slipping through a green suite.

The invariant: **a scheduled time must be a function of the data, never of when the
calculation ran.** Asserted directly:

```
  for each of 7 task shapes           (ordinary, short, late, none, in-progress, overdue, edge)
    for each of 7 recalculation times (0s, 1s, 5s, 30s, 2m, 10m, 30m after t0)
      any identifier surviving between runs must keep its scheduled time
```

Guard against vacuity — assert the sweep actually produced something:

```
  #expect(!seen.isEmpty, "the probe scheduled nothing, so the invariant was not exercised")
```

Then prove it catches the original bug, per the section above.

Reach for this when: the same defect has returned, a fix is a tuned constant, or correctness
depends on an invariant rather than on specific outputs.

## Stale assertions that encode the bug

When your fix makes an existing test fail, read the test before editing it. Sometimes the
suite was asserting the buggy behaviour, which means it was actively protecting the defect.

```
  fix: a grouped notification must not carry per-item action buttons
  result: rescueUsesOneGroupedRequest FAILED
  cause:  #expect(rescue.content.categoryIdentifier == "TASK_RESCUE")
          -- the grouped case asserting the actionable category, i.e. the bug
```

Correct the assertion and say so in the commit message. A test that encoded a bug is worth
naming, because it means the green suite was misleading.

## The defect-class sweep

After each fix, generalise: **what is the shape of this mistake?** Then grep for the shape.

One session found the same shape three times — *offering a UI action the code cannot
honour*:

```
  1  snooze button on a notification too close to its deadline to honour it
  2  same button on the re-armed notification the first one created
  3  action buttons on a grouped notification carrying no target to act on
```

Each surfaced in a separate review round. One sweep after the first would have found all
three.

Shapes worth grepping once you have seen one instance:

| Shape | How to look |
| --- | --- |
| Key mismatch between producer and consumer | grep the key string on both sides; type-check does not catch `"id"` vs `"taskId"` |
| Absence treated as proof of an event | search for `isEmpty` / `== nil` driving irreversible state |
| Derived from "now" where it should derive from data | grep for the clock call inside scheduling or ID generation |
| Identifier built one way, cancelled another | compare every construction site against every removal site |
| Comment no longer describing the code | read the doc comment on each function you touched |
| Unbounded growth against a platform cap | look for per-item resource creation with no ceiling |

Report the sweep even when it comes back clean. "Checked the other three call sites, no
other instance" is a result the reviewer can rely on.
