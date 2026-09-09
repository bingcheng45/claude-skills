---
name: explain-what-agent-did
description: "Explains work that was just completed — a bug fix, an investigation, a refactor, a failed attempt — in plain language the person can follow without reading the diff. Leads with the corrected mental model, uses one physical analogy, draws ASCII diagrams for anything structural or numeric, pairs every cause with what solved it and why that worked, and stays honest about attribution and what is still broken. Use this whenever the user asks: (1) explain what you did, (2) what was the issue / what was actually wrong, (3) what fixed it and why, (4) explain in simple terms / plain English / like I didn't write this, (5) recap or summarise what happened, (6) I don't follow what changed, (7) walk me through it. Also reach for it unprompted right after finishing a debugging or investigation session, when the user has been watching tool calls scroll past and now needs the story — even if they only say 'ok so what happened'."
metadata:
  tags:
    - explanation
    - communication
    - retrospective
    - debugging
---

# Skill: Explain What The Agent Did

## Overview

This skill is for the moment after the work. The code is written, the bug is found or not
found, and the person who asked now wants to understand it. They have been watching tool
calls scroll past and they do not want a transcript. They want the story.

The goal is a reader who could confidently explain the problem to a colleague afterwards.
That is a higher bar than "the reader nodded". It means they hold the mechanism, not a
summary of your activity.

This is distinct from the `explain` skill, which teaches a general concept. Here the
subject is specific work that just happened, with real numbers, real file names and real
uncertainty attached to it.

## When this applies, and when it does not

Use it when work has concluded and the user wants the account. Bug fixes, investigations,
performance work, refactors, and failed attempts all qualify. A failed attempt especially
qualifies, because the reader needs to know what was ruled out.

Do not use it for work still in progress, where a status update is what is wanted. Do not
use it when the user asked a narrow factual question, because a full explanation there is
padding. If they ask "did the tests pass", answer that.

## The shape

Adapt this rather than filling it in mechanically. Sections that have nothing to say get
dropped, not padded.

```
1. The corrected mental model      what they probably think, then what is actually true
2. One section per distinct cause  each ending in What solved it / Why that solved it
3. What the wrong fix would have been
4. What is still open
5. One closing insight             a single thought, no "and"
```

## The moves

### Open by naming the wrong mental model, then correcting it

Start with the belief the reader most likely arrived with, say it plainly, and then say what
is actually true. This works because a reader holding a wrong model will bend everything you
say to fit it. Replacing the model first makes the rest land.

The usual shape is that a single word in their bug report was doing the misleading. "Lag"
implies slowness. "Crash" implies a fatal error. "It's not saving" implies a write failure.
Find the word and take it apart.

```
Okay. Most people think "lag" means the app is slow and needs optimising.

That is the wrong mental model here, and it is why this took so long to find.
Nothing in your app was heavy.
```

### Order the causes by impact, and say which one dominated

When there are several causes, put the biggest first and label it as the biggest. The reader
is deciding where to spend attention, and without a ranking they will assume the causes are
equal. They rarely are. One usually accounts for most of what the user felt.

Saying "Issue 1, the big one" costs three words and tells them the other two are detail.

If you genuinely do not know which dominated, that is a sentence worth writing rather than an
ordering worth faking.

### Make each heading state the mechanism, not a label

A heading like "Formatter caching" names a topic. A heading like "Rebuilding the stamp
machine every single time" names the mistake, and a reader skimming only the headings still
comes away with the story.

Compare:

```
weak                      strong
──────────────────────────────────────────────────────────────────
Formatter caching         Rebuilding the stamp machine every time
Gesture arbitration       One swipe, two page turns
Animation completion      Handing the baton to a page still moving
```

The strong versions are doing explanatory work in the table of contents. That matters
because headings are the part everyone reads.

### Define jargon in street terms, before you use it

Any term the reader might not own gets one plain sentence first. Not a formal definition, a
functional one. What is this thing for.

> A "formatter" is the thing that turns a raw date number into readable text like
> `WED, SEP 9 AT 8:00 AM`.

Doing this inline costs one sentence and saves the reader guessing for three paragraphs. If
a term needs more than a sentence, it probably deserves its own diagram.

### Use exactly one analogy, for the dominant mechanism

One analogy, physical and everyday, requiring no prior knowledge. Spend it on whichever
cause mattered most.

The reason for the limit is that analogies compete. A second one makes the reader ask which
frame they are in, and a third turns the explanation into a zoo. Other causes are usually
simple enough to state mechanically once the main one has landed.

A good analogy is checkable. The reader should be able to picture it and then notice that the
absurd part of the analogy is exactly the absurd part of the code.

> You need to write today's date on 50 envelopes. The sensible way is to pick up a pen once,
> then write 50 times. What the code did was buy a new pen, unwrap it, test it on scrap
> paper, write one envelope, bin the pen, and repeat. Fifty times.
>
> The writing was never the slow part. The unwrapping was.

### Pair every cause with what solved it and why that worked

Each cause section ends with two labelled beats. What solved it, then why that solved it.

The second beat is the one people skip and it is the one that transfers. "We cached it" is a
change. "The work was pure repetition with an identical answer every time, so removing the
repetition cannot change behaviour, it just stops paying" is understanding.

Keep them short and keep them separate, so a reader skimming for the mechanism can find it.

### Draw a diagram for anything structural or numeric

Reach for a diagram whenever there is a comparison, a fork, a pipeline, a chain of
multipliers, or more than about three related parts. Prose describing structure forces the
reader to rebuild the structure in their head, which is work you can just do for them.

Numeric comparison:

```
build a formatter  ... 50.6 microseconds
reuse one          ...  1.6 microseconds
                        ~31x difference
```

A fork where two things both fire:

```
your finger on the bar
        │
        ├──► the bottom bar's own swipe detector  ──► "turn the page"
        └──► the whole-screen swipe detector      ──► "turn the page"

                                        result: two pages turned
```

A chain that explains why something small became visible:

```
1 row  ×  5 badges built eagerly, even the hidden ones
       ×  redrawn every time anything on screen changes
       ×  thrown away when scrolled off, rebuilt when scrolled back
```

Keep them narrow enough not to wrap in a terminal.

### Use the real numbers

"31x", "50.6 microseconds", "18 stale promotions", "4.4 percent duty cycle". Concrete figures
let the reader judge severity themselves instead of trusting your adjective. "Much faster"
tells them nothing and reads as hedging.

If you do not have a number, say so rather than reaching for an adjective.

### Say what the wrong fix would have been

Name the plausible response that the wrong mental model would have produced, and what it
would have cost. This is where the explanation earns its keep, because it changes what the
reader does next time.

> If you had trusted the word "lag", the obvious response would have been to make the app do
> less. Fewer badges, simpler rows, lazier lists. That would have made the app worse and left
> all three bugs in place.

### Be honest about attribution and about what is still broken

If several changes landed and you cannot tell which one the user is feeling, say so. If you
never measured, say you never measured. If part of the original report is still unexplained,
give it its own short section rather than letting it dissolve into the good news.

This is not modesty for its own sake. An explanation that quietly overclaims leaves the
reader with a false model of their own system, which is the exact thing this skill exists to
prevent. It also means that when you do claim something firmly, they can believe you.

### Close with one insight, not a summary

End on a single sentence the reader can carry. One thought. No "and", no compound clause, no
recap of the sections above.

> A stutter almost never means your code is too slow to run once. It means something cheap is
> running far more often than anyone intended.

## Formatting

The reader is usually in a terminal. Dense prose costs them re-reads.

- Short sentences, one idea each.
- A blank line between logical blocks. Avoid paragraphs longer than about three sentences.
- Lead with the conclusion, then the evidence.
- Bold the two recurring labels, **What solved it** and **Why that solved it**, so the
  mechanism is skimmable.
- Reference real file and symbol names so the reader can go look, but do not paste code
  blocks unless a snippet genuinely carries the point. A diagram usually beats the code.

## Anti-patterns

**Narrating your process.** "First I profiled, then I read the model, then I noticed..." The
user asked what was wrong, not what you did in what order. Your search path is only worth
telling when a dead end is itself the finding, and then it belongs in the still-open section.

**One analogy per cause.** Dilutes all of them. Pick the dominant mechanism and spend the
single analogy there.

**Adjectives standing in for measurements.** "Significantly faster", "quite expensive". If
there is a number, use it. If there is not, say there is not.

**Burying the unresolved part.** A reader who thinks a bug is fixed when it is not will stop
watching for it. Give it a heading.

**Ending with a recap.** The sections already said it. A summary paragraph at the end tells
the reader the explanation did not trust itself.

**Explaining the code instead of the mechanism.** The reader does not need your call graph.
They need to know that the same cheap thing ran thousands of times, or that two listeners
both fired, or that a cancelled animation still reported success.

## Worked example, condensed

A real invocation. The user asked why their iOS app's page-swiping felt laggy, after several
turns of profiling had found nothing.

The corrected model came first, that "lag" implied slowness while nothing was actually heavy,
and that three separate problems had been collapsed under one word.

Then one section per cause. Rebuilding a date formatter on every row draw, which got the
single analogy about the pens and envelopes, plus a numeric diagram for the 31x and a
multiplier chain for why it became visible. Two swipe detectors both firing on one gesture,
which got a fork diagram and no analogy. A cancelled animation still reporting success, which
got neither, because "the animation system says finished both when it finishes and when it is
cancelled" is already plain.

Each ended with what solved it and why that worked. Caching removes repetition, and removing
repetition cannot change behaviour. Ownership decided at touch-down replaces a race with a
fact. A generation number makes an ambiguous "finished" unambiguous.

Then the wrong fix, that simplifying the UI would have lost features and kept all three bugs.
Then the honest part, that three commits landed and the biggest was not the agent's, and that
one symptom from the original report had never been reproduced. Then one closing line.
