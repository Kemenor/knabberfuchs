import 'dart:convert';

import 'package:calorie_tracker/data/backup.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _seed(AppDatabase db) async {
  final repo = FoodRepository(db, OffApi(), RegionPackStore());
  final apple = await repo.createFood(name: 'Apple', kcal100: 52);
  final groupId = await db.createEntryGroup('2026-06-17', 'Breakfast');
  await db.addEntry(
    EntriesCompanion.insert(
      day: '2026-06-17',
      mealType: MealType.breakfast,
      grams: 150,
      groupId: Value(groupId),
      foodId: Value(apple.id),
      sName: 'Apple',
      sKcal100: 52,
      sProtein100: const Value(0.3),
    ),
  );
  await db.createRecipe(RecipesCompanion.insert(name: 'Salad'), [
    RecipeItemsCompanion.insert(
      recipeId: 0,
      sName: 'Lettuce',
      grams: 100,
      sKcal100: 15,
    ),
  ]);
  await db.setTarget(
    0,
    const TargetsCompanion(kcalMin: Value(1800), kcalMax: Value(2200)),
  );
  await db.setSetting('groupByMeal', 'false');
}

void main() {
  test('backup map round-trips through JSON into a fresh database', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    await _seed(src);

    final map = await buildBackupMap(src, exportedAt: DateTime(2026, 6, 17));
    // Ensure it's pure JSON (no drift objects leaking).
    final roundTripped = jsonDecode(jsonEncode(map)) as Map<String, dynamic>;

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);
    await restoreBackupMap(dst, roundTripped);

    expect((await dst.allEntries()).length, 1);
    expect((await dst.allCustomFoods()).single.name, 'Apple');
    final recipes = await dst.allRecipes();
    expect(recipes.single.name, 'Salad');
    expect(
      (await dst.itemsForRecipe(recipes.single.id)).single.sName,
      'Lettuce',
    );
    final target = (await dst.targetForWeekday(0))!;
    expect(target.kcalMin, 1800);
    expect(target.kcalMax, 2200);
    expect(await dst.getSetting('groupByMeal'), 'false');

    // The ad-hoc meal group and its membership survive the round-trip.
    final groups = await dst.watchGroups('2026-06-17').first;
    expect(groups.single.name, 'Breakfast');

    // Restored entry keeps its snapshot and group, but drops the food link.
    final entry = (await dst.allEntries()).single;
    expect(entry.sName, 'Apple');
    expect(entry.foodId, isNull);
    expect(entry.groupId, groups.single.id);
  });

  test('restore is idempotent / replaces existing data', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    await _seed(src);
    final map =
        jsonDecode(
              jsonEncode(await buildBackupMap(src, exportedAt: DateTime(2026))),
            )
            as Map<String, dynamic>;

    await restoreBackupMap(src, map); // restore onto itself
    expect((await src.allEntries()).length, 1);
    expect((await src.allCustomFoods()).length, 1);
  });

  test('buildEntriesCsv emits a header and one row per entry', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);
    final csv = buildEntriesCsv(await db.allEntries());
    final lines = csv.split('\n');
    expect(lines.first, 'day,meal,food,grams,kcal,protein_g,carb_g,fat_g');
    expect(lines.length, 2);
    expect(lines[1], startsWith('2026-06-17,Breakfast,Apple,150,78'));
  });
}
