# Knabberfuchs — UI Design System

Prescriptive UI/UX conventions for the app. **New or changed UI must conform to
these.** Each rule has a canonical snippet and a `file:line` pointer to the live
example — copy the pattern and verify it against the referenced code. When you
introduce a genuinely new pattern (not covered here), update this file.

This is a Flutter + Riverpod (Material 3) app. Entry: `lib/main.dart` →
`ProviderScope` → `CalorieApp` (`lib/app.dart`) → `HomeShell`
(`lib/ui/home_shell.dart`).

## 0. Inherits the Fuchsbau design system

The **colours, fonts, shape/spacing scales, and base component patterns come
from the shared [fuchsbau](https://github.com/Kemenor/fuchsbau) package**
(`fuchsbauTheme()` in `lib/core/theme.dart`) — the pinned tangerine triad (fox
orange · indigo · emerald), Figtree + the accessibility font picker, soft
rounding, the pill FAB. This doc records knabberfuchs-specifics and any
**deviation** from Fuchsbau (the principle: *the triad is family, its
application to components is app-level*).

**Deviations from Fuchsbau:**
- **Action FAB is emerald** (not the family-default primary/tangerine): the
  capture (⚡) + Add-food FABs use a lightened `tertiary` so the primary CTA
  reads as a distinct, positive "go" against the warm tangerine surface. Applied
  in `lib/core/theme.dart` via `copyWith` on the fuchsbau theme.

---

## 1. Navigation

- Root is a Material 3 `NavigationBar` ordered **Day, Recipes, [Trends],
  Settings**. **Day is always index 0** (the only programmatic jump target). The
  **Trends** tab is optional — toggled in Settings via `showTrendsProvider`; the
  `pages`/`destinations` lists are built conditionally and the active index is
  `clamp`ed. Each tab pairs an `_outlined` unselected icon with a filled
  `selectedIcon`. Live: `lib/ui/home_shell.dart`.
- Tab index lives in `homeTabProvider` (`lib/providers.dart:307`). Switch tabs
  with `ref.read(homeTabProvider.notifier).set(i)`; pages are kept alive in an
  `IndexedStack` so scroll/search survive switching (`home_shell.dart:24`).
- A flow can jump tabs programmatically — e.g. after logging a recipe portion it
  jumps to Day: `ref.read(homeTabProvider.notifier).set(0)`
  (`recipe_detail_screen.dart:297`).
- **No router package / named routes.** Push imperatively and return values via
  pop:

  ```dart
  final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const FoodPickerScreen()));
  ```

  Live: `add_food_screen.dart:40`, screens pop results
  (`food_picker_screen.dart:66`, `scan_screen.dart:95`).

---

## 2. FABs

- **The main action is an `FloatingActionButton.extended` (icon + label) in the
  default bottom-right.** Every FAB carries a **unique `heroTag`** (prevents
  hero-animation collisions across pushed routes).

  ```dart
  FloatingActionButton.extended(
    heroTag: 'dayAddFood',
    onPressed: ...,
    icon: const Icon(Symbols.add_rounded),
    label: Text(l10n.dayAddFood),
  )
  ```

  Live: `day_screen.dart:119-124`.

- **Secondary action sits to the LEFT of the primary, smaller**, via a
  `Row(mainAxisSize: MainAxisSize.min)` with a `SizedBox(width: 12)` gap. On Day,
  the small `Symbols.bolt_rounded` capture FAB (`.small`, tooltip only) precedes
  the extended "Add food" primary. Live: `day_screen.dart:112-125`.

- **Reuse the established verbs verbatim:**
  - Save → `Symbols.check_rounded` + `l10n.actionSave` (`food_form_screen.dart:201`,
    `recipe_edit_screen.dart:171`)
  - Scan → `Symbols.qr_code_scanner_rounded` + `l10n.scanBarcode`
    (`food_picker_screen.dart:69`)
  - Add/create → `Symbols.add_rounded` (`day_screen.dart:122`, `recipes_screen.dart:251`)

- Give list/form bodies bottom padding so the FAB never overlaps the last item:
  `EdgeInsets.only(bottom: 96)` for lists (`day_screen.dart:268`), `88` for form
  `ListView`s (`food_form_screen.dart`).

- **Don't** ship a bare unlabeled FAB for a multi-purpose entry point, and
  **don't** reuse a `heroTag`.

---

## 3. Menus & swipe actions

- **Inline overflow menu on a row → `PopupMenuButton<String>`** with
  `icon: Icon(Symbols.more_vert_rounded, size: 20)`, text-only items (no leading
  icons), labels from l10n. The only one is the meal-group header; item order is
  **Edit, Scale, Split, Save as recipe, Delete**. Live: `day_screen.dart:518-545`.

- **A menu of distinct actions (not a row overflow) → a bottom sheet of labelled
  `ListTile`s, not a popup.** Each tile has a `leading` icon, `title`, and
  `subtitle`. Used by the Day capture menu (`day_screen.dart:131`) and the
  Recipes create menu (`recipes_screen.dart:95`).

  > **Don't** revert to bare FABs + unlabeled app-bar icons for multi-action
  > entry points — this was a deliberate shift (`recipes_screen.dart:95`).

- **AppBar actions** that are few and obvious → trailing `IconButton`s with
  `tooltip`s (Recipe Detail: edit / share / delete), not a ⋮ menu
  (`recipe_detail_screen.dart:67-87`).

- **Swipe (`Dismissible`) color language is fixed:**
  - Destructive (delete) → `direction: endToStart` (swipe-left), background
    `colorScheme.errorContainer`, right-aligned `Symbols.delete_rounded`.
    Live: `day_screen.dart:831-845`.
  - Positive (e.g. log a portion) → `startToEnd` (swipe-right), background
    `colorScheme.primaryContainer`, left-aligned `Symbols.event_available_rounded`.
    Live: `recipes_screen.dart:176-197`.
  - Use a stable key like `ValueKey('entry-$id')`. Where a stream redraws the
    list, `confirmDismiss` returns `false` after handling.

---

## 4. Bottom sheets

Two sheet styles — pick by purpose.

**A. Menu sheet (action list):** `showModalBottomSheet` with
`showDragHandle: true` (no `isScrollControlled`); body is
`SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile…]))`.
Live: `day_screen.dart:124-161`, `image_source_sheet.dart:13-30`.

**B. Form / input sheet:** `showModalBottomSheet` with **both**
`isScrollControlled: true` and `showDragHandle: true`. Canonical body:

```dart
SafeArea(
  top: false,
  child: Padding(
    // keyboard + nav-bar safe
    padding: EdgeInsets.fromLTRB(
        16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge), // sheet title
        // …fields…
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton(...)),  // bottom action
      ],
    ),
  ),
)
```

Live: `quick_add_sheet.dart:188-294`, `log_food_sheet.dart:205-340`,
`scale_meal_sheet.dart:40-97`.

- **Sheet title is always `textTheme.titleLarge`.**
- **Bottom action** is a full-width `FilledButton`, or a `Row` with a `Spacer()`
  pushing the `FilledButton` right; when a destructive action coexists, a
  left-aligned red `TextButton.icon` + `Spacer` + `FilledButton`
  (`log_food_sheet.dart:312-335`).
- Sheets that log return `bool` via `showModalBottomSheet<bool>` +
  `Navigator.pop(true)` (`quick_add_sheet.dart:30,182`).

---

## 5. Buttons

| Widget | Use for | Live |
|---|---|---|
| `FilledButton` | primary / confirm (sheet submit, dialog affirmative) | `quick_add_sheet.dart:286`, `recipes_screen.dart:187` |
| `TextButton` | dismiss / cancel (always the dialog *Cancel*) | `recipes_screen.dart:67` |
| `TextButton.icon` | inline tertiary / "reveal more" / destructive-in-sheet (red via `foregroundColor: colorScheme.error`) | `quick_add_sheet.dart:277`, `log_food_sheet.dart:315` |
| `OutlinedButton[.icon]` | neutral pickers (date/time, meal windows) | `day_screen.dart:642`, `settings_screen.dart:353` |
| `FilledButton.tonalIcon` | soft secondary CTA | `settings_screen.dart:307` |
| `IconButton` | appbar actions (with `tooltip`), in-row affordances (`visualDensity: VisualDensity.compact`), field suffix toggles | `day_screen.dart:82`, `settings_screen.dart:481` |

- **Dialog action order is fixed: `TextButton`(Cancel) → `FilledButton`(confirm).**
  Live: `recipes_screen.dart:179-191`, `settings_screen.dart:223-237`.

- **Persistent dual-action bar:** a screen with *two* co-equal commit actions may
  use a `bottomNavigationBar` of two `Expanded` buttons — secondary
  `OutlinedButton` + primary `FilledButton` (`FilledButton` on the right) — and may
  still carry an `add`-style FAB above it. Live: `ocr_meal_screen.dart:290-311`
  (Save-as-recipe / Log-to-day). Use this only when both actions are primary; a
  single primary action stays a FAB (§2).

---

## 6. Forms & inputs

- Use `TextField` (no `Form`/`TextFormField`). Standard decoration:

  ```dart
  TextField(
    decoration: InputDecoration(
      labelText: l10n.quickAddName,
      border: const OutlineInputBorder(),
    ),
  )
  ```

  Live: `quick_add_sheet.dart:217-219`.

- **Units via `suffixText`** (`l10n.unitKcal`, `'g'`, or a dynamic unit label).
- **Compact fields** add `isDense: true` (macro/target/key fields).
- **Numeric input:**

  ```dart
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
  ```

  Digits-only fields use `FilteringTextInputFormatter.digitsOnly`.
- **Name fields** set `textCapitalization: TextCapitalization.sentences`.
- **Row + flex** for paired fields: kcal vs weight is `Expanded(flex: 3)` /
  `SizedBox(width: 8)` / `Expanded(flex: 2)` (`quick_add_sheet.dart:225-260`);
  three equal macro fields are `Expanded` + `SizedBox(width: 8)`.

---

## 7. Chips

- **`ChoiceChip`** when there's a selected state (meal-type reclassify, unit
  selector, scale presets, the natural-portion chip showing `selected` while
  active). Lay out in a `Wrap(spacing: 6–8)`. Live: `log_food_sheet.dart:256-302`,
  `scale_meal_sheet.dart:75-85`.
- **`ActionChip`** for fire-and-forget quick-pick that just sets a value
  (`log_food_sheet.dart:304-308`).
- The curated / "natural" option **leads** the quick-pick row
  (`log_food_sheet.dart:285-287`).

---

## 8. Spacing & padding

- **`16` is the standard horizontal screen/sheet inset everywhere.**
- **SizedBox gap vocabulary:** `4` (label↔control), `8` (between fields /
  horizontal), `12` (between fields / before button), `16` (after a title /
  section), `20` (before the primary action).
- **Cards:** `margin: EdgeInsets.fromLTRB(16, 12, 16, 4)`, inner
  `Padding: EdgeInsets.all(16)` (`day_screen.dart:289-291`).
- **Section header padding:** `EdgeInsets.fromLTRB(16, 16, 16, 4)`
  (`settings_screen.dart:568`).
- **List bottom padding for FAB clearance:** `96` (lists) / `88` (forms).
- **Separators:** `Divider(height: 1)`; section dividers use
  `indent: 16, endIndent: 16`.
- **Empty states** are centered with generous padding (`all(48)` Day,
  `all(32)` Recipes).

---

## 9. Theme

- **Single source: `lib/core/theme.dart` → `buildTheme(Brightness, {font})`**,
  wired in `app.dart:48-49` (light + dark, with the user-selected
  `FuchsbauFont`). It delegates to the shared fuchsbau package's
  `fuchsbauTheme()` (§0) — Material 3, the **pinned tangerine triad** (primary
  fox orange · secondary indigo · tertiary emerald), Figtree — replacing the old
  accidental-green `ColorScheme.fromSeed` seed. Component theming (AppBar,
  cards, shapes) is owned by fuchsbau; don't restyle it locally.
- knabberfuchs layers exactly one deviation on top: **the action FAB is emerald**
  (`tertiary`/`onTertiary` via `copyWith`, `theme.dart:18-23`; rationale in §0).
  Record any new deviation in §0 with a pointer back to fuchsbau.
- **Typography roles** (`Theme.of(context).textTheme`):
  - `displaySmall` (bold) — the big day kcal number (`day_screen.dart:330`)
  - `headlineSmall` (bold) — live kcal totals in sheets (`log_food_sheet.dart:291`)
  - `titleLarge` — sheet titles
  - `titleMedium` — unit labels, macro values, subtotals
  - `titleSmall` — section/group headers (settings sections add
    `.copyWith(color: colorScheme.primary)`)
  - `bodySmall` / `bodyMedium` — helper / secondary text
- **Muted text → `colorScheme.outline`** (source labels, help text)
  (`quick_add_sheet.dart:226-233`).
- **Status color semantics** (`core/status_color.dart:14-23`), mapped onto the
  triad: **under = `secondary` (indigo, focus — working toward it), in-range =
  `tertiary` (emerald, achieved), over = amber**
  (`FuchsbauStatusColors.of(context).amber`, the one calm nudge), none =
  `outline`. Fuchsbau ethos: *status is information, never punishment; red is
  for destruction only* — no `error`/red in status.
- **Status as small text uses `statusTextColor`** (`status_color.dart:29-38`):
  darker AA (≥4.5:1) shades in light mode; the bright `statusColor` is for
  bars/dots/icons only.
- **Container color language:** destructive = `errorContainer`/`onErrorContainer`;
  positive = `primaryContainer`/`onPrimaryContainer`.

---

## 10. Feedback

- **All snackbars go through `showAutoSnackBar`** (extension on
  `ScaffoldMessengerState`, `lib/core/snackbar.dart:5-18`) — it works around
  Flutter not auto-dismissing snackbars under an active accessibility service.

  ```dart
  final messenger = ScaffoldMessenger.of(context); // capture BEFORE await
  // …await…
  messenger.showAutoSnackBar(SnackBar(content: Text(l10n.geminiFailed)));
  ```

  > **Don't** call `messenger.showSnackBar(...)` directly — there are zero such
  > calls in `lib/ui/`. Always capture `messenger` before an `await`, then call
  > after (`recipes_screen.dart:22-24`).

- **Loading:** inline `Center(child: CircularProgressIndicator())` for
  `AsyncValue.loading`; a full `showDialog(barrierDismissible: false)` overlay,
  wrapped in `PopScope(canPop: false)` so hardware back can't pop the route
  beneath, for blocking async (AI calls) (`recognize_food_flow.dart:130`
  on-device, `:72` Gemini).
- **Cancellable blocking modal** (long network-bound calls): the blocking dialog
  carries a `TextButton` labelled `l10n.actionCancel` that pops via *its own*
  dialog context and raises a `cancelled` flag; the awaiting flow then discards
  the late result and must not touch the navigator again
  (`recognize_food_flow.dart:71-99`).
- **In-progress download with cancel:** the row's trailing `IconButton`
  (`tooltip: l10n.actionCancel`) stacks a 32×32 `CircularProgressIndicator`
  (determinate; indeterminate while progress is 0) over a small
  `Symbols.close_rounded` (size 14) — tapping the ring cancels
  (`offline_regions_screen.dart:246-263`).
- **Error:** `AsyncValue.error` branches render
  `Center(child: Text(l10n.genericError('$e')))`.
- **Confirmation:** `AlertDialog` with Cancel(`TextButton`) → confirm(`FilledButton`).

---

## 11. Localization

- **No hardcoded user-facing strings.** Access via
  `final l10n = AppLocalizations.of(context);` at the top of `build`, then
  `l10n.<key>`. Live: `home_shell.dart:21`.
- ARB files in `lib/l10n/`: `app_en.arb` is the template (with `@key`
  descriptions), plus `app_de/fr/it.arb`. Config: `l10n.yaml`. `generate: true`
  in pubspec regenerates `AppLocalizations` on build (or run `flutter gen-l10n`).
- Keys are **namespaced by feature**: `nav*`, `action*` (Save/Cancel/Delete/Add/
  Import), `settings*`, `meal*`, `quickAdd*`, `recipe*`, `scan*`, `ai*`.
- Parameterized strings use ICU placeholders (`genericError('$e')`,
  `kcalPer100(...)`).
- Allowed literal exceptions: the brand name `'Knabberfuchs'`, the
  locale-invariant unit suffixes `'g'` / `'kcal'` / `'MB'`, and formatting glyphs
  (`'%'`, `'→'`, `'–'`). (`l10n.unitKcal` also exists and is equally fine for the
  `kcal` suffix.) Numbers format locale-aware via `lib/core/format.dart` driven by
  `localeProvider`.
- **Adding a string:** add the key + `@key` block to `app_en.arb`, mirror into
  `de/fr/it`, rebuild. (IT is machine-translated/unreviewed — see `PLAN.md`.)

---

## 12. Icons

- **Material Symbols Rounded only**, via the `material_symbols_icons` package
  (`import 'package:material_symbols_icons/symbols.dart'`) — the fuchsbau family
  icon set (§0). Always `Symbols.<name>_rounded`; **never `Icons.*`** (zero
  usages left in `lib/`) and no custom icon font/assets.
- **Load-bearing icons (reuse, don't invent synonyms):** `Symbols.add_rounded`
  (add/create/FAB), `Symbols.delete_rounded` (delete/swipe),
  `Symbols.qr_code_scanner_rounded` (scan), `Symbols.check_rounded`
  (save / finish meal), `Symbols.bolt_rounded` (quick-add/capture),
  `Symbols.event_available_rounded` (log a portion),
  `Symbols.document_scanner_rounded` (OCR-from-list),
  `Symbols.more_vert_rounded` (size 20, the only overflow icon).
- `Symbols.auto_awesome_rounded` (14px, `colorScheme.outline`) marks
  **AI-sourced data** (`quick_add_sheet.dart:222-227`).
  `Symbols.restaurant_menu_rounded` is the splash/brand glyph (`app.dart:85`).

---

## 13. Targets & metric bars

- **A metric draws a progress bar only when it has a target, and the bar fills
  toward `max` if set, else `min`** (a floor, e.g. a protein goal). One helper
  drives all four metrics: `DaySummary.barFractionFor(TargetMetric)` returns the
  0..1 fill or `null` (→ no bar). Live: the kcal bar + per-macro under-bars in
  `day_screen.dart` (`_SummaryCard` / `_MacroRow`).
- **The Day card shows every metric at once — no toggle.** kcal headline + bar,
  then the P/C/F row where each macro *with a target* gains a thin
  status-colored under-bar and a status-colored value; targetless macros stay
  plain text (mirrors the optional kcal bar, so a calorie-only card is
  unchanged).
- **Macro value + under-bar fill = `statusColor(context, status)`** (in-range
  emerald, off-target amber, never red). The **kcal hero bar is the structural
  indigo (`secondary`)** progress track — status is carried by the value/text +
  the macro bars, not the kcal bar.
- **Metric switching belongs on the chart, not the Day card.** Trends carries a
  `SegmentedButton<TargetMetric>` (kcal · P · C · F) that swaps the plotted
  series + target band; selection is in-memory (`selectedTrendMetricProvider`,
  defaults to kcal). Values format per metric (kcal vs `g`).
- **Targets get their own screen** (`settings/targets_screen.dart`), pushed from
  a Settings `ListTile`. Metric-first (Calories / Protein / Carbohydrates /
  Fat); each metric has an always-visible default Min/Max row + an independently
  expandable per-weekday `ExpansionTile`. Every bound is optional.

---

## Cross-cutting invariants (quick checklist for any new UI)

1. Main action = bottom-right extended FAB, unique `heroTag`; secondary smaller,
   to its left.
2. Multi-action entry point = labelled `ListTile` bottom sheet (not bare FABs /
   icon menus).
3. Save = check + `actionSave`; Scan = `qr_code_scanner` + `scanBarcode`;
   Add = `add`.
4. Form/input sheet = `isScrollControlled` + `showDragHandle`, `titleLarge`
   title, `viewInsets.bottom + 16` padding, full-width `FilledButton` action.
5. Dialogs/sheets: Cancel(`TextButton`) → confirm(`FilledButton`).
6. Snackbars via `showAutoSnackBar` only; capture `messenger` before `await`.
7. No hardcoded strings — everything through `l10n`; mirror new keys into
   en/de/fr/it.
8. `16` insets; gap vocabulary 4/8/12/16/20; list bottom padding 96/88 for FAB.
9. Colors by semantic role (`error`/`tertiary`/`primary`); muted text =
   `colorScheme.outline`.
