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
