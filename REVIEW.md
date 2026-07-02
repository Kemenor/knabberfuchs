# Knabberfuchs — Full Review Synthesis

Knabberfuchs is in genuinely good shape for a solo project: the domain math, l10n, secret hygiene, and CI craftsmanship are all above par, and the verification pass repeatedly confirmed *conventions being followed*, not just bugs. The confirmed problems cluster in four places: **backup/restore** (a restore that can abort outright, silently dropped fields, an unimplemented version migration, and a plaintext API key in the ZIP), **the offline-pack feature** (two bugs that together make it far less functional than intended), **date arithmetic across DST** (real breakage for the app's Swiss/EU users, twice a year), and **test coverage exactly where damage is irreversible** (11 versions of hand-written SQL migrations with zero tests). A second tier is documentation rot — the privacy policy under-discloses what the Gemini flow sends, and DESIGN_SYSTEM.md/CLAUDE.md/README actively contradict the shipped code.

## At a glance

| Dimension | Health | Confirmed findings |
|---|---|---|
| data-layer | fair | 8 |
| ui-design | good | 8 |
| l10n | good | 5 |
| net-ml-offline | fair | 9 |
| platform-secrets | good | 5 |
| tests | needs work | 12 |
| ci | good | 8 |
| docs | fair | 10 |

*(Counts are per-dimension as reported; several findings are cross-dimension duplicates and are merged below.)*

## Top priorities

1. **Backup restore can abort entirely on a PK collision** — `lib/data/backup.dart:184`. Custom foods are reinserted with their original ids into a foods table that still holds Swiss-seed (~ids 1–290) and OFF-cache rows; any id overlap throws, rolls back the whole transaction, and restore fails with no recovery path. Fix: insert without explicit id and let autoincrement assign — nothing references custom-food ids (entries drop `foodId` on restore).
2. **Offline-pack search results collapse to one row** — `lib/ui/food/food_search_list.dart:122`. All pack rows have `id: 0`, and the UI dedupes the merged list on raw `f.id`, silently dropping every pack result after the first. Fix: dedupe on the same key as `searchLocal` (`barcode ?? 'id:${f.id}:${f.name}'`) or give pack results sentinel ids.
3. **Privacy policy misstates what the Gemini flow sends** — `docs/privacy.html:87` (+ de/fr/it). Since 2026-06-28 the user's free-text meal hint is embedded verbatim in the request to Google, but the policy (dated 24 June) says only the photo is sent. Update the Gemini row in all four pages and bump the date. Same-day fix: the README claim "the only thing that ever leaves the device is an optional Gemini photo upload" (`README.md:35`) contradicts OFF and Hugging Face calls — reword to match the policy.
4. **Zero tests for 11 schema versions of hand-written, data-carrying SQL migrations** — `lib/data/db/database.dart:39`. v2 kcal carry-forward, v8 enum renumbering, v10/v11 DROP COLUMN — all untested; every test builds a fresh v11 DB. A mistake here silently corrupts user data on upgrade. Adopt drift's schema tooling: `dart run drift_dev schema dump` per version + step-by-step upgrade tests with data assertions.
5. **DST-unsafe day arithmetic** — `lib/core/date_x.dart:17` and `lib/domain/day_summary.dart:184`. `Duration(days: 1)` stepping on local midnights makes day navigation no-op on the DST-end day, split-meal seeding duplicate a day, and trends duplicate/drop days (including silently omitting today). Fix both with calendar arithmetic — `DateTime(d.year, d.month, d.day + days)` — and add tests pinned to `TZ=Europe/Zurich` transition dates.
6. **Gemini API key exported in plaintext in the shareable backup ZIP** — `lib/data/backup.dart:125` (flagged independently by two dimensions). `buildBackupMap` dumps the whole settings table, including `geminiApiKey`, into an unencrypted ZIP pushed through the share sheet. Strip credential-class keys on export; restore already tolerates their absence.
7. **Pack update rewrites the SQLite file under a still-open handle** — `lib/data/offline/region_pack_store.dart:21`. `install()` overwrites `region_$code.sqlite` in place while the store holds a read-only handle that `setPacks` never reopens — mixed stale/new pages or SQLITE_NOTADB, swallowed by catch-alls into silently empty offline search until restart. Version the filename or close/reopen around install.
8. **Tag-push releases are not gated on tests** — `.github/workflows/android.yml:22` / `ios.yml`. A `v*` tag on a red or never-tested commit still builds and assigns `status: 'completed'` to both closed-testing tracks and TestFlight. Add a test job and make the release job `needs: test`.

## Data layer

- **high — Restore aborts on PK collision with seeded/cached catalog rows** (`lib/data/backup.dart:184`). See priority 1.
- **medium — Backup export silently drops custom-food fields** (`lib/data/backup.dart:85`). `barcode`/`externalId` are omitted, so scans stop resolving to the custom food after restore, and re-saving the barcode duplicates the row (the `(source, externalId)` upsert can't match a NULL). `densityGPerMl` loss is UX-only (sheet opens in grams); `usageCount`/`lastUsedAt` loss only degrades ranking. Add the fields to export and read them back.
- **medium — `restoreBackupMap` ignores the backup `schemaVersion`** (`lib/data/backup.dart:168`). The file's own header promises import-time migration, but a v1 backup's legacy `kcal` target is silently dropped — worse, targets are upserted with explicit `Value(null)`, so a v1 restore *null-overwrites existing goals*. Newer-versioned backups import partially with no check. Map v1 `kcal` → `kcalMax` (mirroring the DB v2 migration), reject versions newer than `backupSchemaVersion`, and add a checked-in v1 fixture test.
- **medium — DST-unsafe `DayKey.shift` and trend iteration** (`lib/core/date_x.dart:17`, `lib/domain/day_summary.dart:184`, `lib/providers.dart:473`). See priority 5. Also merged from the tests dimension: no DST tests exist and CI runs on UTC, so this is currently untestable as configured.
- **medium — v8 migration never remaps or deletes old `usda` rows** (`lib/data/db/database.dart:86`). Devices skipping from schema ≤6 straight to v8+ have up to 8,077 USDA rows silently decode as `FoodSource.custom`, appear in the custom-foods list, and leak into backups. Add `DELETE FROM foods WHERE source = 1` before the renumbering.
- **low — Multi-row diary writes not transactional** (`lib/data/repositories/recipe_repository.dart:106`). `logPortionGrams` inserts one entry per ingredient with no transaction (interruption = partial meal group); `logFood`'s insert + usage bump likewise. Siblings (`splitGroupAcrossDays`, `editEntryGroup`, `createRecipe`) do this correctly — wrap these two the same way.

## UI

- **medium — `showAutoSnackBar` drops `action`** (`lib/core/snackbar.dart:18`). The wrapper rebuilds the SnackBar with only `content` and `duration`, so the offline-pack nudge's Download button (`offline_reminder.dart:40`) never appears. Copy all relevant fields (or wrap only the content) and fix the stale "callers only ever set content" comment.
- **medium — OCR loading dialog isn't back-button-proof** (`lib/ui/recipes/ocr_meal_screen.dart:37`). `barrierDismissible: false` doesn't block hardware back; the unconditional `navigator.pop()` at :53 then pops the route beneath — which is the root HomeShell route, leaving a black screen. Wrap in `PopScope(canPop: false)` exactly as the sibling `recognize_food_flow.dart:73` already does.
- **medium — Missing double-tap guards on two commit paths** (`lib/ui/day/scale_meal_sheet.dart:115`, `ocr_meal_screen.dart` `_saveRecipe`). Double-tap scales the meal twice (factor squared) or saves a duplicate recipe. Six sibling flows carry a `_busy`/`_saving` flag — add the same pattern here.
- **medium — OCR Dismissible key embeds the list index** (`lib/ui/recipes/ocr_meal_screen.dart:404`). Adjacent duplicate ingredient names (common with multi-photo OCR overlap) hand a live row the dismissed widget's key — debug assertion, or a silently collapsed row in release. Key on a per-item id (`ValueKey('ocr-${item.id}')`), the repo's own convention.
- **low — Day-entry Dismissible uses `onDismissed` with a stream-redrawn list** (`lib/ui/day/day_screen.dart:840`), violating the design system's documented rule. Move the delete into `confirmDismiss` returning false, matching `recipes_screen.dart`.
- **low — AI guess sheet title uses `titleMedium`** (`lib/ui/food/recognize_food_flow.dart:368`); every other sheet uses `titleLarge` per §4. One-word fix.
- **low — Food search list pads bottom 88 instead of 96** (`lib/ui/food/food_search_list.dart:194`) — form value under a list FAB.

## l10n

- **medium — 'tsp'/'tbsp'/'cup' hardcoded English on the main logging path** (`lib/domain/units.dart:8`, rendered at `log_food_sheet.dart:276/308/363` and `ocr_meal_screen.dart:399`). Opaque to non-English users and violates the repo's own no-hardcoded-text rule. Add `unitTsp`/`unitTbsp`/`unitCup` keys in all four locales (de: TL/EL/Tasse, etc.).
- **medium — Missing `CFBundleLocalizations` in `ios/Runner/Info.plist`**. iOS filters the preferred-languages list by declared localizations, so de/fr/it devices default to English out of the box. Add the four-entry array — this is the standard Flutter i18n plist edit.
- **low — No ICU plurals for count strings** (`lib/l10n/app_en.arb:113` `recipeServings`, `:337` `shareMeta`): '1 servings' / '1 Portionen' are reachable. Convert to ICU plural with a **num** placeholder (servings can be fractional) and mirror to de/fr/it (fr `one` covers 0 and 1).
- **low — 253 of 332 template keys lack `@key` metadata**, contrary to CLAUDE.md's own convention. Backfill descriptions, prioritizing ambiguous short labels and a11y strings.
- **low — Hardcoded 'Backup' XTypeGroup label** (`lib/ui/settings/settings_screen.dart:246`) — the one remaining hardcoded literal in `lib/`; `l10n` is in scope two lines above.

## Networking / ML / offline

- **high — Pack results collapse via id-0 dedupe** (`lib/ui/food/food_search_list.dart:122`). See priority 2.
- **medium — Pack update under a still-open handle, never reopened** (`lib/data/offline/region_pack_store.dart:21`). See priority 7.
- **medium — Gemini key in plaintext backups** (`lib/data/backup.dart:125`; flagged by both net-ml and platform-secrets). See priority 6.
- **medium — `install()` compounding gaps** (`lib/data/offline/offline_pack_service.dart:55`): leaked `http.Client` (never closed), no timeout or cancellation (uncancellable spinner), full ~6 MB+ gzip buffered and decoded synchronously on the UI isolate, and a non-atomic `writeAsBytes` that on a crashed update leaves a corrupt pack the store silently swallows at every startup. Fix: closed client + stream timeout, decompress in an isolate, write to `<path>.tmp` and rename after checksum, support cancel.
- **medium — `fetchManifest` has no timeout** (`offline_pack_service.dart:25`), and the provider isn't autoDispose — a stalled connection leaves a permanent spinner that survives leaving and re-entering the screen. Add `.timeout(Duration(seconds: 10))`, matching OffApi.
- **medium — Image decode/encode and TFLite inference run on the UI isolate** (`lib/data/ml/gemini_service.dart:148`, `FoodClassifier.classify`, `preprocessLabelImage`). No `compute()`/`Isolate.run` anywhere in `lib/`. Blocking is bounded (~1 s) on the Gemini path but visibly freezes the spinner on the on-device classify path.
- **low — Gemini key sent as `?key=` query param** (`gemini_service.dart:116`); on network errors the `debugPrint('… $e')` at :137 logs the full URI *including the key*. Switch to the `x-goog-api-key` header.
- **low — Gemini request not user-cancellable** (`recognize_food_flow.dart:68`): up to ~60 s (two 30 s attempts) trapped behind a `canPop:false` modal. Add a Cancel button that pops with a sentinel and makes the flow ignore the late result (guard the unconditional pop at :87).

## Platform & secrets

- **medium — Missing `NSPhotoLibraryUsageDescription`** (`ios/Runner/Info.plist`). No runtime crash (PHPicker is permissionless on iOS 14+), but the key is required by App Store policy and its absence risks ITMS-90683 flags at upload. Add the purpose string.
- **low — Android health integration over-permissioned** (`lib/data/health/health_service.dart:33`). Drop `android.permission.health.READ_NUTRITION` and request `HealthDataAccess.WRITE` when `!Platform.isIOS`. **Keep the iOS read access** — the plugin's delete path queries via HKSampleQuery, which needs read authorization; a WRITE-only iOS change would silently duplicate meals on re-sync.
- **low — Silent debug-signing fallback in release builds** (`android/app/build.gradle.kts:54`). Local `flutter build appbundle --release` without `key.properties` produces a debug-signed AAB with no warning; the `as String` casts also fail opaquely on partial files. Add a loud `logger.warn` and validate the four properties.
- **low — No `distributionSha256Sum`** in `android/gradle/wrapper/gradle-wrapper.properties:5` for a pipeline that signs store artifacts. One-line hardening.

## Tests

- **high — Zero migration tests for 11 raw-SQL schema versions** (`lib/data/db/database.dart:39`; also flagged by data-layer). See priority 4 — this is the single most valuable test investment in the repo.
- **medium — `OffApi._mapProduct` untested despite an injectable `http.Client`** (`lib/data/sources/off_api.dart:112`). The sole OFF-payload translation (kcal drop, string numerics, `sodiumG * 1000`, name fallbacks, `status == 0`, `countries_tags`) fails silently through `catch (_) { return null; }`. A `MockClient` + realistic fixtures test is nearly free.
- **medium — FoodRepository/RegionPackStore layering untested** (`food_repository.dart:131`). Pack-schema drift (column list mirrored in `pipeline/finalize_pack.py`) yields silently empty offline results. Test with a plain `package:sqlite3` fixture pack; add barcode-precedence tests with a stub OffApi.
- **medium — `seedSwissIfNeeded` untested despite AssetBundle injection** (`lib/data/sources/swiss_seed.dart:117`) — including the documented release-only offset-ByteData failure it once had. Also: the asset actually holds ~1190 rows, not the ~290 the stale doc comment at :15 claims — a real-asset test would catch both.
- **medium — `scaleGroup` and `editEntryGroup` untested** (`diary_repository.dart:85`, `database.dart:264`). Both rewrite logged history; both are trivially testable against `NativeDatabase.memory()` exactly like the existing split test.
- **medium — `ActiveGroupNotifier` untested** (`lib/providers.dart:177`). Expiry/day-check/auto-naming logic with inline `DateTime.now()`; a regression silently files entries into dead or yesterday's groups. Inject a clock (the repo already does this for TokenBucket) and test in a ProviderContainer.
- **low — `OfflinePackService` has no test seams** (`offline_pack_service.dart:46`) — inline client, direct `getApplicationDocumentsDirectory`. Inject client + base dir, then test install/checksum-reject/remove with an in-memory gzip fixture.
- **low — Sole app widget test over-mocks every provider** (`test/widget_test.dart:16`); the real `daySummaryProvider`/`trendsProvider` composition is never executed. One ProviderContainer test overriding only `dbProvider` covers the glue.
- **low — Weak assertions in `food_kcal_fallback_test`** (`:15`): 'eggplant parmesan' matches nothing today, so `isNot(155)` passes vacuously against null, and the formula check at :36 is tautological. Pin literal expected values.
- **low — Locale-aware formatters untested** (`lib/core/format.dart:15`): 44 UI call sites, zero tests, and the code comment itself documents the fragile grouping invariant. A small `format_test.dart` closes it.

## CI

- **medium — Releases not gated on tests** (`android.yml:22`, `ios.yml`). See priority 8.
- **medium — Third-party actions on mutable tags in secret-bearing jobs** (`android.yml:45` and 5 other sites): `subosito/flutter-action@v2` and `maxim-lobanov/setup-xcode@v1` run in the same jobs that materialize the keystore, Play key, and Apple certs. Pin to full commit SHAs with a version comment; add Dependabot for actions.
- **medium — Flutter 3.44.4 duplicated across four workflows** with bump instructions naming only two of them, and goldens engine-locked to the exact version. Use `flutter-version-file` against a single `.fvmrc`, or at minimum list all four files in the bump comment.
- **low — No concurrency groups anywhere**: stacked PR pushes duplicate 20-minute runs; concurrent android.yml runs can race independent Play edits. Add cancel-in-progress groups to test/screenshots and a non-cancelling `play-release` group to android.yml.
- **low — `${{ inputs.locales }}` interpolated raw into `run:` blocks** (`screenshots.yml:87`, `:102`) — classic template injection, mitigated by write-access requirement. Pass through `env` like android.yml already does.
- **low — `PLAY_STORE_KEY_JSON_BASE64` not validated** (`android.yml:75`): an empty secret writes a 0-byte JSON and fails ~10 minutes later with a google-auth traceback. Mirror the keystore step's `::error::` guard.
- **low — Weekly offline-packs job installs DuckDB from `releases/latest`** (`offline-packs.yml:19`), and the pip deps are equally unpinned. Pin versions and bump deliberately alongside planned republishes.

## Docs

- **high — Privacy policy omits the Gemini hint text** (`docs/privacy.html:87` + de/fr/it). See priority 3. (Also flagged independently by net-ml-offline.)
- **medium — DESIGN_SYSTEM.md §9 and §12 contradict the shipped code** (`DESIGN_SYSTEM.md:263`, `:337`; flagged by both ui-design and docs). §9 still prescribes the green `ColorScheme.fromSeed(0xFF43A047)` while `theme.dart` delegates to `fuchsbauTheme` (tangerine triad) — the doc contradicts its own §0. §12 mandates "Material `Icons.*` only" while `lib/` has 131 `Symbols.*` usages and zero `Icons.*`; CLAUDE.md's UI summary carries the same stale icon prescriptions. An agent following either section verbatim would reintroduce abandoned patterns. Rewrite both sections and refresh the drifted file:line anchors.
- **medium — CLAUDE.md release/platform rot** (merged with the CI docs-drift finding). It says "Android calorie tracker", documents only the manual `play_upload_aab.py` path, and ends "App is still in closed testing" — while the app is live on the App Store with a full iOS pipeline (fastlane `platform :ios`, `ios.yml`) and a `v*` tag auto-stages `status: 'completed'` releases to both Play tracks and TestFlight. `play_upload_aab.py`'s "stays in Draft" docstring is likewise wrong. Update CLAUDE.md, fix the docstring, and consider a CI step asserting the tag matches pubspec's `version:`.
- **medium — README rot** (`README.md:3/28/35/40/58`, grouped): Android-only framing and Health-Connect-only bullet despite shipping on iOS with Apple Health; the "only thing that ever leaves the device" claim contradicted by OFF/HF calls (see priority 3); `openfoodfacts` listed in Stack but not a dependency (OFF is a hand-rolled `http` client); "License: TBD" with no LICENSE file on a publicly shipped app. One README pass fixes all five.
- **medium — ACCESSIBILITY.md presents fixed items as open** (`ACCESSIBILITY.md:10`). The 1.1.2+34 a11y sweep (commit e586818) implemented many findings verbatim (liveRegion snackbars, tooltips, the exact suggested status-text hexes), but the doc has no status markers — a future audit would redo or mis-report the work. Mark resolved items or date the audit as pre-sweep.
- **low — PLAN.md Phase 14 still "🚧 IN PROGRESS"** (`PLAN.md:461`) though the redesign shipped and the app is live; the pre-redesign status-color note at :22 also diverges from the shipped mapping. Flip to DONE and record the final mapping.

## What's in good shape

- **l10n is near-exemplary**: 332 keys with script-verified key/placeholder parity across all four locales, idiomatic translations, locale-aware number/date formatting, and complete translated fastlane metadata/changelogs.
- **Secret hygiene is clean**: nothing in the working tree or full git history; keystore/Play key properly gitignored and CI-injected; minimal, well-commented Android permissions; git dependency pinned by commit.
- **CI craftsmanship**: test.yml genuinely gates PRs and main, secrets pass via env (no interpolation, no `pull_request_target`), and the golden-test infrastructure (vendored Roboto, tolerant comparator, pinned engine, failure-diff artifacts) is a model setup.
- **UI discipline**: sheets, heroTags, dialog button order, messenger-before-await, controller disposal, and the no-red status rule are consistently right; the flagged items are outliers against the app's own strong conventions.
- **Domain logic and its tests**: nutrition math, target resolution, OCR parsing, share codec, and the injected-clock rate limiter are clean and well-covered.
- **Data-layer design**: per-entry snapshots protect history, migrations are stepwise and commented, restores run in one transaction — the *design* is right; the gaps are specific bugs and missing tests.

## Suggested order of attack

1. **One backup/restore PR**: fix the PK-collision insert (no explicit ids), export the missing custom-food fields, implement the v1 `schemaVersion` migration + newer-version rejection, and strip `geminiApiKey` from the export. Add the v1-fixture and dirty-database restore tests in the same PR — they'd have caught all of this.
2. **One offline-packs PR**: fix the search dedupe key, version the pack filename (solves the stale-handle problem), and add the manifest timeout. The install hardening (isolate decode, atomic write, cancel) can follow separately.
3. **DST fix**: two-line calendar-arithmetic changes in `date_x.dart` and `day_summary.dart` (+ `TrendRangeNotifier.preset`), plus Europe/Zurich-pinned tests.
4. **Migration test harness**: drift schema dumps + step-by-step upgrade tests. Do this before the next schema version, not after.
5. **CI hardening afternoon**: gate releases on tests, SHA-pin third-party actions, single-source the Flutter version, validate the Play key secret.
6. **Docs sweep in one sitting**: privacy pages (all four), README, CLAUDE.md, DESIGN_SYSTEM §9/§12, ACCESSIBILITY status markers, PLAN Phase 14. Mostly mechanical, and it stops the docs from misdirecting future agent sessions.
7. **Remaining UI/l10n polish** (PopScope, double-tap guards, Dismissible keys, unit labels, `CFBundleLocalizations`, snackbar action passthrough) as a batch of small fixes, then the medium-value test additions (OffApi, repo layering, diary mutations, ActiveGroupNotifier) opportunistically.