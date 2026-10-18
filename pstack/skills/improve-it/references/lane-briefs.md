# Review lane briefs

Each lane brief is the shared preamble followed by that lane's section. Fill every `<PLACEHOLDER>` from Phase 0. Drop a bullet whose data source the site lacks, and say so in the brief so the lane doesn't hunt for it.

## Shared preamble

```
Read-only <LANE> review of <SITE_URL> (<FRAMEWORK> on <HOST>, functions in <REGION>, database <DATABASE>). Repo <REPO> on <TRUNK> at <SHA>.

Do NOT edit the repo, commit, deploy, change any host, database, analytics or Search Console setting, write to any database, submit any form or score, or run `vercel curl` (it silently creates a deployment-protection bypass secret). Read env var names only and never print secret values. Write scratch files only under <SCRATCH>/audit/<LANE>/.

If you use the signed-in browser, load its tools in one ToolSearch batch, create your OWN new tab (another agent may be using the browser), and close it when done.

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
Then an "already fine" list, one line each, and the paths of screenshots or traces you saved. Keep the report under <WORD_LIMIT, about 1,200> words.
```

## performance

```
Find the biggest remaining wins for real visitors. Measure, don't guess.
1. Field data first: <HOST_FIELD_DATA, e.g. Vercel Speed Insights via the host MCP> for LCP, INP, CLS, TTFB per route and device, p75, last 28 days. Search Console's Core Web Vitals report if the SEO lane isn't covering it.
2. Lab timing on <KEY_PAGES>, including one non-default locale page: TTFB, LCP, CLS, gzipped JS transferred, request count, render-blocking resources, fonts. Use headless Chrome (playwright-core with `chromium.launch({ channel: "chrome" })`, or `npx lighthouse@12`). At least 3 runs per page, report medians, mobile throttling for LCP at least.
3. Dynamic vs static: which routes render on demand and which are static or ISR, from build output or `x-vercel-cache` / `cache-control` / `age` headers on production. Name routes that cost far-from-region visitors a round trip and could be static or edge-cached. For each read-only API, say whether a short `s-maxage` plus `stale-while-revalidate` is safe (no per-user data).
4. Bundle: largest client chunks per page and what is in them. Build in a throwaway `git worktree add` under your scratch dir with `npm ci` (never symlink node_modules), or analyze production chunk URLs directly.
5. Third-party scripts (ads, analytics, widgets): what loads on every page, what it costs in main-thread time, and whether it does anything on that page (for example an ad script on pages with no ad slot).
6. Images, fonts, long tasks and INP risk during the main interaction on <MAIN_ACTION_PAGE>.
<SITE_SPECIFIC_QUESTIONS, e.g. "rows on /daily arrive 0.8 s after navigation; is server-rendering the top 10 worth it? Estimate the gain">
```

## seo

```
Data sources:
- Search Console <GSC_PROPERTY>. With no connector, use the signed-in browser. Performance URL: https://search.google.com/search-console/performance/search-analytics?resource_id=<RESOURCE_ID> plus `&num_of_days=28` or `&num_of_months=16` and `&breakdown=query|page|country|device`. The table shows 10 rows until you set rows per page to 500: in javascript_tool click `[role=listbox][aria-label*="rows per page" i]`, then the option "500", then read `table tbody tr` cells. Aggregate in the page and print compact lines, because tool output truncates near 1,000 characters. Also read `index` (page indexing), `core-web-vitals`, `sitemaps` and `links`. Many clicks have no named query, so the query table is not the full demand.
- GA4 property <GA4_ID> via the analytics MCP `run_report` (snake_case filter keys, filter hostName to <HOST_NAME>): organic landing pages, sessions by sessionDefaultChannelGroup per day, engagement per landing page. Flag any sudden jump in "Unassigned" or "Direct" against a flat Search Console click line; that is an attribution break, not lost traffic.
- Crawl the live site: sitemap.xml, robots.txt, titles, descriptions, canonicals, hreflang, JSON-LD on key pages, internal links to <MONEY_PAGES>, thin or duplicate pages, the HTML a non-JS crawler sees (`curl`), 404s, soft 404s and redirect chains.

Answer with evidence: what changed since the last review (clicks, impressions, CTR, position); pages and queries with high impressions and low CTR (propose new title and description text); striking-distance queries at positions 8-20 worth a page or section; indexing problems (discovered but not crawled, crawled but not indexed); structured-data opportunities; hreflang correctness on indexable localized pages; content gaps against what people search. Add a short "improved since last review" list with numbers.
```

## players

```
Data: GA4 property <GA4_ID> via the analytics MCP `run_report` (snake_case filter keys, filter hostName to <HOST_NAME>). Events and custom dimensions: <EVENT_LIST, with the date each custom dimension was registered>. Use 28-day windows unless dimensions are older.
- Funnel: visitors, then <FIRST_ACTION_EVENT>, then <COMPLETE_EVENT>, then a second action, then <COMMIT_EVENT e.g. score submit or daily join>, then return next day and next week (newVsReturning, firstSessionDate). Name the biggest drop with its numbers.
- Which landing pages, sources and in-app entry points turn visitors into players; mobile vs desktop; countries; which locales get real use.
- How much each secondary surface (<SECONDARY_SURFACES>) is used relative to the main action.

Then use the product as a first-time visitor in the browser pane (preview_start with a url), at desktop width and at 375 px: <WALKTHROUGH_PATH, e.g. home, first action, result, daily, dashboard, learn, one article>. Note friction, confusing copy, dead ends, missing next steps, empty states, overlays that cover results, and anything that would stop a second action or a return tomorrow. Save a screenshot for every finding you base on the walkthrough and cite its path. Never submit real scores or forms.

Also return 3 to 5 content ideas (pages, features or articles), each tied to the data signal behind it (a query, a landing page, a drop-off).
```

## reliability

```
Known open items to re-verify, not repeat: <KNOWN_ITEMS>.
1. Database permissions with the public (anon) key from <ENV_FILE> (read it into a variable, never echo it). Use only probes that cannot persist anything:
   - SELECT with a small limit: which tables and columns are readable, any personal data.
   - UPDATE and DELETE with a filter that matches nothing (for example `id=eq.-1`) and `Prefer: return=minimal`. A 204 means the role may write; a 401 or 403 means it may not. Never touch real rows.
   - INSERT: decide from the policies and grants in <SCHEMA_PATHS> and migrations. Probe only with a row the database must reject by constraint, and only when certain it cannot persist.
2. Input integrity: can a client post an impossible result or spam a public list; current public rows that look fake (read-only GET); server-side checks to add.
3. Errors: runtime errors and logs from <LOG_SOURCE, e.g. the host MCP get_runtime_errors / get_runtime_logs, or the CLI>. Recurring 4xx and 5xx and exceptions over the last few days, and how long logs are kept on this plan.
4. Security headers on key pages via `curl -sI` (CSP, HSTS, X-Frame-Options or frame-ancestors, Referrer-Policy, Permissions-Policy, X-Content-Type-Options), compared with what the framework config sets.
5. Client data: where user history lives (localStorage, IndexedDB), whether storage is persisted, whether export or backup exists, and what eviction or a cleared browser loses.
6. Dependencies: `npm audit --omit=dev` summary and outdated majors that matter (read-only).
7. Redirects and old links: short locale paths, legacy URLs, trailing slashes.
Grade each finding critical, high, medium or low, and give the exact probe and response code or the log counts with time range.
```
