import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:calorie_tracker/app.dart';
import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/food/recognize_food_flow.dart';
import 'package:calorie_tracker/ui/home_shell.dart';

import 'meal_fixture.dart';

/// Generates App Store screenshots, one locale per run. Pass the locale with
/// `--dart-define=LOCALE=<en|de|fr|it>` (defaults to en):
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart \
///     --dart-define=LOCALE=de -d SIMULATOR_ID
///
/// Screenshots land in `screenshots/<locale>/NN_name.png`. Navigation taps the
/// *localized* labels (via AppLocalizations) and the seeded demo data is
/// translated too, so every locale's set looks native.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const loc = String.fromEnvironment('LOCALE', defaultValue: 'en');

  // Localized demo strings, keyed by a stable id then language (falls back to
  // en). Macros/quantities are language-independent and stay inline below.
  const strings = <String, Map<String, String>>{
    'breakfast': {
      'en': 'Breakfast 07:42', 'de': 'Frühstück 07:42',
      'fr': 'Petit-déjeuner 07:42', 'it': 'Colazione 07:42',
    },
    'lunch': {
      'en': 'Lunch 12:35', 'de': 'Mittagessen 12:35',
      'fr': 'Déjeuner 12:35', 'it': 'Pranzo 12:35',
    },
    'greekYogurt': {
      'en': 'Greek yogurt, plain', 'de': 'Griechischer Joghurt, natur',
      'fr': 'Yaourt grec nature', 'it': 'Yogurt greco, naturale',
    },
    'granola': {
      'en': 'Granola', 'de': 'Granola', 'fr': 'Granola', 'it': 'Granola',
    },
    'blueberries': {
      'en': 'Blueberries', 'de': 'Heidelbeeren',
      'fr': 'Myrtilles', 'it': 'Mirtilli',
    },
    'coffeeMilk': {
      'en': 'Coffee with milk', 'de': 'Kaffee mit Milch',
      'fr': 'Café au lait', 'it': 'Caffè con latte',
    },
    'chickenBreast': {
      'en': 'Chicken breast, grilled', 'de': 'Hähnchenbrust, gegrillt',
      'fr': 'Blanc de poulet grillé', 'it': 'Petto di pollo, grigliato',
    },
    'basmatiRice': {
      'en': 'Basmati rice, cooked', 'de': 'Basmatireis, gekocht',
      'fr': 'Riz basmati, cuit', 'it': 'Riso basmati, cotto',
    },
    'broccoli': {
      'en': 'Broccoli, steamed', 'de': 'Brokkoli, gedämpft',
      'fr': 'Brocoli, vapeur', 'it': 'Broccoli, al vapore',
    },
    'oats': {
      'en': 'Rolled oats', 'de': 'Haferflocken',
      'fr': "Flocons d'avoine", 'it': "Fiocchi d'avena",
    },
    'milk': {
      'en': 'Milk, semi-skimmed', 'de': 'Milch, teilentrahmt',
      'fr': 'Lait demi-écrémé', 'it': 'Latte parzialmente scremato',
    },
    'recipeBowl': {
      'en': 'Chicken rice bowl', 'de': 'Hähnchen-Reis-Bowl',
      'fr': 'Bowl poulet et riz', 'it': 'Bowl di pollo e riso',
    },
    'recipeOats': {
      'en': 'Overnight oats', 'de': 'Overnight Oats',
      'fr': 'Overnight oats', 'it': 'Overnight oats',
    },
    // A query with hits in every locale's bundled Swiss food data.
    'searchQuery': {
      'en': 'Banana', 'de': 'Banane', 'fr': 'Banane', 'it': 'Banana',
    },
  };
  String tr(String k) => strings[k]![loc] ?? strings[k]!['en']!;

  // Representative day — translated foods organised into named meal groups.
  final meals = <Map<String, dynamic>>[
    {
      'group': tr('breakfast'), 'meal': MealType.breakfast,
      'foods': [
        {'k': 'greekYogurt', 'g': 150.0, 'kcal': 59.0, 'p': 10.0, 'c': 3.6, 'f': 0.4},
        {'k': 'granola', 'g': 45.0, 'kcal': 471.0, 'p': 10.0, 'c': 64.0, 'f': 20.0},
        {'k': 'blueberries', 'g': 80.0, 'kcal': 57.0, 'p': 0.7, 'c': 14.0, 'f': 0.3},
        {'k': 'coffeeMilk', 'g': 200.0, 'kcal': 20.0, 'p': 1.0, 'c': 2.0, 'f': 1.0},
      ],
    },
    {
      'group': tr('lunch'), 'meal': MealType.lunch,
      'foods': [
        {'k': 'chickenBreast', 'g': 180.0, 'kcal': 165.0, 'p': 31.0, 'c': 0.0, 'f': 3.6},
        {'k': 'basmatiRice', 'g': 180.0, 'kcal': 130.0, 'p': 2.7, 'c': 28.0, 'f': 0.3},
      ],
    },
  ];

  Future<void> settle(WidgetTester t) async {
    try {
      await t.pumpAndSettle(const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate, const Duration(seconds: 8));
    } catch (_) {
      await t.pump(const Duration(milliseconds: 500));
    }
  }

  testWidgets('App Store screenshots', (tester) async {
    await initializeDateFormatting();
    tester.platformDispatcher.localeTestValue = Locale(loc);

    final container = ProviderContainer(overrides: [
      // Feed the on-device classifier a bundled meal photo instead of the
      // native picker, so the "recognise" screenshot is fully automated.
      mealImagePickerProvider
          .overrideWithValue((_) async => base64Decode(mealJpegBase64)),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const CalorieApp()),
    );

    final db = container.read(dbProvider);
    await db.setSetting('appLocale', loc);

    // Wait out the first-run splash (Swiss food import); its spinner never
    // settles, so pump in a loop until HomeShell appears.
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.byType(HomeShell).evaluate().isNotEmpty) break;
    }

    // Seed the day as named meal groups.
    final day = DayKey.today();
    for (final m in meals) {
      final gid = await db.createEntryGroup(day, m['group'] as String);
      final foods = m['foods'] as List;
      for (var i = 0; i < foods.length; i++) {
        final f = foods[i] as Map;
        await db.addEntry(EntriesCompanion.insert(
          day: day,
          mealType: m['meal'] as MealType,
          grams: f['g'] as double,
          sName: tr(f['k'] as String),
          sKcal100: f['kcal'] as double,
          sProtein100: Value(f['p'] as double),
          sCarb100: Value(f['c'] as double),
          sFat100: Value(f['f'] as double),
          sortIndex: Value(i),
          groupId: Value(gid),
        ));
      }
    }
    container.read(selectedDayProvider.notifier).set(day);

    // A couple of recipes so the Recipes screens have content.
    await db.createRecipe(
      RecipesCompanion.insert(name: tr('recipeBowl'), servings: const Value(2)),
      [
        RecipeItemsCompanion.insert(recipeId: 0, sName: tr('chickenBreast'),
            grams: 300.0, sKcal100: 165.0, sProtein100: const Value(31.0),
            sCarb100: const Value(0.0), sFat100: const Value(3.6)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: tr('basmatiRice'),
            grams: 300.0, sKcal100: 130.0, sProtein100: const Value(2.7),
            sCarb100: const Value(28.0), sFat100: const Value(0.3)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: tr('broccoli'),
            grams: 150.0, sKcal100: 34.0, sProtein100: const Value(2.8),
            sCarb100: const Value(7.0), sFat100: const Value(0.4)),
      ],
    );
    await db.createRecipe(
      RecipesCompanion.insert(name: tr('recipeOats'), servings: const Value(1)),
      [
        RecipeItemsCompanion.insert(recipeId: 0, sName: tr('oats'), grams: 50.0,
            sKcal100: 389.0, sProtein100: const Value(17.0),
            sCarb100: const Value(66.0), sFat100: const Value(7.0)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: tr('milk'),
            grams: 200.0, sKcal100: 47.0, sProtein100: const Value(3.4),
            sCarb100: const Value(5.0), sFat100: const Value(1.5)),
      ],
    );
    await settle(tester);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    // Localized labels for the active locale, read from the live widget tree.
    AppLocalizations l10n() =>
        AppLocalizations.of(tester.element(find.byType(HomeShell).first));

    Future<void> shot(String name) async {
      await settle(tester);
      await binding.takeScreenshot('$loc/$name');
    }

    void tab(int i) => container.read(homeTabProvider.notifier).set(i);

    // Tap a widget by its (localized) label; returns false if not found so each
    // shot degrades gracefully instead of crashing the whole run.
    Future<bool> tapText(String text) async {
      final f = find.text(text);
      if (f.evaluate().isEmpty) return false;
      await tester.ensureVisible(f.first);
      await settle(tester);
      await tester.tap(f.first);
      await settle(tester);
      return true;
    }

    Future<void> tapFab(String heroTag) async {
      final fab = find.byWidgetPredicate(
          (w) => w is FloatingActionButton && w.heroTag == heroTag);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await settle(tester);
      }
    }

    // Settings is a long scroller — bring a row into view before tapping it
    // (off-screen rows in the lazy list aren't built, so find.text misses them).
    Future<bool> tapRow(String text) async {
      try {
        await tester.scrollUntilVisible(find.text(text), 250,
            scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      } catch (_) {}
      return tapText(text);
    }

    // The marketing set (matches the Android Play listing).

    // 1. Day hero (meal-grouped)
    tab(0);
    await shot('01_day');

    // 2. Quick add (capture menu → Quick add)
    try {
      tab(0);
      await tapFab('dayCapture');
      if (await tapText(l10n().quickAdd)) await shot('02_quicklog');
      await tester.tapAt(const Offset(20, 20)); // dismiss any open sheet
      await settle(tester);
    } catch (_) {}

    // 3. Add food with live search results from the food database
    try {
      tab(0);
      await tapFab('dayAddFood');
      final search = find.byType(TextField);
      if (search.evaluate().isNotEmpty) {
        await tester.enterText(search.first, tr('searchQuery'));
        await settle(tester);
      }
      await shot('03_search');
      await tester.pageBack();
      await settle(tester);
    } catch (_) {}

    // 4. Recipes list
    try {
      tab(1);
      await shot('04_recipes');
    } catch (_) {}

    // 5. A recipe, broken into its ingredients
    try {
      tab(1);
      if (await tapText(tr('recipeBowl'))) {
        await shot('05_recipe');
        await tester.pageBack();
        await settle(tester);
      }
    } catch (_) {}

    // 6. Offline regions (Settings → Offline regions)
    try {
      tab(2);
      if (await tapRow(l10n().settingsOfflineRegions)) {
        await shot('06_regions');
        await tester.pageBack();
        await settle(tester);
      }
    } catch (_) {}

    // 7. Language — the collapsible "App language" tile at the TOP of Settings.
    // Scroll back up to it (we may be scrolled down from the regions step),
    // then tap to expand the picker.
    try {
      tab(2);
      await settle(tester);
      for (var i = 0; i < 40; i++) {
        if (find.text(l10n().settingsLanguage).evaluate().isNotEmpty) break;
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
        await tester.pump(const Duration(milliseconds: 80));
      }
      if (await tapText(l10n().settingsLanguage)) {
        await shot('07_language');
      }
    } catch (_) {}

    // 8. Settings overview (bonus — not in the marketing set)
    try {
      tab(2);
      await shot('08_settings');
    } catch (_) {}

    // 9. Recognise a meal — the injected photo drives the on-device classifier;
    // capture the guess sheet ("Looks like…" + ranked dishes).
    try {
      tab(0);
      await settle(tester); // let the Day tab rebuild after leaving Settings
      await tapFab('dayCapture');
      if (await tapText(l10n().captureScanAi)) {
        for (var i = 0; i < 60; i++) {
          if (find.text(l10n().recognizeLooksLike).evaluate().isNotEmpty) break;
          await tester.pump(const Duration(milliseconds: 200));
        }
        await shot('09_recognize');
        await tester.tapAt(const Offset(20, 20)); // dismiss the sheet
        await settle(tester);
      }
    } catch (_) {}
  });
}
