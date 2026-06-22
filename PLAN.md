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
    80 tests pass, builds + runs on emulator. Still deferred to the naming question: meal-type
    words (Breakfast/…) + relative date title (Today/Yesterday) — they double as persisted
    auto-name tokens.
  - **11c — Translate.** Fill `app_de.arb` / `app_fr.arb` / `app_it.arb`. Review by a
    native/fluent speaker (the user is Swiss — DE/FR at least) since machine translations
    of UI microcopy are often stilted.
  - **11d — Locale-aware numbers (nice-to-have).** Display/parse decimals per locale
    (German/French use "1,5"). The app already tolerates comma input; this makes
    *display* consistent too (via `intl` NumberFormat). Dates already go through `intl`.
  - **Notes:** big mechanical refactor, low architectural risk; no backend, no schema
    change. The OCR nutrition-label parser already handles DE/FR/IT/EN *input* keys —
    separate from UI i18n but the same languages.

- **Phase 12 — Data localization:** 📋 PLANNED. Localize the *food data*, not just the UI
  (Phase 11). Key asymmetry: **OFF data is already mostly localized** (the pack pipeline
  extracts each product's native "main" name), so the real work is the **English-only USDA
  bundle** (~5,600 generic whole foods — there is no DE/FR/IT USDA).
  - **12a — Translate USDA at build time.** In `tool/build_usda_bundle.dart`, machine-
    translate the names (DeepL/Google) and bundle `name_de` / `name_fr` / `name_it`
    columns into `assets/usda_foods.csv.gz`. One-time build cost; **no runtime API key**.
    Hand-review the **top ~200 common foods** (machine translations of USDA's formal
    taxonomic names are stilted); leave the long tail machine-translated.
  - **12b — Locale-aware food display + search.** Show the name column for the current
    locale (fallback to English); make local search match localized queries (e.g. "Banane"
    → "Bananen, roh"). Localize the produce **synonyms** (`search_query.dart`) too, or
    accept weaker synonym matching in non-English.
  - **12c — OFF region-language preference (refinement, optional).** The pack name is
    currently `coalesce(main, en, de, fr, it)`. Could prefer the *region's* language per
    pack (de-first for the DE pack, etc.) for the few products whose `main` isn't local.
    Mostly already handled — low priority.
  - **Notes:** depends on Phase 11 (locale selection). Build-time only — no keys shipped,
    no runtime cost, asset grows modestly. Scope is small because OFF (the big dataset) is
    already multilingual.

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
- ✅ Toolchain ready: Flutter 3.44.2 / Dart 3.12.2 / JDK 21 / Android SDK 35+36 in the
  `flutter` distrobox; debug APK builds.
- No runtime API keys needed (OFF keyless; USDA bundled). Optional user-supplied USDA key
  is a future power-user setting only.
- Default locale → device locale (German for CH); OFF returns multilingual names.
- App name/branding: TBD (placeholder until you pick one).
