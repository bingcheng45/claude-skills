# Adaptive Explanation — Reading Signals and Adjusting

A good explanation isn't a monologue. It's a loop. Deliver, read the response, adjust, deliver again. This file tells Claude how to close that loop.

---

## Step 0 — Check User Preferences First

Before explaining, read the user's explanation preferences from memory:

```
/Users/bing.toh/.claude/projects/-Users-bing-toh-Documents-foodpanda/memory/explain-preferences.md
```

If the file exists, apply the preferences immediately — preferred analogy style, chunking pace, detail level, what has worked before, what hasn't. Don't make the user restate preferences they've already revealed.

If the file doesn't exist yet, start building it from this session.

---

## Reading Understanding Signals

Don't wait for the user to say "I'm confused." Read the signal in how they respond.

### Strong understanding signals
- Extends the explanation: "Oh so that means X would also..."
- Applies it correctly in a follow-up question
- Asks a *deeper* question that builds on what was explained
- Says "that makes sense" and moves forward confidently

### Partial understanding signals
- "I kind of get it but the [X] part is unclear"
- Asks about one specific piece — the rest landed, one piece didn't
- Repeats back the concept but gets one detail wrong
- Asks a follow-up that's slightly adjacent, not quite on point

### Confusion signals
- Asks the same question again in different words
- "Can you explain that again"
- Follow-up question reveals a term you already defined wasn't retained
- Response is very short and non-committal — "ok" / "I see" without engagement
- Asks for "more clarity" or "can you simplify"
- Asks about a term that was in the explanation — they got lost before you used it

### Over-explanation signals (went too deep too fast)
- Sudden silence or one-word response after a long explanation
- "I'm lost" after the first paragraph — complexity hit before the hook landed
- "Can you start from the beginning"

---

## What To Do When It Doesn't Land

**Never repeat the same explanation again.** The words are already there — they didn't work. Repetition isn't clarity.

Instead, diagnose *which part* failed before re-explaining anything:

> "Which part lost you — the [X] piece or the [Y] piece?"

Then apply the right adjustment:

| Signal | Adjustment |
|--------|-----------|
| Analogy didn't click | Replace the analogy entirely — try a different domain, more physical, more everyday |
| Concept too abstract | Show a real code example first, then explain it |
| Went too fast | Slow down — one concept per message, not per paragraph |
| Jargon wasn't grounded | Back up, redefine the term with a more concrete anchor |
| Lost in the middle | Rebuild from the last point they confirmed understanding |
| "What do you mean by X" (X was defined) | The definition didn't stick — redefine with a different anchor, not the same words |
| Too much at once | Split into parts, ask "does this part make sense before I continue?" |

---

## Checking In Without Being Patronising

After a complex explanation, build in a natural check — not "did you understand?" (yes/no, defensive), but something that invites response:

- "Does that mechanism make sense, or is there a part you want me to drill into?"
- "Want me to trace through a real example from the code?"
- "Which part felt shaky?"

Make it easy to say "I'm not sure" without it feeling like a test.

---

## When the User Asks for More Clarity

"More clarity" is a signal that something specific didn't land — but they may not know what. Help them locate it:

1. Ask: "Which part — the [concept A] or the [concept B]?"
2. If they can't pinpoint it, offer two angles: "Do you want me to try a different analogy, or show you what this looks like in actual code?"
3. Never re-explain the whole thing — isolate the unclear piece and explain only that

---

## Updating User Preferences After Each Session

After an explanation session — especially when adjustments were made — update the user's preference file:

**File location:**
```
/Users/bing.toh/.claude/projects/-Users-bing-toh-Documents-foodpanda/memory/explain-preferences.md
```

**What to record:**

```markdown
## Explanation Preferences

### What works
- [e.g., physical/sensory analogies land better than procedural ones]
- [e.g., showing code first, then explaining, works better than describing first]
- [e.g., execution traces (step-by-step "what happens when") are effective]
- [e.g., prefers one concept per message for complex topics]

### What doesn't work
- [e.g., abstract descriptions without code examples get lost]
- [e.g., long setup before the main point — loses attention]

### Analogies that landed
- [analogy → concept it explained, session date]

### Analogies that didn't land
- [analogy → what was tried instead, session date]

### Preferred pace
- [e.g., check in after each major concept vs. explain fully then check]

### Preferred entry point
- [e.g., prefers "why does this exist" before "what is it"]
```

Only record things that were actually revealed in the session — confirmed by explicit feedback or a clear signal. Don't infer preferences from a single session without signal. Update existing entries rather than duplicating.

---

## The Improvement Loop

This is how the skill gets better over time for this user specifically:

```
Explain → Read signal → Adjust if needed → Note what worked/didn't → Save to memory → Apply next session
```

Each session, the explanation should start slightly better calibrated than the last. After 3–4 sessions, the preferences file should contain enough signal to skip most of the early calibration and go straight to what works.
