# Surface: macOS app

A native Mac app built from an Xcode project or a Swift package, shipped through the Mac App Store or downloaded directly. Lanes: performance, store, audience, reliability.

## Frame fields

- App. `APP_NAME`, `BUNDLE_ID`, `APP_KIND` (windowed, menu bar, background agent or helper, or a mix), `BUILD_CMD` (the `xcodebuild` scheme or `swift build`), `TEST_CMD`, `MIN_OS`, `DISTRIBUTION` (Mac App Store, direct download with Sparkle or another updater, Setapp, Homebrew cask), `PRICING` (free, paid, subscription through StoreKit, trial then license key through a service such as Polar, Paddle or Gumroad), `SANDBOXED` (yes or no), `PRIVILEGES` (Full Disk Access, Accessibility, Screen Recording, Automation, a privileged helper, login item, or none).
- Backend. `BACKEND` (none, a database with a public key, or a server such as a Worker or API), `ENV_FILE` or `.xcconfig` holding its keys, `SCHEMA_PATHS`, `NON_PROD_DB`.
- Data and side effects. `USER_DATA` (where the app keeps the user's data: SwiftData, Core Data, files in Application Support, Keychain, iCloud, user-chosen folders), `DESTRUCTIVE_ACTIONS` (anything that deletes, moves, kills, sends, pays or changes things outside the app, including the user's files and other apps), `TELEMETRY` (analytics and crash SDKs, and how a debug build turns them off).
- Analytics and field data. `FIELD_DATA` (Xcode Organizer metrics and App Store Connect crashes for Mac App Store builds, MetricKit, Sentry, Crashlytics, or crash reports the app collects itself), `ANALYTICS` (TelemetryDeck, PostHog, Firebase, Mixpanel, or none), `FUNNEL_EVENTS` (download, first launch, permissions granted, onboarding done, first main action, trial started, license entered or purchase, day-1 and day-7 return), `STORE_ANALYTICS` (App Store Connect for Mac App Store builds; for direct distribution the download page's analytics, update-feed requests and license-service sales), and how each is read (asc CLI, MCP connector, or the signed-in browser). With several asc credentials, use the one whose app matches `BUNDLE_ID`; ask when none does.
- Screens. `KEY_SCREENS` (first launch, permission requests, the main window or menu bar popover, settings, license or paywall, one empty state, one error state), `MAIN_ACTION`, `WALKTHROUGH_PATH`, `SCREEN_LEVER` (how to get screenshots without taking over the user's screen: a headless render mode, snapshot tests, or UI tests that save screenshots).

Drop any field the app lacks (no backend, no analytics) and say so in the briefs. Most indie Mac apps have no analytics SDK and no field metrics. Then the audience lane's funnel comes from `STORE_ANALYTICS`, and the walkthrough and code reading carry the lanes.

## Phase 4 values

- `PROOF_RUN`: run the tests and the `SCREEN_LEVER`, saving screenshots. Launch the app window only with the user's OK.
- `RUN_SLOTS`: none, unless the app runs a local server; then one port per owner and per verifier lane.
- `RELEASE_LIMITS`: never upload a build, submit for review, publish a release, update feed or download, notarize for distribution, or change App Store Connect, StoreKit products, license-service or download-host settings. A merge to trunk ships nothing by itself. The release is an owner step.
- `SAFETY_FOCUS`: data loss and migration of `USER_DATA`, `DESTRUCTIVE_ACTIONS` firing on the wrong items or without confirmation, sandbox, entitlements and `PRIVILEGES` changes, hardened runtime and notarization, update-feed signing, privacy manifest and usage strings, purchase or license state, secrets in the bundle, crash risk on `MIN_OS`, Swift concurrency warnings, and anything that changes what a release would ship.

## Live-run rules

Lanes, owners and verifiers all follow these.

- Never act on the user's real data. Run `DESTRUCTIVE_ACTIONS` only against fixtures or throwaway files and processes you create under your scratch dir. Read-only use of real data (a scan, a list) is fine.
- Never make a real purchase or enter a real license key. Use a StoreKit configuration file, a sandbox account, or the license service's test mode.
- Keep runs out of the app's analytics and away from anything that costs money or reaches people: use a debug build with `TELEMETRY` off, purchases in sandbox or test mode, and paid APIs (AI models, SMS) and email or feedback endpoints stubbed or skipped. Say which.
- Never launch the app's window (the bare binary, `open X.app`, `swift run`) without the user's OK. It takes focus while they type. Headless paths are fine: tests, a CLI or server mode, a render mode. Never quit or replace a copy of the app the user is running.
- Build bundles only under your scratch dir and delete them, so Spotlight and Launch Services never see a stray copy. Never install a login item, helper or launch agent, and never grant or reset `PRIVILEGES` (`tccutil`).
- Backend calls point at `NON_PROD_DB` when it exists. Prove write paths in tests with mocked clients, never against the live backend.

## Shared preamble

```
Read-only <LANE> review of <APP_NAME> (<APP_KIND> macOS app, minimum <MIN_OS>, distributed via <DISTRIBUTION>, <PRICING>, sandboxed: <SANDBOXED>). Repo <REPO> on <TRUNK> at <SHA>. Read the code in a detached worktree at <SCRATCH>/audit/wt, not the main checkout.

Do NOT edit the repo, commit, push, upload, notarize or publish a build, change any App Store Connect, analytics, license-service or download-host setting, or write to any backend (the reliability lane's zero-row probes are the only exception). Read env and .xcconfig key names only and never print secret values. Write scratch files only under <SCRATCH>/audit/<LANE>/.

<LIVE_RUN_RULES, pasted from this file>

Read first, so you report NEW findings and progress, not repeats:
<PRIOR_WORK: PRD, roadmaps, earlier review artifacts (read with the Artifact tool, action "read"), release notes>
Recent trunk commits worth knowing: <RECENT_CHANGES>
Already decided, don't relitigate without new evidence: <DECIDED>
For a fix that shipped since the last review, check it is correct and complete. A fix with a hole is a finding.

Return at most ~10 findings, highest impact first. Each finding:
- title (a plain claim, e.g. "The menu bar app uses 3% CPU while idle")
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
1. Field data first, when <FIELD_DATA> exists: launch time, hang rate, memory, disk writes and energy, per OS version and Mac model, last 28 days.
2. Lab: cold and warm launch to first useful frame, and the time of <MAIN_ACTION>, at least 3 runs, medians, on the release build through a headless path.
3. Main thread: IO, parsing or `Process` calls on the main actor; long synchronous work in view bodies; heavy work repeated on every render; large tables or lists that redraw.
4. Idle cost: an app that stays running (menu bar, background agent, login item) should cost nothing when idle. Measure idle CPU over 60 s, wakeups, timers, polling, file-system watchers, memory growth over time, open file handles and child processes (`top -l`, `footprint`, `sample`, `lsof -p`) on a running copy you did not launch, or on one the live-run rules allow.
5. Work the app repeats: network calls, file scans, shell-outs, image decoding. What is cached, what is redone every time, and what could run in parallel.
6. Binary and download size, universal versus single-architecture builds, and assets that inflate it.
<APP_SPECIFIC_QUESTIONS>
Give each finding its expected gain.
```

## store

```
How people find, judge and get the app, and what stops them.
- Mac App Store (when <DISTRIBUTION> includes it): from <STORE_ANALYTICS>, impressions, product page views, conversion rate, downloads, by source and country, last 28 and 90 days. Ratings and recent reviews: recurring complaints and praise, with counts. Read the live listing: title, subtitle, keywords field (from App Store Connect or the asc CLI), promotional text, description, screenshots and their order, what's new. Propose new title, subtitle and keyword text tied to search terms people use.
- Direct distribution (download page, Sparkle, Setapp, Homebrew cask): the download page's copy, price and trial clarity, screenshots, and the path from page to running app (download, Gatekeeper, notarization, moving to Applications, first launch, permission requests). The update feed: HTTPS, signed, current, and the version a stale install would move to.
- Pricing and the license or paywall screen: what a user sees, when, and whether price, trial length and what happens at expiry are clear before they commit. How a user moves a license to a new Mac.
- Review or notarization risks: entitlements the app cannot justify, usage strings, privacy labels, private API use, and anything that needs `PRIVILEGES` without saying why.
Use the `prepare-ios-review` skill's checks for App Store metadata when it exists.
```

## audience

```
Data: <ANALYTICS> and <STORE_ANALYTICS>. Events: <FUNNEL_EVENTS>. 28-day windows unless events are younger.
- Funnel: downloads, first launches, then each step of <FUNNEL_EVENTS>, then day-1 and day-7 return. Name the biggest drop with its numbers. With no analytics SDK, say so and build what you can from store data, update-feed requests and license sales.
- Which macOS versions, Mac models (Apple silicon or Intel), countries and languages the users have; whether anything ships for a version nobody uses.

Then use the app as a first-time user via <SCREEN_LEVER>, under the live-run rules: <WALKTHROUGH_PATH>. Cover the minimum window size and a large one, light and dark, and each <PRIVILEGES> request the first run makes. Note friction, unclear copy, permission requests made before the user knows why, dead ends, missing next steps, empty and error states, confirmations for <DESTRUCTIVE_ACTIONS>, and anything that would make a user distrust the app or not come back tomorrow. Check VoiceOver labels, keyboard shortcuts and full keyboard access from the code, and that standard menu items (Settings, Quit, Undo) work. Save a screenshot for every finding you base on the walkthrough, open it, and cite its path.

Also return 3 to 5 ideas (features, onboarding changes, menu bar or Shortcuts integration, store or download-page assets), each tied to the data signal or walkthrough moment behind it.
```

## reliability

```
Known open items to re-verify, not repeat: <KNOWN_ITEMS>.
1. Crashes and hangs from <FIELD_DATA>, or from the app's own crash reports and `~/Library/Logs/DiagnosticReports` entries for it: top signatures, counts, OS versions, time range, and the code each points at.
2. User data: where <USER_DATA> lives, how writes happen (atomic or not), schema migration between versions, what a corrupt or newer-version file does, what iCloud sync conflicts do, and what a user loses moving to a new Mac. For <DESTRUCTIVE_ACTIONS>: can one act on the wrong item, act on stale information (a file or process that changed since the scan), follow a symlink out of its folder, or run without the user's say. Prove it with a throwaway fixture where you can.
3. Concurrency and lifecycle: Swift 6 strict-concurrency warnings from a clean `<BUILD_CMD>`, races between background work and the UI, sleep and wake, quit mid-write, two copies running, and losing `PRIVILEGES` while running.
4. Purchases and licensing: restore purchases, offline launch, expired trial or subscription, clock changes, the license service down, a license used on too many Macs. Does any failure lock out a paying user, or leave a paid feature open.
5. Updates and release: the update path (App Store, or Sparkle feed signing and EdDSA keys), version and build numbering, notarization and hardened runtime, entitlements and privacy manifest against what the code uses, and what an update does to a running copy and its helpers.
6. Backend (when <BACKEND> exists): for a database with a public key, <ZERO_ROW_PROBES, pasted by the coordinator from surface-web.md's reliability item 1, using the key the app ships>. For a server, read its code for auth, abuse limits and what it trusts from the app; never call endpoints that spend quota or send mail.
7. Errors swallowed: `try?` and empty `catch` on paths that matter; what the user is told when something fails.
8. `<TEST_CMD>` result, and dependencies with known advisories or abandoned upstreams.
Grade each finding critical, high, medium or low, and give the exact reproduction, command and output, or the crash counts with time range.
```
