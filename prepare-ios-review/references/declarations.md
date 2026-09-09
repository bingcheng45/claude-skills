# Compliance and age rating declarations

These are statements about the product made to Apple, not configuration. Gather evidence,
present what you found, and let the user confirm. The cost of being wrong is not a build
failure; it is a false declaration in their name.

Both are one-time per app. Once set they persist across versions, so the effort is front-loaded.

## Contents

- [Export compliance](#export-compliance)
- [Age rating](#age-rating)
- [How to present a finding](#how-to-present-a-finding)

## Export compliance

`usesNonExemptEncryption` unset shows as **Missing Compliance** beside the build and blocks
submission until answered, every release.

### Gather evidence first

```bash
grep -rn --include="*.swift" -E \
  "import (CryptoKit|CommonCrypto|Security)|SecKey|kSecAttr|AES|SHA256|RSA" <source-dirs>
```

Also look at what the app talks to. Standard HTTPS is exempt, so an app whose only encrypted
traffic is HTTPS to an analytics or backend service qualifies for `false`. Custom
cryptography, encrypted local storage beyond the system's own, or a bundled crypto library
does not.

If the grep returns nothing and the network traffic is plain HTTPS, `false` is the accurate
answer. Say that, cite the grep, and ask.

### Two places, two effects

| Where | Effect | Applies to |
| --- | --- | --- |
| `ITSAppUsesNonExemptEncryption` in Info.plist | answered at build time | the **next** archive onward |
| `asc builds update --uses-non-exempt-encryption` | answered via API | one **already-uploaded** build |

The plist key is compiled into the binary, so adding it cannot fix a build that already
exists. Doing both is usually right: the API call unblocks the release in hand, the plist key
stops the question recurring.

Verify the key actually reached the binary rather than only the source file:

```bash
plutil -extract ITSAppUsesNonExemptEncryption raw "$APP/Info.plist"
```

## Age rating

Apple adds fields over time, so an app that was fully declared last year can be missing
fields this year. `asc review doctor` reports each one as `age_rating.missing_field`.

```bash
asc age-rating view --version-id "$VERSION_ID"
```

Fields reading `MISSING` or absent from the output are the blockers. Everything else is
already answered.

### Reason from what is already declared

The existing declaration is strong evidence. A set like this describes an app with no social
surface at all:

```
  messagingAndChat        false
  userGeneratedContent    false
  unrestrictedWebAccess   false
  advertising             false
```

so `socialMedia` and `socialMediaAgeRestricted` are consistently `false`. Corroborate in the
code before saying so:

```bash
grep -rn --include="*.swift" -E \
  "UIActivityViewController|ShareLink|SLComposeView|import Social" <source-dirs>
```

### Setting them

```bash
asc age-rating edit --version-id "$VERSION_ID" \
  --social-media false --social-media-age-restricted false
```

App Store Connect enforces dependencies in the `true` direction only: `--social-media true`
requires `--user-generated-content true`, and `--social-media-age-restricted true` requires
both age assurance and social media. Setting `false` needs no prerequisites.

`--all-none` sets every rating to `NONE`/`false` in one call. Reasonable for an app with no
objectionable content, but read the resulting declaration back before relying on it — it is a
blunt instrument and it touches fields nobody reviewed.

## How to present a finding

State the evidence, the recommendation, and what you did not check. Do not assert on the
user's behalf.

> `usesNonExemptEncryption` is unset, which shows as Missing Compliance and blocks
> submission.
>
> No CryptoKit, CommonCrypto, Security framework or hand-rolled cryptography anywhere in the
> app or the widget. The only encrypted traffic is HTTPS to PostHog, and standard HTTPS is
> exempt. So `false` is the accurate answer.
>
> I would like you to confirm before I declare it, since this is a legal statement rather than
> a config flag.

That shape does three things: it explains the blocker, shows the work, and leaves the
decision where it belongs.
