# Google Play — Production Access Application

Prepared 2026-07-11. The closed test (12+ opted-in testers, 14+ consecutive days —
requirement for personal developer accounts created after 2023-11-13) has run its
course; this file holds the paste-ready answers for the Play Console
**"Apply for production"** questionnaire, plus the steps before and after.

> **Before submitting, personalize the two facts only you know:**
> 1. the exact number of opted-in testers (answers below say "14" — replace with
>    the real count from Play Console → Testing → Closed testing),
> 2. the recruitment description if it wasn't personal network (answers assume
>    friends, family and colleagues in Switzerland/Germany).
>
> Google rejects generic/templated answers — everything below is grounded in this
> repo's real history (`FEEDBACK.md`, `PLAN.md`, fastlane changelogs), so keep the
> specifics when editing.

## Where to apply

Play Console → **ch.knabberfuchs.app** → Dashboard → the "Apply for production"
task (also reachable via Testing → Closed testing once the 14-day/12-tester
banner shows the requirement as met). The form has three sections; free-text
answers should be specific and a few sentences long (very short answers are a
common rejection reason). Google's review typically takes a few days, up to
about a week. If rejected, you can reapply after addressing their reason —
running the closed test further is never wasted.

---

## Section 1 — About your closed test

### How easy was it to recruit testers? *(dropdown)*

Pick honestly — for a personal-network recruit, **"Somewhat easy"** is the
credible choice (finding 12+ people who commit to daily use for two weeks takes
effort even among friends).

### How did you recruit the testers for your closed test?

> I recruited 14 testers from my personal and professional network in
> Switzerland and Germany — friends, family and colleagues who already track
> calories or wanted to start. Because the app targets German, French, Italian
> and English speakers (it ships fully localized in all four), I deliberately
> included native speakers of each language to exercise every locale. Each
> tester joined the closed track via the opt-in link, installed from Google
> Play, and agreed to use the app for their real, daily food logging — not
> just to open it once.

### Describe the engagement you received from testers during your closed test.

> Testers used Knabberfuchs as their actual daily calorie tracker throughout
> the test: logging meals by barcode scan, text search against the bundled
> Swiss/USDA food databases, photographing nutrition labels (OCR) and meal
> photos, building reusable recipes, setting per-weekday calorie and macro
> targets, and syncing to Health Connect. Engagement was deep enough to
> surface non-obvious issues — e.g. one tester sent a screenshot of the
> Health Connect developer docs to argue for activity-adjusted calorie
> budgets, others compared the app's nutrient-field order against printed
> Swiss/EU food labels, and reported edge cases like late dinners crossing
> midnight or accented search queries ("Müsli", "Käse") failing offline. I
> shipped 20+ builds to the closed track during the test in direct response.

### Provide a summary of the feedback you received, including how you collected it.

> I collected feedback through direct conversations and messages with testers
> and tracked every item in a written log with status and resolution (kept in
> the project repository). Around 27 distinct items came in. Highlights:
> testers asked for per-macro goals, not just calories (shipped: per-weekday
> min/max targets for protein/carbs/fat with progress bars); reported that
> barcode scanning sometimes missed (shipped: consensus capture across frames,
> torch toggle, higher camera resolution); wanted liquids defined in ml, not
> grams (shipped: g/ml basis for custom foods); found the AI photo estimate
> off for ambiguous dishes (shipped: optional text hint; later removed the
> weak on-device model entirely based on uniformly negative feedback); asked
> for collapsible meal groups, editable custom foods, fiber/saturated-fat/
> sugar/salt tracking, and a Health Connect full resync. Critical feedback
> ("the app felt generic, some surfaces were hard to read") drove a full
> design refresh with better contrast, calmer status colors and an
> accessibility typeface picker.

---

## Section 2 — About your app

### Who is the intended audience of your app?

> Adults (18+) in Switzerland, Germany, Austria, France and Italy — and
> English speakers generally — who want to track calories and nutrients
> without ads, subscriptions or creating an account. It particularly serves
> privacy-conscious users: everything is stored locally on the device, there
> is no backend and no sign-up. The app is fully localized in German, French,
> Italian and English and bundles a Swiss food database alongside
> OpenFoodFacts and USDA data, so it fits the local food landscape of its
> target countries. It is not directed at children.

### How does your app provide value to this audience?

> Knabberfuchs is a completely free, ad-free, subscription-free calorie and
> macro tracker with no account requirement. Its value: (1) privacy — all
> data lives in a local database on the phone, with user-controlled ZIP
> backup/restore; (2) speed of logging — barcode scanning, offline food
> databases (bundled Swiss + USDA data work with no network), nutrition-label
> OCR, reusable recipes, and an optional AI photo estimate using the user's
> own API key; (3) honest goal tracking — per-weekday min/max targets for
> calories and a configurable set of nutrients, with optional Health Connect
> sync and activity-adjusted budgets; (4) accessibility — a typeface picker
> including Atkinson Hyperlegible and OpenDyslexic, full dark mode, and
> status colors designed to inform rather than alarm.

---

## Section 3 — Production readiness

### What changes did you make to your app based on your closed test?

> Over 20 closed-track releases (1.0.x through 1.3.1), directly from tester
> feedback: added per-weekday macro targets with progress bars; hardened the
> barcode scanner (multi-frame consensus, torch, higher resolution); added a
> g/ml basis for custom foods; reordered nutrition fields to match printed
> Swiss/EU labels; made meal groups collapsible; added editing and deletion
> of custom foods; added recipe servings at creation from an ingredient list;
> fixed accented offline search, midnight-crossing dinners, and custom meal
> names being overwritten; added Health Connect full resync and
> activity-adjusted calorie budgets; removed a weak on-device photo model
> after uniformly negative feedback and replaced it with a better flow; and
> executed a full design overhaul (contrast, dark mode, accessibility
> typefaces) in response to readability complaints. Every item was tracked
> to resolution in a written feedback log.

### How have you decided your app is ready for production?

> Three signals. First, the feedback loop has converged: recent closed-track
> builds produced polish items rather than functional complaints, testers use
> the app daily without issues, and there were no crashes or ANRs in Play
> Console vitals during the test. Second, engineering quality gates: every
> release passes a CI pipeline (static analysis + an automated test suite
> spanning 40+ test files, including golden-image UI tests) before a build
> can be tagged and shipped; the release process itself is automated and was
> exercised 20+ times during the test. Third, the identical app has already
> passed Apple's review and is live on the iOS App Store, where it runs for
> real users. The store listing (descriptions, screenshots, data-safety form)
> is complete in all four languages.

---

## After access is granted

1. **Promote the current build** — Production → Create new release → add
   **1.3.1 (37)** from the artifact library (no rebuild needed; it's the exact
   AAB the testers ran). Reuse the build-37 changelogs from
   `fastlane/metadata/android/<locale>/changelogs/37.txt` as release notes.
   Alternatively `python3 tool/play_upload_aab.py production` uploads/assigns a
   fresh AAB — the Console promote flow is preferred since it ships the tested
   binary bit-for-bit.
2. **Staged rollout** — start at 10–20%, watch vitals for a few days, then
   ramp to 100%. (Closed-testing tracks used `completed` releases; production
   supports percentage rollout.)
3. **Country availability** — confirm the production country list (at minimum
   CH/DE/AT/FR/IT + English-speaking markets) before rollout.
4. **First production Play review** may take longer than track updates —
   expect up to a few days.
5. **Update the docs** — flip the status line in `CLAUDE.md` ("Android in Play
   closed testing" → live) and note the date here and in `PLAN.md`.
6. The Phase 15/16 work (configurable nutrients + Health Connect budget) on
   `main` ships as the *next* feature release after production is live —
   don't fold it into the promotion.
