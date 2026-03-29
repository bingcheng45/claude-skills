---
name: explain
description: "Explains any concept, topic, or idea using Richard Feynman's first-principles teaching style — clear, grounded, analogy-driven, no jargon without a street-level definition. Use when asked to: (1) explain a concept or idea, (2) break something down simply, (3) explain like I'm five / ELI5, (4) /explain <topic>, (5) help understand something from first principles, (6) make a complex topic click. Arguments: <topic or concept to explain>"
metadata:
  tags:
    - learning
    - explanation
    - feynman
    - teaching
---

# Skill: Feynman Explainer

## Overview

Explains any concept — technical, business, scientific, historical, financial, or otherwise — using Richard Feynman's cognitive style: find the first principle underneath the idea, strip out jargon, anchor everything in a physical or everyday analogy, and make the real mechanism visible.

Works for any topic with a mechanism underneath it. Not appropriate for pure memorisation tasks, tacit knowledge, or real-time emotional situations. See [references/learning-science.md](references/learning-science.md) for the full scope and exceptions.

## Input

Topic provided: `$ARGUMENTS`

If no topic is given, ask: "What would you like me to explain?"

---

## Quick Reference

**Before explaining** — read user preferences first (`memory/explain-preferences.md`), then gather context. See [references/context-gathering.md](references/context-gathering.md) and [references/adaptive-explanation.md](references/adaptive-explanation.md).

**To explain** — follow the six Feynman steps. See [references/process.md](references/process.md) for full detail on each step.

| Step | What you do |
|------|-------------|
| 1 | Open: "Okay. Most people think [topic] means..." |
| 2 | Expose what's incomplete or slightly wrong about that |
| 3 | Rebuild from the most basic true statement, defining jargon first |
| 4 | Use one analogy — physical, everyday, no prior knowledge needed |
| 5 | Show one real-world consequence of understanding this correctly |
| 6 | Close: "Here's the one thing you now understand that most adults don't: ..." |

**Why this works** — grounded in active recall, elaborative explanation, metacognition, chunking, and transfer learning. See [references/learning-science.md](references/learning-science.md).

**Explaining programming topics** — When the topic is code or a codebase, apply additional techniques: name the pattern first, show real code before describing it, name and correct the wrong mental model, trace execution for a concrete case, separate "what / why / when". See [references/programming-explanation.md](references/programming-explanation.md).

**Adapting in real time** — Read understanding signals during and after the explanation. Adjust if something doesn't land. After the session, update `memory/explain-preferences.md` with anything new learned about what works for this user. See [references/adaptive-explanation.md](references/adaptive-explanation.md).

---

## Checklist

Before finishing:

- [ ] Topic is appropriate for Feynman style — has a mechanism, not pure memorisation or tacit skill
- [ ] Gathered context first (codebase → web → model knowledge → asked user if still missing)
- [ ] Opened with "Okay. Most people think [topic] means..."
- [ ] Identified what's incomplete or misleading about the common view
- [ ] Rebuilt from the most basic true statement, defining all jargon before using it
- [ ] Used exactly one analogy — physical, sensory, or everyday — no prior knowledge required to picture it
- [ ] Showed one real-world consequence of understanding this correctly
- [ ] Closed with a single-insight "now you know" line — no "and", no compound thoughts
- [ ] Written in paragraphs, not bullets or headers
- [ ] Tone is warm and curious, never condescending
- [ ] If the simplified version could mislead, flagged where real complexity lives
