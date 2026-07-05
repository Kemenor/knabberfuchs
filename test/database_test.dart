import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seeds 7 weekday targets on create, all null', () async {
    final t = await db.allTargets();
    expect(t.length, 7);
    expect(t.every((x) => x.kcalMin == null && x.kcalMax == null), isTrue);
  });

  test('upsertFood dedups on (source, externalId)', () async {
    final id1 = await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.openFoodFacts,
        externalId: const Value('123'),
        name: 'Cola',
        kcal100: 42,
      ),
    );
    final id2 = await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.openFoodFacts,
        externalId: const Value('123'),
        name: 'Cola Updated',
        kcal100: 43,
      ),
    );
    expect(id1, id2);
    final found = await db.searchFoodsLocal('Cola');
    expect(found.length, 1);
    expect(found.first.name, 'Cola Updated');
    expect(found.first.kcal100, 43);
  });

  test(
    'upsertFood update path returns the row id, not last_insert_rowid',
    () async {
      // Regression: insert() without RETURNING reports last_insert_rowid(),
      // which SQLite leaves at the most recent *actual* insert when the upsert
      // takes the DO UPDATE path. Pollute it with an unrelated insert first.
      final colaId = await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.openFoodFacts,
          externalId: const Value('123'),
          name: 'Cola',
          kcal100: 42,
        ),
      );
      await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.openFoodFacts,
          externalId: const Value('456'),
          name: 'Water',
          kcal100: 0,
        ),
      );
      final again = await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.openFoodFacts,
          externalId: const Value('123'),
          name: 'Cola Zero',
          kcal100: 0,
        ),
      );
      expect(again, colaId);
      expect((await db.foodById(again))!.name, 'Cola Zero');
    },
  );

  test('custom foods with null externalId stay distinct', () async {
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        name: 'Granny Apple',
        kcal100: 52,
      ),
    );
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        name: 'Granny Pear',
        kcal100: 57,
      ),
    );
    final found = await db.searchFoodsLocal('Granny');
    expect(found.length, 2);
  });

  test('tokenized search matches USDA formal names via synonyms', () async {
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        externalId: const Value('p1'),
        name: 'Peppers, sweet, green, raw',
        kcal100: 20,
      ),
    );
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        externalId: const Value('c1'),
        name: 'Candies, milk chocolate',
        kcal100: 535,
      ),
    );
    final r = await db.searchFoodsLocal('bell pepper');
    expect(r.map((f) => f.name), contains('Peppers, sweet, green, raw'));
    expect(r.map((f) => f.name), isNot(contains('Candies, milk chocolate')));
  });

  test(
    'accented queries match accented stored names and search text',
    () async {
      await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.custom,
          name: 'Birchermüesli, zubereitet',
          kcal100: 86,
        ),
      );
      // As typed with accents: the unfolded variant matches the stored name.
      expect((await db.searchFoodsLocal('müesli')).length, 1);
      expect((await db.searchFoodsLocal('Crème')).length, 0);
      // Folded tokens match diacritic-free search_text spellings.
      await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.custom,
          externalId: const Value('st1'),
          name: 'Crunchy Mix',
          searchText: const Value('muesli mix crunchy'),
          kcal100: 420,
        ),
      );
      expect((await db.searchFoodsLocal('Müesli')).length, 2);
    },
  );

  test('ranks simpler/shorter names first', () async {
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        externalId: const Value('a'),
        name: 'Potatoes, au gratin, dry mix, prepared with water and milk',
        kcal100: 93,
      ),
    );
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        externalId: const Value('b'),
        name: 'Potatoes, raw',
        kcal100: 77,
      ),
    );
    final r = await db.searchFoodsLocal('potatoes');
    expect(r.first.name, 'Potatoes, raw');
  });

  test('watchDay reflects added entries', () async {
    const day = '2026-06-17';
    await db.addEntry(
      EntriesCompanion.insert(
        day: day,
        mealType: MealType.breakfast,
        grams: 100,
        sName: 'Egg',
        sKcal100: 155,
      ),
    );
    final entries = await db.watchDay(day).first;
    expect(entries.length, 1);
    expect(entries.first.sName, 'Egg');
  });

  test('entry groups: create, watch, prune empties', () async {
    final gid = await db.createEntryGroup('2026-06-17', 'Meal 12:00');
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-06-17',
        mealType: MealType.snack,
        groupId: Value(gid),
        grams: 100,
        sName: 'X',
        sKcal100: 50,
      ),
    );
    expect((await db.watchGroups('2026-06-17').first).length, 1);

    // prune keeps non-empty groups
    await db.pruneEmptyGroups('2026-06-17');
    expect((await db.watchGroups('2026-06-17').first).length, 1);

    // remove the only entry -> group is empty -> prune removes it
    final e = (await db.watchDay('2026-06-17').first).single;
    await db.deleteEntry(e.id);
    await db.pruneEmptyGroups('2026-06-17');
    expect((await db.watchGroups('2026-06-17').first), isEmpty);
  });

  test('deleting a group cascades its entries', () async {
    final gid = await db.createEntryGroup('2026-06-17', 'M');
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-06-17',
        mealType: MealType.snack,
        groupId: Value(gid),
        grams: 100,
        sName: 'X',
        sKcal100: 50,
      ),
    );
    await db.deleteEntryGroup(gid);
    expect(await db.watchDay('2026-06-17').first, isEmpty);
  });

  test('OCR mapping round-trips and resolves to a food', () async {
    final id = await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        name: 'Crème Fraîche 30%',
        kcal100: 300,
      ),
    );
    await db.setOcrMapping('creme fraiche', id);
    expect((await db.mappedFoodForOcr('creme fraiche'))?.id, id);
    expect(await db.mappedFoodForOcr('unknown'), isNull);

    // re-mapping overwrites
    final id2 = await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        name: 'Light Crème Fraîche',
        kcal100: 160,
      ),
    );
    await db.setOcrMapping('creme fraiche', id2);
    expect((await db.mappedFoodForOcr('creme fraiche'))?.id, id2);
  });

  test('updateRecipe replaces fields and items', () async {
    final id = await db.createRecipe(RecipesCompanion.insert(name: 'A'), [
      RecipeItemsCompanion.insert(
        recipeId: 0,
        sName: 'Oats',
        grams: 50,
        sKcal100: 389,
      ),
    ]);
    await db.updateRecipe(
      id,
      RecipesCompanion(name: const Value('B'), servings: const Value(3)),
      [
        RecipeItemsCompanion.insert(
          recipeId: 0,
          sName: 'Rice',
          grams: 100,
          sKcal100: 130,
        ),
        RecipeItemsCompanion.insert(
          recipeId: 0,
          sName: 'Beans',
          grams: 80,
          sKcal100: 90,
        ),
      ],
    );
    final r = await db.recipeById(id);
    expect(r!.name, 'B');
    expect(r.servings, 3);
    final items = await db.itemsForRecipe(id);
    expect(items.map((i) => i.sName), ['Rice', 'Beans']);
  });

  test('settings round-trip', () async {
    await db.setSetting('unit', 'kcal');
    expect(await db.getSetting('unit'), 'kcal');
    await db.setSetting('unit', 'kJ');
    expect(await db.getSetting('unit'), 'kJ');
  });

  test('target update persists', () async {
    await db.setTarget(0, const TargetsCompanion(kcalMax: Value(2200)));
    final t = await db.targetForWeekday(0);
    expect(t!.kcalMax, 2200);
  });

  test('per-macro target columns round-trip', () async {
    await db.setTarget(
      1,
      const TargetsCompanion(
        proteinMin: Value(140),
        carbMax: Value(250),
        fatMax: Value(70),
      ),
    );
    final t = await db.targetForWeekday(1);
    expect(t!.proteinMin, 140);
    expect(t.proteinMax, isNull);
    expect(t.carbMax, 250);
    expect(t.fatMax, 70);
  });

  test('recipe with items round-trips and cascades on delete', () async {
    final id = await db
        .createRecipe(RecipesCompanion.insert(name: 'Porridge'), [
          RecipeItemsCompanion.insert(
            recipeId: 0,
            sName: 'Oats',
            grams: 50,
            sKcal100: 389,
          ),
          RecipeItemsCompanion.insert(
            recipeId: 0,
            sName: 'Milk',
            grams: 200,
            sKcal100: 64,
          ),
        ]);
    final items = await db.itemsForRecipe(id);
    expect(items.length, 2);
    await db.deleteRecipe(id);
    expect(await db.itemsForRecipe(id), isEmpty);
  });
}
