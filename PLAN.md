# Calorie Tracker — Plan

An ad-free, no-subscription, no-popup calorie tracker. Android-first (Flutter, so
iOS stays possible). Local-first data, optional Health Connect sync, serverless
recipe sharing, ZIP backup/restore.

## Status (2026-06-17)

Phases **0, 1, 2, 4 done**; **6 core done**. 52 tests pass, debug + release APK build.
**Verified on a real device** (id ch.knabberfuchs.app, Android 16): launching, USDA
produce search, logging, and **barcode scanning all work**. USDA bundle cleaned to
whole foods (5,655) and search improved (synonyms/ranking). Remaining: **Phase 3
(Health Connect)** needs device verification; **Phase 5** optional; **Phase 7 (photo/OCR
meal tracking)** later; plus near-term enhancements below (min/max targets, track-by-day
switch, units).

## Decisions (from planning)

| Area | Decision |
|---|---|
| Framework | **Flutter** (official OpenFoodFacts Dart pkg, `mobile_scanner`, `health`, `drift`) |
| Food data | **OpenFoodFacts** live API (barcode, no key) + **bundled USDA public-domain produce DB** (Foundation + SR Legacy, no key) + **manual custom foods** |
| Offline | OFF results cached locally; **USDA produce bundled = offline from day one**; optional opt-in OFF **regional packs** later. No runtime API keys (avoids key-leak/deactivation — see note) |
| Day model | Entries grouped by **meal** (Breakfast/Lunch/Dinner/Snacks) **with a flat-list toggle** |
| Targets | **Per-weekday** optional calorie target (training days can be higher) + default; counter is per-day |
| Recipes | Create from a meal or selected products; reusable |
| Recipe sharing | **QR** (self-contained, calories+macros, serverless) + **"Share as file"** fallback for big/full-micro recipes |
| Health sync | **Health Connect, write-only, opt-in** (energy + macros + micros). Fast-follow after core logging |
| Backup | **ZIP** = SQLite snapshot (lossless) + JSON export (portable) + CSV of entries; manifest carries schema version |

## Architecture

- **Offline-first.** Everything reads/writes the local SQLite DB. Network is only for
  *resolving new foods* (barcode scan / text search), and results are cached locally.
- **Repository with layered sources** for food lookup:
  `local cache (incl. bundled USDA produce) → OpenFoodFacts live → (manual entry prompt)`.
- **No runtime API keys.** OFF is keyless. USDA is shipped as a *bundled* dataset (built at
  dev-time from public-domain data), so we never embed a USDA key in the app — nothing to
  leak or have deactivated. An optional user-supplied USDA key (stored on-device) can enable
  live branded search later, but is never required.
- **History is immutable to food edits.** Each logged entry stores a *snapshot* of the
  food's nutrition + grams, so re-caching or editing a food never rewrites past days.
- Stack: `drift` (SQLite + migrations), `riverpod` (state), `mobile_scanner` (barcode),
  `openfoodfacts` (OFF), `health` (Health Connect), `archive`/`share_plus`
  (ZIP backup + share sheet), `qr_flutter` + `mobile_scanner` (QR encode/decode).
  `http` only if/when optional live-USDA is added.

### Build-time data pipeline (USDA produce bundle)
A dev-time script (DuckDB or Dart) downloads USDA FoodData Central **Foundation Foods +
SR Legacy** (~10k whole foods, public domain — excludes the huge Branded Foods set, which
OFF already covers), keeps the columns we need, and emits a compact SQLite asset bundled in
the app. Refreshed manually on USDA dataset updates. No runtime key, fully offline, ~few MB.

### Data model (draft)

- **foods** — `id, source(off|usda|custom), barcode?, name, brand?, locale,
  serving_g?, serving_label?, kcal_100g, protein_100g, carb_100g, fat_100g,
  fiber_100g?, sugar_100g?, sodium_100g?, micros(json)?, updated_at`
- **entries** — `id, date, meal_type, food_ref?, grams, + snapshot(name, kcal,
  protein, carb, fat, micros), created_at`  *(snapshot = stable history)*
- **targets** — `weekday(0-6) → kcal, protein?, carb?, fat?` + a `default` row
- **recipes** / **recipe_items** — recipe header + ingredient snapshots (food + grams)
- **settings** — key/value (locale, health-sync on/off, default view, etc.)

### Quantity model
Grams are primary ("enter gramm"). When the source provides a serving size, offer
quick-pick chips (e.g. "1 serving = 30 g") that just fill the grams field.

## Rate limiting & caching (critical)

API limits force search to be **local-first, network-on-pause** — never per-keystroke:

- OFF product read (barcode): **15 req/min/IP** · OFF search: **10 req/min/IP**
  (OFF explicitly: *don't use for search-as-you-type*). **USDA is not hit at runtime** (bundled),
  so it has no rate limit to manage; limits below apply only to OFF.

Strategy:
1. **Search-as-you-type hits the local cache only** (instant, zero network). The
   `foods` table is the live search index.
2. **Network search is deferred + explicit:** fire an online query only after the user
   pauses (debounce ≥ 600 ms) *and* local results are thin, or when they tap
   "Search online". Results are merged into the cache.
3. **Client-side token-bucket rate limiter per source** wraps every API call: OFF-search
   bucket (10/min), OFF-product bucket (15/min). Requests queue when the
   bucket is empty; UI shows "searching…/rate-limited, retrying in Ns" instead of erroring.
4. **Aggressive caching:** every fetched product and search hit is stored in `foods`
   with `updated_at`; barcodes cache effectively forever (background refresh only if
   stale). Repeat scans/searches never touch the network.
5. **Barcode scan = single product read**, which is the cheap 15/min endpoint — but it's
   cache-checked first, so a re-scan is free.

## Roadmap (phased)

- **Phase 0 — Scaffold:** ✅ Flutter project created (Android + Linux desktop), toolchain in
  a distrobox, debug APK builds. Next within Phase 0: drift schema + migrations, settings, theming.
- **Phase 1 — Usable MVP:** ✅ DONE. USDA produce bundle built (8,077 foods, 218 KB
  gzipped asset, imported on first launch); barcode scan + text search (local cache +
  bundled USDA + debounced OFF live) + manual food; log grams into a day; day view
  (meal grouping + flat toggle) with running total; per-weekday target with
  remaining/over readout; custom foods; local cache. 34 tests, debug APK builds.
- **Phase 2 — Recipes & sharing:** ✅ DONE. Recipe editor (search/add ingredients,
  servings); detail with whole + per-serving nutrition; QR share (self-contained
  CTR1 payload) + share_plus text; import via QR scan.
- **Phase 3 — Health Connect:** ⏳ NOT STARTED (needs a physical device + the Health
  Connect app to verify, so deferred — can't validate headlessly). Plan: `health`
  pkg (already a dep) write-only push of energy/macros on log, opt-in Settings toggle,
  Health Connect permission declarations + privacy-policy intent in the manifest.
- **Phase 4 — Backup:** ✅ DONE. ZIP = backup.json (lossless logical restore) +
  entries.csv (portable) + manifest (schema version). Export shares the zip;
  import picks a zip (file_selector), confirms, and restores transactionally.
  (JSON restore is lossless for user data; cached OFF/USDA re-seed/re-fetch.)
- **Phase 5 — Offline packs (optional):** DuckDB preprocessing of the OFF Parquet
  (5.74 GB worldwide) into a compact regional SQLite pack (~30–300 MB), downloadable
  from Settings, with live API fallback for misses. **Hosting:** static file on
  **GitHub Releases** (free, ≤2 GB/file) or Hugging Face; a free GitHub Actions job
  rebuilds packs periodically and re-uploads them. Packs carry a manifest
  (version + date + checksum) so the app can offer "update available". No server.
- **Phase 6 — Batch cooking / portioning:** ✅ CORE DONE via the recipe "Log portion to
  a day" sheet (pick day + portion count, log repeatedly across days). Builds on the
  Phase 2 recipe model: a portion = a density-scaled snapshot entry. Possible polish
  later: a one-shot "split into N, assign each to a day" wizard.
- **Phase 7 — Track a meal by photo (OCR):** snap one or two screenshots of a recipe's
  ingredient list (e.g. from the Sidekick app), run on-device OCR
  (`google_mlkit_text_recognition`, free/offline — sibling of the barcode ML Kit we
  already use), parse each line into name + quantity + unit, match each to a food
  (reusing the search layer + synonyms), let the user confirm/adjust, then build a
  recipe or log the meal directly. Depends on unit handling (below). All on-device, no
  server.

- **Phase 8 — Auto-meal grouping (track-by-day mode):** ✅ DONE (schema v3, verified on
  emulator + device DB). In by-day mode, consecutive
  adds form an ad-hoc **meal group** (header + ingredients), *not* auto-saved to the
  cookbook. Adding the first item creates the group and enters **edit mode**; while
  active, the group's header button is a **✓** (finish) and the bottom-right FAB adds
  into that group. Edit mode ends on ✓ or after ~15 min inactivity (incl. app
  backgrounded, checked on resume). A closed group's header shows a **+** to re-open it
  (re-enter edit + add); the FAB then starts a new group. Decisions (2026-06-17):
  **time-based default names** ("Meal 13:24", editable), each group offers
  **"Save as recipe"** (promotes to cookbook/QR), and this **replaces** the plain flat
  list (a single item = a one-item group). Model: `entry_groups` table (id, day, name,
  createdAt) + `entries.groupId`; active-group id + last-activity time persisted for the
  timeout. Schema migration v3.

## Near-term enhancements (from on-device testing, 2026-06-17)

- ✅ **Search quality** — synonyms (bell pepper→peppers sweet, rocket→arugula…),
  token-AND matching, simpler/raw entries ranked first. Fixed bell pepper / cherry
  tomato / potato-variety findings. (Done.)
- ✅ **Calorie target → min + max** (both optional): under-min / in-range / over-max
  readout. Targets-table migrated to kcalMin/kcalMax (schema v2, verified on-device).
- ✅ **Track-by-meal vs track-by-day switch** (Settings > Logging): by-day mode skips the
  meal picker on add; unified with the meal/flat display toggle.
- ✅ **Units** (g / ml / tsp / tbsp / cup): log sheet unit selector, volume→grams at
  ~1 g/ml with a "≈" hint. Entries stay grams. *Still TODO:* per-food density &
  piece/clove weights for accuracy; units in the recipe-ingredient dialog (for Phase 7).

## Prerequisites / open dev details
- ✅ Toolchain ready: Flutter 3.44.2 / Dart 3.12.2 / JDK 21 / Android SDK 35+36 in the
  `flutter` distrobox; debug APK builds.
- No runtime API keys needed (OFF keyless; USDA bundled). Optional user-supplied USDA key
  is a future power-user setting only.
- Default locale → device locale (German for CH); OFF returns multilingual names.
- App name/branding: TBD (placeholder until you pick one).
