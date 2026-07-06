# Knabberfuchs — Full Review Synthesis

*Review date: 2026-07-06, at commit `2af3c06` (v1.3.0+36). Four parallel deep-review passes: data layer, UI/state, domain+tests, CI/tooling/security/docs. Every finding below was verified against the actual code — file:line references included. Supersedes the 2026-07-02 review.*

**Headline:** the 2026-07-02 review's entire top-priority list — all eight items — is **fixed and verified** (details in the last section). The suite is green: `flutter analyze` clean, 201/201 tests pass. The new findings cluster in three places: **upgrade-path atomicity** (the migration chain is not transactional, and an interrupted upgrade can destroy custom foods), **search for accented queries** (the tokenizer defeats offline-pack FTS for exactly the German/French queries this app's users type), and **identity/credential hygiene at the edges** (real name in commit author emails of a public repo; Gemini key rides along in OS cloud backups).

## Fix status (updated 2026-07-06, same-day fix session)

**Fixed and committed** (each commit references its finding):

| Finding | Commit |
|---|---|
| #1 critical — migration chain not transactional | `e67b0ec` |
| #2 high — `upsertFood` stale rowid on update path | `4105d00` |
| #3 high — diacritic queries defeat offline/local search | `cd28a3a` |
| #4 high — real name in commit metadata | history rewritten + force-pushed, remote verified clean; see finding for residual GitHub-support purge |
| #5 high — trends "days in target" counts unlogged days | `c9e7c71` |
| #7 medium — Swiss re-seed wipes favorites/usage/mappings | `3ae31ad` |
| #8 medium — backup drops catalog favorites + OCR mappings | `beffd46` |
| Trends-tab toggle yanks user off Settings | `9fd7866` (HomeTab enum) |
| `ref` after `await` in dismissible sheets (+`_pickDate`) | `360a5bb` |
| Unconfirmed meal delete | `1ae12b6` (+ `mealDeleteConfirm` ×4 locales) |
| kJ thousands-separator parsing | `eefd865` |
| Website hero overclaim + privacy §2 OS-backup gap | `b337aff` |
| `_logToDay` double-tap; salt-chart y-axis; Gemini dropdown crash | `b76a155` / `16fd7c9` / `1b1284f` |
| Meal windows crossing midnight → snack | `1125ea9` |
| Debug wipe leaves pack files; seeder DST stepping | `2dcf3ec` |
| Backup RangeError + 1970 timestamps on restore | `0285b77` |
| Salt keyword substring false-positive; `decodeMicros` all-or-nothing | `c22ef5e` |
| cut_release lower-version guard; screenshots.yml locale fallback; store-graphic palette note | `5c96a64` |
| DESIGN_SYSTEM §1/§3 rot | `995a348` |
| Locale-aware meal times; 48dp kcal fast-path; l10n unit sweep | `62b01ba` |
| Dialog-owned TextEditingController (shared `showTextPromptDialog`, 4 sites) | `149d2b8` |
| "davon" merged-OCR-row nearest-keyword heuristic | `afb4446` |
| Pipeline sed-metacharacter escaping | `dda6824` |
| `entries.day` index (schema v14, migration + tests) | `10ba9e7` |
| Gemini HTTP fallback-loop tests + corrupt-photo tolerance | `dc88745` |
| HealthService record-window clamping extracted + tested | `ada973d` |

**Still open** —

1. **Priority 6: Gemini key in OS cloud backups.** Needs a decision:
   `flutter_secure_storage` (new plugin dep — blocked on a clean
   `pubspec.lock`, currently dirtied by the local fuchsbau path override) vs.
   excluding the key another way. The privacy pages already disclose OS
   backups since `b337aff`.
2. **fastlane version pinning** in `ios.yml`/`ios-release.yml` — pick and pin
   a known-good version (or Gemfile + lockfile).
3. **sha256 verification** for the DuckDB CLI zip (offline-packs.yml) and
   ideally the OFF parquet (pipeline/build_all.sh) — needs the real hashes.
4. **`production`-track dispatch approval gate** in android.yml — policy call.
5. ~~Test investments~~ — all covered now: Gemini HTTP loop, HealthService
   clamping, and the log-food sheet math driven through the real widget
   (`886e9fc`).

## At a glance

| Dimension | Health | Notes |
|---|---|---|
| data layer | good, one critical | Snapshot design, FK enforcement, transactional backup import all solid; migration chain lacks a transaction wrapper |
| UI / state | good | Conventions followed almost everywhere; a wrong statistic and two sheet lifecycle gaps |
| domain logic | good | Math verified correct (kJ, sodium, DST); tokenizer diacritic bug is the outlier |
| tests | strong | 670-line fixture-based migration suite is the standout; gaps only at Gemini HTTP loop + Health service |
| CI | strong | Release gates in place, secrets handled well, actions pinned |
| security/privacy | fair | Tracked files clean; commit metadata and OS-backup scope are the two leaks |
| docs | good | Privacy pages accurate and current; website hero overclaims; DESIGN_SYSTEM §3 rotted |

## Top priorities

1. **[critical] Migration chain is not transactional — an interrupted upgrade can permanently delete custom foods or brick the DB** — `lib/data/db/database.dart:39-213`. Drift runs `onUpgrade` statement-by-statement with no wrapping transaction and bumps `user_version` only after the whole callback succeeds (verified against drift 2.34.0 source). Concrete scenario: a device on schema ≤7 upgrades to 13; the v8 block renumbers `foods.source` (`2,3→1`, `4→2`) and autocommits; the process is killed during the slow v12/v13 backfills (correlated full-scan subqueries — an OS kill mid-spinner is realistic). On relaunch `user_version` is still ≤7, the v8 block re-runs, and now `source = 1` means *custom*: `DELETE FROM foods WHERE source = 1` silently destroys every user-created food. A crash between two `addColumn`s instead yields "duplicate column name" on every launch → drift refuses all queries → app permanently bricked. **Fix:** wrap the `onUpgrade` body in `await transaction(() async { ... })` (drift's documented pattern). The excellent migration test suite covers correctness but cannot cover interruption — this is the one hole left.

2. **[high] `upsertFood` returns a wrong row id on the update path** — `lib/data/db/database.dart:225-233`. `insert(..., onConflict: DoUpdate(...))` returns `last_insert_rowid()`, which SQLite does **not** update when the upsert takes the UPDATE path (drift documents this; the stale value is connection-wide across all tables, e.g. a diary-entry id). Repeat an online search whose results are already cached (`food_repository.dart:85-97`): every returned id is stale and `foodById(staleId)` drops results or resolves to an unrelated food the user can log with wrong nutrition. `createFood` re-saving with a used barcode (`food_repository.dart:140-161`) hits `(await db.foodById(id))!` → null-assert crash or wrong food. **Fix:** `insertReturning`, or re-fetch by the conflict key `(source, externalId)`.

3. **[high] `searchTokens` destroys accented queries — offline-pack search misses German/French products entirely** — `lib/domain/search_query.dart:35-39`. The tokenizer splits on `[^a-z0-9]+` after lowercasing, so `"Müsli"` → `['m','sli']`, `"Käse"` → `['k','se']`. The pack FTS index folds diacritics (`unicode61 remove_diacritics 2` indexes `musli`), so the generated prefix query `MATCH 'm* sli*'` can never match — **a Swiss user searching "Müsli" or "Käse" offline gets zero pack results** in a de/fr/it-first app. Local `LIKE` search (`database.dart:265-287`) degrades to noisy substring matching. **Fix:** fold diacritics before tokenizing — the accent map already exists in `normalizeOcrName` (`lib/domain/ocr_ingredient.dart:30-65`); extract and share it. Add `expect(searchTokens('Müsli'), ['musli'])` — no current test feeds a non-ASCII query, which is why the green suite hides this.

4. **[high — FIXED 2026-07-06] Author's real name leaked via commit author/committer emails on a public repo** — 29 commit objects (2026-06-30 → 07-03) plus the taggers of two local-only annotated tags carried a personal Gmail address containing the real name. **Resolved:** history rewritten with `git filter-repo --mailmap` (identical trees, metadata-only), force-pushed `main`, `feature/feedback-0703`, and re-pointed `v1.2.0`/`v1.3.0` with the release workflows temporarily disabled; remote scan confirms 0 residual identities across all 320 commits; local tags `v1.0.25`/`v1.0.26` (never pushed) re-created with the clean identity. Residual: GitHub may serve the *old* commits by their original SHAs until garbage collection — request a purge via GitHub Support if desired; and enable "Keep my email addresses private" + "Block command line pushes that expose my email" at github.com/settings/emails to prevent recurrence. Two local stashes still chain to the old history (harmless — stashes can't be pushed).

5. **[high] Trends "days in target" counts unlogged days** — `lib/ui/trends/trends_screen.dart:254-257` with `day_summary.dart:178-183`. The gap-filled series gives unlogged days value 0; for a max-only kcal target `statusFor(0, target)` returns `inRange`, so someone who logged 2 of 30 days sees "30/30 days in target". Min-bearing targets instead count unlogged days as "under", inflating the denominator. **Fix:** restrict to logged days (`t.kcal > 0 && t.status != TargetStatus.none`).

6. **[medium] Gemini API key rides along in OS cloud backups** — the key is stored plaintext in the settings table inside the diary DB (`lib/providers.dart:107`). The in-app export correctly strips it (`backup.dart:35`), but `android/.../data_extraction_rules.xml` includes the DB in Google cloud backup/device transfer, and iOS backs up Documents to iCloud — so the credential the export flow protects still lands in Google/Apple backups. **Fix:** move the key to `flutter_secure_storage` (Keystore/Keychain), or exclude it from OS backup paths.

7. **[medium] Swiss dataset re-seed wipes favorites, usage/recency, OCR mappings, and entry links** — `lib/data/sources/swiss_seed.dart:132-142`. A `swissDatasetVersion` bump (already at v5) handles the update via `DELETE FROM foods WHERE source = swissFcdb` + fresh insert: `isFavorite`/`usageCount`/`lastUsedAt` reset, `ocr_mappings` cascade away, `entries.foodId` set-nulls — a routine app update silently empties the favorites and recently-used pickers. **Fix:** upsert by `(source, externalId)` updating nutrition columns only, or carry user-state columns over by `externalId`.

8. **[medium] Backup doesn't export favorites/usage on catalog foods** — `lib/data/backup.dart:112-137`. Only custom foods are exported; favorites and recency on Swiss/OFF rows are user data and not re-fetchable, so device migration via backup empties the favorites/recent pickers. `ocr_mappings` are never backed up either. **Fix:** export `(source, externalId, isFavorite, usageCount, lastUsedAt)` tuples and re-apply by external id.

## Other bugs (medium)

- **Enabling the Trends tab from Settings yanks the user to Trends** — `lib/ui/home_shell.dart:25-30,57` + `settings_screen.dart:106-114`. With Trends hidden, Settings is index 2; inserting Trends makes index 2 the Trends page while the user is mid-toggle. The clamp only protects the shrink direction. Key tabs by enum identity, not raw index.
- **`ref` used after `await` in dismissible sheets → StateError** — `day_screen.dart:827-850` (`_EditMealSheet._save`: after `editEntryGroup` + up to two multi-second `maybeSyncDay` platform calls) and `recipe_detail_screen.dart:440-470` (`_LogPortionSheet._log`: four `ref.read`s after the first await; the `catch (_)` can swallow the error so the portion silently never logs). Riverpod 3.3.2 throws from every `WidgetRef` method after unmount. Add `if (!mounted) return;` after each await gap or hoist reads before the first await.
- **"Delete meal" has no confirmation and no undo** — `day_screen.dart:605-607,739-745`. One tap in the ⋮ menu (directly below "Save as recipe") cascade-deletes the group and every entry. Recipe and custom-food deletion both confirm; DESIGN_SYSTEM §10 calls for it. Add a confirm dialog or undo snackbar.
- **Nutrition-label kJ parsing breaks on thousands separators** — `lib/domain/nutrition_label.dart:47-49,63-72`. `"Energie 2'000 kJ"` first-matches `"000 kj"` → kcal 0, accepted; `"1.046 kJ"` → 0.25 kcal. Fires exactly on partial OCR reads where no kcal figure is present. Strip grouping separators before matching and/or add a plausibility floor.
- **Website hero still claims "your data never leaves your phone"** — `docs/index.html:68-69` + meta/OG at lines 7,10. Contradicts the (now accurate) privacy policy and README: OFF gets search terms/barcodes, Gemini gets photos/descriptions. Scope it as "your diary stays on your phone".

## Low-severity findings

**UI / state**
- `ocr_meal_screen.dart:282-323` — "Log to day" lacks the `_saving` double-tap guard its sibling `_saveRecipe` has; a second tap can log the meal twice.
- `scan_screen.dart:119-149`, `recipes_screen.dart:55-88`, `ocr_meal_screen.dart:199-236`, `debug_section.dart:291-331` — `TextEditingController` disposed in `finally` while the dialog is still animating out; IME teardown can hit the disposed notifier in debug/profile.
- `trends_screen.dart:215-221,451-483` — `_niceInterval`'s smallest step is 10, so low-gram metrics (salt tops out ~5.75) render with zero y-axis labels/gridlines. Extend steps downward (`0.5, 1, 2, 5, …`).
- `day_screen.dart:189-199` — `_pickDate` reads `ref` after await unguarded; benign today (DayScreen lives in an IndexedStack) but a latent trap.
- `settings_screen.dart:740-742,826-848` — Gemini model dropdown asserts if the stored setting matches neither item; any future model rename turns Settings into a crash. Coerce unknown values to the default.
- `settings_screen.dart:588-600` + `meal_times.dart:31-36` — meal windows accept start ≥ end with no validation; "Dinner 20:00–00:30" stores an empty window and every dinner logs as Snack with no feedback. Either treat `end < start` as wrapping midnight or validate in the picker. *(Flagged independently by two reviewers.)*
- `day_screen.dart:570-584` — the tappable meal-header kcal subtotal is a ~60×16 px tap target (codebase norm is 48dp); pad it or make the whole header open details.
- `providers.dart:221-224` — meal auto-names always use `DateFormat('HH:mm')` regardless of locale; use `DateFormat.Hm(locale)`/`jm(locale)`.

**Domain**
- `nutrition_label.dart:43,45` — `'sel'` keyword substring-matches "**Sel**en" (selenium rows on Swiss labels) and French "selon"; use word boundaries for the short keys.
- `nutrition_label.dart:76-102` — OCR-merged lines ("Kohlenhydrate 50 g davon Zucker 30 g") assign the first number to the wrong branch (sugar=50, carbs=null); "number nearest keyword" would fix it.
- `nutrition.dart:67-76` — `decodeMicros` drops the whole map on one bad value; tolerate per-entry instead.

**Data**
- `debug_tools.dart:17-39` — debug wipe clears `installed_packs` rows but leaves pack files on disk and stale open handles; pack search keeps working until restart, files orphaned permanently. Call `OfflinePackService.remove()` per code.
- `backup.dart:38-39,321` — restore maps absent `createdAt` to epoch 1970 and hard-crashes with `RangeError` on out-of-range `mealType` (transaction rolls back cleanly, but the user sees a raw exception, not the localized format error).
- `debug_tools.dart:106` — debug seeder still uses `Duration(days:)` day-stepping (only DST-unsafe spot left; everywhere else uses `DayKey.shift`).
- `entries.day` has no index — every day-view/trends query full-scans `entries`; worth adding as diaries grow.

**CI / tooling / docs**
- `ios-release.yml:49` (and `ios.yml:127`) — fastlane installed/used unpinned; a breaking fastlane release can alter an App Store submission on release day. Pin a version or use a Gemfile.
- `offline-packs.yml:23`, `pipeline/build_all.sh:17-19` — DuckDB CLI zip and the 7 GB OFF parquet are downloaded with no checksum; output flows into the public HF dataset all installs download. Verify sha256 for the DuckDB zip at minimum.
- `screenshots.yml:112-114` — locale `case` has no `*)` default; a custom locale input kills the staging step under `set -u` *after* the ~60-minute capture. Mirror `tool/screenshots.sh`'s fallback.
- `android.yml:31` — workflow dispatch offers `production` with `status: completed` (full rollout); test-gated but a one-click prod push from any ref. Consider requiring a tag or environment approval.
- `tool/cut_release.sh:32` — rejects only `VERSION == current`, not a *lower* version; `cut_release.sh 1.2.9` after 1.3.0 would tag confusingly.
- `tool/make_store_graphics.py:23` — feature graphic still generated in pre-rebrand green; regenerating would reintroduce off-brand assets.
- `pipeline/build_all.sh:27-28`, `build_pack.sh:20-21` — sed-into-SQL templating escapes `&` only for `SRC` and breaks on `|` in paths; hardening only.
- `docs/privacy.html:68-70` — §2 says data "stays on the device unless you export it", but Android Auto Backup ships the diary DB (including the Gemini key, see priority 6) to Google Drive and iOS backups include it. Add a sentence on OS-level backups.
- `DESIGN_SYSTEM.md` §3 rotted: meal-header menu now leads with "Meal details" and includes "Merge"; `food_search_list.dart:301-316` is a second `PopupMenuButton`; the tappable kcal-subtotal fast path is undocumented.
- Minor l10n consistency: some sites inline `'… kcal'` instead of `l10n.kcalValue` (`day_screen.dart:579,966-967`, `merge_meal_sheet.dart:128`, `scale_meal_sheet.dart:75`, `recipe_detail_screen.dart:401`, `trends_screen.dart:211`).

## Test coverage — where to invest next

Suite state: **201 tests, all passing; `flutter analyze` clean** (run 2026-07-06). Migration coverage is now the standout: `test/migration_test.dart` (670 lines) runs real on-disk fixtures of v1/v6/v7/v10/v11/v12 through the genuine upgrade chain to v13, asserting migrated data, FK integrity, and `user_version`. Goldens are tolerance-hardened and Linux-scoped — not fragile. Remaining gaps, by risk:

1. **Gemini HTTP loop** (`gemini_service.dart:89-172`) — model-fallback on 503/timeout, cancellation, non-200 paths untested despite an injectable `http.Client` and an existing MockClient pattern in `test/off_api_test.dart` to copy.
2. **HealthService** (226 lines, zero tests) — the timestamp clamping (`health_service.dart:141-156`) silently corrupts what lands in Health Connect if wrong; it's extractable and cheap to test.
3. **Backup failure paths** — round-trip/collision/version tests exist; missing: malformed record mid-list proving rollback, and `restoreFromZip` with a corrupt zip.
4. **Adversarial label-parser inputs** — grouped-digit kJ, `Selen`/`selon`, merged rows (the three bugs above).
5. **Accented search queries** — one-line test would have caught priority 3.
6. **Log-food sheet math** (`log_food_sheet.dart:203`) — the one UI spot where a regression alters stored numbers; only covered indirectly via `units_test`.

## What's verifiably good

- **All 8 top-priority findings from the 2026-07-02 review are fixed** (see below).
- Domain math verified correct: kJ→kcal 4.184, OFF sodium g→mg, Health salt→sodium ÷2.5; DST handling systematically eliminated via calendar arithmetic with Europe/Zurich-pinned tests.
- Snapshot-per-entry design makes diary history immune to catalog edits; FKs declared and enforced (`PRAGMA foreign_keys = ON`); backup import fully transactional and version-gated both directions.
- UI discipline: exact 371-key ARB parity across en/de/fr/it, zero `Icons.*`, unique heroTags, snackbars uniformly via `showAutoSnackBar` with messenger captured pre-await, AA-checked status colors, live-region snackbars.
- CI: release builds gated on analyze+test with tag==pubspec verification; third-party actions SHA-pinned; secrets env-passed with fail-fast empty checks; `.fvmrc` single-sourced; no secret ever committed (verified across full history).
- Versions consistent end-to-end: pubspec 1.3.0+36 == tag == 4× Android changelog == 4× iOS release notes.

## Status of the 2026-07-02 review's top priorities — all fixed

| # | Prior finding | Status | Evidence |
|---|---|---|---|
| 1 | Backup restore aborts on PK collision | **Fixed** | `backup.dart:232-264` — custom foods re-inserted without explicit id, documented |
| 2 | Offline-pack results collapse to one row | **Fixed** | `food_search_list.dart:153-162` — dedupe on `barcode ?? 'id:$id:$name'` composite key |
| 3 | Privacy policy omits Gemini text hint | **Fixed** | All four privacy pages cover photo *and* typed description incl. the new describe-meal flow, dated 5 July 2026; in-app `aiKeyDesc` matches |
| 4 | Zero migration tests | **Fixed** | `test/migration_test.dart` — real fixtures v1→v13 with data assertions |
| 5 | DST-unsafe day arithmetic | **Fixed** | `date_x.dart:18-22`, `day_summary.dart:227-229`, `health_service.dart:104-136` all calendar-based (only the debug seeder remains, noted above) |
| 6 | Gemini key in backup ZIP | **Fixed** | `backup.dart:35,165-167,369` — stripped on export *and* on import of old backups |
| 7 | Pack file rewritten under open handle | **Fixed** | Versioned filenames + tmp-write/rename (`offline_pack_service.dart:74-125`); store reopens on path change |
| 8 | Releases not gated on tests | **Fixed** | `android.yml` `play: needs: test`, `ios.yml` `testflight: needs: test`, both with tag==pubspec checks |

*(README egress overclaim also fixed at `README.md:41-45`; the website hero at `docs/index.html:68` is the one surface still making the old absolute claim.)*

## Working-tree note

`pubspec.lock` is currently dirty because the gitignored `pubspec_overrides.yaml` flips fuchsbau to a local `path:` dependency. Don't commit it in that state — `cut_release.sh`'s clean-tree check will correctly block a release until it's reverted.
