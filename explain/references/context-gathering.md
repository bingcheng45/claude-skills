# Context Gathering — Before You Explain

A Feynman explanation built on vague assumptions is worse than useless — it teaches the wrong thing confidently. Before explaining, locate the real source material.

---

## Step 1 — Try to find it yourself

Search in this order:

1. **Codebase** — use Grep, Glob, or Read to find the actual implementation, PR, or relevant files
2. **Web** — search for public documentation, articles, or specs if the topic is external or involves a library/framework
3. **Model knowledge** — if it's a well-known, stable concept (e.g. async/await semantics, TCP/IP, compound interest), your existing knowledge may be sufficient

For abstract, timeless concepts: skip to model knowledge immediately. No codebase or web search needed.

For codebase-specific topics (e.g. "explain how our voucher flow works"): always read the actual files first. Don't explain what you guess is there.

---

## Step 2 — Ask the user if context is out of reach

Stop and ask the user before explaining if any of these are true:

| Condition | Why it matters |
|-----------|---------------|
| Topic is internal, proprietary, or undocumented | Can't be found in codebase or online — explanation would be fabricated |
| Knowledge is likely newer than training cutoff | Recent releases, new APIs, recent events — model knowledge may be outdated or wrong |
| Topic is sensitive enough that a wrong explanation could cause harm | Medical, legal, financial, security — wrong mental models here have real consequences |
| Found something but not confident it's the right thing | Better to surface uncertainty than explain the wrong file or document |

**When asking, be specific — not vague.**

Don't say: "I don't have enough context to explain this."

Do say: "I found `VoucherClient.swift` but I can't tell which version of the API you're running against — the async path and the Rx path have different error handling. Can you point me to the right one, or share the relevant part?"

The more specific the question, the faster the user can unblock you.

---

## Step 3 — If context never arrives

If you can't find it and the user doesn't or can't provide it:

- Explain what you *do* know
- Label it clearly as general knowledge, not specific to their codebase or situation
- Flag what would change if their context differs from the general case

Never fill a knowledge gap with a confident-sounding guess. Labelled uncertainty is more useful than unmarked fiction.
