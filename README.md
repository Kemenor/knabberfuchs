# Knabberfuchs 🦊

An ad-free, no-subscription, no-popup calorie tracker for Android. Scan a barcode or
search a food, enter grams, done. See your intake day by day.

(App id `ch.knabberfuchs.knabberfuchs`; repo named `openfoodfact-calorietracker`.)

> Built because every popular tracker nags with paywalls. This one doesn't.

## What it does (planned)

- 📷 **Barcode scan** → look up via Open Food Facts, log grams.
- 🔎 **Search** packaged + whole foods (Open Food Facts + USDA FoodData Central), or add your own.
- 📅 **Day-by-day** view, grouped by meal or as a flat list, with a running total.
- 🎯 **Per-weekday calorie targets** (higher on training days).
- 🍳 **Recipes** you can reuse and share by **QR code or file** — no server.
- ❤️ **Health Connect** sync (opt-in, write-only).
- 💾 **ZIP backup / restore**, fully local.

## Stack

Flutter · drift (SQLite) · riverpod · mobile_scanner · openfoodfacts · health

## Status

Planning complete — see [`PLAN.md`](./PLAN.md) for architecture, data model, and the phased roadmap.

## License

TBD
