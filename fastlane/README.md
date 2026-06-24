# Play Store metadata (fastlane)

Version-controlled Play Store listing for **Knabberfuchs** (`ch.knabberfuchs.app`),
pushed with [fastlane `supply`](https://docs.fastlane.tools/actions/supply/).
Every lane uploads as a **draft** — nothing goes live until you press
"Send for review" in the Play Console.

## Layout

```
fastlane/
  Appfile                       package name + key path
  Fastfile                      lanes: validate / listing / internal
  metadata/android/<locale>/
    title.txt                   ≤ 30 chars
    short_description.txt        ≤ 80 chars
    full_description.txt         ≤ 4000 chars
    changelogs/1.txt             release notes for versionCode 1 (≤ 500 chars)
    images/
      icon.png                   512×512  — REQUIRED, not yet added (see below)
      featureGraphic.png         1024×500 — REQUIRED, not yet added (see below)
      phoneScreenshots/          1.png … 8.png  (en-US only, for now)
```

Locales: `en-US` (default), `de-DE`, `fr-FR`, `it-IT`.

## No-Ruby alternative: `tool/play_publish.py`

fastlane needs Ruby. If you don't have it, `tool/play_publish.py` pushes this
same metadata tree via the Android Publisher API directly (Python only):

```sh
python3 -m pip install --user google-auth google-api-python-client
python3 tool/play_publish.py            # DRY RUN — validates, saves nothing
python3 tool/play_publish.py --commit   # saves the listing as a draft
```

It reads `fastlane/play-store-key.json` and the `metadata/android/<locale>`
text + screenshots. `--commit` uses `changesNotSentForReview`, so nothing is
submitted for review — you still publish manually in the Console.

## One-time setup

1. **Service account + key (you do this — it's a credential):**
   - Play Console → *Setup → API access* → create / link a Google Cloud service
     account, grant it permission to manage this app.
   - Download its JSON key and save it as `fastlane/play-store-key.json`.
   - This file is **gitignored**. Never commit it, print it, or paste it anywhere.
2. **Install fastlane:** `gem install fastlane` (needs Ruby).

## Lanes

```sh
fastlane validate   # check metadata locally, no upload
fastlane listing    # push text + screenshots as a draft (no binary)
fastlane internal   # upload build/app/outputs/bundle/release/app-release.aab to internal testing (draft)
```

Build the AAB first for `internal`:
`flutter build appbundle --release`

## Still needed before the listing can go live

Graphics aren't generated yet (the repo only has a 256×256 fox logo). Add:

- **`images/icon.png`** — 512×512 32-bit PNG hi-res icon.
- **`images/featureGraphic.png`** — 1024×500 PNG/JPG banner.

Drop them into `metadata/android/en-US/images/` (and per-locale if you want
localized banners). `supply` only uploads files that are present, so their
absence won't break a metadata push — but the Play Console requires both to
publish.

## Notes

- The de/fr/it copy is a first translation pass and is **unreviewed** — give it
  a read before publishing.
- Screenshots currently show the English UI and live only under `en-US`. Add
  localized screenshots under each locale's `images/phoneScreenshots/` later if
  desired.
- `supply` does **not** handle the content-rating questionnaire, target-audience,
  category/tags, or most of the Data Safety form — those stay in the Console.

---

# App Store (iOS)

The iOS twin of the above, via [`deliver`](https://docs.fastlane.tools/actions/deliver/)
(metadata) and [`pilot`](https://docs.fastlane.tools/actions/pilot/) (TestFlight).
Auth is the **App Store Connect API key** (team key `knabberfuchs-ci`, role App
Manager) instead of a Play service account. Nothing is submitted for review —
you press **Submit** in App Store Connect.

## Layout

```
fastlane/
  Fastfile                      ios lanes: validate / listing / beta
  AuthKey_B8TQ2VVZMA.p8         App Store Connect API private key — GITIGNORED
  asc_api_key.json              key id / issuer id / key path     — GITIGNORED
  metadata/ios/<locale>/
    name.txt                    ≤ 30 chars
    subtitle.txt                ≤ 30 chars
    keywords.txt                ≤ 100 chars (comma-separated)
    description.txt             ≤ 4000 chars
    promotional_text.txt        ≤ 170 chars (editable without review)
    release_notes.txt           "What's New"
    support_url.txt / marketing_url.txt
  metadata/ios/copyright.txt
  metadata/ios/primary_category.txt
```

Key id `B8TQ2VVZMA`, issuer `cb228e56-508d-4ed5-9a25-89923265a7ad`. The `.p8` is
**gitignored** and backed up in `ProtonDrive/knabberfuchs-secrets/` (alongside a
`.base64` for CI). Never commit, print, or paste it.

## Lanes

```sh
fastlane ios validate   # check App Store metadata locally, no upload
fastlane ios listing    # push listing text as a draft (no binary, no screenshots)
fastlane ios beta       # upload the built IPA to TestFlight
```

Build the IPA first for `beta` (macOS only): `flutter build ipa --release`.

## CI

`.github/workflows/ios.yml` runs `beta` on a `v*` tag using the free macOS
runner. It needs these repo secrets — the first three we already have, the rest
come from the first Mac build:

| Secret | Status |
|---|---|
| `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_API_KEY_P8_BASE64` | ✅ in ProtonDrive |
| `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD` | ⏳ export on Mac |
| `IOS_PROVISION_PROFILE_BASE64`, `KEYCHAIN_PASSWORD` | ⏳ export on Mac |

## Still needed (the Mac step — #4)

1. `flutter create --platforms=ios .` to generate `ios/`.
2. In Xcode: bundle id `ch.knabberfuchs.app`, add the **HealthKit** capability,
   and Info.plist usage strings (camera, photo library, HealthKit share/update).
3. One manual signed **TestFlight** build (Xcode automatic signing creates the
   distribution cert + provisioning profile). Export them + `ios/ExportOptions.plist`,
   `base64` them into the GitHub secrets above, then CI takes over.
4. **Screenshots** (6.7"/6.9" iPhone) under `fastlane/screenshots/ios/<locale>/`,
   and set the **privacy policy URL** + App Privacy answers in the Console — these
   are required to submit, and `deliver` doesn't cover the privacy questionnaire.

## Notes

- The de/fr/it copy is reused from the Play listing (first-pass, **unreviewed**)
  with "Health Connect" adapted to **Apple Health**. Read before publishing.
- `keywords.txt` is iOS-only (Play has none) — tune for App Store search.
- `support_url` / `marketing_url` currently point at the public GitHub repo —
  swap for a dedicated support page if you make one.
