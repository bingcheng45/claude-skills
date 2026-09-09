# asc command reference

Every command this workflow uses. `APP_ID`, `V` (version string) and `VERSION_ID` recur
throughout; get the first from `asc apps list` and the third from `asc versions list`.

## Contents

- [Orientation](#orientation)
- [Preflight](#preflight)
- [Versions](#versions)
- [Metadata](#metadata)
- [Builds](#builds)
- [Declarations](#declarations)
- [Submission](#submission)
- [Metadata JSON shape](#metadata-json-shape)
- [Gotchas](#gotchas)

## Orientation

```bash
asc apps list                     # app IDs, bundle IDs, names
asc status --app "$APP_ID"        # one-screen release dashboard
asc review doctor --app "$APP_ID" # every public-API blocker, at once
```

`asc apps list` returns a large JSON blob. Pipe it through a filter rather than printing it
whole:

```bash
asc apps list | python3 -c "
import json,sys
for a in json.load(sys.stdin)['data']:
    x=a['attributes']; print(f\"{a['id']}  {x['bundleId']:32} {x['name']}\")"
```

## Preflight

```bash
# Is the target version already published? 90062/90186 come from this.
asc versions list --app "$APP_ID" | python3 -c "
import json,sys
for v in json.load(sys.stdin)['data'][:6]:
    a=v['attributes']; print(f\"  {a['versionString']:8} {a['appStoreState']}\")"

# Is there a usable build?
asc builds list --app "$APP_ID" --limit 5 | python3 -c "
import json,sys
for b in json.load(sys.stdin)['data']:
    a=b['attributes']
    print(f\"  v{a['version']:8} {a['processingState']:10} expired={a['expired']} {a['uploadedDate']}\")"
```

`READY_FOR_SALE` on the version you are targeting means the train is closed. The only fix is
a higher version.

## Versions

```bash
asc versions create --app "$APP_ID" --version "$V" --platform IOS \
  --copy-metadata-from "$PREVIOUS" --exclude-fields "whatsNew,description"

asc versions view --version-id "$VERSION_ID" --include-build --include-submission
asc versions view --version-id "$VERSION_ID" --include "ageRatingDeclaration,appStoreReviewDetail"
asc versions update --version-id "$VERSION_ID" --copyright "2025 Your Company"
asc versions delete --version-id "$VERSION_ID"     # only in PREPARE_FOR_SUBMISSION
```

`--copy-metadata-from` carries `keywords`, `marketingUrl`, `promotionalText` and `supportUrl`.
Those live only in App Store Connect, so without it a new version loses its URLs.

Copyright must start with a four-digit year: `2025 Company`, not `Company 2025`. Use the year
rights were obtained, not the current year.

## Metadata

```bash
asc metadata pull  --app "$APP_ID" --version "$V" --platform IOS --dir ./out
asc metadata apply --app "$APP_ID" --version "$V" --platform IOS --dir ./dir --dry-run --pretty
asc metadata apply --app "$APP_ID" --version "$V" --platform IOS --dir ./dir
```

Summarise a dry run rather than reading it whole — it embeds every string:

```bash
asc metadata apply ... --dry-run | python3 -c "
import json,sys,collections
d=json.load(sys.stdin)
for bucket in ('adds','updates','deletes'):
    items=d.get(bucket) or []
    if items:
        print(f'{bucket}: {len(items)}')
        for f,n in collections.Counter(i['field'] for i in items).most_common():
            print(f'    {f}: {n}')"
```

`--allow-deletes` needs `--confirm` and disables the default-locale fallback. Omitted fields
are no-ops; they never imply deletion.

## Builds

```bash
asc builds info --build-id "$BUILD_ID"
asc builds info --app "$APP_ID" --latest
asc builds wait --app "$APP_ID" --latest          # blocks until processing completes
asc versions attach-build --version-id "$VERSION_ID" --build-id "$BUILD_ID"
asc builds next-build-number --app "$APP_ID" --version "$V" --platform IOS
```

## Declarations

```bash
asc builds update --build-id "$BUILD_ID" --uses-non-exempt-encryption=false

asc age-rating view --version-id "$VERSION_ID"
asc age-rating edit --version-id "$VERSION_ID" --social-media false --social-media-age-restricted false
asc age-rating edit --app "$APP_ID" --all-none          # safe default, no objectionable content
```

App Store Connect accepts `--social-media true` only when `--user-generated-content true`,
and `--social-media-age-restricted true` only when age assurance and social media are both
true. Setting them false needs no prerequisites.

## Submission

```bash
asc review status --app "$APP_ID"
asc review submissions-list --app "$APP_ID"
asc review submit --app "$APP_ID" --version "$V" --build-id "$BUILD_ID" --confirm
asc submit cancel --id "$SUBMISSION_ID" --confirm
asc versions release --version-id "$VERSION_ID" --confirm   # pending-developer-release only
```

After submitting, confirm the state moved:

```bash
asc review status --app "$APP_ID"   # expect WAITING_FOR_REVIEW
```

## Metadata JSON shape

What `asc metadata apply` reads. A fastlane `.txt` tree must be converted to this:

```text
app-info/<locale>.json           name, subtitle, privacyPolicyUrl, privacyChoicesUrl
version/<version>/<locale>.json  description, keywords, marketingUrl,
                                 promotionalText, supportUrl, whatsNew
```

```json
{
  "description": "...",
  "keywords": "task manager,to-do list,productivity",
  "promotionalText": "...",
  "whatsNew": "..."
}
```

Omit a field rather than writing it empty. Empty is a change; omitted is a no-op.

Limits: `name` 30, `subtitle` 30, `promotionalText` 170, `keywords` 100, `description` 4000,
`whatsNew` 4000. Validate before applying, where the error can name the file.

## Gotchas

- **`asc apps list` and dry-run output are enormous.** Always filter.
- **The apply response is not confirmation.** Pull back, or dry-run again and expect empty.
- **Stale review submissions accumulate.** `asc review submit` skips one it cannot exclusively
  use and creates a fresh submission, which is the safe behaviour. The message names the id if
  you want to cancel it.
- **`asc metadata` does not cover screenshots, categories, review information or age ratings.**
  Screenshots carry over when a version is created from a previous one.
- **Regulations and permits declarations are web-UI only** and `review doctor` says so
  explicitly. Never report a release as fully verified without noting this.
