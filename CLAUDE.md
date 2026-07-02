# Knabberfuchs — project guide for Claude

Ad-free, no-subscription, **serverless** Android + iOS calorie tracker (Flutter/Dart).
Local-first (drift/SQLite), Riverpod, Material 3, four locales (en/de/fr/it).
Product plan & backlog: `PLAN.md`.

## Working in this repo

**Flutter is NOT on PATH — it runs inside a distrobox container named `flutter`.**
Wrap every flutter/dart command:

```bash
distrobox enter flutter -- bash -lc 'flutter <cmd>'
```

- **Analyze / test:** `flutter analyze` · `flutter test` (tests in `test/`).
- **l10n:** edit `lib/l10n/app_en.arb` (template, with `@key` blocks), then mirror
  the key into `app_de/fr/it.arb`. `generate: true` regenerates `AppLocalizations`
  on build, or run `flutter gen-l10n`. Config: `l10n.yaml`.
- **Run on device/emulator:** `flutter run` (emulator restart needs `-gpu host`).
- **Release flow (CI, the normal path):** write the four changelogs at
  `fastlane/metadata/android/<locale>/changelogs/<nextBuildNumber>.txt`, then
  `tool/cut_release.sh x.y.z` — it verifies tree/changelogs/CI, bumps pubspec,
  tags `vX.Y.Z` and pushes. The tag triggers `.github/workflows/android.yml`
  (analyze+test gate → signed AAB → *completed* release on both Play
  closed-testing tracks) and `ios.yml` (analyze+test gate → TestFlight).
  **App Store production:** once the build is on TestFlight, update
  `fastlane/metadata/ios/*/release_notes.txt` and run
  `gh workflow run ios-release.yml -f version=x.y.z -f build_number=N` —
  submits for review, **auto-releases on approval**. Manual fallback:
  `flutter build appbundle --release` → `python3 tool/play_upload_aab.py <track>`
  (track(s) as positional args, e.g. `internal`; AAB path hardcoded in the
  script). Status: Android in Play closed testing; iOS **live on the App Store**.
  The CI Flutter version is single-sourced in `.fvmrc` (all workflows read it via
  `flutter-version-file`); bump it together with the goldens (see `test.yml`).
- **Store screenshots (local):** `tool/screenshots.sh android|ios [locales]` runs
  the `integration_test/screenshots_test.dart` harness (the single shot list,
  ≤10 scenes ×4 locales) against the first adb device / booted simulator and
  files the PNGs into the fastlane layouts; upload with `fastlane android
  listing` / `fastlane ios screenshots`. `screenshots.yml` stays as a
  dispatch-only CI fallback for iOS.
- **Secrets:** keep the app keyless by default; never commit API keys. Keystore,
  `key.properties`, `play-store-key.json` are gitignored.

## UI conventions (summary — full rules in `DESIGN_SYSTEM.md`)

Conform new/changed UI to these:

- **FABs:** main action = `FloatingActionButton.extended` (icon + label) in the
  bottom-right with a **unique `heroTag`**. A secondary action sits **smaller, to
  its left** in a `Row(mainAxisSize: .min)`. Save = `Symbols.check_rounded`+`actionSave`,
  Scan = `Symbols.qr_code_scanner_rounded`+`scanBarcode`, Add = `Symbols.add_rounded`.
- **Icons:** Material Symbols Rounded via `material_symbols_icons` —
  `Symbols.<name>_rounded`, never `Icons.*`.
- **Menus:** row overflow = `PopupMenuButton` (⋮, `Symbols.more_vert_rounded` size 20).
  A menu of distinct actions = a **bottom sheet of labelled `ListTile`s** (icon +
  title + subtitle), *not* bare FABs or app-bar icons.
- **Sheets:** input sheets use `isScrollControlled: true` + `showDragHandle: true`,
  a `titleLarge` title, `SafeArea(top:false)` + `viewInsets.bottom + 16` padding,
  and a full-width `FilledButton` action at the bottom.
- **Buttons/dialogs:** `FilledButton` = primary/confirm, `TextButton` =
  cancel/dismiss; dialog order is **Cancel → Confirm**.
- **Feedback:** snackbars **only** via `showAutoSnackBar`; capture `messenger`
  before any `await`.
- **Strings:** no hardcoded user-facing text — everything through `l10n`; mirror
  new keys into en/de/fr/it.
- **Spacing:** `16` insets; gap vocabulary 4/8/12/16/20; list bottom padding 96
  (88 for forms) so FABs don't overlap.
- **Theme:** single source `lib/core/theme.dart`, which delegates to the shared
  **fuchsbau** design-system package (tangerine triad: primary orange, secondary
  indigo, tertiary emerald — *not* the old M3 green seed). muted text =
  `colorScheme.outline`; status colors (`core/status_color.dart`) = under indigo
  (focus) / in-range emerald / over amber / none outline — **no red in status**
  (red is destruction-only). Per-app deviations recorded in `DESIGN_SYSTEM.md`.

**When you introduce a genuinely new UI pattern, update `DESIGN_SYSTEM.md`** so it
doesn't rot.
