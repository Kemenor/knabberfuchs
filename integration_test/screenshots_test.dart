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
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/home_shell.dart';

/// Generates App Store screenshots. Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart -d SIMULATOR_ID
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Representative day — same foods/macros as the Play Store screenshots,
  // organised into named meal groups (matches the app's "name meals by time").
  final meals = <Map<String, dynamic>>[
    {
      'group': 'Breakfast 07:42', 'meal': MealType.breakfast,
      'foods': [
        {'name': 'Greek yogurt, plain', 'g': 150.0, 'kcal': 59.0, 'p': 10.0, 'c': 3.6, 'f': 0.4},
        {'name': 'Granola', 'g': 45.0, 'kcal': 471.0, 'p': 10.0, 'c': 64.0, 'f': 20.0},
        {'name': 'Blueberries', 'g': 80.0, 'kcal': 57.0, 'p': 0.7, 'c': 14.0, 'f': 0.3},
        {'name': 'Coffee with milk', 'g': 200.0, 'kcal': 20.0, 'p': 1.0, 'c': 2.0, 'f': 1.0},
      ],
    },
    {
      'group': 'Lunch 12:35', 'meal': MealType.lunch,
      'foods': [
        {'name': 'Chicken breast, grilled', 'g': 180.0, 'kcal': 165.0, 'p': 31.0, 'c': 0.0, 'f': 3.6},
        {'name': 'Basmati rice, cooked', 'g': 180.0, 'kcal': 130.0, 'p': 2.7, 'c': 28.0, 'f': 0.3},
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
    tester.platformDispatcher.localeTestValue = const Locale('en');

    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const CalorieApp()),
    );

    final db = container.read(dbProvider);
    await db.setSetting('appLocale', 'en');

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
          sName: f['name'] as String,
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
      RecipesCompanion.insert(name: 'Chicken rice bowl', servings: const Value(2)),
      [
        RecipeItemsCompanion.insert(recipeId: 0, sName: 'Chicken breast, grilled',
            grams: 300.0, sKcal100: 165.0, sProtein100: const Value(31.0),
            sCarb100: const Value(0.0), sFat100: const Value(3.6)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: 'Basmati rice, cooked',
            grams: 300.0, sKcal100: 130.0, sProtein100: const Value(2.7),
            sCarb100: const Value(28.0), sFat100: const Value(0.3)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: 'Broccoli, steamed',
            grams: 150.0, sKcal100: 34.0, sProtein100: const Value(2.8),
            sCarb100: const Value(7.0), sFat100: const Value(0.4)),
      ],
    );
    await db.createRecipe(
      RecipesCompanion.insert(name: 'Overnight oats', servings: const Value(1)),
      [
        RecipeItemsCompanion.insert(recipeId: 0, sName: 'Rolled oats', grams: 50.0,
            sKcal100: 389.0, sProtein100: const Value(17.0),
            sCarb100: const Value(66.0), sFat100: const Value(7.0)),
        RecipeItemsCompanion.insert(recipeId: 0, sName: 'Milk, semi-skimmed',
            grams: 200.0, sKcal100: 47.0, sProtein100: const Value(3.4),
            sCarb100: const Value(5.0), sFat100: const Value(1.5)),
      ],
    );
    await settle(tester);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    Future<void> shot(String name) async {
      await settle(tester);
      await binding.takeScreenshot(name);
    }

    void tab(int i) => container.read(homeTabProvider.notifier).set(i);

    // Tap a widget by its (English) label; returns false if not found so each
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

    // The marketing set (matches the Android Play listing), minus "recognise"
    // (a live AI result) which can't be reproduced deterministically in a test.

    // 1. Day hero (meal-grouped)
    tab(0);
    await shot('01_day');

    // 2. Quick add (capture menu → Quick add)
    try {
      tab(0);
      await tapFab('dayCapture');
      if (await tapText('Quick add')) await shot('02_quicklog');
      await tester.tapAt(const Offset(20, 20)); // dismiss any open sheet
      await settle(tester);
    } catch (_) {}

    // 3. Add food with live search results from the food database
    try {
      tab(0);
      await tapFab('dayAddFood');
      final search = find.byType(TextField);
      if (search.evaluate().isNotEmpty) {
        await tester.enterText(search.first, 'Chicken');
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
      if (await tapText('Chicken rice bowl')) {
        await shot('05_recipe');
        await tester.pageBack();
        await settle(tester);
      }
    } catch (_) {}

    // 6. Offline regions (Settings → Offline regions)
    try {
      tab(2);
      if (await tapRow('Offline regions')) {
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
        if (find.text('App language').evaluate().isNotEmpty) break;
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
        await tester.pump(const Duration(milliseconds: 80));
      }
      if (await tapText('App language')) {
        await shot('07_language');
      }
    } catch (_) {}

    // 8. Settings overview (bonus — not in the marketing set)
    try {
      tab(2);
      await shot('08_settings');
    } catch (_) {}
  });
}
