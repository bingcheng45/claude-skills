# Surface: iOS app

A native iPhone or iPad app built from an Xcode project or a Swift package, shipped through the App Store. Lanes: performance, store, audience, reliability.

## Frame fields

- App. `APP_NAME`, `BUNDLE_ID`, `DEVICES` (iPhone, iPad, or both), `BUILD_CMD` (the `xcodebuild` scheme and simulator destination), `TEST_CMD`, `MIN_OS`, `DISTRIBUTION` (App Store, TestFlight only), `PRICING` (free, paid, subscription or in-app purchase through StoreKit), `EXTENSIONS` (widgets, Live Activities, share or notification extensions, App Clips, a watch app, or none).
- Backend. `BACKEND` (none, a database with a public key, or a server such as a Worker or API), `ENV_FILE` or `.xcconfig` holding its keys, `SCHEMA_PATHS`, `NON_PROD_DB`.
- Data and side effects. `USER_DATA` (where the app keeps the user's data: SwiftData, Core Data, files in the app container, Keychain, iCloud, an App Group shared with extensions), `DESTRUCTIVE_ACTIONS` (anything that deletes, sends, pays or changes things outside the app), `TELEMETRY` (analytics and crash SDKs, and how a debug build turns them off), `PUSH` (remote notifications and their sender, or none).
- Analytics and field data. `FIELD_DATA` (Xcode Organizer metrics, MetricKit, App Store Connect crashes and hangs, Crashlytics, Sentry), `ANALYTICS` (TelemetryDeck, PostHog, Firebase, Mixpanel, or none), `FUNNEL_EVENTS` (first launch, onboarding done, permission prompts accepted, first main action, paywall shown, purchase, day-1 and day-7 return), `STORE_ANALYTICS` (App Store Connect impressions, product page views, conversion, downloads, retention, ratings and reviews), and how each is read (asc CLI, MCP connector, or the signed-in browser). With several asc credentials, use the one whose app matches `BUNDLE_ID`; ask when none does.
- Screens. `KEY_SCREENS` (first launch, permission prompts, the main action screen, settings, paywall, one empty state, one error state), `MAIN_ACTION`, `WALKTHROUGH_PATH`, `SCREEN_LEVER` (how to get screenshots without a person at the device: the simulator tool, UI tests that save screenshots, or snapshot tests).

Drop any field the app lacks (no backend, no analytics, no extensions) and say so in the briefs. Most indie apps have no analytics SDK. Then the audience lane's funnel comes from `STORE_ANALYTICS` and the walkthrough carries the lane.

## Phase 4 values

- `PROOF_RUN`: build for the owner's own simulator and drive it with the simulator tool or UI tests, saving screenshots.
- `RUN_SLOTS`: one simulator per owner and per verifier lane, created by that agent and shut down when it finishes.
- `RELEASE_LIMITS`: never upload a build, submit for review, release a version, or change App Store Connect, TestFlight, StoreKit products or push-notification settings. A merge to trunk ships nothing by itself. The release is an owner step.
- `SAFETY_FOCUS`: data loss and migration of `USER_DATA`, `DESTRUCTIVE_ACTIONS` firing on the wrong items or without confirmation, entitlements and App Group changes, privacy manifest and permission strings, purchase and restore state, secrets in the bundle, crash risk on `MIN_OS`, Swift concurrency warnings, and anything that changes what a release would ship.

## Live-run rules

Lanes, owners and verifiers all follow these.

- Never act on the user's real data. Run `DESTRUCTIVE_ACTIONS` only against fixtures, a fresh simulator, or throwaway data you create under your scratch dir.
- Never make a real purchase. Use a StoreKit configuration file or a sandbox account; never enter a payment detail.
- Keep runs out of the app's analytics and away from anything that costs money or reaches people: use a debug build with `TELEMETRY` off, purchases in sandbox, `PUSH` sent to no real device, and paid APIs (AI models, SMS) and email or feedback endpoints stubbed or skipped. Say which.
- Only lanes that run the app take a simulator, and no more than two run at once. Before booting, run `xcrun simctl list devices booted` and reuse one your session booted. Never drive a simulator another session uses. Shut down every simulator you booted before you finish.
- Backend calls point at `NON_PROD_DB` when it exists. Prove write paths in tests with mocked clients, never against the live backend.

## Shared preamble

```
Read-only <LANE> review of <APP_NAME> (iOS app for <DEVICES>, minimum <MIN_OS>, distributed via <DISTRIBUTION>, <PRICING>). Repo <REPO> on <TRUNK> at <SHA>. Read the code in a detached worktree at <SCRATCH>/audit/wt, not the main checkout.

Do NOT edit the repo, commit, push, upload or submit a build, change any App Store Connect, TestFlight or analytics setting, or write to any backend (the reliability lane's zero-row probes are the only exception). Read env and .xcconfig key names only and never print secret values. Write scratch files only under <SCRATCH>/audit/<LANE>/.

<LIVE_RUN_RULES, pasted from this file>

Read first, so you report NEW findings and progress, not repeats:
<PRIOR_WORK: PRD, roadmaps, earlier review artifacts (read with the Artifact tool, action "read"), release notes>
Recent trunk commits worth knowing: <RECENT_CHANGES>
Already decided, don't relitigate without new evidence: <DECIDED>
For a fix that shipped since the last review, check it is correct and complete. A fix with a hole is a finding.

Return at most ~10 findings, highest impact first. Each finding:
- title (a plain claim, e.g. "Cold launch takes 2.8 s on iPhone 12")
- what a user or the owner notices
- evidence: file:line, command and output, numbers with source and date range, screenshot path; each claim labelled measured or inferred
- suggested change, concrete (copy text, setting, file, API)
- effort S/M/L, and risk
- already planned? (name the doc or PR and its status)
Then an "already fine" list, one line each, and the paths of screenshots or traces you saved. Keep the report under <WORD_LIMIT, about 1,200> words. Return it as your final message, not as a file; the coordinator saves it.
```

## performance

```
Find the biggest wins users would feel. Measure, don't guess, and record machine load (`uptime`, core count) beside every lab timing.
1. Field data first: <FIELD_DATA> for launch time, hang rate, memory, disk writes, battery and terminations, per OS version and device, last 28 days.
2. Lab: cold and warm launch to first useful frame, and the time of <MAIN_ACTION>, at least 3 runs, medians, on a simulator. Simulator timings run fast on a Mac; say so, and weight field data above them.
3. Main thread: IO, parsing or decoding on the main actor; long synchronous work in view bodies; heavy work repeated on every render; scrolling hitches in long lists.
4. Background cost: background refresh, location, audio or Bluetooth modes, and <EXTENSIONS> (widget timelines that reload too often, Live Activities that update too often). What each wakes for and how often.
5. Work the app repeats: network calls, image loading and decoding, database queries. What is cached, what is redone every time, and what could run in parallel.
6. Download and install size per device, and assets that inflate it.
<APP_SPECIFIC_QUESTIONS>
Give each finding its expected gain.
```

## store

```
How people find, judge and get the app, and what stops them.
- From <STORE_ANALYTICS>: impressions, product page views, conversion rate, downloads, by source (search, browse, referrer, web) and country, last 28 and 90 days. Ratings and recent reviews: recurring complaints and praise, with counts.
- The live listing: title, subtitle, keywords field (from App Store Connect or the asc CLI), promotional text, description, screenshots and preview order, what's new, and every localization. Propose new title, subtitle and keyword text tied to search terms people use. Check the screenshots show the main action in the first two, and that iPad has its own when <DEVICES> includes it.
- Pricing and the paywall: what a user sees, when, and whether price, trial length and what happens at renewal or expiry are clear before they commit. Restore purchases is reachable.
- Review-guideline risks that would get a build rejected: permission strings, purchase rules, privacy labels against what the code collects, required account deletion, sign in with Apple when other sign-ins exist.
Use the `prepare-ios-review` skill's checks for App Store metadata when it exists.
```

## audience

```
Data: <ANALYTICS> and <STORE_ANALYTICS>. Events: <FUNNEL_EVENTS>. 28-day windows unless events are younger.
- Funnel: downloads or first launches, then each step of <FUNNEL_EVENTS>, then day-1 and day-7 return. Name the biggest drop with its numbers. With no analytics SDK, say so and build what you can from store data (downloads, retention, crashes per session).
- Which OS versions, devices, countries and languages the users have; whether anything ships for a device or language nobody uses.

Then use the app as a first-time user via <SCREEN_LEVER>, under the live-run rules: <WALKTHROUGH_PATH>. Use a small phone and a large one (and an iPad when <DEVICES> includes it), light and dark, and the largest Dynamic Type size. Note friction, unclear copy, permission prompts asked before the user knows why, dead ends, missing next steps, empty and error states, confirmations for <DESTRUCTIVE_ACTIONS>, and anything that would make a user distrust the app or not come back tomorrow. Check VoiceOver labels from the code. Save a screenshot for every finding you base on the walkthrough, open it, and cite its path.

Also return 3 to 5 ideas (features, onboarding changes, widgets, store assets), each tied to the data signal or walkthrough moment behind it.
```

## reliability

```
Known open items to re-verify, not repeat: <KNOWN_ITEMS>.
1. Crashes and hangs from <FIELD_DATA>: top signatures, counts, OS versions, time range, and the code each points at.
2. User data: where <USER_DATA> lives, how writes happen (atomic or not), schema migration between versions, what a corrupt or newer-version store does, what iCloud sync conflicts do, what the app and its <EXTENSIONS> do when both write the App Group, and what a user loses on reinstall or a new phone. For <DESTRUCTIVE_ACTIONS>: can one act on the wrong item, act on stale information, or run without the user's say. Prove it with a throwaway fixture where you can.
3. Concurrency and lifecycle: Swift 6 strict-concurrency warnings from a clean `<BUILD_CMD>`, races between background work and the UI, backgrounding and termination mid-write, low memory, state restoration, offline and flaky network.
4. Purchases: restore purchases, offline launch, expired trial or subscription, refunds, family sharing, Ask to Buy. Does any failure lock out a paying user, or leave a paid feature open.
5. Release: version and build numbering, entitlements and privacy manifest against what the code uses, permission strings for every protected API the code calls, and <PUSH> certificates or keys.
6. Backend (when <BACKEND> exists): for a database with a public key, <ZERO_ROW_PROBES, pasted by the coordinator from surface-web.md's reliability item 1, using the key the app ships>. For a server, read its code for auth, abuse limits and what it trusts from the app; never call endpoints that spend quota or send mail.
7. Errors swallowed: `try?` and empty `catch` on paths that matter; what the user is told when something fails.
8. `<TEST_CMD>` result, and dependencies with known advisories or abandoned upstreams.
Grade each finding critical, high, medium or low, and give the exact reproduction, command and output, or the crash counts with time range.
```
