import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FoodRepository(db, OffApi(), RegionPackStore());
  });
  tearDown(() => db.close());

  group('updateFood', () {
    test('overwrites the row in place, clearing dropped values', () async {
      final food = await repo.createFood(
        barcode: '7610000000000',
        name: 'Rivella',
        brand: 'Rivella AG',
        kcal100: 38,
        carb100: 9.2,
        sugar100: 9.0,
        densityGPerMl: 1.0,
      );

      final updated = await repo.updateFood(
        food.id,
        barcode: '7610000000000',
        name: 'Rivella Rot',
        kcal100: 39,
        carb100: 9.4,
        // brand and sugar left out -> cleared, not silently preserved
        densityGPerMl: 1.0,
      );

      expect(updated.id, food.id);
      expect(updated.name, 'Rivella Rot');
      expect(updated.kcal100, 39);
      expect(updated.carb100, 9.4);
      expect(updated.brand, isNull);
      expect(updated.sugar100, isNull);
      expect(updated.densityGPerMl, 1.0);
      expect(updated.source, FoodSource.custom);
    });

    test('changing the barcode updates this row, no duplicate appears', () async {
      final food = await repo.createFood(name: 'Birchermüesli', kcal100: 150);

      final updated = await repo.updateFood(
        food.id,
        barcode: '7610000000001',
        name: 'Birchermüesli',
        kcal100: 150,
      );

      expect(updated.id, food.id);
      expect(updated.barcode, '7610000000001');
      // A re-scan of the new barcode finds the edited food.
      final hit = await db.foodByExternal(FoodSource.custom, '7610000000001');
      expect(hit?.id, food.id);
    });

    test('deleteFood unlinks logged entries but keeps their snapshots', () async {
      final food = await repo.createFood(name: 'Zopf', kcal100: 320);
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-07-01',
          mealType: MealType.breakfast,
          grams: 80,
          foodId: Value(food.id),
          sName: food.name,
          sKcal100: food.kcal100,
        ),
      );

      await repo.deleteFood(food.id);

      expect(await db.foodById(food.id), isNull);
      final entry = (await db.allEntries()).single;
      expect(entry.foodId, isNull); // FK set-null, not cascade
      expect(entry.sName, 'Zopf');
      expect(entry.sKcal100, 320);
    });

    test('diary snapshots are untouched by a later edit', () async {
      final food = await repo.createFood(name: 'Quark', kcal100: 68);
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-07-01',
          mealType: MealType.breakfast,
          grams: 250,
          sName: food.name,
          sKcal100: food.kcal100,
        ),
      );

      await repo.updateFood(food.id, name: 'Magerquark', kcal100: 62);

      final entry = (await db.allEntries()).single;
      expect(entry.sName, 'Quark');
      expect(entry.sKcal100, 68);
    });
  });
}
