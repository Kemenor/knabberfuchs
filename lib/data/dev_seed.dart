import 'package:drift/drift.dart' show Value;

import '../core/date_x.dart';
import '../domain/enums.dart';
import 'db/database.dart';

/// Debug-only sample data so the app can be explored / screenshotted with a
/// realistic diary, history, and cookbook. Never ships: only runs when launched
/// with `--dart-define=SEED=1`, and is idempotent (a `devSeeded` flag guards it).
///
/// Seeds: today (named meal groups), ~2 weeks of history with varied totals
/// (so Trends shows under/in-range/over), and a few recipes.
Future<void> maybeSeedDevData(AppDatabase db) async {
  if (await db.getSetting('devSeeded') == '1') return;

  // Default targets so the status colours + bars have something to read against:
  // a kcal range, a protein floor (min), and carb/fat ceilings (max).
  await db.setSetting('defaultKcalMin', '1800');
  await db.setSetting('defaultKcalMax', '2200');
  await db.setSetting('defaultProteinMin', '120');
  await db.setSetting('defaultCarbMax', '260');
  await db.setSetting('defaultFatMax', '80');

  final today = DayKey.today();

  // --- Today: realistic named meal groups -----------------------------------
  final breakfast = await db.createEntryGroup(today, 'Breakfast 07:42');
  await _add(
    db,
    today,
    MealType.breakfast,
    breakfast,
    0,
    'Scrambled eggs',
    150,
    155,
    13,
    1.1,
    11,
  );
  await _add(
    db,
    today,
    MealType.breakfast,
    breakfast,
    1,
    'Wholegrain toast',
    80,
    250,
    9,
    43,
    3.5,
  );
  await _add(
    db,
    today,
    MealType.breakfast,
    breakfast,
    2,
    'Latte',
    250,
    32,
    3.2,
    4.8,
    0.6,
  );

  final lunch = await db.createEntryGroup(today, 'Lunch 12:35');
  await _add(
    db,
    today,
    MealType.lunch,
    lunch,
    0,
    'Chicken & rice bowl',
    420,
    165,
    12,
    18,
    4.2,
  );

  // --- History: ~2 weeks of varied daily totals -----------------------------
  // A mix that lands under / in-range / over a 1800–2200 kcal target.
  const totals = [
    1980, 2080, 1660, 2320, 1900, 2040, 1740, //
    2200, 1850, 2410, 1600, 2010, 1950, 2150,
  ];
  for (var d = 1; d <= totals.length; d++) {
    await _seedDay(db, DayKey.shift(today, -d), totals[d - 1].toDouble());
  }

  // --- Cookbook -------------------------------------------------------------
  await db.createRecipe(
    RecipesCompanion.insert(
      name: 'Chicken rice bowl',
      servings: const Value(2),
    ),
    [
      _item('Chicken breast, grilled', 300, 165, 31, 0, 3.6),
      _item('Basmati rice, cooked', 300, 130, 2.7, 28, 0.3),
      _item('Broccoli, steamed', 150, 34, 2.8, 7, 0.4),
    ],
  );
  await db.createRecipe(
    RecipesCompanion.insert(name: 'Overnight oats', servings: const Value(1)),
    [
      _item('Rolled oats', 50, 389, 17, 66, 7),
      _item('Milk, semi-skimmed', 200, 47, 3.4, 5, 1.5),
      _item('Blueberries', 60, 57, 0.7, 14, 0.3),
    ],
  );
  await db.createRecipe(
    RecipesCompanion.insert(name: 'Lentil curry', servings: const Value(4)),
    [
      _item('Red lentils', 300, 354, 24, 60, 1),
      _item('Coconut milk', 200, 230, 2.3, 6, 24),
      _item('Onion', 150, 40, 1.1, 9, 0.1),
      _item('Tomato', 200, 18, 0.9, 3.9, 0.2),
      _item('Spinach', 100, 23, 2.9, 3.6, 0.4),
    ],
  );

  await db.setSetting('devSeeded', '1');
}

/// A history day as a single snapshot entry totalling exactly [kcal]
/// (grams = 100 + sKcal100 = kcal ⇒ day total = kcal). Macros from a
/// 30/45/25 % energy split, so the per-macro Trends views are realistic too.
Future<void> _seedDay(AppDatabase db, String day, double kcal) async {
  await _add(
    db,
    day,
    MealType.lunch,
    null,
    0,
    'Daily intake',
    100,
    kcal,
    kcal * 0.30 / 4,
    kcal * 0.45 / 4,
    kcal * 0.25 / 9,
  );
}

Future<void> _add(
  AppDatabase db,
  String day,
  MealType meal,
  int? groupId,
  int sort,
  String name,
  double grams,
  double kcal100,
  double p,
  double c,
  double f,
) {
  return db.addEntry(
    EntriesCompanion.insert(
      day: day,
      mealType: meal,
      grams: grams,
      sName: name,
      sKcal100: kcal100,
      sProtein100: Value(p),
      sCarb100: Value(c),
      sFat100: Value(f),
      sortIndex: Value(sort),
      groupId: Value(groupId),
    ),
  );
}

RecipeItemsCompanion _item(
  String name,
  double grams,
  double kcal,
  double p,
  double c,
  double f,
) {
  return RecipeItemsCompanion.insert(
    recipeId: 0,
    sName: name,
    grams: grams,
    sKcal100: kcal,
    sProtein100: Value(p),
    sCarb100: Value(c),
    sFat100: Value(f),
  );
}
