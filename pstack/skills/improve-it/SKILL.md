---
name: improve-it
description: "Review a website or web app the user owns across performance, SEO, players and funnel, and reliability and security, with four parallel read-only lanes, re-check every headline claim, publish one ranked review page, and on the user's go run the fixes as an autopilot PR program. Use for /improve-it, 'review my site', 'what should I improve next', or a site-wide health check that should end in a prioritized list."
disable-model-invocation: true
---

# Improve it

Find what to change next on a site the user owns, prove each claim, and hand back one ranked page. Fixing is a separate, opt-in phase.

## Start

Open a todolist with one entry per phase before launching anything.

0. Frame
1. Review lanes
2. Re-check and rank
3. Publish the review page
4. Fix program (only on the user's go)

## Phase 0: Frame

Collect these facts once and put them in every brief. Read them from the repo, the host's MCP, and memory before asking. Ask only for what you cannot find.

- `SITE_URL`, `REPO` path, trunk branch and head SHA, framework, host and region, database.
- Analytics. The host's field data (for example Vercel Speed Insights), the GA4 property ID, the Search Console property, and how each is read (MCP connector, or the signed-in browser when no connector exists).
- Prior work. Plan docs, roadmaps, earlier review pages or artifacts, and open PRs. Lanes must read these first.
- Recent changes. The last ~20 trunk commits, so lanes don't report shipped work as missing.
- `SCRATCH`, the session scratchpad. Each lane writes only under `$SCRATCH/audit/<lane>/`.
- Locales, key pages (home, the main action page, any daily or repeat surface, one content page, one non-default locale page), and anything already decided that lanes must not relitigate.

## Phase 1: Review lanes

Spawn four background subagents in one message, `model: opus` unless `~/.claude/pstack-models.md` names a `judgment and prose` model. Full tool access, since lanes need MCP and the browser. Fill each brief from `references/lane-briefs.md`: the shared preamble plus that lane's section.

| Lane | Covers |
|---|---|
| performance | host field data, lab timing in headless Chrome, cache headers, dynamic vs static routes, bundle, third-party scripts |
| seo | Search Console, GA4 organic, a crawl of sitemap, robots, canonicals, hreflang and structured data, low-CTR and position 8-20 queries |
| players | GA4 funnel (visit, first action, repeat, return), converting landing pages and sources, a first-visit walkthrough at desktop and 375 px with screenshots, content ideas tied to a data signal |
| reliability | database permission probes that cannot persist anything, input integrity, error logs and their retention, security headers, client data loss, `npm audit` |

Every lane is read-only. No code edits, commits, deploys, settings changes, data writes, form or score submissions, and no `vercel curl` (it silently creates a deployment-protection bypass secret). Each lane creates its own browser tab and closes it.

Each lane returns at most ~10 new findings. Each finding carries evidence (numbers with source and date range, every claim labelled measured or inferred), a suggested change, effort S/M/L, and whether it is already planned. Each lane also returns an "already fine" list and its screenshot paths.

While lanes run, start re-checking the first reports as they arrive (Phase 2). Don't idle.

## Phase 2: Re-check and rank

You own every claim on the page. A lane's report is a lead, not a fact.

1. Re-run the check behind every headline claim yourself: a `curl -sI`, one analytics query, a file read, opening the screenshot. Say in the page which ones you re-checked.
2. Drop stale items. Search trunk history and open PRs for each fix (`git log --oneline -S<term>`, `gh pr list --search`). A fix already shipped, or an event already retired, is out. A claim whose data predates the fix is out.
3. Merge duplicates across lanes. One finding seen by two lanes is one item with both lanes' evidence.
4. Downgrade one-day signals to "watch" unless a second source agrees. Say so on the page.
5. Rank by player impact over effort. Anything that corrupts measurement (broken analytics attribution) ranks first, because it distorts every other number. Then security holes that allow writes, then what blocks the main action, then search and speed.
6. Split out owner steps: anything only the site owner can do (dashboard settings, keys, migrations against production, Search Console buttons, registering analytics dimensions).

## Phase 3: Publish the review page

Build one artifact page per `references/review-page.md`. Load the `artifact-design` skill and read `~/.claude/design/*.md` that apply (at least `00` to `03`, `05`, `07`, `08`, `09`, and `artifacts.md`) before writing it. Publish with the Artifact tool and give the user the link.

The page holds, in order: the top ~6 "do first" items, one section per area with expandable findings, real screenshots, a funnel visual, content ideas, "already fine", and "only you can do" owner steps.

Then reply in chat with the link and the "do first" list in plain words. Change nothing on the site. Offer Phase 4 in one line.

## Phase 4: Fix program (only on the user's go)

Run this only when the user says to fix items. Follow the Autopilot-full playbook, `../poteto-mode/playbooks/autopilot-full.md`. This phase sets up its inputs.

1. **Group findings into PRs.** One PR per set of findings that share files. Two PRs never edit the same file in the same wave. A PR that needs another's code or a shared config waits a wave (depends_on). Write `$SCRATCH/program/queue.tsv` from `references/queue-template.tsv`. List each operator gate in its row.
2. **Write the shared protocols once.** Copy `references/owner-protocol.md` and `references/verify-protocol.md` into `$SCRATCH/program/` and fill every `<PLACEHOLDER>` from Phase 0 and the repo's AGENTS.md (gates, test runner, flaky tests, locales, design files, verify skill). Briefs point at these files. Never paste them inline.
3. **State the plan and wait.** Show the queue, the waves, and the operator gates, then stop until the user says go.
4. **Run waves.** Spawn one owner per wave-1 PR (fresh `poteto-agent`, background), each with its id, branch, port, scope, and the problem with its evidence. Keep about six owners at once so test runs stay stable. Track agents in `$SCRATCH/program/roster.tsv` and your own trail in `$SCRATCH/program/decisions.tsv` per the **show-me-your-work** skill.
5. **Verify before every merge.** At each code-ready head SHA, fan out the verifier lanes from the verify protocol per the **swarm** skill. Send every proven finding back to the owner in one message. Only a clean verdict on the merge-ready head earns "clean verdict, merge".
6. **Hand off owner steps.** End with the merged PRs, the open ones, and the operator gates still waiting on the user, in the order they must happen (for example "set the key, then run the migration").

## Rules

- Lanes never write. The coordinator writes only the scratch files and the artifact page until Phase 4.
- Every number on the page has a source and a date range. Every claim says measured or inferred.
- A finding without a suggested change is a note, not a finding.
- Never print secrets. Read env names, keep values in variables.
- Reply per poteto-mode's **Writing the reply**: the link, the do-first list, what you re-checked, what you dropped as stale and why.
