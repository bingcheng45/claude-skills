---
name: prepare-ios-review
description: Take an iOS app from merged code to a submission-ready App Store Connect version using the asc CLI — preflight the version and build, create the version, apply localized metadata, attach the build, clear compliance and age-rating declarations, then gate on `asc review doctor` and stop before submitting. Use this whenever the user mentions preparing or cutting an iOS release, App Store Connect, asc, TestFlight promotion, "what's new" or release notes, App Store metadata or screenshots, a rejected or failed upload (ITMS errors, 90062, 90186, Missing Compliance), age rating questions, or asks to submit an app for review — even if they only say "let's ship 3.7" or paste an App Store Connect error.
---

# Preparing an iOS App Store submission

## The rule

**Run `asc review doctor` before you do anything else, and again before you stop.**

App Store Connect fails late and vaguely. A submission attempt reports one blocker at a
time, and each round trip costs an archive or an upload. The doctor reports all of them at
once, up front, against the public API.

A real session that motivated this skill:

```
  attempted upload  ->  90062 version already approved     (caught after archiving)
                        90186 train closed
  bumped, uploaded  ->  Missing Compliance                 (caught at submission)
  cleared that      ->  age rating: socialMedia missing    (caught at submission)
                        age rating: socialMediaAgeRestricted missing
```

Four blockers, discovered one at a time, each after real work. One `asc review doctor` at
the start reports all four in about a second.

## Workflow

```
  1  PREFLIGHT   is this version already published? does the build exist?
       |         asc review doctor -- collect every blocker now
       |
  2  VERSION     create it, inheriting URLs from the previous version
       |
  3  METADATA    convert the source tree to asc's layout, apply, verify by pulling back
       |
  4  BUILD       attach it, and check the app and its extensions agree on version
       |
  5  DECLARE     export compliance and age rating -- gather evidence before asserting
       |
  6  GATE        asc review doctor -- must report zero blockers
       |
  7  STOP        report readiness. Do not submit unless explicitly told to.
```

## 1. Preflight

Two checks before any archiving, because both are cheap and both have cost a release cycle.

```bash
asc versions list --app "$APP_ID"     # is the target version already READY_FOR_SALE?
asc builds list --app "$APP_ID"       # does a build exist, is it VALID and unexpired?
asc review doctor --app "$APP_ID"     # every blocker, at once
```

An already-published version is the 90062/90186 pair. The train is closed and the only fix
is a higher version, so discovering it *after* archiving wastes the archive.

Read the doctor output in full before planning. It reports errors, warnings and checks it
explicitly cannot perform, and that last category matters — regulations and permits
declarations live only in the web UI.

## 2. Create the version

```bash
asc versions create --app "$APP_ID" --version "$V" --platform IOS \
  --copy-metadata-from "$PREVIOUS" --exclude-fields "whatsNew,description"
```

Copy from the previous version so support and marketing URLs carry over; those live only in
App Store Connect and are not in most metadata trees. Exclude the fields you are about to
replace, so the copy does not fight the apply.

## 3. Metadata

Two traps here, both quiet.

**The layouts differ.** A fastlane-style `metadata/<locale>/<field>.txt` tree is not what
`asc metadata apply` reads — it wants JSON split between app-info and version scopes, and
fails with `no metadata .json files found`. Convert first. If the project has no converter,
`references/asc-commands.md` describes the target shape.

**Field limits are per-field and unforgiving.** Localized text expands: a description that
fits in English can overflow in German, French or Italian, which run 15 to 25 percent
longer. Validate locally, where the error can name the file, rather than letting App Store
Connect reject the apply with something vague.

```
  name 30   subtitle 30   promotionalText 170   keywords 100
  description 4000   whatsNew 4000
```

Always dry run, then apply, then **verify by pulling back**:

```bash
asc metadata apply --app "$APP_ID" --version "$V" --platform IOS --dir "$DIR" --dry-run
asc metadata apply --app "$APP_ID" --version "$V" --platform IOS --dir "$DIR"
asc metadata pull  --app "$APP_ID" --version "$V" --platform IOS --dir /tmp/verify
```

A second dry run after applying should report `adds: [] updates: [] deletes: []`. That is
the only real confirmation that local and remote agree. The apply response tells you what
was attempted, not what landed.

## 4. Attach the build

```bash
asc versions attach-build --version-id "$VERSION_ID" --build-id "$BUILD_ID"
```

Check that the app and every embedded extension report the same version. A widget or
extension left behind is its own rejection, and it surfaces only on the *next* upload
attempt, long after the mismatch was introduced.

```bash
plutil -extract CFBundleShortVersionString raw "$APP/Info.plist"
plutil -extract CFBundleShortVersionString raw "$APP/PlugIns/"*.appex/Info.plist
```

## 5. Declarations

Export compliance and age rating are **statements about the product**, not configuration.
Gather evidence, state what you found, and let the user confirm before asserting anything on
their behalf. `references/declarations.md` has the evidence-gathering commands and the
reasoning for each.

The one mechanical fact worth knowing here: `ITSAppUsesNonExemptEncryption` in Info.plist is
compiled into the binary. Adding it does **not** fix a build already uploaded. That build
needs `asc builds update --uses-non-exempt-encryption`; the plist key only takes effect from
the next archive. Fixing both is usually right — one unblocks today, the other stops the
question recurring.

## 6. Gate

```bash
asc review doctor --app "$APP_ID"
```

Zero errors and zero blocking checks, or the release is not ready. Report warnings too;
they are cheap to fix while you are already here, and a copyright string in the wrong format
is a thirty-second correction that otherwise ships wrong for another year.

## 7. Stop

Report readiness and stop. **Do not submit unless the user explicitly asks in this turn.**

Submission is irreversible in a way nothing else in this workflow is. It enters a review
queue, a rejection is recorded against the account, and an approved build may auto-release
to users. Being ready and choosing to ship are different decisions, and the second is the
user's.

When they do ask, submit with `asc review submit --app "$APP_ID" --version "$V"
--build-id "$BUILD_ID" --confirm`, then verify the state actually moved to
`WAITING_FOR_REVIEW`. Watch for a skipped stale submission in the output — accounts
accumulate abandoned `READY_FOR_REVIEW` objects, and the CLI declines to reuse one rather
than silently attaching your release to it.

## Release notes

Generated notes are a changelog. App Store copy is something else:

```
  generated   fix: give a grouped rescue only the action it can honour
  shipped     Reminders that actually help you start.
```

Use `asc release-notes generate --since-tag` to learn what changed, then write the store copy
from it. Ship the generated text and the listing reads like a commit log.

This needs tags. If the project has never tagged a release, say so — without them there is no
answer to "what is unreleased", and the notes end up written from memory.

Match the project's existing house style: read the previous version's notes before writing.
Check for punctuation conventions the user cares about, and when replacing something like an
em dash, use punctuation natural to each language rather than one substitution everywhere. A
dash carrying a copula in Russian becomes a word, not a comma.

## Reporting back

Lead with readiness, then the evidence:

```
  version 3.6    PREPARE_FOR_SUBMISSION
  build          v3.6 VALID, attached, compliance answered
  metadata       11 locales applied and verified
  doctor         0 errors, 0 warnings, 0 blocking
  ───────────────────────────────────────────────────
  ready to submit. Not submitted.
```

Name anything you could not check — the regulations and permits declarations, and any
machine-translated copy that has not had a native review.

## References

- `references/asc-commands.md` — every command in this workflow with its flags, plus the
  metadata JSON shape. Read when you need exact invocations.
- `references/declarations.md` — export compliance and age rating: what to grep for, what the
  fields mean, and how to present the finding. Read before asserting either one.
