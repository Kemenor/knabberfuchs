# Knabberfuchs — UI Design System

Prescriptive UI/UX conventions for the app. **New or changed UI must conform to
these.** Each rule has a canonical snippet and a `file:line` pointer to the live
example — copy the pattern and verify it against the referenced code. When you
introduce a genuinely new pattern (not covered here), update this file.

This is a Flutter + Riverpod (Material 3) app. Entry: `lib/main.dart` →
`ProviderScope` → `CalorieApp` (`lib/app.dart`) → `HomeShell`
(`lib/ui/home_shell.dart`).

---

## 1. Navigation

- Root is a Material 3 `NavigationBar` with a fixed three-tab order: **Day,
  Recipes, Settings**. Each tab pairs an `_outlined` unselected icon with a
  filled `selectedIcon`. Live: `lib/ui/home_shell.dart:25-45`.
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
    icon: const Icon(Icons.add),
    label: Text(l10n.dayAddFood),
  )
  ```

  Live: `day_screen.dart:110-115`.

- **Secondary action sits to the LEFT of the primary, smaller**, via a
  `Row(mainAxisSize: MainAxisSize.min)` with a `SizedBox(width: 12)` gap. On Day,
  the small `Icons.bolt` capture FAB (`.small`, tooltip only) precedes the
  extended "Add food" primary. Live: `day_screen.dart:100-117`.

- **Reuse the established verbs verbatim:**
  - Save → `Icons.check` + `l10n.actionSave` (`food_form_screen.dart:154`,
    `recipe_edit_screen.dart:151`)
  - Scan → `Icons.qr_code_scanner` + `l10n.scanBarcode`
    (`add_food_screen.dart:81`, `food_picker_screen.dart:58`)
  - Add/create → `Icons.add` (`day_screen.dart:110`, `recipes_screen.dart:213`)

- Give list/form bodies bottom padding so the FAB never overlaps the last item:
  `EdgeInsets.only(bottom: 96)` for lists (`day_screen.dart:247`), `88` for form
  `ListView`s (`food_form_screen.dart`).

- **Don't** ship a bare unlabeled FAB for a multi-purpose entry point, and
  **don't** reuse a `heroTag`.

---

## 3. Menus & swipe actions

- **Inline overflow menu on a row → `PopupMenuButton<String>`** with
  `icon: Icon(Icons.more_vert, size: 20)`, text-only items (no leading icons),
  labels from l10n. The only one is the meal-group header; item order is
  **Edit, Scale, Split, Save as recipe, Delete**. Live: `day_screen.dart:417-444`.

- **A menu of distinct actions (not a row overflow) → a bottom sheet of labelled
  `ListTile`s, not a popup.** Each tile has a `leading` icon, `title`, and
  `subtitle`. Used by the Day capture menu (`day_screen.dart:122-162`) and the
  Recipes create menu (`recipes_screen.dart:82-131`).

  > **Don't** revert to bare FABs + unlabeled app-bar icons for multi-action
  > entry points — this was a deliberate shift (`recipes_screen.dart:80-81`).

- **AppBar actions** that are few and obvious → trailing `IconButton`s with
  `tooltip`s (Recipe Detail: edit / share / delete), not a ⋮ menu
  (`recipe_detail_screen.dart:67-87`).

- **Swipe (`Dismissible`) color language is fixed:**
  - Destructive (delete) → `direction: endToStart` (swipe-left), background
    `colorScheme.errorContainer`, right-aligned `Icons.delete_outline`.
    Live: `day_screen.dart:677-689`.
  - Positive (e.g. log a portion) → `startToEnd` (swipe-right), background
    `colorScheme.primaryContainer`, left-aligned `Icons.event_available`.
    Live: `recipes_screen.dart:156-197`.
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

- **Single source: `lib/core/theme.dart` → `buildTheme(Brightness)`**, wired in
  `app.dart:24-25` (light + dark).
- Material 3 (`useMaterial3: true`). Color scheme:
  `ColorScheme.fromSeed(seedColor: const Color(0xFF43A047) /* green */, …)` — a
  fresh green for a food/health feel (`theme.dart:5-8`).
- `AppBarTheme`: `surface` background, transparent surface tint,
  `centerTitle: true`.
- **Typography roles** (`Theme.of(context).textTheme`):
  - `displaySmall` (bold) — the big day kcal number (`day_screen.dart:300`)
  - `headlineSmall` (bold) — live kcal totals in sheets (`log_food_sheet.dart:248`)
  - `titleLarge` — sheet titles
  - `titleMedium` — unit labels, macro values, subtotals
  - `titleSmall` — section/group headers (settings sections add
    `.copyWith(color: colorScheme.primary)`)
  - `bodySmall` / `bodyMedium` — helper / secondary text
- **Muted text → `colorScheme.outline`** (source labels, help text)
  (`quick_add_sheet.dart:203-207`).
- **Status color semantics** (`day_screen.dart:273-278`): over = `error`,
  under = `tertiary`, in-range = `primary`, none = `onSurfaceVariant`.
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
  `AsyncValue.loading`; a full `showDialog(barrierDismissible: false)` overlay for
  blocking async (AI calls) (`recognize_food_flow.dart:84` on-device, `:50`
  Gemini).
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

- **Material `Icons.*` only** — no custom icon font/assets. Outlined variants for
  list/secondary contexts; filled for selected/emphasis.
- **Load-bearing icons (reuse, don't invent synonyms):** `Icons.add`
  (add/create/FAB), `Icons.delete_outline` (delete/swipe),
  `Icons.qr_code_scanner` (scan), `Icons.check` (save),
  `Icons.bolt` (quick-add/capture), `Icons.event_available` (log a portion),
  `Icons.document_scanner_outlined` (OCR-from-list), `Icons.more_vert` (size 20,
  the only overflow icon).
- `Icons.auto_awesome` (14px, `colorScheme.outline`) marks **AI-sourced data**
  (`quick_add_sheet.dart:202-204`). `Icons.restaurant_menu` is the splash/brand
  glyph.

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
