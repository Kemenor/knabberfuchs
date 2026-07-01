# Knabberfuchs — Tester Feedback & Implementation Tracking

Running log of feedback from closed testing, with implementation notes and status.
Same conventions as `PLAN.md`: `-` bullets led by an emoji status marker
(✅ done · 🔨 in progress · ⏳ queued · 📝 needs decision) + a **bold title**, with
file/path references. Product backlog & architecture stay in `PLAN.md`; this file
tracks tester-driven changes specifically.

## Feedback queue (opened 2026-06-24)

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

## Feedback (2026-07-01)

- 📝 **Edit a custom food** — no decision yet. Once a custom food is created there's no
  way to go back and fix/update it — only create-new exists today.
  - `lib/ui/food/food_form_screen.dart:24-30` (`FoodFormScreen` ctor takes only `barcode`,
    no edit mode), `lib/data/repositories/food_repository.dart:154` (`createFood(...)`
    only, no `updateFood`), `lib/ui/food/food_search_list.dart:208,234-246` (tile tap
    picks/logs the food, no edit affordance).
  - **📝 decision:** where does edit live — a long-press/overflow menu on the food list
    tile, or tucked under Settings as the tester suggested? Leaning: overflow menu on the
    food tile (consistent with `PopupMenuButton` convention in `DESIGN_SYSTEM.md`), since
    Settings is a poor discovery path for a per-food action.

- 📝 **Make tracked nutrients switchable, starting with fiber** — no decision yet. Fiber
  is captured per-food (`fiber100`, `lib/data/db/tables.dart:41`) but isn't part of the
  target/goals system, so it never surfaces as something a user can track against.
  - `lib/domain/day_summary.dart:56` — `enum TargetMetric { kcal, protein, carb, fat }`,
    no fiber. `lib/data/db/tables.dart:121-124` (Targets table) has no fiber columns.
    `lib/ui/settings/targets_screen.dart:66-104` wires protein/carb/fat rows only.
  - Tester's framing: rather than just bolting on fiber, make the whole target list
    **user-configurable** (pick which nutrients you care about tracking), not a fixed
    kcal/P/C/F set.
  - **📝 decision:** minimal fix (add fiber as a 5th fixed `TargetMetric`) vs. the bigger
    ask (a settings toggle list for which nutrients get a target row at all). Latter is
    more work but is what was actually requested and generalizes to future nutrients.

- 📝 **Split fat into saturated vs. unsaturated in the overview/trends** — no decision
  yet. Saturated fat is captured per-food (`satFat100`, `tables.dart:42`) but only folds
  into the total fat number downstream — never aggregated/shown separately.
  - `lib/ui/day/day_screen.dart:396` (`_macro(context, TargetMetric.fat, ...)` — one
    aggregate number), `:618` (`fat100: e.entry.sFat100` aggregation point),
    `lib/domain/day_summary.dart:18`. `lib/ui/trends/trends_screen.dart` reuses the same
    `TargetMetric` enum, so no saturates series exists for the chart either.
  - Same shape as the fiber ask: needs `TargetMetric` (or a parallel concept) extended to
    carry a saturates split, plus Day-card and Trends UI to show it.

- 📝 **Daily hint/recommendation for targets** — no decision yet. Tester flagged the
  nagging risk themselves — a proactive daily recommendation prompt could feel pushy, so
  lean towards a passive **hint in the Targets settings screen** instead (e.g. "most
  adults aim for ~X g protein/day") rather than a runtime nudge.
  - `lib/ui/settings/targets_screen.dart:16` (`TargetsScreen`), per-metric blocks at
    `:64-104`, `_MetricTargets`/`_TargetRow` widgets at `:117,197` — a subtitle/hint text
    would slot in per metric block or once near the top of the screen.
  - **📝 decision:** static hint copy per metric vs. no hint at all (defer). No agreement
    yet on wording or whether it's worth the l10n surface (×4 locales) for a "maybe
    nagging" feature.

- 📝 **Health Connect: full resync / clear-data-for-days button** — no decision yet.
  Sync today is automatic push-only with no manual control beyond the on/off switch.
  - `lib/data/health/health_service.dart:8` ("write-only... no-op until enabled"),
    trigger is `ref.listen(selectedDayEntriesProvider, ...)` in
    `lib/ui/day/day_screen.dart:59-65` (fires on entry changes only — no manual trigger).
    `lib/ui/settings/settings_screen.dart:112-127` — only a `SwitchListTile` exists.
    `deleteAll()` (`health_service.dart:111-121`) wipes everything and is only invoked
    when the feature is toggled off — no per-day granularity.
  - Tester wants: a **"resync"/"full sync" button** to push all days again, plus a way to
    **clear synced data for specific days** and re-push them (useful after fixing a
    logging mistake that already synced wrong numbers to Health Connect).
  - **📝 decision:** scope of a first pass — global "resync everything" button only, or
    also per-day clear+resync (needs a day picker / range picker UI)?

- 📝 **Read calories burned from Health Connect (adjust the daily budget by exercise)**
  — no decision yet. A tester sent a screenshot of Health Connect's Android developer
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

- 📝 **Merge two meal groups into one** — no decision yet. There's already a per-meal
  overflow menu with scale and **split** actions, but no inverse "merge" action.
  - `lib/ui/day/day_screen.dart:518-550` — `PopupMenuButton` per meal group with
    `edit` / `scale` (`showScaleMealSheet`, `lib/ui/day/scale_meal_sheet.dart:12`) /
    `split` (`showSplitMealSheet`, `lib/ui/day/split_meal_sheet.dart:14`) / `recipe` /
    `delete`. Groups are ad-hoc (`GroupView`, keyed by `group.id`,
    `lib/ui/day/day_screen.dart:454,462-463`), not fixed slots — a tester can end up
    with e.g. two separate "Snack" groups on the same day and no way to combine them.
  - `deleteEntryGroup` (`lib/data/repositories/diary_repository.dart:134`) already
    removes a group + its entries — a merge would look like: move all entries from
    group B into group A, then delete group B the same way `split` breaks one group's
    entries out into a second (`split_meal_sheet.dart`), just in reverse.
  - **📝 decision:** how does the user pick which two groups to merge — a "merge into…"
    entry in the overflow menu that opens a picker of the day's other groups, or a
    drag-and-drop/long-press gesture on the day list?
