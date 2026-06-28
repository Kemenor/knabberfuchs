# Calorie Tracker — Plan

An ad-free, no-subscription, no-popup calorie tracker. Android-first (Flutter, so
iOS stays possible). Local-first data, optional Health Connect sync, serverless
recipe sharing, ZIP backup/restore.

## Open reminders / TODO (updated 2026-06-27)

### New feedback (2026-06-27)

- 📊 **Macro goals + macro visualization** (feedback) — ✅ **DONE 2026-06-27** (grilled →
  5 commits; schema v11, Targets sub-screen, Day-card bars, Trends toggle, docs). Optional
  per-weekday min/max targets for protein/carb/fat at full parity with kcal, surfaced as
  glanceable bars on the Day card and as a swappable metric on the Trends graphs. As built:
  - **Schema (v10→v11):** `targets` gains 6 nullable columns (`proteinMin/Max`, `carbMin/Max`,
    `fatMin/Max`; `addColumn` ×6, no backfill) + 6 app-wide default settings keys
    (`defaultProteinMin/Max`, `defaultCarbMin/Max`, `defaultFatMin/Max`), mirroring the
    `kcalMin/Max` + `defaultKcalMin/Max` shape. `entries` unchanged (macros already snapshotted).
  - **Bar gating, unified across all four metrics:** a metric draws a progress bar when *either*
    bound is set; denominator = `max` if set else `min` (a floor fills toward the min — the
    dominant macro case, e.g. protein ≥120 g). kcal adopts this too (its min-only case now grows
    a bar). Status via shared `statusFor` (under=`tertiary` / in-range=`primary` / over=`error`).
  - **Day card: NO toggle** — shows everything at once. kcal headline unchanged; the P/C/F row
    keeps its compact horizontal 3-up but each macro *with a target* gains a thin under-bar and a
    status-colored gram value. Targetless macros stay plain text, so a calorie-only card is
    essentially unchanged (optional, exactly like the kcal bar).
  - **Settings → new Targets sub-screen** (pushed; moved out of the inline section to avoid
    clutter): **metric-first** — Calories · Protein · Carbohydrates · Fat, each with a default
    Min/Max row always visible + an independent `ExpansionTile` "Per-weekday" revealing the 7
    weekday rows. Reuses `_TargetRow`/`_TargetField` with `g`/`kcal` suffixes.
  - **Trends: the metric swap lives here** — a `SegmentedButton` (kcal · P · C · F) at the top
    re-plots the value series + target band for the selected metric (per-day macro totals = `SUM`
    over entry snapshots, analogous to `watchDailyKcal`). Selection is in-memory (`StateProvider`,
    defaults to kcal, not persisted); range/bucketing untouched.
  - **Also:** new l10n keys mirrored en/de/fr/it; regenerate Trends goldens (SegmentedButton
    changes the screen); update `DESIGN_SYSTEM.md` (per-metric summary-card mini-bars + the metric
    SegmentedButton are new patterns). Build order: (1) schema+domain+providers+tests → (2)
    Targets sub-screen → (3) day-card bars → (4) Trends toggle+goldens → (5) docs.
- 🔗 **Make "Contribute to Open Food Facts" prominent in the food form** (feedback): in
  `lib/ui/food/food_form_screen.dart` the OFF contribution link today sits at the **bottom**
  of the form, only when a barcode is present, as small muted text, and points at the generic
  `how-to-add-a-product` page. Improve it: **move it to the top** (just under the barcode
  field), **deep-link to the product page** `https://world.openfoodfacts.org/product/{barcode}`
  (and/or the add/edit URL from Phase 9c — confirm which best lands an editable/contributable
  view), and **explain more** — a short sentence on why contributing helps (fills the shared
  open database so the next person's scan resolves) and that OFF handles its own login. Keep
  it barcode-gated (no barcode → nothing to contribute) and localized (en/de/fr/it). Builds on
  Phase 9c's link-out approach; still no API/OAuth on our side.
- 📷 **Barcode scanning reliability** (feedback): scans sometimes miss. First, **tune
  `mobile_scanner` config** — restrict `formats` to the barcode symbologies we actually expect
  (EAN-13/EAN-8/UPC-A/UPC-E for grocery), consider `detectionSpeed` (normal vs unrestricted),
  resolution/`cameraResolution`, autofocus, and a torch toggle for low light. If config alone
  isn't enough, add a **consensus capture**: read several frames and only accept a barcode once
  **≥2 of N agree** (e.g. best-2-of-3), debouncing single bad reads. Investigate via the scan
  screen + on real packages (some printed codes are low-contrast/curved). Measure miss rate
  before/after. No backend; pure client-side scanner tuning.


- ✅ **Shipped 2026-06-23 (food-flow + AI batch):** **Free add** (quick name+kcal log, in the
  search list and the Day bolt menu); **AI meal recognition** — on-device (Phase 13a) + optional
  **Gemini** cloud with the user's own free key (13b); merged add-product + custom-food into one
  **`FoodFormScreen`** (barcode is an editable field with an inline scan icon); collapsed
  `FoodSource` to `{ openFoodFacts, custom, swissFcdb }` (schema **v8** renumber migration);
  recipe "log a portion" now logs **per-ingredient** (scaled), recipes-list **swipe** to log/
  delete, recipe **Save**-as-FAB, share QR **as image**, **import from text**; shared
  camera/gallery picker across all image features; scan-barcode moved to a FAB; FAB hero-tag fix;
  release builds are arm64-only (~113 MB). Landing page (`docs/`) refreshed + republished.
- 📦 **Phone builds: arm64-only.** Sideload to the phone (arm64-v8a) with
  `flutter build apk --release --target-platform android-arm64` → ~113 MB vs ~157 MB universal
  (drops armeabi-v7a + the emulator-only x86_64). The size is dominated by on-device ML (ML Kit
  OCR/barcode native libs ~bigger than the 21 MB AIY food model) + the Flutter engine. For a
  Store release, use `flutter build appbundle` (Play splits per-device automatically).

- ✅ **Italian food data** (Phase 12): DONE — `it.xlsx` fetched into `tool/swiss_fcdb/`, dataset
  regenerated with **full Italian** (commit `9214694`), `swissDatasetVersion` bumped to 5 so
  existing installs re-seed. `name_it` populated for all 1190 rows; consumed via `food_name.dart`.
- ✅ **Translation review** (Phase 11c): DONE — DE/FR/IT microcopy reviewed (closed 2026-06-28).
- ✅ **Locale-aware number display** (Phase 11d): DONE 2026-06-22 — `core/format.dart` renders a
  decimal comma in de/fr/it + thousands grouping on kcal, via a number-locale set from the app
  (separate from `Intl.defaultLocale` so dates are untouched). CSV export uses raw period decimals.
- ✅ **Localized dates + meal-type words** (the two deferred i18n bits): DONE 2026-06-22.
  `core/date_label.dart` `dayLabel(context, key)` → localized Today/Yesterday/Tomorrow + locale
  date format ("Sa., 20 Juni"); `initializeDateFormatting()` added in `main`. Meal-type words via
  `domain/meal_type_i18n.dart` (a locale map, NOT the ARB, so the no-context provider can build
  the auto-name): auto-name localized **at creation** ("Abendessen 20:57"), display chips/rows
  localized, CSV pinned to English. Verified on emulator in German; 82 tests pass.
- ✅ **Per-food density / piece weights** (units follow-up): DONE — per-food `density` + natural-
  portion weights ("1 medium cucumber = 300 g") shipped (commits `3fed236`/`28deced`/`59ebb43`);
  `density` populated for all 1190 Swiss rows, consumed in `food_repository`/`recipe_repository`.
- ⚖️ **Quick add + Gemini: optional weight (grams)** — ✅ DONE 2026-06-23 (v1.0.13+14): Quick add
  has a Weight (g) field; Gemini prefills its estimated portion grams; entered totals ÷ weight →
  correct per-100 g snapshot with real grams (blank still = grams 100). Original note: Free add / Quick add stored the
  typed kcal+macros as a per-100 g snapshot with `grams = 100` (the numbers are portion totals),
  and Gemini recognition prefills that same sheet with portion totals. Add an optional **weight in
  grams** field so the logged entry carries a real gram amount — lets the user edit/scale the
  portion later and keeps it consistent with catalog foods (per-100 g × grams). Gemini already
  returns an estimated `grams` per portion (in `GeminiFoodResult.grams`), so it can pre-fill the
  weight; the sheet would then divide the entered totals by the weight to derive the per-100 g
  snapshot instead of hard-coding 100.
- ☁️ **Auto-backup to Google Drive** — ✅ DONE 2026-06-23 (v1.0.18+19): re-enabled **Android Auto Backup** (`allowBackup=true`) with `res/xml/data_extraction_rules.xml` + `backup_rules.xml` that back up only the diary DB (~0.5 MB) and **exclude `app_flutter/flutter_assets` (~96 MB) + offline packs** so it stays under the 25 MB cap and actually runs. This IS the standard free GDrive backup (no OAuth/account). Was briefly disabled after stale restores dropped settings during reinstall testing. The Drive-API route below is now unnecessary. Original note: optional, opt-in automatic backup so data survives
  phone loss / reinstall (today's ZIP backup is manual + local). Two routes:
  1. **Android Auto Backup** (`android:allowBackup`, system-managed to the user's existing Google
     account) — zero code, no OAuth, no extra account, fits the keyless/no-account ethos. Caveat:
     ~25 MB cap and it backs up app data wholesale, so **exclude the large offline packs + bundled
     assets** (back up only the diary DB + settings) via `backup_rules.xml` / `dataExtractionRules`.
     Preferred first step.
  2. **Drive API (app-data folder)** — explicit Google sign-in (OAuth) + scheduled upload of the
     backup ZIP; gives visible/cross-device backups but adds an account + a key, against the
     no-account default → strictly opt-in, only if users ask. Either way: opt-in and disclosed
     (data leaves the device to the user's own Drive).
- 🤖 **Improve on-device recognition** — **DECISION 2026-06-28: cheap wins shipped; model swap is
  a non-goal (nothing to swap to); offline beverages parked.** The bundled AIY food_V1 (2022 dish
  classes, NA-skewed, **zero beverage classes** — confirmed by reading its label map) is the only
  serious Apache-2.0 on-device food classifier that exists. Research (license-verified across HF/
  Kaggle/TF Hub/Roboflow) found **no permissively-licensed off-the-shelf `.tflite` beverage or
  better-food classifier**: alternatives are research-only (Food2K, ISIA Food-500), unlicensed,
  proprietary (STMicro SLA0044), container-detectors, or hosted SaaS. ImageNet-MobileNet as a drink
  fallback is a trap (only 3 real drink-content classes: red wine/espresso/eggnog). So:
  - ✅ **Done — better label→portion/kcal mapping** (`data/ml/food_kcal_fallback.dart`): a curated,
    whole-word category table gives realistic portion grams (was a flat 300 g for ~85% of catalog
    rows that lack a serving size) and a sane kcal estimate even on a catalog miss (was null).
  - ✅ **Done — Gemini nudge:** when no key is set, the on-device path points at the free cloud key
    (richer estimates incl. drinks) — in the guess sheet + the empty-result snackbar; localized.
  - ⏸️ **Parked — offline beverages:** the *only* legitimate path is training our own ~3–5 MB
    EfficientNet-Lite0/MobileNetV3 on Open Images V7 (CC-BY-4.0) + Wikimedia — a build-it-yourself
    project, and single-photo drink-type ID is inherently hard. Not worth it; Gemini covers drinks.
- 🥫 **Additional food sources** — **DECISION 2026-06-27: demoted to a non-goal for grocery; kept
  only as "more *generic* tables if a locale needs them."** Research conclusion (Kemenor): for
  **branded grocery products, Open Food Facts *is* the open database** — there is no serious second
  one. Everything else is the wrong shape or the wrong licence:
  - **The open national tables are generic/whole-foods, not branded grocery:** CIQUAL (FR/ANSES),
    UK CoFID, USDA Foundation/SR Legacy, and the bundled Swiss FCDB. Bundling more of these broadens
    *generic* coverage only — it does **not** close the packaged-products gap. Still fine to add a
    locale's table on demand via the existing `tool/` pipeline (ID-joins into `foods`,
    `FoodSource` gains a value, credited in About; the real work is cross-source dedup + ranking).
  - **USDA FoodData Central → Branded Foods** is the one open *branded* set (public-domain, GS1/
    Label Insight, ~hundreds of k products) — but it's **US-centric**, so low value for a Swiss/EU
    user; most local shelf products aren't in it. Deliberately still excluded.
  - **Commercial APIs (Nutritionix / FatSecret / Edamam / Spoonacular / Passio) are all paid/
    key-gated;** GS1 itself doesn't give nutrition away. Only ever as **opt-in user-key power-user**
    features (mirrors the Gemini/USDA-key pattern), never in the keyless default.
  - **Strategy instead of a new source:** the grocery gap is an *OFF-coverage* problem, and the two
    right levers already ship — **offline regional packs** (Phase 5/10, better local OFF coverage)
    and the **contribute-back flow** (OCR label + the prominent OFF link, 2026-06-27). Improving OFF
    is the serverless answer to "more grocery products."
- ✅ **UI consistency: barcode scan as a bottom-right FAB** (fix): DONE — `food_picker_screen.dart`
  (the ingredient-matching flow) now uses a bottom-right `FloatingActionButton.extended`, matching
  `add_food_screen.dart` and the rest of the app.
- 📐 **Scale a meal** — ✅ DONE 2026-06-23 (v1.0.16+17): meal ⋮ → Scale meal: slider + preset chips (25/50/75/150/200%) with a live kcal preview; multiplies every entry's grams. Original note: add an action to the meal's overflow
  menu to **scale the whole meal by a factor** — multiply every entry's grams (and so kcal/macros)
  by a chosen ratio. Primary use is *down*scaling: you logged a full meal/recipe portion but only
  ate part of it (e.g. ate 60% → scale to 0.6). Sits alongside the existing Edit / Split-across-
  days / Save-as-recipe actions; complements per-ingredient logging and the natural-portion chips.
- 💤 **Phase 5b offline-pack deltas**: PARKED INDEFINITELY (packs are tiny; full re-download is fine).

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
- **Phase 3 — Health Connect:** ✅ DONE (verified on a physical Android 16 phone).
  Opt-in "Sync to Health Connect" toggle writes each day's entries as nutrition/meal
  records (calories + macros + meal type + name); idempotent per-day re-sync (delete
  day + rewrite), auto-fires when the viewed day changes. `HealthService` (health pkg),
  MainActivity = FlutterFragmentActivity, manifest READ/WRITE_NUTRITION + rationale
  intents. Timestamps clamped to ≤ now (HC rejects future records). Confirmed the
  record appears in Health Connect's Nutrition data.
- **Phase 4 — Backup:** ✅ DONE. ZIP = backup.json (lossless logical restore) +
  entries.csv (portable) + manifest (schema version). Export shares the zip;
  import picks a zip (file_selector), confirms, and restores transactionally.
  (JSON restore is lossless for user data; cached OFF/USDA re-seed/re-fetch.)
- **Phase 5 — Offline OFF regional packs (optional):** per-country SQLite packs built
  from the OFF Parquet, hosted on Hugging Face, downloadable in-app with live-API
  fallback. Full design below.
- **Phase 6 — Batch cooking / portioning:** ✅ CORE DONE via the recipe "Log portion to
  a day" sheet (pick day + portion count, log repeatedly across days). Builds on the
  Phase 2 recipe model: a portion = a density-scaled snapshot entry. Possible polish
  later: a one-shot "split into N, assign each to a day" wizard.
- **Phase 7 — Track a meal by photo (OCR):** ✅ DONE (emulator-verified with a real
  Sidekick screenshot). Recipes → "From photo(s)" → pick 1+ images → on-device ML Kit OCR
  → parse name+amount+unit → Review screen of placeholders → swipe/tap to match each to a
  food (search/scan/custom), keeping the parsed unit → Save as recipe or Log to a day.
  Possible polish: occasional missed line on dense screenshots; per-ingredient grams for
  count units without a serving; batch-match suggestions.

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

- **Phase 9 — Contribute a missing product to Open Food Facts:** ✅ DONE near-term
  (2026-06-19) — 9a (add product locally) + 9b (OCR nutrition label) + 9c (link out to
  OFF) built & emulator-verified; **9d (in-app API submit via OAuth) deferred**. When a
  scanned barcode is found *nowhere* (local cache, offline packs, OFF live all miss),
  turn the dead end into a contribution. Instead of "not found", offer **"Add this
  product"** → a form pre-filled with the scanned barcode. To make data entry fast,
  **OCR the label**: photograph the nutrition table (Nährwerttabelle) and the
  ingredients list, run on-device ML Kit OCR (reuse the Phase 7 pipeline), and parse the
  rows into our nutrition fields. Saving stores it as a **contributed custom food keyed
  by the barcode**, so a re-scan finds it immediately — fully offline, no account needed.
  **Near-term scope (decided 2026-06-19): local add + OCR only; for contributing back, we
  just deep-link out to the Open Food Facts app/website** rather than building API
  submission. This dodges the OAuth/OIDC-client-registration blocker (see 9c), keeps the
  app keyless, and OFF handles its own auth + submission in its own app. Sub-parts:
  - **9a — Add product locally.** Barcode-miss → "Add product" form (name, brand,
    quantity/serving, per-100 g energy + macros). Save keyed by barcode so it's instantly
    loggable and persists for future scans. Likely a new `FoodSource.userContributed`
    (or reuse `custom` + barcode) and a `submittedToOff` flag.
  - **9b — OCR the nutrition + ingredients.** Photograph the label → OCR →
    `parseNutritionLabel` maps **localized keys** (DE/FR/IT/EN — the user is Swiss:
    Energie/Brennwert·Énergie·Energy, Fett·Matières grasses·Fat, davon Zucker·dont
    sucres·of which sugars, Kohlenhydrate·Glucides·Carbohydrate, Eiweiß·Protéines·Protein,
    Salz·Sel·Salt) to fields, normalizing units (**kJ→kcal**, g/mg) and handling
    two-column "per 100 g / per serving" layouts. Also OCR the ingredients **text** for
    the OFF ingredients field. User reviews/edits before saving (OCR is a head start,
    not gospel). Reuse ML Kit + the row-by-vertical-position reconstruction from Phase 7.
  - **9c — Contribute via the OFF app/site (NEAR-TERM, no API/auth on our side).** A
    "Add to Open Food Facts" button just **opens OFF for that barcode** with
    `url_launcher` (already a dep) — e.g. the add/edit page
    `https://world.openfoodfacts.org/cgi/product.pl?type=add&code=<barcode>` (confirm exact
    URL at build time). Android **App Links** route it to the installed OFF app, else the
    browser; OFF handles its own login + submission. No account, no OAuth, no write API,
    no client registration — the app stays keyless and we ship the contribution path now.
    Optionally pass along what the user entered, if OFF's add URL supports prefill params.
  - **9d — In-app API submission (LATER / optional, deferred).** Push directly from the
    device via OFF's write API (`/api/v3/product/{barcode}` + `/cgi/product_image_upload.pl`
    for photos, `User-Agent: Knabberfuchs/<ver>`). **Blocked on auth:** OFF requires an
    account for writes (no anonymous adds) and is on Keycloak/OIDC; the right native flow
    is **Authorization Code + PKCE** (public client, system browser, no secret shipped, no
    custom password screen — tokens in `flutter_secure_storage` via `flutter_appauth`). But
    **OFF pre-registers no clients**, so this needs a one-time request to register a public
    native OIDC client for Knabberfuchs (`ch.knabberfuchs.app://oauth`) and confirmation
    they support public/PKCE clients. Until then, 9c (link-out) is the contribution path.
    Test against staging (`world.openfoodfacts.net`). Contributions are ODbL.
  - **Deps / notes:** image capture (camera/image_picker) + existing ML Kit OCR + http +
    url_launcher. Optional small schema bump for the contributed-food flag. (9d adds
    `flutter_appauth` + `flutter_secure_storage` + the OFF OIDC-client registration.)

- **Phase 10 — All regions + searchable Offline regions screen:** ✅ DONE (2026-06-19).
  **106 countries** (≥1000 products each) now live on the HF dataset; the picker has a
  text search + installed-first sort. Pipeline refactored to a single extraction pass
  (`build_extract.sql.tmpl` → `.cache/extracted.parquet`, then fast per-country scans);
  `gen_regions.py` auto-derives the list from the parquet (DuckDB + pycountry, friendly
  names, overrides for the tricky ones); `publish.py` uploads all packs + manifest in one
  commit; CI regenerates the list + frees the source for disk. Original goal below.
  - **10a — Build every region.** Auto-generate the full region list instead of the
    hand-curated `regions.json`: a step that scans the OFF parquet for distinct
    `countries_tags` with product counts, maps each to an ISO code + display name, and
    emits the build list. Decide a **min-product threshold** (e.g. skip countries with
    only a handful of products, or build them but flag them tiny) so we don't ship
    near-empty packs. The DuckDB build + `publish.py` + manifest already loop over the
    list, so they scale; the work is the list generation + name/code mapping.
  - **10b — CI / hosting at scale.** Building ~150+ countries weekly is much heavier
    (more passes over the 7 GB parquet, more uploads, more Hugging Face storage — France
    alone is 58 MB). Options: build all weekly if runtime/storage allow, or tier it
    (top-N by product count weekly, the long tail monthly). Watch HF dataset storage and
    GitHub Actions minutes; `log()` anything skipped so coverage stays honest.
  - **10c — Searchable picker.** The Offline regions screen is a flat list — fine for 4
    countries, unusable for 150+. Add a **text search/filter** by country name at the
    top, and sort **installed first, then alphabetically** (show product count + size).
    Pure client-side filter over the manifest; no backend.
  - **Notes:** keeps the keyless/serverless model (anonymous HF downloads). Mostly
    pipeline + a small UI addition; no app schema change.

- **Phase 11 — App translations (i18n):** 📋 PLANNED. Localize the app UI. Swiss-first
  target locales: **English, German, French, Italian** (start there; easy to add more).
  Uses Flutter's standard stack — `flutter_localizations` + `gen_l10n` + ARB files (`intl`
  is already a dep). NB: this is the app **chrome** only — food/product names come from
  OFF/USDA in their own languages and aren't translated by us.
  - **11a — Infrastructure. ✅ DONE (2026-06-19).** `flutter_localizations` + `generate:true`
    + `l10n.yaml`; ARB files in `lib/l10n` (en template; de/fr/it seeded for infra strings).
    `MaterialApp` wired with delegates/supportedLocales/onGenerateTitle + a `locale` override
    driven by `localeProvider` (persisted `appLocale` setting; null/'system' = device locale).
    Settings → Language section (RadioGroup: System default + EN/DE/FR/IT). Emulator-verified:
    switching to Deutsch flips nav + Material's own strings; System default reverts.
  - **11b — Extract strings (the bulk). ✅ DONE.** All UI screens now pull from `app_en.arb`
    (~230 keys, English; DE/FR/IT fall back until 11c): Day, Recipes + create menu, Settings
    (incl. language picker, health snackbars, backup dialogs, OFF thanks), log/add-food sheet,
    food search + picker, add-product, manual-food, OCR review, recipe edit/detail/share,
    offline regions, scan, crop, split-meal, offline reminder, splash. Parameters/plurals
    handled (`{products}k products`, `{kcal} kcal`, `{n} days`, etc.). Verified: analyze clean,
    builds + runs on emulator. (Meal-type words + relative date title were initially deferred as
    "persisted auto-name tokens" — now DONE, see 2026-06-22 reminders block: dates are pure
    display; meal-type uses a domain locale map so the no-context provider localizes the auto-name
    at creation.)
  - **11c — Translate. ✅ MACHINE PASS DONE (awaiting human review).** All ~216 keys filled
    in `app_de.arb` / `app_fr.arb` / `app_it.arb` (gen-l10n reports zero untranslated). DE
    verified on emulator (nav, macros, empty-state, FAB). Macro letters localized in `macroPcf`
    (DE P/K/F, FR P/G/L, IT P/C/G). Brand/product names kept (Knabberfuchs, Health Connect,
    Open Food Facts, USDA). **TODO:** the user (Swiss, DE/FR) should review microcopy — machine
    translations of UI strings can be stilted; IT especially is unreviewed.
  - **11d — Locale-aware numbers (nice-to-have).** Display/parse decimals per locale
    (German/French use "1,5"). The app already tolerates comma input; this makes
    *display* consistent too (via `intl` NumberFormat). Dates already go through `intl`.
  - **Notes:** big mechanical refactor, low architectural risk; no backend, no schema
    change. The OCR nutrition-label parser already handles DE/FR/IT/EN *input* keys —
    separate from UI i18n but the same languages.

- **Phase 12 — Data localization:** ✅ DONE (DE/FR/EN; IT pending one file). **Pivoted from
  the original "machine-translate USDA" plan to swapping the generic-foods source entirely.**
  Instead of translating English USDA names, we replaced the USDA layer with the **Swiss Food
  Composition Database (FSVO/BLV, naehrwertdaten.ch)** — an official, curated table that ships
  names + synonyms natively in **DE/FR/IT/EN** (the app's exact locales). No machine
  translation, no synonym maintenance.
  - **Source/license:** free incl. commercial use, "subject to acknowledgment of the source"
    (the FSVO literally names a *nutrition diary app* as an allowed use). Credited in
    Settings → About. Build tool + provenance: `tool/swiss_fcdb/` (Python + openpyxl; raw
    xlsx pulled via the Internet Archive since the live host is geo-blocked/down).
  - **What shipped:** `assets/swiss_foods.csv.gz` (1109 generic foods, EN/DE/FR + `search_text`
    = all-language names+synonyms). `Foods` gained `nameDe/nameFr/nameIt/searchText` (schema
    v6→v7). New `FoodSource.swissFcdb` (USDA enum kept for legacy/backup compat). `swiss_seed.dart`
    seeds on first launch and **purges the old USDA rows** (diary entries keep snapshots).
    `searchFoodsLocal` matches `search_text` → cross-language search (verified: "apfel"→12,
    "poulet"→13). Display via `Food.localizedName()` at the search tile, log snapshot, and
    recipe-ingredient flow; falls back to English. Verified on emulator end-to-end in German.
  - **IT pending:** the Italian xlsx isn't on the Wayback Machine and the live site is down;
    `nameIt` is null → falls back to English. Drop `it.xlsx` into `tool/swiss_fcdb/`, re-run
    `build.py`, bump `swissDatasetVersion` — the ID join slots Italian in with zero code change.
  - **Dropped from the old plan:** the `food_terms_i18n.dart` query-synonym dictionary (a
    workaround for English-only USDA) — unnecessary now that the data is natively multilingual.
  - **12c — OFF region-language preference (refinement, optional, still open).** The pack name
    is `coalesce(main, en, de, fr, it)`. Could prefer the *region's* language per pack.
    Mostly already handled — low priority.
  - **Notes:** depends on Phase 11 (locale selection). Build-time only — no keys shipped,
    no runtime cost, asset grows modestly. Scope is small because OFF (the big dataset) is
    already multilingual.

- **Free add — ✅ DONE (2026-06-22).** Quick-log an arbitrary item by name + calories
  (e.g. "Lasagna 816 kcal") without searching the catalog or creating a persistent food.
  A "⚡ Quick add \"<query>\"" tile appears in the Add-food search as you type → opens
  `quick_add_sheet.dart` (name prefilled, calories, optional P/C/F) → logs via
  `diaryRepository.logSnapshot` as a per-100 g snapshot with grams=100 (so the entered
  totals are exactly what the diary shows). Flows into the current meal group like any add.
  Localized (de/fr/it). Verified on emulator (DB: `Lasagna | 100 g | 816 kcal/100g = 816`).

- **Phase 13 — Image recognition (photo → kcal):** ✅ DONE (2026-06-23). Take a photo of a meal →
  ML guesses it → pre-fills the **Free add** sheet (name + kcal [+ macros]) to confirm/edit.
  Two tiers: keyless on-device by default, optional cloud LLM with the user's own key.
  - **13a — On-device classifier. ✅ DONE.** Bundles **Google AIY food_V1**
    (`assets/foodmodel/food_V1.tflite`, Apache-2.0, ~20 MB, 2024 dish classes, 192×192 uint8)
    via `tflite_flutter`. `food_classifier.dart` centre-crops to square then top-K (skip
    `__background__`); `recognize_food_flow.dart`: camera/gallery → classify → "Looks like…"
    candidate sheet → `FoodRepository.estimateKcalForLabel` (catalog match, head-noun fallback,
    300 g default) → Free add, always editable, never auto-logged. Entry = the Day-screen bolt
    **capture menu**. Verified: pizza → "Neapolitan pizza" 98%. Provenance in
    `tool/foodmodel/README.md`; credited in About. Gradle:
    `kotlin.jvm.target.validation.mode=warning` (tflite_flutter target mismatch).
  - **13b — Optional Gemini cloud path. ✅ DONE (2026-06-23).** `gemini_service.dart`: downscale
    photo → Gemini `generateContent` with a JSON response schema → dish + grams + portion totals
    (kcal + macros) → Free add prefilled (macros section auto-expands). Uses the **user's own
    free-tier Gemini key** (`gemini-3.5-flash`; free tier verified: 1500 req/day, image input, no
    card) stored in the `geminiApiKey` setting; Settings → AI recognition has a masked key field,
    "Get an API key" link, and an honest disclosure (photo goes to Google; free tier may train on
    it; billing-enabled accounts may incur charges). On **any** failure (no key/network/bad key/
    404) it falls back to the on-device classifier. Pure `parseGeminiResponse()` is unit-tested;
    **live path verified end-to-end** with a real key (pizza → "Pizza Margherita", 850 kcal,
    P32/C105/F28). The on-device path stays the keyless default.
  - **Caveat:** calorie-from-photo is inherently rough → always framed as an *estimate to confirm*.

- **Phase 14 — Design-system migration (fuchsbau):** 🚧 IN PROGRESS (planned + grilled
  2026-06-28). Re-skin knabberfuchs onto the shared **fuchsbau** design system (tangerine
  triad, Figtree + accessibility font picker, Material Symbols Rounded, rounding/spacing
  tokens, "red = destruction only"). knabberfuchs is the **validation consumer** of a new
  shared `fuchsbau` Flutter package; checkfuchs migrates onto it afterwards. No feature,
  data-model, or architecture change — the app is already theme-driven (single-source
  `core/theme.dart`, semantic `colorScheme`, zero hardcoded `Colors.*`), so this is a re-skin
  + token adoption, not a rewrite. Done **before** production (woven into the running 14-day
  closed test; a new build to the closed track does NOT reset the 14-day clock).
  - **Decisions (grilled 2026-06-28):**
    - **Package, not copy:** `fuchsbau` becomes a Flutter package at its repo root
      (github.com/Kemenor/fuchsbau), design-system scope only (theme builder, `FuchsbauColors`,
      status-color `ThemeExtension`, `FuchsbauFont` + bundled OFL fonts, icon defaults). Reuse
      checkfuchs's proven **3-seed-graft** ColorScheme (one `fromSeed` per hue, graft indigo→
      secondary / emerald→tertiary; NOT single-seed). Backup-helper extraction explicitly OUT.
    - **Dependency/CI:** knabberfuchs uses a **git-dep on fuchsbau (pinned ref) +
      `dependency_overrides` → local `../fuchsbau` path** — local live-edit + green CI + pinned
      production builds.
    - **Status colours (ethos: status is information, never punishment; red = destruction
      only):** in-range → **emerald**, off-target **over AND under** → **amber**, `none` →
      `outline`. No red in status (frees red for Delete). Direction stays legible via the bar +
      number. One-file change: `core/status_color.dart` + two `day_screen.dart` `error` sites.
    - **Typography:** bundle Figtree (default) + Atkinson Hyperlegible + OpenDyslexic + System;
      package owns plumbing (incl. tabular figures); knabberfuchs adds one Settings "Typeface"
      `RadioGroup` + `fontProvider` (mirrors the Language picker). Deferrable tail.
    - **Icons:** Material Symbols Rounded via `material_symbols_icons`; mechanical
      `Icons.*`→`Symbols.*` sweep + rounded defaults via `IconThemeData`. Deferrable tail.
    - **App icon:** keep the (tangerine) fox; recolor the adaptive background off the accidental
      green to **indigo or emerald** (decided on device), regen Android + iOS + docs favicon/fox.
    - **Execution:** branch `redesign/fuchsbau`, one self-contained commit per phase, each gated
      on goldens (diffs read, not blind-accepted) + a whole-branch emulator look. Single version
      bump + 4-locale changelog at the end → merge → AAB to closed track → real-device check →
      submit production.
    - **Store/landing:** regenerate screenshots from the current (expanded) seed fixture +
      `integration_test/screenshots_test.dart` harness (4 locales, Android+iOS); recolor
      `featureGraphic.png` by hand; refresh `docs/` accent CSS + screenshots — after visual freeze.
  - **Build sequence:** P1 package skeleton + git-dep/override wiring (no visual change) → P2
    palette swap (green seed gone) → P3 status colours → P4 shape/spacing/elevation + components
    → P5 icons → P6 fonts + picker → P7 icon retheme → P8 store/landing → P9 ship → P10 checkfuchs
    migrates onto the package. Regenerate the 29 goldens per visual phase.

## Phase 5 design — Offline OFF regional packs (planned 2026-06-17)

**Decisions:** build on **GitHub Actions** → host on **Hugging Face** dataset; **per-country**
regions (download any combination); **full download first, deltas as a fast-follow**; **lean
packs** (only products with a name + energy). **License:** OFF data is **ODbL** → attribute
Open Food Facts and keep packs open (we do); show an attribution line on the regions screen.

**Build pipeline (GitHub Actions, weekly cron):**
1. DuckDB reads OFF `food.parquet` directly from Hugging Face over HTTP (httpfs + predicate
   pushdown — no full 5.74 GB download).
2. Per country: filter `countries_tags` contains the country; require a name +
   `energy-kcal_100g`; project barcode, names (region languages + generic), brand,
   serving/quantity, kcal + protein/carb/fat/fiber/sugar/sat-fat/sodium/salt, nutriscore.
3. Emit `region.sqlite` — a `products` table (barcode PK) + an **FTS5** index on name/brand
   for fast search; gzip it (decompress on-device via dart:io, no extra dep).
4. Compute the **delta** vs the previous version (upserted + deleted barcodes) — fast-follow.
5. sha256 every artifact; write `manifest.json` (each region → latest version, full
   URL/size/sha256, deltas list, product count, updated-at).
6. Upload artifacts + manifest to the HF dataset; retain ~12 weeks of deltas.
   Layout: `manifest.json`; `packs/<cc>/v<N>/region.sqlite.gz`; `packs/<cc>/deltas/vN-vN+1.gz`.
   Generate for all countries above a product threshold (e.g. ≥5k); manifest lists them.

**App side:**
- **Offline regions** screen (Settings): list from the manifest; download / update / remove;
  multiple regions; storage usage; OFF attribution.
- Each downloaded region = a read-only `sqlite3` file (not drift); open handles tracked.
- **Search:** main drift DB (custom / USDA / scan-cache) ∪ each region pack (FTS5 MATCH) →
  dedup by barcode → existing simpler-first ranking. **Barcode lookup:** main cache → region
  packs (barcode PK) → OFF live API.
- **Update:** apply sequential deltas to the region file; if older than retention, full
  re-download. Verify sha256. Dep to add: `crypto`.

**Phasing:** 5a ✅ DONE — pipeline (DuckDB+FTS5) + manifest + HF upload (live:
`Knabberfuchs/offline-packs`, CH/DE/AT/FR) + GitHub Actions; app: Settings → Offline
regions (download/verify-sha256/decompress/remove), FTS5 search merged into local search,
barcode lookup, ODbL attribution. Verified on emulator (downloaded CH, searched "Rivella",
logged it). Phase 10 later expanded this to all 106 countries.

**5b (per-region deltas): PARKED INDEFINITELY (decision 2026-06-19).** Not worth the
complexity — packs are tiny: median **0.24 MB**, 87% under 2 MB, 100/106 under 10 MB; only
France (60 MB) and US (59 MB) are large, and only re-syncs of *those* would benefit. Full
re-download already works at these sizes. Instead, fix update-detection to be content-based
(see below) so unchanged packs don't show "update available".

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
- 💡 **Region-aware offline nudge (idea):** when a scanned barcode resolves via the OFF
  *online* API, the result's `countries_tags` tell us which country the product is sold
  in. The "Regions" nudge could deep-link straight to that country (open the Offline
  regions screen with the search **pre-filtered** to it), so the user downloads the right
  pack in one tap. Needs: off_api to also return countries_tags, map tag→region code, and
  an optional initial-query param on OfflineRegionsScreen. Small-to-medium plumbing.

## Prerequisites / open dev details
- ✅ Toolchain ready: Flutter 3.44.4 / Dart 3.12.2 / JDK 21 / Android SDK 35+36 in the
  `flutter` distrobox; debug APK builds. (CI pins Flutter 3.44.4 in `ios.yml` + `test.yml`,
  kept in lockstep; goldens are regenerated on a Flutter bump — see `test/flutter_test_config.dart`.)
- No runtime API keys needed (OFF keyless; USDA bundled). Optional user-supplied USDA key
  is a future power-user setting only.
- Default locale → device locale (German for CH); OFF returns multilingual names.
- App name/branding: TBD (placeholder until you pick one).
