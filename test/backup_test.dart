import 'dart:convert';
import 'dart:io';

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
  final apple = await repo.createFood(
    name: 'Apple',
    kcal100: 52,
    barcode: '7610000000001',
    densityGPerMl: 0.95,
  );
  await db.bumpFoodUsage(apple.id);
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
    final food = (await dst.allCustomFoods()).single;
    expect(food.name, 'Apple');
    expect(food.barcode, '7610000000001');
    expect(food.externalId, '7610000000001');
    expect(food.densityGPerMl, 0.95);
    expect(food.usageCount, 1);
    expect(food.lastUsedAt, isNotNull);
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

  test('restore survives food-id collisions with catalog rows', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    await _seed(src);
    final map =
        jsonDecode(
              jsonEncode(await buildBackupMap(src, exportedAt: DateTime(2026))),
            )
            as Map<String, dynamic>;

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);
    // Occupy the backup's custom-food id with a catalog row, like the Swiss
    // seed / OFF cache would on a real device.
    final seededId = await dst.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.swissFcdb,
        externalId: const Value('seed-1'),
        name: 'Seeded bread',
        kcal100: 250,
      ),
    );
    expect(seededId, (map['customFoods'] as List).single['id']);

    await restoreBackupMap(dst, map);

    final restored = (await dst.allCustomFoods()).single;
    expect(restored.name, 'Apple');
    expect(restored.id, isNot(seededId));
    expect((await dst.foodById(seededId))!.name, 'Seeded bread');
    expect((await dst.allEntries()).single.sName, 'Apple');
  });

  test('v1 fixture restores with the legacy kcal target migrated', () async {
    final map =
        jsonDecode(File('test/fixtures/backup_v1.json').readAsStringSync())
            as Map<String, dynamic>;

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A bound the v1 backup predates must survive the restore untouched.
    await db.setTarget(0, const TargetsCompanion(proteinMax: Value(150)));

    await restoreBackupMap(db, map);

    final entry = (await db.allEntries()).single;
    expect(entry.sName, 'Spaghetti');
    expect(entry.groupId, isNull); // v1 had no entry groups

    expect((await db.allCustomFoods()).single.name, 'Oat cookie');
    final recipes = await db.allRecipes();
    expect(recipes.single.name, 'Muesli');
    expect((await db.itemsForRecipe(recipes.single.id)).single.sName, 'Oats');

    final monday = (await db.targetForWeekday(0))!;
    expect(monday.kcalMax, 2000); // legacy `kcal` -> kcalMax
    expect(monday.kcalMin, isNull);
    expect(monday.proteinMax, 150); // absent field not null-overwritten
    expect((await db.targetForWeekday(1))!.kcalMax, isNull);

    // The v1 settings key is renamed, mirroring the DB v2 migration.
    expect(await db.getSetting('defaultKcalMax'), '2100');
    expect(await db.getSetting('defaultKcalTarget'), isNull);
    expect(await db.getSetting('groupByMeal'), 'true');
  });

  test('export strips the Gemini key; restore keeps device key', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);
    await db.setSetting('geminiApiKey', 'secret-key-123');

    final map = await buildBackupMap(db, exportedAt: DateTime(2026, 6, 17));
    expect((map['settings'] as Map).containsKey('geminiApiKey'), isFalse);
    expect(jsonEncode(map), isNot(contains('secret-key-123')));
    // Non-credential settings still export.
    expect((map['settings'] as Map)['groupByMeal'], 'false');

    await restoreBackupMap(
      db,
      jsonDecode(jsonEncode(map)) as Map<String, dynamic>,
    );
    expect(await db.getSetting('geminiApiKey'), 'secret-key-123');
  });

  test('restore rejects a backup written by a newer app version', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);

    final map = await buildBackupMap(db, exportedAt: DateTime(2026, 6, 17));
    map['schemaVersion'] = backupSchemaVersion + 1;

    await expectLater(restoreBackupMap(db, map), throwsFormatException);
    // The rejected import must not have wiped anything.
    expect((await db.allEntries()).length, 1);
    expect((await db.allCustomFoods()).length, 1);
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
