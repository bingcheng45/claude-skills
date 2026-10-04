---
name: goal-alignment
description: "Restate the user's goal and the problem behind it in your own words before starting work, so a wrong read costs a paragraph instead of an afternoon. Use for /goal-alignment, 'what do you think I'm asking for', 'are we aligned', or before any expensive, ambiguous, or long-running task."
disable-model-invocation: true
---

# Goal alignment

Say back what the user is trying to achieve and what problem they are solving, in your own words, before you start. Then start.

**Why:** The cheapest place to catch a misread is the first paragraph. An agent that restates after building has already spent the budget.

**Pattern:**
- **Name the outcome, not the task.** The request is a proposed means. State the end it serves.
- **Name the problem behind it.** What is costly or broken now that prompted this. If you cannot say, you are guessing at the goal.
- **Commit to the load-bearing assumptions.** The two to four inferences that change the work if they are wrong. This is the falsifiable part. Without it there is nothing for the user to correct.
- **Draw the scope boundary.** Say what you are deliberately not doing, so silence is not mistaken for agreement.
- **Say what done looks like.** Concrete enough that either of you could check it.
- **Then begin.** The restatement is a checkpoint the user can interrupt, not a gate you wait behind.

**The test:** if nothing in your restatement could be wrong, you echoed the request instead of understanding it. Rewrite it, or ask one real question.

**Boundaries:**
- **Skip it** when the task is small, unambiguous, and cheap to redo. A factual lookup needs no preamble.
- **One paragraph.** A long restatement is its own kind of stall.
- **Never ask permission to begin.** State the reading, start work, let the user cut in (the `principle-never-block-on-the-human` skill).
- **Restate again out loud** when evidence mid-task changes your read. A stale alignment is worse than none, because both sides think it holds.
