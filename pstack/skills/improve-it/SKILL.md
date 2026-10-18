---
name: improve-it
description: "Review a website or web app the user owns across performance, SEO, audience and funnel, and reliability and security, with four parallel read-only lanes, re-check every headline claim, publish one ranked review page, and on the user's go run the fixes as an autopilot PR program. Use for /improve-it, 'review my site', 'what should I improve next', or a site-wide health check that should end in a prioritized list."
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

Fill every `<PLACEHOLDER>` in `references/lane-briefs.md`. Read the values from the repo, the host's MCP, and memory before asking. Ask only for what you cannot find. Drop a bullet whose data source the site lacks and say so in the brief.

- Site. `SITE_URL`, `HOST_NAME`, `REPO`, `TRUNK`, `SHA`, `FRAMEWORK`, `HOST`, `REGION`, `DATABASE`.
- Data stores. `NON_PROD_DB` (a non-production database or branch, if any), `ENV_FILE`, `SCHEMA_PATHS` (policies, grants, migrations), `WRITE_ENDPOINTS` (every route or table the site writes to from the browser), `BEACON_HOSTS` (GA collect and every vendor beacon).
- Analytics. `HOST_FIELD_DATA`, `GA4_ID`, `EVENT_LIST` with the date each custom dimension was registered, `FUNNEL_EVENTS`, `GSC_PROPERTY` and its `RESOURCE_ID`, `LOG_SOURCE`, and how each is read (MCP connector, or the signed-in browser when no connector exists). On a site that is not a game, the funnel steps are its conversion events: CTA click, sign-up, lead form.
- Pages. `KEY_PAGES` (home, the main action page, any repeat surface, one content page, one non-default locale page), `MAIN_ACTION_PAGE`, `MONEY_PAGES`, `SECONDARY_SURFACES`, `WALKTHROUGH_PATH`.
- Prior work. `PRIOR_WORK` (plan docs, roadmaps, earlier review pages, open PRs), `RECENT_CHANGES` (the last ~20 trunk commits), `KNOWN_ITEMS`, `DECIDED`, `SITE_SPECIFIC_QUESTIONS`.
- Run. `SCRATCH`, the session scratchpad. Each lane writes only under `$SCRATCH/audit/<lane>/`. `LANE` and `WORD_LIMIT` are per brief.

## Phase 1: Review lanes

Spawn four lanes in one message as local background agents, `subagent_type: general-purpose` (they need MCP and the browser), `model: opus` unless `~/.claude/pstack-models.md` names a `judgment and prose` model. Each brief is the shared preamble plus that lane's section from `references/lane-briefs.md`.

| Lane | Covers |
|---|---|
| performance | host field data, lab timing in headless Chrome, cache headers, dynamic vs static routes, bundle, third-party scripts |
| seo | Search Console, GA4 organic, a crawl of sitemap, robots, canonicals, hreflang and structured data, low-CTR and position 8-20 queries |
| audience | GA4 funnel (visit, first action, repeat, return), converting landing pages and sources, a first-visit walkthrough at desktop and 375 px with screenshots, content ideas tied to a data signal |
| reliability | zero-row database permission probes, input integrity, error logs and their retention, security headers, client data loss, `npm audit` |

Every lane is read-only. The coordinator writes only scratch files and the review page until Phase 4.

While lanes run, start re-checking the first reports as they arrive (Phase 2). Don't idle.

## Phase 2: Re-check and rank

You own every claim on the page. A lane's report is a lead, not a fact.

1. Re-run the check behind every headline claim yourself: a `curl -sI`, one analytics query, a file read, opening the screenshot. Say in the page which ones you re-checked.
2. Drop stale items. Search trunk history and open PRs for each fix (`git log --oneline -S<term>`, `gh pr list --search`). A fix already shipped, or an event already retired, is out. A claim whose data predates the fix is out.
3. Merge duplicates across lanes. One finding seen by two lanes is one item with both lanes' evidence.
4. Downgrade one-day signals to "watch" unless a second source agrees. Say so on the page.
5. Rank by user impact over effort. Security holes that allow production writes rank first, then broken measurement (it distorts every other number), then what blocks the main action, then search and speed.
6. Split out owner steps: anything only the site owner can do (dashboard settings, keys, migrations against production, Search Console buttons, registering analytics dimensions).

## Phase 3: Publish the review page

Run Artifact quickstart, then write and publish one page per `references/review-page.md`. Before writing, load the `artifact-design` skill and read the `~/.claude/design/*.md` files that apply (at least `00` to `03`, `05`, `07`, `08`, `09`, and `artifacts.md`).

Then reply in chat with the link and the "do first" list in plain words. Change nothing on the site. Offer Phase 4 in one line.

## Phase 4: Fix program (only on the user's go)

Run the Autopilot-full playbook, `../poteto-mode/playbooks/autopilot-full.md`, with these changes for a single-owner site repo.

- Keeps: one owner per PR, decision trails, self-proof on the real app, `/simplify` and `/no-comments`, one rebase onto trunk before code-ready, the babysit loop to CI green, swarm verification at the merge-ready head, owner merges on a clean verdict, the patch-id rule, the audit tick, and stand-down on the user's stop.
- Replaces: no `gt` registration (plain `git` and `gh`); Bugbot triage only when the repo runs Bugbot; verifiers run as local background agents (they need the repo, `ENV_FILE`, ports and worktrees), not swarm's cloud default; operator-named items become `gate_timing` in the queue.

States. **code-ready** means the diff is final, the gates are green on the committed head, and the branch was rebased once onto trunk. **merge-ready** means code-ready, CI green (when the repo has CI), and self-proof done, at a trunk-current head. The swarm verifies the merge-ready head and pins its SHA.

1. **Group findings into PRs.** One PR per set of findings that share files. Two PRs never edit the same file in the same wave. A PR that needs another's code or a shared config waits a wave (`depends_on`). Write `$SCRATCH/program/queue.tsv` from `references/queue-template.tsv`. Each operator gate gets a `gate_timing`: `before-merge` stops the PR at merge-ready until the user confirms the step is done; `after-merge` lets it merge and lists the step in the hand-off. Prefer code that is safe to merge before the gate, for example falling back to the old behaviour while a new env var is missing.
2. **Write the shared protocols once.** Copy `references/owner-protocol.md` and `references/verify-protocol.md` into `$SCRATCH/program/` and fill every `<PLACEHOLDER>` from Phase 0 and the repo's AGENTS.md (gates, test runner, flaky tests, locales, design files, verify skill). Briefs point at these files. Never paste them inline.
3. **State the plan and wait.** Show the queue, the waves, and the operator gates with their timing. Say that the user's go authorizes the owners to merge, and that each merge deploys to production. Then stop until the user says go.
4. **Run waves.** Spawn one owner per wave-1 PR (fresh `poteto-agent`, background), each with its id, branch, port, scope, and the problem with its evidence. Allocate owner ports in steps of 10 from a base (3100, 3110, ...) and give each verifier lane two ports from a separate base (its run and the trunk baseline). Keep about six owners at once so test runs stay stable. Track agents in `$SCRATCH/program/roster.tsv` and your own trail in `$SCRATCH/program/decisions.tsv` per the **show-me-your-work** skill.
5. **Verify before every merge.** At each merge-ready head SHA, fan out the verifier lanes from the verify protocol per the **swarm** skill, as local background agents. Send every proven finding back to the owner in one message. Only a clean verdict on that head earns "clean verdict, merge".
6. **Hand off owner steps.** End with the merged PRs, the open ones, and the operator gates still waiting on the user, in the order they must happen (for example "set the key, then run the migration").

## Rules

- A finding without a suggested change is a note, not a finding.
- Never print secrets. Read env names, keep values in variables.
- Reply per poteto-mode's **Writing the reply**: the link, the do-first list, what you re-checked, what you dropped as stale and why.
