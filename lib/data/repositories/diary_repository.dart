import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/database.dart';

/// Reads/writes the daily diary. Every log captures a per-100g nutrition
/// snapshot so later edits to the source food never rewrite history.
class DiaryRepository {
  final AppDatabase db;

  DiaryRepository(this.db);

  Stream<List<Entry>> watchDay(String day) => db.watchDay(day);

  Future<List<String>> recentDays() => db.daysWithEntries();

  /// Log a catalog food into a day/meal at [grams].
  Future<void> logFood({
    required Food food,
    required double grams,
    required MealType meal,
    required String day,
  }) async {
    await db.addEntry(EntriesCompanion.insert(
      day: day,
      mealType: meal,
      grams: grams,
      foodId: Value(food.id),
      sName: food.name,
      sKcal100: food.kcal100,
      sProtein100: Value(food.protein100),
      sCarb100: Value(food.carb100),
      sFat100: Value(food.fat100),
      sMicrosJson: Value(food.microsJson),
    ));
    await db.bumpFoodUsage(food.id);
  }

  /// Log a raw snapshot (used by recipes / imported items with no catalog row).
  Future<void> logSnapshot({
    required String name,
    required double kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    String? microsJson,
    required double grams,
    required MealType meal,
    required String day,
  }) async {
    await db.addEntry(EntriesCompanion.insert(
      day: day,
      mealType: meal,
      grams: grams,
      sName: name,
      sKcal100: kcal100,
      sProtein100: Value(protein100),
      sCarb100: Value(carb100),
      sFat100: Value(fat100),
      sMicrosJson: Value(microsJson),
    ));
  }

  Future<void> editEntry(Entry entry,
          {required double grams, required MealType meal}) =>
      db.updateEntry(entry.copyWith(grams: grams, mealType: meal));

  Future<void> deleteEntry(int id) => db.deleteEntry(id);
}
