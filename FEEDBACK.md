# Knabberfuchs — Tester Feedback & Implementation Tracking

Running log of feedback from closed testing, with implementation notes and status.
Same conventions as `PLAN.md`: `-` bullets led by an emoji status marker
(✅ done · 🔨 in progress · ⏳ queued · 📝 needs decision · 🚫 deferred) + a **bold title**, with
file/path references. Product backlog & architecture stay in `PLAN.md`; this file
tracks tester-driven changes specifically.

## Feedback queue (opened 2026-06-24)

- ✅ **Servings at recipe creation from an ingredient list** — DONE 2026-07-06.
  The OCR review screen (`ui/recipes/ocr_meal_screen.dart`) previously saved
  recipes hardcoded to 1 serving; setting the real count meant reopening the
  saved recipe in the editor. A servings field now sits next to the meal-name
  field (same numeric input as the recipe editor, `recipeServingsField` label;
  blank/invalid falls back to 1).

- ✅ **Meal-type change no longer overwrites a custom meal name** — DONE
  2026-07-06. The edit-meal sheet treated only names edited *inside the sheet*
  as user-chosen, so reclassifying (e.g. Lunch → Dinner) rewrote a
  previously customized name with the auto "MealType HH:MM" pattern. The sheet
  now also treats any stored name that doesn't match the auto pattern as
  custom and never rewrites it (`day_screen.dart` `_EditMealSheet`).

- ✅ **Meal-header nutrient line: bold labels, no trailing unit** — DONE
  2026-07-06. `P 32 · KH 45 · F 8 g` read as if only fat had a unit; the line
  is now unitless with bold metric letters (**P** 32 · **KH** 45 · **F** 8) —
  `nutrientSpans` replaces `nutrientLine` (`core/metric_labels.dart`), also
  used by the meal-detail ingredient rows. DESIGN_SYSTEM §13 updated.

- ✅ **Collapsible meals in day overview** — DONE 2026-06-24. Each meal group has a
  chevron toggle; collapsed groups keep their subtotal kcal visible. Let testers
  expand/collapse each meal group on the day screen to reduce scrolling on busy days.
  - Today meal groups render **flat**: `_DayBody` builds a `ListView` of
    `_SummaryCard` → one `_GroupSection` per group → loose `_EntryTile`s
    (`lib/ui/day/day_screen.dart:229`, `:235-261`). `_GroupSection`
    (`:397`) is a `ConsumerWidget` that unconditionally renders
    `for (final e in group.items) _EntryTile(...)` (`:502`) — no per-group
    expand state exists.
  - **Approach:** give each group an expanded/collapsed flag and conditionally
    render the entries loop. Header row (`:413-505`) gets a chevron/affordance;
    keep the subtotal-kcal always visible so a collapsed meal still shows its total.
  - **State (decided):** **session-only** — a simple provider keyed by group id,
    no schema change. Groups are ad-hoc (`GroupView`), not fixed slots, so key by
    group id; state resets on app restart / date change.
  - **UI:** confirm against `DESIGN_SYSTEM.md`; collapsing rows is a new pattern,
    so update that doc if we add a reusable expand/collapse affordance.

- ✅ **Portion type g → ml when creating a custom food** — DONE 2026-06-24. Added a
  g/ml `SegmentedButton` next to the serving field; choosing ml relabels the
  serving + "per 100" header and stores a 1 g/ml density so the log sheet measures
  the food in ml. When adding a custom food, the serving size and "per 100" basis
  were hardcoded to grams. Testers want to define liquids in ml (e.g. a drink:
  serving 250 ml, nutrition per 100 ml).
  - **Where:** `lib/ui/food/food_form_screen.dart`. Serving field is
    `_numField(_serving, l10n.addServingSize, 'g')` (`:227`) — unit hardcoded
    `'g'`. The nutrition block header is `addNutritionPer100` (`:231`), which
    implies per-100**g**. Both need to follow a chosen base unit.
  - **Infra that already exists:** `Foods` table has `densityGPerMl`
    (`lib/data/db/tables.dart:35`), `servingG` (`:30`) and
    `servingLabel` (`:31`); `AmountUnit` + `toGrams(amount, {density})`
    live in `lib/domain/units.dart`. Storage stays per-100**g** /
    grams (don't change the entry math) — ml is an authoring/display convenience
    backed by density.
  - **Approach:** add a base-unit toggle (g / ml) to the form. When ml is chosen,
    label the serving field and the "per 100" header as ml, and set
    `densityGPerMl` (default `1.0` g/ml, editable for non-water liquids) so the
    ml-entered values convert to the stored per-100g basis. Persist via
    `createFood(...)` (`:157-169`, named args). Then the log sheet's existing
    ml default (`log_food_sheet.dart:171`) kicks in for that food automatically.
  - **📝 decision:** start with a simple g/ml toggle assuming density `1.0`
    (good enough for water-like drinks), or expose an editable density field up
    front? Leaning: toggle now, editable density as a follow-up.
  - Cross-ref `PLAN.md` open item "Per-food density / piece weights" (volume→grams
    still assumes ~1 g/ml; no per-piece weights yet).

- ✅ **Reorder nutrient fields to match Swiss/EU label order** — DONE 2026-06-24.
  Fields now read Energy → Fat → Saturates → Carbohydrate → Sugars → Fibre →
  Protein → Salt in `food_form_screen.dart`. Add Food fields should follow the
  order printed on real product labels so manual entry / OCR cross-checking reads
  top-to-bottom.
  - **Verified order (Swiss "Big 7", EU 1169/2011 mandatory):** Energie → Fett →
    gesättigte Fettsäuren → Kohlenhydrate → davon Zucker → Eiweiss → Salz. Fibre
    (Ballaststoffe) is voluntary and sits after the carbohydrate/sugar block,
    before protein. → Target app order: **Energy → Fat → Saturates → Carbohydrate
    → Sugars → Fibre → Protein → Salt**.
  - **Current order** (`lib/ui/food/food_form_screen.dart:250-264`,
    widget build order of `_numField(...)` calls): Energy → Protein → Carbohydrate
    → Fat → Sugars → Saturates → Fibre → Salt.
  - **Approach:** reorder the `_numField` lines only. The OCR auto-fill `set(...)`
    calls (`:118-125`) and `createFood(...)` (`:157-169`) use named args,
    so reordering the UI is self-contained — no model/logic change. Optionally
    indent the "of which" sub-nutrients (saturates under fat, sugars under carbs)
    to mirror label nesting.
  - Low-risk, self-contained — good first one to ship.

### Sources (label-order verification)

- [Nährwertkennzeichnung und Nährwerttabelle Schweiz — Santina GmbH](https://santina-gmbh.ch/naehrwertkennzeichnung-bei-lebensmitteln/)
- [Nährwertkennzeichnung — Lebensmittelverband Deutschland](https://www.lebensmittelverband.de/de/lebensmittel/kennzeichnung/naehrwert)
- [Die Nährwerttabelle laut LMIV — Thomas Markel](https://thomasmarkel.de/naehrwerttabelle-laut-lmiv-2-2/)

## Feedback (2026-06-27)

- ✅ **Per-macro goals, not just calories** — DONE 2026-06-27. Testers wanted to track
  protein / carbs / fat against targets, not only kcal. Added optional **per-weekday min/max
  targets** for protein, carbs and fat (full parity with the calorie target), shown as
  glanceable bars on the Day card and as a swappable metric (kcal · P · C · F) on the Trends
  chart. Settings → Targets sub-screen. (Schema v11; commits `cb45c53`…`7579833`.)

- ✅ **Make "Contribute to Open Food Facts" obvious** — DONE 2026-06-27. The contribute link
  was buried at the bottom of the Add-food form. Moved it to a prominent card at the **top**
  (when a barcode is present), deep-linking to the product page with a short note on why
  contributing helps the shared database. (commit `9f3f720`.)

- ✅ **Barcode scanning sometimes misses** — DONE 2026-06-27. Hardened the scanner: restricted
  to the grocery symbologies, higher camera resolution, a **torch toggle** for low light, and
  **consensus capture** (accept a code only once ≥2 of N frames agree) to reject single bad
  reads. (commit `73db76b`.)

- ✅ **Smaller fixes from testing** — DONE late June. Tapping an external Open Food Facts link
  now returns cleanly to the app on Android Back (`9623c01`); the amount field in the log sheet
  is pre-selected on focus so you can overtype it immediately (`e224df4`).

## Feedback (2026-06-28)

- ✅ **AI photo estimate is sometimes off — let me add context** — DONE 2026-06-28. A tester
  noted the photo guess can misread an ambiguous dish. Added an **optional text hint**: after
  picking a photo (cloud/Gemini path), a sheet lets you add a short description
  (e.g. "homemade lasagne, large portion") sent with the image to tighten the estimate.
  Optional and skippable; the keyless on-device path is unchanged. (commits `4fc0b92`, `595fb0a`.)

- ✅ **On-device recognition weak on drinks / portion sizes** — DONE 2026-06-28. Improved the
  recognised-label → calorie mapping (realistic per-category portion sizes instead of a flat
  default, and an estimate even when the local catalog has no match), and added a nudge to set
  up the free Gemini key for sharper results — including drinks the on-device model can't
  recognise. (commit `a7eb950`.) Note: a fully-offline beverage model isn't feasible under a
  permissive licence today, so drinks route to the optional cloud path by design.

- ✅ **App felt generic; some surfaces hard to read** — DONE 2026-06-28. Acting on review
  feedback, reskinned the whole app onto a consistent design system:
  - a warmer, distinct **colour palette** (the old green was an accidental default);
  - **cards that stand out** from the background (white cards + hairline borders) — fixing
    low-contrast meal lists and a hero card that didn't read as the summary;
  - **calmer status colours** — no alarming red; under / in-range / over read as focus /
    achieved / gentle nudge;
  - friendlier **typography** with an **accessibility typeface picker** (incl. low-vision
    Atkinson Hyperlegible and OpenDyslexic fonts) and rounded icons;
  - first-class **dark mode**, including a fix for dark-mode header icons that rendered
    near-invisible. (Redesign commit series `896fb1b`…`d13ef7a`.)

## Product questions (2026-07-02)

- ✅ **Remove on-device photo recognition entirely?** — DECIDED 2026-07-03,
  BUILT 2026-07-04 (`feature/feedback-0703`, together with the Describe-meal
  flow as planned). Feedback on the local model was uniformly negative (weak on
  drinks/portions even after the a7eb950 improvements), and it was already dropped
  from the store screenshot set (2026-07-02). **Decision: option (b) — remove the
  local image model entirely.** Photo estimate becomes Gemini-only; keyless users
  tapping it get the existing key nudge. Drops the 21 MB bundled model
  (`food_classifier.dart` + assets, APK size win) and ends the expectation
  management. The keyless-ethos tension is answered by the **local catalog
  matcher** for typed input instead (see the text-only AI guess item, 2026-07-03):
  keyless users keep an offline path whose numbers come from real food data, not
  a weak model.
  - **Small on-device text LLM was evaluated and rejected** (researched
    2026-07-03): smallest viable text models via AI Edge/flutter_gemma are
    Gemma 3 1B (~529 MB int4, wants ~4 GB RAM) — 25× the image model we're
    removing — and the tiny tier (Gemma 3 270M / SmolLM 135M) only works
    fine-tuned, i.e. a standing ML project (training data, 4-locale evals,
    updates) with hallucinated-numbers risk. The catalog matcher beats both on
    size, determinism and data quality for this task.
  - **Ships together with the "Describe meal" feature** so the capture sheet and
    its copy are reworked once and the changelog tells one story: model out,
    text path in.

## Feedback (2026-07-01)

- ✅ **Edit a custom food** — DONE 2026-07-02. Custom-food tiles in the search list get a
  ⋮ overflow with **Edit** (decided over the tester's Settings suggestion — Settings is a
  poor discovery path for a per-food action), opening the food form pre-filled
  (`FoodFormScreen(initial:)`, incl. the g/ml basis) and saving in place via
  `FoodRepository.updateFood` → `updateFoodById` (keyed by id, so barcode edits update the
  row instead of upserting a duplicate). Diary entries keep their logged snapshots by
  design. Tests in `test/food_update_test.dart`.
  - Follow-up same day: the ⋮ menu also gained **Delete** (confirm dialog, recipes-style).
    Safe by schema: entries `foodId` is set-null + snapshots, recipe items snapshot
    everything, OCR mappings cascade. Swipe actions were considered and rejected — the
    search list mixes sources, so only custom rows would respond, breaking the uniform
    swipe grammar of the diary/recipes lists; a future custom-only "My foods" screen
    would be the right home for swipes.

- ✅ **Make tracked nutrients switchable, starting with fiber** — BUILT 2026-07-02
  (on main, ships with the Phase 16 release). Implemented as the tester's bigger ask:
  a **Tracked nutrients** chip row atop Settings → Targets toggles fiber, saturated
  fat, sugar and salt (and P/C/F; kcal fixed). Each enabled nutrient gets the full
  min/max default + per-weekday target block, a Day-card bar (rows wrap by 3), and a
  Trends chip. Data: schema v12 + snapshot micros write-through + best-effort history
  backfill — details in **PLAN.md Phase 15**.

- ✅ **Split fat into saturated vs. unsaturated in the overview/trends** — BUILT
  2026-07-02 as part of the same mechanism: saturated fat is one of the configurable
  tracked nutrients (enable its chip → targets, Day-card bar, Trends series).

- 🚫 **Daily hint/recommendation for targets** — DEFERRED indefinitely 2026-07-02.
  The tester flagged the nagging risk themselves; static "most adults aim for ~X"
  copy is reference info with real drawbacks: dietary reference values differ across
  our four-country audience (invites "says who?"), and it costs 4-locale l10n surface
  for a feature that may read as pushy. Revisit only if testers ask again.

- ✅ **Health Connect: full resync button** — DONE 2026-07-02 (first pass: global
  resync only; per-day clear+resync deferred until someone actually needs it — it
  requires a range-picker UI). Settings → Health section gains **"Resync all days"**
  (visible when sync is on): `HealthService.resyncAll` wipes everything the app ever
  wrote (`deleteAll`) and re-pushes the whole diary, so days whose entries were since
  edited or deleted end up matching exactly — the fix for "a wrong number already
  synced".

- ✅ **Read calories burned from Health Connect (adjust the daily budget by exercise)**
  — BUILT 2026-07-02 (ships with the Phase 15 release; design + decisions in
  **PLAN.md Phase 16**). Opt-in "Adjust budget by activity" switch (separate read
  grant): the day's active burn shifts the whole kcal band — remaining/over, bar and
  status move with it, explained by a "⚡ +N kcal from activity" line. Active-only
  add-on (no TDEE/BMR double-counting); Trends notes that its band stays static.
  Original research notes kept below. A tester sent a screenshot of Health Connect's Android developer
  docs listing three record types: `ActiveCaloriesBurnedRecord` (energy burned by
  workouts/activity, excludes BMR), `TotalCaloriesBurnedRecord` (active + BMR, i.e.
  TDEE for the window), and `BasalMetabolicRateRecord` (resting energy cost as a
  `rateKcalPerDay` power rating).
  - **Why these numbers:** today `HealthService` is **write-only** — it only pushes
    logged nutrition to Health Connect and never reads anything back
    (`lib/data/health/health_service.dart:8`, `_types` only covers
    `NUTRITION`/dietary-* at `:24-31`, no read permissions requested). The kcal target
    is a static min/max the user sets once (`TargetMetric.kcal`,
    `lib/ui/day/day_screen.dart:294`; `Targets` table, `lib/data/db/tables.dart:121-124`)
    — it doesn't move with how much the user actually burned that day. Reading these
    three record types is the standard way calorie-counting apps (MyFitnessPal, Lose
    It, Cronometer) do **"eat back your exercise calories"**: a smartwatch/fitness app
    writes active-energy/TDEE/BMR into Health Connect over the day, and the tracker
    adds that to (or replaces) the static target so "remaining" reflects actual burn,
    not just a fixed budget.
  - The `health` package (pubspec.yaml:55, v13.3.1) already exposes the matching Dart
    types (`HealthDataType.ACTIVE_ENERGY_BURNED`, `TOTAL_CALORIES_BURNED`,
    `BASAL_ENERGY_BURNED`) — no new dependency needed, just read permissions + a query.
  - **📝 decision:** which record to key off (active-only add-on vs. full TDEE
    replacing BMR-based static target), and whether this is opt-in (separate toggle
    from the existing write-sync switch, since it's a new read-permission grant) or
    folds into the current Health Connect setting.

- ✅ **Merge two meal groups into one** — DONE 2026-07-02. Decided for the overflow
  entry over drag-and-drop (more discoverable, matches the existing ⋮ conventions):
  the per-meal menu gains **"Merge into another meal"**, opening a picker sheet of the
  day's other groups (`lib/ui/day/merge_meal_sheet.dart`, each with its subtotal kcal
  so two same-named "Snack" groups stay distinguishable). `DiaryRepository.mergeGroups`
  is the inverse of split: entries move to the end of the target (adopting its day and
  meal type), then the emptied source group is deleted. Tests in
  `test/diary_mutations_test.dart`.

## Feedback (2026-08-27)

- ✅ **AI failures now name their cause** — DONE 2026-08-27. A tester (Leonardo,
  German, closed testing) pasted a Gemini key, got "Gemini nicht erreichbar" on
  every AI action, and separately saw a **404** in Google AI Studio. The app was
  not at fault for the 404 — both model ids we ship (`gemini-2.5-flash`,
  `gemini-3.5-flash`) are current and free-tier-listed — but the app **could not
  tell him that**: `GeminiService` turned every non-200 into `continue` → `null`,
  and both capture flows rendered the single string `geminiFailed`
  ("couldn't reach Gemini"). A key/project problem was therefore reported as a
  network problem, which is why it became a support mail instead of a two-tap fix.
  - **Cause is now carried out of the service.** `GeminiFailure` (invalidKey ·
    noAccess · modelUnavailable · quota · busy · network · notFood · unknown) +
    `classifyGeminiError` + a `GeminiOutcome<T>` return
    (`data/ml/gemini_service.dart`). Google reports a bad key as **400
    `API_KEY_INVALID`**, not 401, so the body is classified, not just the status.
  - **Fail fast on a rejected key:** invalidKey/noAccess short-circuit the model
    chain — the fallback would be rejected identically and only re-uploads the
    photo. 404 still falls through to `gemini-2.5-flash`, which is the point of
    the chain. When the two models fail differently, the **most actionable**
    cause is reported (`_failureRank`).
  - **`is_food: false` is no longer an error.** A photo of a cat said "couldn't
    reach Gemini"; it now says Gemini recognised no food (`geminiSaidNotFood`).
  - **Settings → "Test key"** (`ui/settings/settings_screen.dart`,
    `GeminiService.testKey`) checks the key against the selected model on the
    spot and names the problem at the field. This is the fix that should stop
    this class of mail.
  - Messages come from one place (`core/gemini_error.dart`), mirrored into
    en/de/fr/it.

- ✅ **Error toast was drawn under the sheet that opened next** — DONE
  2026-08-27. Reported alongside the above: "when we get an error the toast is
  under the modal that pops up after". `recognize_food_flow.dart` showed the
  snackbar and then immediately opened the Quick add **bottom sheet**, which is a
  route over the Scaffold — both live at the bottom, so the message was never
  read. `describe_meal_flow.dart` had the same shape, plus two snackbars queued
  back-to-back when the local matcher also came up empty.
  - Fixable causes are promoted to a **dialog before** the sheet (with a route
    into Settings); transient ones stay a snackbar shown **after** the sheet
    closes / after the review screen is pushed. Describe-meal now shows exactly
    one message. DESIGN_SYSTEM §10 pins both rules.

- ✅ **Two stale strings corrected** — DONE 2026-08-27. `aiModelNote` promised a
  fallback "then on-device" in all four locales; the on-device classifier was
  removed 2026-07-03. And `aiKeyDesc` warned that Google may use free-tier data
  to improve its models — but Google's API terms say that for the **EEA,
  Switzerland and the UK** the paid-service data terms apply to free use too,
  i.e. the opposite, for most of our users. Both rewritten in en/de/fr/it.

- ✅ **EEA/CH/UK "Paid Services" clause — decided 2026-08-30.** Read in full and
  resolved: keep the feature, stop soliciting. The key field and the AI Studio
  link now sit behind an explicit disclosure the user has to accept, consent is
  versioned and withdrawable, and the capture copy no longer pitches "a free API
  key". GDPR turned out not to be the exposure at all. Full reasoning and the
  accepted residual risk: **PLAN.md → "AI estimates — consent gate & terms
  position"**. Original note: the terms say:
  *"You may use only Paid Services when making API Clients available to users in
  the European Economic Area, Switzerland, or the United Kingdom."* Knabberfuchs
  ships an API Client to exactly those users, even though each user brings their
  own key. Worth reading properly before the next release — it is a compliance
  question, not a bug, and it is not addressed by anything above.
  <https://ai.google.dev/gemini-api/terms>

## Feedback (2026-07-03)

- ✅ **Text-only AI guess (no photo)** — BUILT 2026-07-04
  (`feature/feedback-0703`; grilled 2026-07-03). Estimate a meal from a
  typed description alone ("two slices of rye bread with butter and honey, large
  coffee with milk") — for meals with no photo opportunity: already eaten,
  restaurant courses, or anything a camera can't capture well.
  - **Most of the plumbing exists:** `GeminiService.recognizeFood`
    (`lib/data/ml/gemini_service.dart:75`) already sends a prompt + image and
    parses a structured name/kcal/portion result, and the photo path already
    carries an optional user hint (`buildGeminiPrompt`, `:19-27`). A text-only
    variant is the same call minus the image part, with a prompt built around the
    description as the primary signal instead of a refinement.
  - **Cloud-only by nature:** the on-device classifier is image-in
    (`lib/data/ml/food_classifier.dart`), so text-only rides the optional Gemini
    key exactly like the existing cloud path — keyless users get the existing
    key nudge, keyless-by-default ethos untouched.
  - **Logging:** result lands as a snapshot entry (`logSnapshot`), same as the
    photo guess — no catalog row, no barcode.
  - **Decisions (grilled 2026-07-03):**
    - **Entry point:** 4th tile in the ⚡ capture sheet (Quick add · Scan a dish
      · From list · **Describe meal**) — `_showCaptureMenu`,
      `lib/ui/day/day_screen.dart:134`. No extra path inside the photo flow.
    - **Keyless users:** tile stays visible; tapping without a key shows the
      existing Gemini-key nudge (photo-flow pattern).
    - **Result shape: itemized.** The prompt asks for per-component estimates
      ("rye bread 120 g, butter 15 g, …") logged as **one meal group with an
      entry per component** — matches the diary model; a wrong part is
      individually correctable. (New prompt variant + list parsing; the photo
      flow's single-guess shape is unchanged.)
    - **Input UI:** adapt `_GeminiHintSheet` (`recognize_food_flow.dart:184`)
      into an image-less mode — field required, example-description placeholder,
      button = Estimate. One widget, two modes. l10n ×4.
    - **Keyless fallback: local catalog matcher** (grilled 2026-07-03, together
      with the local-model removal above): without a Gemini key, the same
      "Describe meal" input feeds the OCR-ingredient pipeline instead — parse
      lines/quantities → `searchFoodsLocal` (synonyms + localized names +
      `OcrMappings` memory) → per-line confirm pickers → logged as a group.
      Deterministic, offline, 0 MB, real nutrition data. The key nudge then
      up-sells the AI variant ("sharper, handles free-form descriptions")
      rather than gating the whole tile.

- ✅ **Per-meal nutrition breakdown** — BUILT 2026-07-04
  (`feature/feedback-0703`; grilled 2026-07-03). "How much protein was
  breakfast?" currently requires mental math over the entry tiles — the group
  header shows only its kcal subtotal.
  - **Data is free:** `GroupView.subtotal` is already a full `Nutrition`
    (`lib/domain/day_summary.dart:38`); the header just renders only its kcal
    (`'${kcalStr(group.subtotal.kcal)} kcal'`, `lib/ui/day/day_screen.dart:559`),
    and each `EntryView.nutrition` is complete too (`:911` shows kcal only).
    No schema/provider work — purely a display surface.
  - **Leading option — meal detail page:** tap a meal group → a screen with the
    group's full stats (every enabled tracked nutrient, Phase 15 set — not
    hardcoded P/C/F) plus each ingredient with its own stats. Keeps the day list
    exactly as compact as today (the header already carries chevron/⋮/+, and a
    macro line per group would double its height), gives the full nutrient set
    room, and has a design precedent: the recipe detail screen's
    `_NutritionCard` + per-item list (`lib/ui/recipes/recipe_detail_screen.dart:201`).
    Existing per-entry actions (edit/delete) could ride along, but v1 can be
    read-only.
  - **Decisions (grilled 2026-07-03):**
    - **Detail page:** opened via a "Meal details" entry in the group's existing
      ⋮ menu (discoverable, matches conventions) **and** tapping the kcal
      subtotal as the fast path.
    - **v1 is read-only:** meal totals per enabled nutrient + ingredient list
      with per-entry stats; editing stays on the Day screen. l10n ×4.
    - **Header subtotal line: IN after all** — initially deferred, then a tester
      specifically asked for the enabled nutrients in the meal header
      (2026-07-03, second grill):
      - **Content:** plain subtotals of the enabled tracked-nutrient set
        (`P 32 · C 45 · F 8 g`) — no %-of-target math, no hardcoded P/C/F.
      - **Toggleable:** opt-in switch in **Settings** (near the display
        options), "Show nutrients per meal"; off by default.
      - **Visibility:** part of the header, so it shows expanded **and**
        collapsed — consistent with the always-visible kcal subtotal.

- ✅ **Hidden debug menu (developer/tester tool)** — BUILT 2026-07-04
  (`feature/feedback-0703`; grilled 2026-07-03). A Debug
  section in Settings, unlocked by an easter-egg gesture: **long-press the app
  name in the About dialog** (`_AboutTile` → `showAboutDialog`,
  `lib/ui/settings/settings_screen.dart:395-414`) to flip a `debugMenu` settings
  key; the section then renders at the bottom of Settings until toggled off.
  Not a user feature — no store-listing mention; English-only copy is acceptable
  (breaks the l10n rule deliberately, DEBUG-labelled, off by default).
  - **Clear all data:** wipe the DB (entries, groups, recipes, targets, custom
    foods, settings, OCR mappings, packs) back to first-run. Destructive →
    confirm dialog (Cancel → Confirm, red allowed here: destruction-only rule).
  - **Load test data:** seed a realistic multi-week demo diary (varied meals,
    groups, a couple of recipes, custom foods, targets, some micros-rich and
    micros-less rows) — makes Trends, backfills and goldens/screenshots
    reviewable on an emulator without hand-logging. Could share its fixture with
    the `integration_test/screenshots_test.dart` harness so demo data stays in
    one place.
  - **Decisions (grilled 2026-07-03):**
    - **Clear-all wipes the health store too** when the sync toggle was on
      (`HealthService.deleteAll`) — a true factory reset, no orphaned records
      that a reinstall would double on resync.
    - **All four extra tools ship in v1:**
      - **DB inspector + export:** schema version, per-table row counts, DB
        file size, plus share-sheet export of the raw .sqlite — the desk
        debugging kit for tester reports.
      - **Fake activity kcal:** inject a pretend active-energy value so the
        Phase 16 band shift is testable without a wearable/HC writer — unblocks
        the open H6/TestFlight verification.
      - **Shift diary N days back:** age the whole diary to exercise Trends
        windows, weekday targets and day-navigation edges.
      - **Health sync status:** enabled flags, permission probe result, last
        `syncDay` outcome — surfaces the errors sync swallows by design.
    - **Graduation queued:** a user-facing, localized **"Delete all my data"**
      in Settings is a future item (privacy-friendly, fits the serverless
      ethos); the debug entry doubles as its prototype.
