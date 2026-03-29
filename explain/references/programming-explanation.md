# Programming Explanation Techniques

When the topic is code, syntax, or a codebase, these techniques make the explanation more digestible — applied on top of the six Feynman steps.

---

## Name the Pattern Before Dissecting It

Experts navigate code by recognising high-level patterns as single units — a filter, a retry loop, an observer, an actor. Novices get lost in the individual lines.

When explaining code, name the pattern first. Then dissect it.

> "What you're looking at is a **bridge pattern** — it's letting the old Rx world and the new async world talk to each other. Here's how it works..."

This gives the listener a hook before the detail lands. Without the hook, the detail is noise.

---

## Show the Mechanism in Real Code, Then in Words

For abstract concepts, the analogy comes first. For programming, often the code *is* the analogy — but only if it's shown in the right order.

- Show a minimal real example first (from their actual codebase if possible, not hypothetical)
- Then explain what each part does
- Never explain code that hasn't been shown yet

If you describe a pattern without showing it, you're asking the listener to hold an abstract shape in their head. Show the shape first.

---

## Explicitly Name and Correct the Wrong Mental Model

Most confusion in programming comes from a wrong mental model, not missing information. The listener already has a theory — it's just incorrect.

Don't just explain the right thing. Name the wrong model first.

> "You might think `actor` means the same as a thread-safe class — like it's just `class` with a lock on it. It's not. An actor isn't a lock — it's a **mailbox**. Things get queued and processed one at a time..."

This is Step 2 of Feynman applied with precision to code: the "lie in the obvious" is almost always a misapplied mental model from a different context.

---

## Separate the Three Questions

Programming explanations often collapse three different questions into one muddled answer:

| Question | What it answers |
|----------|----------------|
| **What is it?** | The mechanism — what it does and how |
| **Why does it exist?** | The problem it solves — what breaks without it |
| **When do I use it?** | The decision boundary — when to reach for it vs alternatives |

Answer them in that order. Skipping "why does it exist" is the most common mistake — it leaves the listener with a fact but no intuition for when it matters.

---

## Trace Execution, Don't Just Describe Structure

Structure descriptions ("the presenter calls the interactor which calls the repository") are forgettable. Execution traces are memorable.

Walk through what actually happens, step by step, for a concrete input:

> "User taps the voucher button. That fires `validateVoucher(code:)` on the presenter. The presenter is `@MainActor`, so we're on the main thread. It calls `await interactor?.applyVoucherFor(...)`. Now we hop off the main thread — the actor takes over on its own executor. The network call happens. Result comes back. We return to the presenter, still `@MainActor`..."

This is the "trace the path" exercise from learning science — following a single concrete case through the full system. It makes the control flow feel real rather than diagrammatic.

---

## Layer Complexity — One Concept Per Paragraph

Cognitive load is real. Don't pile two new concepts into the same sentence.

Introduce one concept. Let it land. Then build on it.

If you find yourself using "and also" or "additionally" — stop. Split it. The second concept belongs in the next paragraph, after the first one has had space to breathe.

---

## Make Jargon Earn Its Place

Every technical term introduced before it's understood adds to the cognitive load without adding meaning. The listener has to hold the unfamiliar word in memory *while* trying to parse the rest of the sentence.

The rule: define before use, always. But go further — only introduce a term when you're about to use it. Don't pre-define a glossary. Introduce each term at the moment it becomes necessary.

---

## Use Their Codebase, Not Hypothetical Code

Generic examples ("imagine you have a `Car` class...") are forgettable. Examples from code the listener has already touched are immediately meaningful.

When the topic is codebase-specific: use actual files, actual function names, actual patterns from the PR or module being discussed. The explanation should feel like it's about *their* code, not about code in general.

---

## End With "What Would Break Without This"

The Feynman closing ("here's the one thing you now understand that most adults don't") is more powerful for programming when it takes this specific form:

> "Here's the one thing you now understand that most adults don't: you'll immediately know *why* the `CancellationError` catch is separate — because if you miss it, you're showing an error UI to someone who already left the screen. That's the mistake the wrong mental model causes."

The consequence should be a *specific wrong thing* that now makes sense — not a vague "now you'll write better code."
