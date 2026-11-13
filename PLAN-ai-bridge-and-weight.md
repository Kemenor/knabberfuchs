# Plan — AI bridge (replacing the Gemini key) and weight tracking

Draft for review (2026-11-13). Once the open questions at the end are decided, the
parts become phases in `PLAN.md`.

Two features, one principle: **knabberfuchs stays keyless and serverless.** Instead of
calling an AI itself, the app works *with* whatever AI app the user already has —
Claude, ChatGPT, the Gemini app — by handing it instructions and taking its answer back
as text. Nothing leaves the phone except what the user chooses to share.

---

## Part A — The AI bridge

### A.1 What we have today

- **Gemini BYOK** (`lib/data/ml/gemini_service.dart` + 8 more files): photo estimate →
  Quick add (editable), and "Describe meal" → itemized estimate that **logs directly
  without review**. Needs a Google key, a consent gate, a model picker, error
  classification for rejected keys — most of the support load in `FEEDBACK.md`.
- **Ingredient-list scan** (`ocr_meal_screen.dart`): OCR → `parseIngredientLines` →
  review screen that auto-matches names the user matched before (`OcrMappings`) →
  "Save as recipe" or "Log to day".
- **Recipe codes** (`CTR1:` = gzip+base64 JSON) via QR or paste. An LLM can't produce
  these (gzip).
- **No incoming share** on either platform (no `ACTION_SEND` filter, no iOS share
  extension).

### A.2 The two answers an AI gives back

| | **List** — "adapt my chili to 600 kcal" | **Estimate** — "what was in this lunch?" (photo / text) |
|---|---|---|
| Items carry | name + amount | name + amount + **estimated nutrition** |
| Nutrition comes from | the user's own foods (remembered matches, search) | the AI's estimate, marked as such |
| Lands in | review screen → recipe or day | review screen → day (or recipe) |
| Replaces | today's retype-from-chat loop | Gemini photo + Describe meal |

Both go through **one review screen** (the generalized ingredient-list screen), so
there is one place where things get checked before they're saved — including estimates,
which today skip review.

### A.3 Format the AI writes

A fenced JSON block with a marker key. LLMs produce JSON reliably, chat apps put a copy
button on code blocks, and the parser can find the block inside any surrounding prose.

```json
{"knabberfuchs": 1, "kind": "meal", "name": "Lunch bowl", "meal": "lunch",
 "items": [
  {"name": "Chicken breast, grilled", "g": 150, "kcal": 248, "protein": 46, "carbs": 0, "fat": 5.4},
  {"name": "Rice, cooked", "g": 180, "kcal": 234, "protein": 4.3, "carbs": 51, "fat": 0.5}
 ]}
```

- `kind`: `meal` (log) or `recipe` (+ `servings`).
- Item amount: `g` or `ml`, or `amount` + `unit` (tbsp, piece, slice… — the existing
  unit vocabulary). Nutrition fields optional and **per item total** (what LLMs think
  in); converted to per-100 g on save like Quick add does today.
- Items **with** nutrition = estimate; items **without** = must be matched to a food.
- Optional `date`, `meal`; missing → the Day screen's selected day and the inferred meal.
- Unknown keys ignored; `knabberfuchs` version lets the format grow.

**Plain lists keep working too.** If no block is found, the text goes through a
tolerant line parser (A.5) — so an ingredient list Claude already wrote, or one from a
website, still imports.

### A.4 Getting it into the app

1. **Android share target** — `ACTION_SEND` `text/plain` filter on `MainActivity`
   (`singleTop` → `onNewIntent`), handed to Dart through the existing
   `ch.knabberfuchs.app/intent` MethodChannel. In the AI app: Share → knabberfuchs →
   review screen. A shared `CTR1:` recipe code imports as before.
2. **"Paste from AI"** tile in the Day capture menu (replaces "AI scan" + "Describe")
   and in the Recipes create sheet; the dialog pre-fills from the clipboard. The
   existing "Import recipe code" paste accepts all three formats.
3. **iOS:** paste only at first. A Share Extension (new target + App Group) is a later
   phase.

### A.5 Review screen improvements (the ingredient-list screen, generalized)

- **Tolerant parser**: amount-first lines ("200 g flour", "2 slices bread"), bullets and
  numbering, fractions ("½", "1/2"), "Serves 4" → servings, a heading → name. Also fixes
  Describe meal's own example, which today parses into "2 slices rye bread" as a name.
- **Estimate items** show "estimated" and their numbers; each can be swapped for a real
  food (swipe → match, as today) or kept.
- **Best-match suggestion** for names never matched before: relaxed local search
  (all tokens → fall back to the longest/most specific token), shown as a *suggestion*
  to confirm, never applied silently. Confirming remembers it like any match.
- **Fix the "Log to day" path** (bugs found while surveying):
  - uses the Day screen's selected day and active group instead of a date picker
    defaulting to today and always a new group;
  - logs through `DiaryRepository.logFood` (keeps `foodId`, micros, usage bump) instead
    of a bare `logSnapshot` that drops fiber/sat. fat/sugar/salt;
  - Health sync covers the logged day even when it isn't the one on screen.
- **No recipe notes** (decided): recipes stay ingredients-only. An AI's `steps` / `note`
  are ignored on import.

### A.6 The instructions (replaces the key)

New **Settings → AI helper** screen (replaces the AI section):

- Short explanation: use your own AI app; knabberfuchs never talks to it.
- **Copy instructions** — two presets, generated in the app language with the user's
  current targets and tracked nutrients filled in:
  - *Log what I ate* — "estimate each item, answer with a knabberfuchs block";
    works with a photo or a description in the AI app.
  - *Adapt a recipe* — "scale to my target, keep it cookable, answer with a
    knabberfuchs recipe block".
- How-to: paste once into a Claude Project / ChatGPT custom instructions / a Gem.
- **Share summary** (Part C) lives here too.

### A.7 Removing Gemini

- Code: `gemini_service.dart`, `gemini_key_store.dart`, `gemini_error.dart`,
  `gemini_loading_dialog.dart`, `gemini_problem_dialog.dart`, `recognize_food_flow.dart`,
  `ai_consent_sheet.dart`, the Gemini half of `describe_meal_flow.dart`, the AI settings
  section + `SettingsScrollNotifier`, Gemini providers, ~60 l10n keys ×4, 3 test files.
- Quick add keeps working as is (it only loses the Gemini prefill entry).
- **Clean up stored data**: delete the stored key and the `geminiModel` /
  `geminiConsent*` settings on first launch of the new version; ignore them in backup
  import. Keep `flutter_secure_storage` for that one release, drop it (and the
  data-extraction excludes) in the next.
- Docs: privacy pages ×4 (simpler: no third-party AI at all), store descriptions ×8,
  README, DESIGN_SYSTEM §10, PLAN's AI sections, mockups 04/07, changelog wording for
  people who used a key ("your key is no longer needed — here's the new way").

---

## Part B — Weight

### B.1 Principles

- **The trend, not the day.** Daily weight swings ±1 kg with water and salt; the
  headline number is the **7-day average** and its change against the week before.
  Daily values are shown, but quietly (faded dots).
- **Health is the home of the data** when the user wants it: read weights a smart scale
  wrote there, write manual entries back. knabberfuchs adds what those apps do badly —
  the graph and the link to what was eaten.
- **Colour only with a goal.** The goal's direction decides what "toward" means:
  losing → down is emerald, gaining → up is emerald, the other way amber. **No goal →
  plain neutral numbers** and no milestone lines. Never red ("no red in status").
- **One switch: Settings → "Track weight".** Off = none of it shows (no Day row, no
  Nutrition | Weight switch in Trends, no Health weight switches). Off by default, so
  nobody who doesn't weigh gets a new row on the Day screen; the release notes and the
  Trends empty state point to it.

### B.2 Data

- New table `body_measurements`: `id, kind (weight; waist later), value (kg), measuredAt,
  source (manual | health), externalId?, countsForDay (bool, at most one per day)` —
  `externalId` dedupes Health imports.
- **Daily value** for charts and averages: the weigh-in flagged `countsForDay`, else the
  day's first (morning weight). The flag is local only — it never touches Health.
- Settings: unit (kg / lb, default from the phone's region), goal weights / milestones
  (a list), optional height for BMI milestones. The direction follows from the goal
  (below the current trend → lose, above → gain); no goal → neutral.
- Schema v16 migration + explicit backup export/import blocks + `entries.csv`-style
  weights CSV in the ZIP + tests (backup is hand-written per table).

### B.3 Logging (mockup `examples/ui/08-weight.html`)

- **Day screen row** in the summary card — the trend leads here too: big **"87.0 kg
  7-day · −0.5 kg this week"**, small "Today 86.9 kg" (or "Add today's weight" before
  the weigh-in).
- **Tap the row → Weight sheet** for the day on screen (one tap to log, no detour via
  Trends): value field, time, the day's weigh-ins listed with their times, Save, and
  "See trend →" into Trends · Weight. A forgotten weigh-in: go to that day, tap the row.
- **Several weigh-ins a day** are kept; by default the **first of the day counts**
  ("counts · first"). **"Count this one"** on another weigh-in overrides it ("counts ·
  chosen"); removing the chosen one falls back to the first. Per weigh-in (⋮): count
  this one · edit (manual only) · remove. Entries **from Health can't be edited** —
  Health owns that number — but can be removed from knabberfuchs or simply not counted.
- The days in an expanded Trends week open that day's Weight sheet.
- **Trends · Weight** has its own **Add weight** FAB (the Nutrition view stays FAB-less).
- With Health "Read weight" on, a scale's reading simply appears — nothing to type.

### B.4 Health integration

- In the existing Health section: **"Read weight"** and **"Write my weights"** switches
  (separate, like nutrition write / energy read today).
- Android: `READ_WEIGHT` / `WRITE_WEIGHT` permissions. iOS: `BODY_MASS` read/write.
  Fix the iOS usage strings while there (they already
  describe reads the app doesn't do).
- Read: import new samples since the last sync on app start / screen open, dedupe by
  `externalId`; manual entries made in knabberfuchs aren't re-imported.

### B.5 The Weight screen

Modelled on your tracking artifact:

- **Cards** (2×2): *7-day average* + change vs. previous week (big) · *Latest* (small,
  date) · *Since start* (trend-based, not first raw value) · *Next milestone* + distance.
- **Chart** (fl_chart, like Trends): faded daily dots, **bold 7-day average line**, latest
  dot highlighted, dashed goal/milestone lines labelled at the right edge; ranges
  1 M / 3 M / 1 Y / all. Average = mean of the available days in the trailing 7, shown
  from 3 values on (gaps don't make it jump).
- **Rolling vs. calendar** — the *chart line, the headline and the Day row* use the
  trailing 7 days (always the latest week); the *week list* uses **calendar weeks**
  (Mon–Sun, or the locale's first day of the week) so its rows don't shift every day.
- **Week list**: each calendar week's mean of its weigh-ins and the change vs. the week
  before; the current week says "so far". **Tap a week → it expands to its days**
  (each day's counting weigh-in, "—" for none).
- **No goal set**: the milestone card becomes "Set a goal weight →".
- Golden tests for the chart, like Trends.

### B.6 Placement (decided)

**A "Weight" view inside Trends** — a Nutrition | Weight switch at the top — plus the
Day-screen row as the everyday way in. Trends can be hidden in Settings; the Day row
and its sheet keep weight logging available either way.

### B.7 Later: weight × intake

With both in one app: weekly average intake vs. weekly trend change → the user's *actual*
daily burn ("adaptive TDEE", already a someday item in `PLAN.md`). Not in this plan's
scope; the data model above is what it needs.

---

## Part C — Share summary (analysis)

"Share summary" (AI helper screen, and Trends' menu): the last 7/30 days as compact
text — daily totals vs. targets, tracked nutrients, weight trend — through the share
sheet to the user's AI app. One-way, no format to parse back.

---

## Phases

| # | Phase | Ships |
|---|---|---|
| 1 | Tolerant parser, review-screen fixes (A.5), "Paste from AI" with plain lists, Android share target | release — useful on its own (your recipe loop) |
| 2 | `knabberfuchs` JSON format incl. estimates, AI helper + instructions, Share summary, **Gemini removed** + docs/store/privacy | release |
| 3 | Weight: table + migration + backup, logging, Weight view + chart + goldens | release |
| 4 | Health weight read/write | release (needs the store's health-permission review) |
| 5 | iOS Share Extension | later |
| 6 | Adaptive TDEE | later |

Every phase: analyze + tests green, four locales, DESIGN_SYSTEM updated for new
patterns, mockup first where the UI is new (review screen with estimates, Weight view).

---

## Decisions (2026-11-13)

1. **Gemini** — removed in phase 2, in the same release as its replacement.
2. **Format** — the JSON block (A.3).
3. **Weight placement** — inside Trends (Nutrition | Weight), Day-screen row + Weight
   sheet for logging (B.3, B.6).
4. **Several weights on one day** — the first of the day is the daily value, unless
   another weigh-in is chosen with "Count this one" in the day's Weight sheet.
5. **Goals** — several goal weights / milestones of your own, plus BMI milestones once
   height is set (one extra field in Settings).
6. **Waist** — not for now; weight only. (`body_measurements.kind` keeps the door open.)
7. **Units** — default from the phone's region (US, Liberia, Myanmar → lb; else kg),
   with a kg / lb toggle in Settings. Stone only if asked for. The platforms' own
   measurement-system setting can be read through the existing MethodChannel if the
   region guess proves wrong.
8. **Recipe notes** — none for now; recipes stay ingredients-only.
9. **Colour** — only with a goal; its direction (lose / gain) decides toward vs. away;
   no goal → neutral.
10. **Track weight** — one Settings switch hides all of it; off by default.
11. **Weeks** — calendar weeks in the list (tap to expand to days); rolling 7 days for
    the line, headline and Day row.
