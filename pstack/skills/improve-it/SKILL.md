---
name: improve-it
description: "Review a website, web app, iOS app or macOS app the user owns with four parallel read-only lanes (web: performance, SEO, audience, reliability; apps: performance, store, audience, reliability), re-check every headline claim, publish one ranked review page, and on the user's go run the fixes as an autopilot PR program. Use for /improve-it, 'review my site', 'review my app', 'what should I improve next', or a product-wide health check that should end in a prioritized list."
disable-model-invocation: true
---

# Improve it

Find what to change next in a product the user owns, prove each claim, and hand back one ranked page. Fixing is a separate, opt-in phase.

## Surfaces

Each surface file owns its frame fields, Phase 4 values, live-run rules and four lane briefs. Pick one in Phase 0 and read only that file.

| Surface | Pick when | File | Lanes |
|---|---|---|---|
| web | a deployed site or web app (`package.json` with a web framework, a host config, a `SITE_URL`) | `references/surface-web.md` | performance, seo, audience, reliability |
| apple-app | an iOS or macOS app (`.xcodeproj`, `.xcworkspace`, or `Package.swift` with an executable or app target) | `references/surface-apple-app.md` | performance, store, audience, reliability |

An app repo with a server folder (a Worker, an API) is apple-app with that server as its `BACKEND`. A repo with two products, such as an app plus its marketing site, gets the surface the user names. When they name neither, ask which one. Run the other as a second review afterwards if they want it.

## Start

Open a todolist with one entry per phase before launching anything.

0. Frame
1. Review lanes
2. Re-check and rank
3. Publish the review page
4. Fix program (only on the user's go)

## Phase 0: Frame

Pick the surface. Then fill every `<PLACEHOLDER>` in its file and the shared fields below. Read the values from the repo, the host's or store's MCP or CLI (read-only calls only, such as `list` and `get`), and the project's memory under `~/.claude/projects/<project>/memory/` before asking. Copy memory gotchas that a lane would trip on (wrong device, missing env var, flaky tool) into that lane's brief. Ask only for what you cannot find. Drop a bullet whose data source the product lacks and say so in the brief.

- Shared. `REPO`, `TRUNK` (the branch name; lanes read `origin/<TRUNK>`), `SHA` (`origin/<TRUNK>` after `git fetch`; the local checkout may be behind it), `PRIOR_WORK` (plan docs, roadmaps, earlier review pages, open PRs; give main-checkout paths for docs that are untracked, since the lane worktree lacks them), `RECENT_CHANGES` (the last ~20 trunk commits), `KNOWN_ITEMS`, `DECIDED`, `SITE_SPECIFIC_QUESTIONS` or `APP_SPECIFIC_QUESTIONS` (add each question to the brief of the lane it belongs to).
- Surface. Every field in the surface file's "Frame fields".
- Live-run rules. Copy the surface file's "Live-run rules" into every lane brief, and later into both Phase 4 protocols as `LIVE_RUN_RULES`, with each backticked field name replaced by its value. Drop a clause whose field is none. Lanes, owners and verifiers all run under them.
- Run. `SCRATCH`, the session scratchpad, as an absolute path (lanes don't share your env). Each lane writes only under `$SCRATCH/audit/<lane>/`. `LANE` and `WORD_LIMIT` are per brief. Make one detached worktree of `SHA` at `$SCRATCH/audit/wt` for lanes to read; a lane that builds makes its own. Remove them after Phase 3. Leave the main checkout's branch, untracked files and local refs as they are. Name in each brief the MCP tools the lane needs and tell it to load them with ToolSearch first.

## Phase 1: Review lanes

Spawn four lanes in one message as local background agents, `subagent_type: general-purpose` (they need MCP and the browser), `model: opus` unless `~/.claude/pstack-models.md` names a `judgment and prose` model. Each brief is the surface file's shared preamble plus that lane's section.

| Surface | Lane | Covers |
|---|---|---|
| web | performance | host field data, lab timing in headless Chrome, cache headers, dynamic vs static routes, bundle, third-party scripts |
| web | seo | Search Console, GA4 organic, a crawl of sitemap, robots, canonicals, hreflang and structured data, low-CTR and position 8-20 queries |
| web | audience | GA4 funnel (one row per `FUNNEL_EVENTS` step, then return), converting landing pages and sources, a first-visit walkthrough at desktop and 375 px with screenshots, content ideas tied to a data signal |
| web | reliability | zero-row database permission probes, input integrity, error logs and their retention, security headers, client data loss, `npm audit` |
| apple-app | performance | field metrics (Organizer, MetricKit), launch and main-action timing, main-thread work, idle cost of a resident app, repeated work, size |
| apple-app | store | App Store Connect conversion and search, listing text and screenshots, ratings and reviews, or the download page and update feed; pricing and paywall clarity; review-guideline risks |
| apple-app | audience | funnel from the analytics SDK or store data, then day-1 and day-7 return, a first-use walkthrough through the screen lever at small and large sizes in both themes, ideas tied to a signal |
| apple-app | reliability | crashes and hangs, user data and migrations, destructive actions on the wrong item, concurrency, purchases and licensing, update and signing path, backend probes |

Every lane is read-only except the reliability lane's zero-row probes and throwaway fixtures under its scratch dir. The coordinator writes only scratch files and the review page until Phase 4.

While lanes run, start re-checking the first reports as they arrive (Phase 2).

## Phase 2: Re-check and rank

You own every claim on the page. A lane's report is a lead, not a fact.

1. Re-run the check behind every headline claim yourself: a `curl -sI`, one analytics query, a file read, a test or command, opening the screenshot. Say in the page which ones you re-checked.
2. Drop stale items. Search trunk history and open PRs for each fix (`git log --oneline -S<term>`, `gh pr list --search`). A fix already shipped, or an event already retired, is out. A claim whose data predates the fix is out.
3. Merge duplicates across lanes. One finding seen by two lanes is one item with both lanes' evidence.
4. Downgrade one-day signals to "watch" unless a second source agrees. Say so on the page.
5. Rank by user impact over effort. Anything that can lose user data, act destructively on the wrong thing, or allow production writes ranks first. Then crashes and broken measurement (it distorts every other number), then what blocks the main action or the purchase, then discovery (search, store) and speed.
6. Split out owner steps: anything only the owner can do (dashboard settings, keys, migrations against production, Search Console buttons, registering analytics dimensions, App Store Connect metadata, StoreKit products, signing and release).

## Phase 3: Publish the review page

Run Artifact quickstart, then write and publish one page per `references/review-page.md`. Before writing, read `~/.claude/design/*.md` when present (at least `00` to `03`, `05`, `07`, `08`, `09`, and `artifacts.md`).

Then reply in chat with the link and the "do first" list in plain words. Change nothing in the product. Offer Phase 4 in one line.

## Phase 4: Fix program (only on the user's go)

Run the Autopilot-full playbook, `../poteto-mode/playbooks/autopilot-full.md`, with these changes for a single-owner product repo, and everything else in autopilot-full as written.

- Replaces: no `gt` registration (plain `git` and `gh`); Bugbot triage only when the repo runs Bugbot; verifiers run as local background agents (they need the repo, `ENV_FILE`, ports, simulators and worktrees), not swarm's cloud default. A PR the user names stays at merge-ready for the user's click; `gate_timing` covers owner steps only.
- The audit tick re-reads the installed `../poteto-mode/playbooks/autopilot-full.md`, this SKILL.md and `$SCRATCH/program/queue.tsv` instead of a trunk copy, since the product repo has no pstack.

States. **code-ready** means the diff is final, the gates are green on the committed head, and the branch was rebased onto current trunk. **merge-ready** means code-ready, CI green (when the repo has CI), and self-proof done, at a trunk-current head. The swarm verifies the merge-ready head and pins its SHA.

1. **Group findings into PRs.** One PR per set of findings that share files. Two PRs never edit the same file in the same wave. A PR that needs another's code or a shared config waits a wave and starts when its `depends_on` merges. Write `$SCRATCH/program/queue.tsv` from `references/queue-template.tsv`. Each operator gate gets a `gate_timing`: `before-merge` stops the PR at merge-ready until the user confirms the step is done; `after-merge` lets it merge and lists the step in the hand-off. Prefer code that is safe to merge before the gate, for example falling back to the old behaviour while a new env var is missing. For an app, the release itself is always an owner step after the last merge.
2. **Write the shared protocols once.** Copy `references/owner-protocol.md` and `references/verify-protocol.md` into `$SCRATCH/program/` and fill every `<PLACEHOLDER>`. Phase 0 holds most. `LIVE_RUN_RULES`, `PROOF_RUN`, `RUN_SLOTS`, `RELEASE_LIMITS` and `SAFETY_FOCUS` come from the surface file. The rest:
   - From the repo and `gh repo view`: `PRODUCT_NAME`, `GH_OWNER`, `GH_REPO`, `STACK` (framework, libraries, host plan), `DEPLOY_NOTE` (what a merge to trunk ships, if anything), `SERVICES` (hosted services and consoles owners must not change), `LIVE_SURFACES` (public forms and lists, or none).
   - From package scripts, the Xcode scheme and AGENTS.md: `INSTALL`, `GATES`, `TEST_CMD`, `FLAKY_TESTS` (tests that also time out on trunk), `I18N_RULE` (where new strings go and their validator), `VERIFY_SKILL` (a repo skill that drives the app, if any), `UNTRACKED_DOCS` (plan docs only in the main checkout).
   - `WATCH_PR`, the absolute path of `../poteto-mode/scripts/watch-pr/watch-pr` (the babysit watcher).

   Briefs point at these files. Never paste them inline.
3. **State the plan and wait.** Show the queue, the waves, and the operator gates with their timing. Say that the user's go authorizes the owners to merge, and what each merge ships (`DEPLOY_NOTE`). Pushes may create preview deployments, which are allowed. Then stop until the user says go. On the go, arm `/goal` with the program objective.
4. **Run waves.** Spawn one owner per wave-1 PR (fresh `poteto-agent`, background), each with its id, branch, run slot, scope, and the problem with its evidence. Allocate run slots per the surface file's `RUN_SLOTS`. Keep about six owners at once so test runs stay stable. Track agents in `$SCRATCH/program/roster.tsv` and your own trail in `$SCRATCH/program/decisions.tsv` per the **show-me-your-work** skill.
5. **Verify before every merge.** At each merge-ready head SHA, fan out the verifier lanes from the verify protocol per the **swarm** skill, as local background agents. Send every proven finding back to the owner in one message. Only a clean verdict on that head earns "clean verdict, merge".
6. **Hand off owner steps.** End with the merged PRs, the open ones, and the operator gates still waiting on the user, in the order they must happen (for example "set the key, then run the migration").

## Rules

- A finding without a suggested change is a note, not a finding.
- Never print secrets. Read env and `.xcconfig` key names, keep values in variables.
- Reply per poteto-mode's **Writing the reply**: the link, the do-first list, what you re-checked, what you dropped as stale and why.
