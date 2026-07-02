# Knabberfuchs 🦊

An ad-free, no-subscription, no-popup calorie tracker for Android and iOS. Scan a barcode, search,
snap a photo of your meal, or just type a name and the calories. Your data stays on your phone.

> Built because every popular tracker nags with paywalls. This one doesn't.

🌐 [knabberfuchs.ch](https://knabberfuchs.ch)

## What it does

- 📷 **Barcode scan** — Open Food Facts products. Not in the database? Add it yourself (scan the
  nutrition label) and it's saved for next time.
- 🔎 **Fast local search** — Open Food Facts + the curated **Swiss Food Composition Database**,
  plus your own custom foods.
- ⚡ **Quick add** — already know the number? Log “Lasagna · 816 kcal” in a couple of taps.
- 📸 **AI meal recognition** — snap a photo and get the dish + an estimated portion. Runs
  **on-device by default** (no account, no cloud); optionally use your own free **Google Gemini**
  key for sharper results with full macros.
- 🖼️ **Meal from a photo** — photograph a printed ingredient list; on-device OCR turns it into a
  meal to log.
- 📅 **Day by day** — meals group automatically as you add; running total and macros.
- 🎯 **Per-weekday targets** — a minimum, a maximum, or both (training days can differ).
- 📖 **Recipes** — build once, log a portion to any day (added as its individual ingredients),
  share by **QR or image**, import by **QR or text**.
- 🌍 **Offline, worldwide** — download any of 106 country databases and search with no connection.
- 🗣️ **Multilingual** — English, German, French, Italian.
- ❤️ **Apple Health / Health Connect** — optional, write-only sync of calories & macros.
- 💾 **ZIP backup / restore** — fully local, no cloud, no lock-in.

## Data & privacy

- Food data: **Open Food Facts** (ODbL) + the **Swiss Food Composition Database** (FSVO).
- On-device food image model: **Google AIY food_V1** (Apache-2.0), bundled and run locally.
- The app talks to the internet only for: **Open Food Facts** lookups (barcode / search terms),
  downloading **offline country packs** from Hugging Face when you request one, and — **optional**,
  only if *you* configure a key — sending a meal photo (plus your typed hint, if any) to Gemini.
  Everything else is on-device. No accounts, no analytics, no server. Details:
  [privacy policy](https://knabberfuchs.ch/privacy.html).

## Stack

Flutter · drift (SQLite) · Riverpod · fuchsbau (shared design system) · mobile_scanner ·
`http` (hand-rolled Open Food Facts client) · health (Apple Health / Health Connect) ·
`tflite_flutter` (food model) · ML Kit (OCR) · `image_picker`

## Build & run

Dev toolchain lives in a distrobox container (`flutter`). Typical commands:

```sh
flutter test
flutter build apk --debug                                   # emulator
flutter build apk --release --target-platform android-arm64 # phone (~113 MB)
flutter build appbundle                                     # Play Store (per-device split)
flutter build ipa --release                                 # App Store (macOS only)
```

Architecture, data model, and the phased roadmap are in [`PLAN.md`](./PLAN.md).

## License

TBD
