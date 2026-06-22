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

  /// Log a catalog food into a day at [grams]. In meal mode pass [meal]; in
  /// track-by-day mode pass [groupId] (the ad-hoc meal group).
  Future<void> logFood({
    required Food food,
    required double grams,
    required MealType meal,
    required String day,
    int? groupId,
    String? displayName,
  }) async {
    await db.addEntry(EntriesCompanion.insert(
      day: day,
      mealType: meal,
      groupId: Value(groupId),
      grams: grams,
      foodId: Value(food.id),
      sName: displayName ?? food.name,
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
    int? groupId,
  }) async {
    await db.addEntry(EntriesCompanion.insert(
      day: day,
      mealType: meal,
      groupId: Value(groupId),
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

  /// Split a meal group into equal portions across [days]: each day gets a new
  /// group (same name) with every ingredient scaled to 1/N of its grams. The
  /// original group is replaced.
  Future<void> splitGroupAcrossDays({
    required int groupId,
    required List<String> days,
  }) async {
    if (days.isEmpty) return;
    final group = await db.entryGroupById(groupId);
    if (group == null) return;
    final items = await db.entriesForGroup(groupId);
    final n = days.length;

    await db.transaction(() async {
      for (final day in days) {
        final gid = await db.createEntryGroup(day, group.name);
        for (var i = 0; i < items.length; i++) {
          final e = items[i];
          await db.addEntry(EntriesCompanion.insert(
            day: day,
            mealType: e.mealType,
            groupId: Value(gid),
            grams: e.grams / n,
            foodId: Value(e.foodId),
            sName: e.sName,
            sKcal100: e.sKcal100,
            sProtein100: Value(e.sProtein100),
            sCarb100: Value(e.sCarb100),
            sFat100: Value(e.sFat100),
            sMicrosJson: Value(e.sMicrosJson),
            sortIndex: Value(i),
          ));
        }
      }
      await db.deleteEntryGroup(groupId); // removes the original + its entries
    });
  }
}
