# Surface: iOS or macOS app

A native app built from an Xcode project or a Swift package. Lanes: performance, store, audience, reliability. Lines marked iOS or macOS apply to that platform only; drop the other platform's lines from the briefs.

## Frame fields

- App. `APP_NAME`, `PLATFORM` (iOS, macOS, or both), `BUNDLE_ID`, `BUILD_CMD` (the `xcodebuild` scheme and destination, or `swift build`), `TEST_CMD`, `MIN_OS`, `DISTRIBUTION` (App Store, TestFlight, direct download with Sparkle or another updater, Setapp), `PRICING` (free, paid, subscription through StoreKit, trial then license key).
- Backend. `BACKEND` (none, a database with a public key, or a server such as a Worker or API), `ENV_FILE` or `.xcconfig` holding its keys, `SCHEMA_PATHS`, `NON_PROD_DB`.
- Data and side effects. `USER_DATA` (where the app keeps the user's data: SwiftData, Core Data, files in Application Support, Keychain, iCloud), `DESTRUCTIVE_ACTIONS` (anything that deletes, sends, pays or changes things outside the app), `TELEMETRY` (analytics and crash SDKs, and how a debug build turns them off).
- Analytics and field data. `FIELD_DATA` (Xcode Organizer metrics, MetricKit, App Store Connect crashes and hangs, Crashlytics, Sentry), `ANALYTICS` (TelemetryDeck, PostHog, Firebase, Mixpanel, or none), `FUNNEL_EVENTS` (first launch, onboarding done, first main action, paywall shown, purchase or license entered, day-1 and day-7 return), `STORE_ANALYTICS` (App Store Connect impressions, product page views, conversion, downloads, ratings and reviews; or the download page's analytics for direct distribution), and how each is read (asc CLI, MCP connector, or the signed-in browser). With several asc credentials, use the one whose app matches `BUNDLE_ID`; ask when none does.
- Screens. `KEY_SCREENS` (first launch, the main action screen, settings, paywall or license, one empty state, one error state), `MAIN_ACTION`, `WALKTHROUGH_PATH`, `SCREEN_LEVER` (how to get screenshots without a person at the keyboard: iOS simulator plus UI tests or the simulator tool; macOS a headless render mode, snapshot tests, or UI tests).

Drop any field the app lacks (no backend, no analytics) and say so in the briefs. Most indie apps have no analytics SDK. Then the audience lane's funnel comes from `STORE_ANALYTICS` and the walkthrough carries the lane.

## Phase 4 values

- `PROOF_RUN`: iOS, build for the owner's own simulator and drive it with the simulator tool or UI tests, saving screenshots. macOS, run the tests and the `SCREEN_LEVER`; launch the app window only with the user's OK.
- `RUN_SLOTS`: iOS, one simulator per owner and per verifier lane, created by that agent and shut down when it finishes. macOS, none.
- `RELEASE_LIMITS`: never upload a build, submit for review, publish a release or update feed, notarize for distribution, or change App Store Connect, TestFlight, StoreKit products or license-service settings. A merge to trunk ships nothing by itself. The release is an owner step.
- `SAFETY_FOCUS`: data loss and migration of `USER_DATA`, `DESTRUCTIVE_ACTIONS` firing on the wrong items or without confirmation, entitlements and sandbox changes, privacy manifest and permission strings, purchase or license state, secrets in the bundle, crash risk on `MIN_OS`, Swift concurrency warnings, and anything that changes what a release would ship.

## Live-run rules

Lanes, owners and verifiers all follow these.

- Never act on the user's real data. Run `DESTRUCTIVE_ACTIONS` only against fixtures, a test container, or throwaway data you create under your scratch dir. Read-only use of real data (a scan, a list) is fine.
- Never make a real purchase. Use a StoreKit configuration file or a sandbox account; never enter a real license key or payment detail.
- Keep runs out of the app's analytics and away from anything that costs money or reaches people: use a debug build with `TELEMETRY` off, purchases in sandbox, and paid APIs (AI models, SMS) and email or feedback endpoints stubbed or skipped. Say which.
- iOS. Only lanes that run the app take a simulator, and no more than two run at once. Before booting, run `xcrun simctl list devices booted` and reuse one your session booted. Never drive a simulator another session uses. Shut down every simulator you booted before you finish.
- macOS. Never launch the app's window (the bare binary, `open X.app`, `swift run`) without the user's OK. It takes focus while they type. Headless paths are fine: tests, a CLI or server mode, a render mode. Build bundles only under your scratch dir and delete them, so Spotlight and Launch Services never see a stray copy.
- Backend calls point at `NON_PROD_DB` when it exists. Prove write paths in tests with mocked clients, never against the live backend.

## Shared preamble

```
Read-only <LANE> review of <APP_NAME> (<PLATFORM>, minimum <MIN_OS>, distributed via <DISTRIBUTION>, <PRICING>). Repo <REPO> on <TRUNK> at <SHA>. Read the code in a detached worktree at <SCRATCH>/audit/wt, not the main checkout.

Do NOT edit the repo, commit, push, upload or submit a build, change any App Store Connect, TestFlight, analytics or license-service setting, or write to any backend (the reliability lane's zero-row probes are the only exception). Read env and .xcconfig key names only and never print secret values. Write scratch files only under <SCRATCH>/audit/<LANE>/.

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
Then an "already fine" list, one line each, and the paths of screenshots or traces you saved. Keep the report under <WORD_LIMIT, about 1,200> words.
```

## performance

```
Find the biggest wins users would feel. Measure, don't guess, and record machine load (`uptime`, core count) beside every lab timing.
1. Field data first: <FIELD_DATA> for launch time, hang rate, memory, disk writes, battery, per OS version and device, last 28 days.
2. Lab: cold and warm launch to first useful frame, and the time of <MAIN_ACTION>, at least 3 runs, medians. iOS on a simulator (note that simulator timings run fast on a Mac; say so) and on an older device class if one is available. macOS on the release build.
3. Main thread: IO, parsing or `Process` calls on the main actor; long synchronous work in view bodies; heavy work repeated on every render.
4. Idle cost: an app that stays running (menu bar, background modes, widgets) should cost nothing when idle. Measure idle CPU over 60 s, wakeups, timers, polling, memory growth over time, open file handles and child processes (`top -l`, `footprint`, `sample`, `lsof -p`) on a running copy you did not launch, or on one the live-run rules allow.
5. Work the app repeats: network calls, file scans, shell-outs, image decoding. What is cached, what is redone every time, and what could run in parallel.
6. Binary and download size, and assets that inflate it.
<APP_SPECIFIC_QUESTIONS>
Give each finding its expected gain.
```

## store

```
How people find, judge and get the app, and what stops them.
- App Store (when <DISTRIBUTION> includes it): from <STORE_ANALYTICS>, impressions, product page views, conversion rate, downloads, by source (search, browse, referrer, web) and country, last 28 and 90 days. Ratings and recent reviews: recurring complaints and praise, with counts. Read the live listing: title, subtitle, keywords field (from App Store Connect or the asc CLI), promotional text, description, screenshots and preview order, what's new. Propose new title, subtitle and keyword text tied to search terms people use. Check the screenshots show the main action in the first two.
- Direct distribution (download page, Sparkle, Setapp): the download page's copy, price and trial clarity, the path from page to running app (download, Gatekeeper, notarization, first launch), and the update feed (HTTPS, signed, current).
- Pricing and the paywall or license screen: what a user sees, when, and whether price, trial length and what happens at expiry are clear before they commit.
- Review-guideline risks that would get a build rejected (permission strings, purchase rules, privacy labels, required account deletion).
Use the `prepare-ios-review` skill's checks for App Store metadata when it exists.
```

## audience

```
Data: <ANALYTICS> and <STORE_ANALYTICS>. Events: <FUNNEL_EVENTS>. 28-day windows unless events are younger.
- Funnel: downloads or first launches, then each step of <FUNNEL_EVENTS>, then day-1 and day-7 return. Name the biggest drop with its numbers. With no analytics SDK, say so and build what you can from store data (downloads, retention, crashes per session).
- Which OS versions, devices, countries and languages the users have; whether anything ships for a platform nobody uses.

Then use the app as a first-time user via <SCREEN_LEVER>, under the live-run rules: <WALKTHROUGH_PATH>. iOS: a small phone and a large one, light and dark, the largest Dynamic Type size. macOS: the minimum window size and a large one, light and dark. Note friction, unclear copy, dead ends, missing next steps, empty and error states, confirmations for <DESTRUCTIVE_ACTIONS>, and anything that would make a user distrust the app or not come back tomorrow. Check VoiceOver labels and keyboard paths from the code. Save a screenshot for every finding you base on the walkthrough, open it, and cite its path.

Also return 3 to 5 ideas (features, onboarding changes, store assets), each tied to the data signal or walkthrough moment behind it.
```

## reliability

```
Known open items to re-verify, not repeat: <KNOWN_ITEMS>.
1. Crashes and hangs from <FIELD_DATA>: top signatures, counts, OS versions, time range, and the code each points at.
2. User data: where <USER_DATA> lives, how writes happen (atomic or not), schema migration between versions, what a corrupt or newer-version file does, what iCloud sync conflicts do, and what a user loses on reinstall. For <DESTRUCTIVE_ACTIONS>: can one act on the wrong item, act on stale information, or run without the user's say. Prove it with a throwaway fixture where you can.
3. Concurrency and lifecycle: Swift 6 strict-concurrency warnings from a clean `<BUILD_CMD>`, races between background work and the UI, sleep and wake, backgrounding, app termination mid-write, two copies running (macOS).
4. Purchases and licensing: restore purchases, offline launch, expired trial or subscription, clock changes, validation server down. Does any failure lock out a paying user, or leave a paid feature open.
5. Updates and release: the update path (App Store, Sparkle feed signing, version and build numbering), notarization and hardened runtime (macOS), entitlements and privacy manifest against what the code uses.
6. Backend (when <BACKEND> exists): for a database with a public key, <ZERO_ROW_PROBES, pasted by the coordinator from surface-web.md's reliability item 1, using the key the app ships>. For a server, read its code for auth, abuse limits and what it trusts from the app; never call endpoints that spend quota or send mail.
7. Errors swallowed: `try?` and empty `catch` on paths that matter; what the user is told when something fails.
8. `<TEST_CMD>` result, and dependencies with known advisories or abandoned upstreams.
Grade each finding critical, high, medium or low, and give the exact reproduction, command and output, or the crash counts with time range.
```
