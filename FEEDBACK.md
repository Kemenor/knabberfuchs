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
