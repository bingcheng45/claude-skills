# Surface: web

A website or web app on a host. Lanes: performance, seo, audience, reliability.

## Frame fields

- Site. `SITE_URL`, `HOST_NAME`, `FRAMEWORK`, `HOST`, `REGION`, `DATABASE`.
- Data stores. `NON_PROD_DB` (a non-production database or branch, if any), `ENV_FILE`, `SCHEMA_PATHS` (policies, grants, migrations), `WRITE_ENDPOINTS` (write URLs on other hosts the browser calls, such as the database's REST API), `BEACON_URLS` (same-origin analytics paths such as `/_vercel/insights/*`, `/_vercel/speed-insights/*` or a first-party tag proxy), `ALLOWED_HOSTS` (the other hosts a page needs to render, such as a font or image CDN).
- Analytics. `HOST_FIELD_DATA`, `GA4_ID`, `EVENT_LIST` with each custom dimension's registration date (ask the user when no doc records it), `FUNNEL_EVENTS`, `GSC_PROPERTY` and its `RESOURCE_ID`, `LOG_SOURCE`, and how each is read (MCP connector, or the signed-in browser when no connector exists). On a site that is not a game, the funnel steps are its conversion events: CTA click, sign-up, lead form.
- Pages. `KEY_PAGES` (home, the main action page, any repeat surface, one content page, one non-default locale page), `MAIN_ACTION_PAGE`, `MONEY_PAGES`, `SECONDARY_SURFACES`, `WALKTHROUGH_PATH`.

## Phase 4 values

- `PROOF_RUN`: `<SERVE_CMD> -p <your port>`, then drive it in Playwright under the live-run rules. `SERVE_CMD` must accept a trailing `-p <port>` (`npx next start`, or `npm run start --`).
- `RUN_SLOTS`: owner ports in steps of 10 from 3100; each verifier lane gets two ports from a separate base (its run and the trunk baseline).
- `RELEASE_LIMITS`: never deploy, and never run `vercel deploy`, `vercel curl` (it silently creates a deployment-protection bypass secret) or anything that changes `SERVICES` settings or data. A push may create a preview deployment, which is allowed. A merge to trunk deploys to production.
- `SAFETY_FOCUS`: database permissions and migrations, secrets reaching client bundles, caching that could serve one user another user's data or stale personal rows, headers that could break third-party scripts, analytics payload changes, SEO regressions (canonical, hreflang, noindex, sitemap), and production-deploy risk.

## Live-run rules

Lanes, owners and verifiers all follow these.

- Drive the site with Playwright from `$SCRATCH/audit/pw`, not the signed-in browser, and follow `VERIFY_SKILL`. Before the first navigation, `page.route` fulfills every non-GET request to `SITE_URL`'s origin (Server Actions post to the page URL) and to `WRITE_ENDPOINTS` with a stub response, aborts `BEACON_URLS`, and aborts every request whose host is neither `SITE_URL`'s nor in `ALLOWED_HOSTS`. Log each aborted host. Never use a blocklist of analytics hosts instead, since GA also collects through hosts such as `analytics.google.com` and regional `google.<tld>`. No write leaves the browser, and no run lands in the site's analytics.
- `page.route` cannot stop writes the server makes while rendering a page. Run such pages only against `NON_PROD_DB`, or skip them and say so.
- Local servers use `ENV_FILE`, which points at production services. When `NON_PROD_DB` exists, point runs at it. Prove server write paths in tests with mocked clients, never against the live database.
- Use the signed-in browser only for dashboards (Search Console). Load its tools in one ToolSearch batch, create your own new tab, and close it when done.

## Shared preamble

```
Read-only <LANE> review of <SITE_URL> (<FRAMEWORK> on <HOST>, functions in <REGION>, database <DATABASE>). Repo <REPO> on <TRUNK> at <SHA>.

Do NOT edit the repo, commit, deploy, change any host, database, analytics or Search Console setting, write to any database (the reliability lane's zero-row probes are the only exception), submit any form, or run `vercel curl` (it silently creates a deployment-protection bypass secret). Read env var names only and never print secret values. Write scratch files only under <SCRATCH>/audit/<LANE>/.

<LIVE_RUN_RULES, pasted from this file> Lab runs and walkthroughs must not write data or pollute the analytics being measured.

Read first, so you report NEW findings and progress, not repeats:
<PRIOR_WORK: plan docs, roadmaps, earlier review artifacts (read with the Artifact tool, action "read"), measurement docs>
Recent trunk commits worth knowing: <RECENT_CHANGES>
Already decided, don't relitigate without new evidence: <DECIDED>

Return at most ~10 findings, highest impact first. Each finding:
- title (a plain claim, e.g. "Organic sessions fell to 10 on 17 Oct")
- what a visitor or the owner notices
- evidence: numbers with source and date range, how you measured, each claim labelled measured or inferred
- suggested change, concrete (proposed title text, header value, query, file)
- effort S/M/L, and risk
- already planned? (name the doc or PR and its status)
Then an "already fine" list, one line each, the paths of screenshots or traces you saved, and the start and end time and user agent of each run against production. Keep the report under <WORD_LIMIT, about 1,200> words. Return it as your final message, not as a file; the coordinator saves it.
```

## performance

```
Find the biggest remaining wins for real visitors. Measure, don't guess.
1. Field data first: LCP, INP, CLS, TTFB per route and device, p75, last 28 days. Use the sources in this order and give each one's last-updated date: <HOST_FIELD_DATA, e.g. Vercel Speed Insights via the host MCP>, Search Console's Core Web Vitals report, the CrUX or PageSpeed Insights API (its quota may be spent).
2. Lab timing on <KEY_PAGES>, including one non-default locale page: TTFB, LCP, CLS, gzipped JS transferred, request count, render-blocking resources, fonts. Use headless Chrome (playwright-core with `chromium.launch({ channel: "chrome" })`, writes and beacons routed as above). At least 3 runs per page, report medians, mobile throttling for LCP at least. Run `uptime` before each batch and write the 1-minute load beside each median.
3. Dynamic vs static: which routes render on demand and which are static or ISR, from build output or `x-vercel-cache` / `cache-control` / `age` headers on production. Name routes that cost far-from-region visitors a round trip and could be static or edge-cached. For each read-only API, say whether a short `s-maxage` plus `stale-while-revalidate` is safe (no per-user data).
4. Bundle: largest client chunks per page and what is in them. Build in a throwaway `git -C <REPO> worktree add --detach <SCRATCH>/audit/performance/wt <SHA>` with `npm ci` (never symlink node_modules), and end with `git -C <REPO> worktree remove --force <SCRATCH>/audit/performance/wt`. Or analyze production chunk URLs directly.
5. Third-party scripts (ads, analytics, widgets): what loads on every page, what it costs in main-thread time, and whether it does anything on that page (for example an ad script on pages with no ad slot).
6. Images, fonts, long tasks and INP risk during the main interaction on <MAIN_ACTION_PAGE>.
<SITE_SPECIFIC_QUESTIONS, e.g. "list rows arrive 0.8 s after navigation; is server-rendering the first 10 worth it? Estimate the gain">
```

## seo

```
Data sources:
- Search Console <GSC_PROPERTY>. With no connector, use the signed-in browser. Performance URL: https://search.google.com/search-console/performance/search-analytics?resource_id=<RESOURCE_ID> plus `&num_of_days=28` or `&num_of_months=16` and `&breakdown=query|page|country|device`. The table shows 10 rows until you set rows per page to the max. Aggregate in the page and print compact lines, because tool output truncates near 1,000 characters. Also read `index` (page indexing), `core-web-vitals`, `sitemaps` and `links`. Many clicks have no named query, so the query table is not the full demand.
- GA4 property <GA4_ID> via the analytics MCP `run_report` (snake_case filter keys, filter hostName to <HOST_NAME>): organic landing pages, sessions by sessionDefaultChannelGroup per day, engagement per landing page. Flag any sudden jump in "Unassigned" or "Direct" against a flat Search Console click line; that is an attribution break, not lost traffic.
- Crawl the live site: sitemap.xml, robots.txt, titles, descriptions, canonicals, hreflang, JSON-LD on key pages, internal links to <MONEY_PAGES>, thin or duplicate pages, the HTML a non-JS crawler sees (`curl`), 404s, soft 404s and redirect chains.

Answer with evidence: what changed since the last review (clicks, impressions, CTR, position; skip this when there is no prior review); pages and queries with high impressions and low CTR (propose new title and description text); striking-distance queries at positions 8-20 worth a page or section; indexing problems (discovered but not crawled, crawled but not indexed); structured-data opportunities; hreflang correctness on indexable localized pages; content gaps against what people search. Add a short "improved since last review" list with numbers when there is one.
```

## audience

```
Data: GA4 property <GA4_ID> via the analytics MCP `run_report` (snake_case filter keys, filter hostName to <HOST_NAME>). Events and custom dimensions: <EVENT_LIST, with the date each custom dimension was registered>. Use 28-day windows unless dimensions are younger.
- Funnel: visitors, then each step of <FUNNEL_EVENTS, e.g. first action, completion, second action, commit; on a non-game site CTA click, sign-up, lead form>, then return next day and next week (newVsReturning, firstSessionDate). Name the biggest drop with its numbers.
- Which landing pages, sources and in-app entry points turn visitors into active users; mobile vs desktop; countries; which locales get real use.
- How much each secondary surface (<SECONDARY_SURFACES>) is used relative to the main action.

Then use the product as a first-time visitor in Playwright, writes and beacons routed as above, at desktop width and at 375 px: <WALKTHROUGH_PATH, e.g. home, first action, result, account, one article>. Note friction, confusing copy, dead ends, missing next steps, empty states, overlays that cover results, and anything that would stop a second action or a return tomorrow. Save a screenshot for every finding you base on the walkthrough and cite its path.

Also return 3 to 5 content ideas (pages, features or articles), each tied to the data signal behind it (a query, a landing page, a drop-off).
```

## reliability

```
Known open items to re-verify, not repeat: <KNOWN_ITEMS>.
1. Database permissions with the public (anon) key from <ENV_FILE> (read it into a variable, never echo it). The only writes allowed are zero-row probes:
   - SELECT with a small limit: which tables and columns are readable, any personal data.
   - UPDATE and DELETE with a filter that matches no row and fits the column type (`id=eq.-1` for an integer key, `id=eq.00000000-0000-0000-0000-000000000000` for a uuid) and `Prefer: return=minimal`. First check <SCHEMA_PATHS> for statement-level triggers on the table; they fire even when no row matches, so skip that table. A 204 proves only that the role holds the table grant, not that row-level security lets it change a row. A 401 or 403 means no grant.
   - INSERT: never probe live. Decide from the policies and grants in <SCHEMA_PATHS> and the migrations.
   Confirm write exposure against the row-level security policies before grading any write finding above medium.
2. Input integrity: can a client post an impossible value or spam a public list; current public rows that look fake (read-only GET); server-side checks to add.
3. Errors: runtime errors and logs from <LOG_SOURCE, e.g. the host MCP get_runtime_errors / get_runtime_logs, or the CLI>. Recurring 4xx and 5xx and exceptions over the last few days, the time span the logs actually covered, and how long logs are kept on this plan.
4. Security headers on key pages via `curl -sI` (CSP, HSTS, X-Frame-Options or frame-ancestors, Referrer-Policy, Permissions-Policy, X-Content-Type-Options), compared with what the framework config sets.
5. Client data: where user history lives (localStorage, IndexedDB), whether storage is persisted, whether export or backup exists, and what eviction or a cleared browser loses.
6. Dependencies: `npm audit --omit=dev` summary and outdated majors that matter (read-only).
7. Redirects and old links: short locale paths, legacy URLs, trailing slashes.
Grade each finding critical, high, medium or low, and give the exact probe and response code or the log counts with time range.
```
