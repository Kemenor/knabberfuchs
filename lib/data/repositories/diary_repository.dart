import 'package:drift/drift.dart';

import '../../domain/day_summary.dart' show snapshotMicros100;
import '../../domain/enums.dart';
import '../../domain/nutrition.dart' show encodeMicros;
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
    await db.transaction(() async {
      await db.addEntry(
        EntriesCompanion.insert(
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
          // Open micros + the tracked nutrients (fiber/satFat/sugar/salt)
          // from the food's typed columns — snapshotted like the macros so
          // later food edits never rewrite history.
          sMicrosJson: Value(encodeMicros(snapshotMicros100(food))),
        ),
      );
      await db.bumpFoodUsage(food.id);
    });
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
    await db.addEntry(
      EntriesCompanion.insert(
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
      ),
    );
  }

  Future<void> editEntry(
    Entry entry, {
    required double grams,
    required MealType meal,
  }) => db.updateEntry(entry.copyWith(grams: grams, mealType: meal));

  Future<void> deleteEntry(int id) => db.deleteEntry(id);

  /// Scale every entry in a meal group by [factor] (e.g. 0.6 = you ate 60%).
  /// Each entry's grams — and so its kcal/macros — is multiplied; the per-100 g
  /// snapshot is unchanged. A factor of 1 is a no-op.
  Future<void> scaleGroup({
    required int groupId,
    required double factor,
  }) async {
    if (factor <= 0 || factor == 1) return;
    final items = await db.entriesForGroup(groupId);
    await db.transaction(() async {
      for (final e in items) {
        await db.updateEntry(e.copyWith(grams: e.grams * factor));
      }
    });
  }

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
          await db.addEntry(
            EntriesCompanion.insert(
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
            ),
          );
        }
      }
      await db.deleteEntryGroup(groupId); // removes the original + its entries
    });
  }

  /// Merge one meal group into another (the inverse of split): every entry of
  /// [fromGroupId] moves to the end of [toGroupId] — re-filed onto the target's
  /// day and meal so the day view stays consistent — then the emptied source
  /// group is deleted. Entry times are untouched.
  Future<void> mergeGroups({
    required int fromGroupId,
    required int toGroupId,
  }) async {
    if (fromGroupId == toGroupId) return;
    final target = await db.entryGroupById(toGroupId);
    if (target == null) return;
    final existing = await db.entriesForGroup(toGroupId);
    final moved = await db.entriesForGroup(fromGroupId);
    var next = existing.isEmpty
        ? 0
        : existing.map((e) => e.sortIndex).reduce((a, b) => a > b ? a : b) + 1;
    await db.transaction(() async {
      for (final e in moved) {
        await db.updateEntry(
          e.copyWith(
            groupId: Value(toGroupId),
            day: target.day,
            mealType: existing.isEmpty ? e.mealType : existing.first.mealType,
            sortIndex: next++,
          ),
        );
      }
      await db.deleteEntryGroup(fromGroupId);
    });
  }
}
