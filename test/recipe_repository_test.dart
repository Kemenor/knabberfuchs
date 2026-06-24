import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/repositories/diary_repository.dart';
import 'package:calorie_tracker/data/repositories/recipe_repository.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/recipe_share.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RecipeRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RecipeRepository(db, DiaryRepository(db));
  });
  tearDown(() => db.close());

  const share = RecipeShare(
    name: 'Chili',
    servings: 4,
    items: [
      RecipeShareItem(name: 'Beans', grams: 400, kcal100: 100, protein100: 7),
      RecipeShareItem(name: 'Beef', grams: 400, kcal100: 250, protein100: 26),
    ],
  );

  test('create + toShare round-trips items', () async {
    final id = await repo.create(
      name: share.name,
      servings: share.servings,
      items: share.items,
    );
    final recipe = (await db.allRecipes()).firstWhere((r) => r.id == id);
    final items = await repo.items(id);
    final back = repo.toShare(recipe, items);
    expect(back.name, 'Chili');
    expect(back.items.length, 2);
    expect(back.totalGrams, 800);
    // 400g*1.0 + 400g*2.5 = 400 + 1000 = 1400 kcal
    expect(back.total.kcal, closeTo(1400, 0.001));
  });

  test('logPortionGrams logs each ingredient scaled by the portion', () async {
    // One of 4 servings = 200 g of 800 g total -> 1/4 of each ingredient.
    final grams = repo.portionGramsForServings(share);
    expect(grams, 200);

    await repo.logPortionGrams(
      share: share,
      grams: grams,
      meal: MealType.dinner,
      day: '2026-06-17',
    );
    final entries = await db.watchDay('2026-06-17').first;
    expect(entries.length, 2); // one entry per ingredient, not a single dish
    expect(entries.map((e) => e.sName), containsAll(['Beans', 'Beef']));
    // each 400 g ingredient scaled by 0.25 -> 100 g
    for (final e in entries) {
      expect(e.grams, closeTo(100, 0.001));
    }
    // total still 1/4 of 1400 = 350 kcal
    final totalKcal = entries.fold<double>(
      0,
      (s, e) => s + e.sKcal100 * e.grams / 100,
    );
    expect(totalKcal, closeTo(350, 0.001));
  });

  test('portions across two days split the batch', () async {
    await repo.logPortionGrams(
      share: share,
      grams: 200,
      meal: MealType.dinner,
      day: '2026-06-17',
    );
    await repo.logPortionGrams(
      share: share,
      grams: 200,
      meal: MealType.lunch,
      day: '2026-06-18',
    );
    // two ingredients -> two entries per portion
    expect((await db.watchDay('2026-06-17').first).length, 2);
    expect((await db.watchDay('2026-06-18').first).length, 2);
  });

  test('importShare persists a shared recipe', () async {
    final id = await repo.importShare(share);
    expect(await repo.items(id), hasLength(2));
  });
}
