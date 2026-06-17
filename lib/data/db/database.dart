import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enums.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Foods, Entries, Targets, Recipes, RecipeItems, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'calorie_tracker'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed the 7 weekday target rows (all null = "use default").
          for (var wd = 0; wd < 7; wd++) {
            await into(targets).insert(TargetsCompanion.insert(weekday: Value(wd)));
          }
        },
        beforeOpen: (details) async {
          // Enforce FK constraints (recipe_items cascade, entries.food set-null).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ---------------- Foods ----------------

  /// Insert or update a catalog food by its (source, externalId) identity.
  /// Custom foods (null externalId) never conflict, so each is a fresh row.
  /// Returns the row id (existing row's id on update).
  Future<int> upsertFood(FoodsCompanion food) {
    return into(foods).insert(
      food,
      onConflict: DoUpdate(
        (_) => food,
        target: [foods.source, foods.externalId],
      ),
    );
  }

  Future<Food?> foodById(int id) =>
      (select(foods)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<Food?> foodByExternal(FoodSource source, String externalId) =>
      (select(foods)
            ..where((f) =>
                f.source.equalsValue(source) & f.externalId.equals(externalId)))
          .getSingleOrNull();

  /// Local-first search over the cached/bundled catalog. Ranks favorites and
  /// frequently-used foods first. Used for search-as-you-type (no network).
  Future<List<Food>> searchFoodsLocal(String query, {int limit = 50}) {
    final q = query.trim();
    final like = '%${q.replaceAll('%', '').replaceAll('_', '')}%';
    return (select(foods)
          ..where((f) => f.name.like(like) | f.brand.like(like))
          ..orderBy([
            (f) => OrderingTerm.desc(f.isFavorite),
            (f) => OrderingTerm.desc(f.usageCount),
            (f) => OrderingTerm.asc(f.name),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> bumpFoodUsage(int foodId) async {
    await customUpdate(
      'UPDATE foods SET usage_count = usage_count + 1 WHERE id = ?',
      variables: [Variable.withInt(foodId)],
      updates: {foods},
    );
  }

  Future<void> setFavorite(int foodId, bool value) =>
      (update(foods)..where((f) => f.id.equals(foodId)))
          .write(FoodsCompanion(isFavorite: Value(value)));

  // ---------------- Diary entries ----------------

  /// Live stream of all entries for a day (caller groups by meal).
  Stream<List<Entry>> watchDay(String day) {
    return (select(entries)
          ..where((e) => e.day.equals(day))
          ..orderBy([
            (e) => OrderingTerm.asc(e.mealType),
            (e) => OrderingTerm.asc(e.sortIndex),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .watch();
  }

  Future<int> addEntry(EntriesCompanion entry) => into(entries).insert(entry);

  Future<void> updateEntry(Entry entry) => update(entries).replace(entry);

  Future<void> deleteEntry(int id) =>
      (delete(entries)..where((e) => e.id.equals(id))).go();

  /// Distinct days that have at least one entry, newest first (for history).
  Future<List<String>> daysWithEntries({int limit = 60}) async {
    final rows = await customSelect(
      'SELECT DISTINCT day FROM entries ORDER BY day DESC LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {entries},
    ).get();
    return rows.map((r) => r.read<String>('day')).toList();
  }

  // ---------------- Targets ----------------

  Future<List<Target>> allTargets() => select(targets).get();

  Stream<List<Target>> watchTargets() => select(targets).watch();

  Future<Target?> targetForWeekday(int weekday) =>
      (select(targets)..where((t) => t.weekday.equals(weekday)))
          .getSingleOrNull();

  Future<void> setTarget(int weekday, TargetsCompanion values) async {
    await (update(targets)..where((t) => t.weekday.equals(weekday)))
        .write(values);
  }

  // ---------------- Recipes ----------------

  Future<List<Recipe>> allRecipes() =>
      (select(recipes)..orderBy([(r) => OrderingTerm.asc(r.name)])).get();

  Stream<List<Recipe>> watchRecipes() =>
      (select(recipes)..orderBy([(r) => OrderingTerm.asc(r.name)])).watch();

  Future<List<RecipeItem>> itemsForRecipe(int recipeId) =>
      (select(recipeItems)
            ..where((i) => i.recipeId.equals(recipeId))
            ..orderBy([(i) => OrderingTerm.asc(i.sortIndex)]))
          .get();

  Future<int> createRecipe(
      RecipesCompanion recipe, List<RecipeItemsCompanion> items) async {
    return transaction(() async {
      final id = await into(recipes).insert(recipe);
      for (final item in items) {
        await into(recipeItems).insert(item.copyWith(recipeId: Value(id)));
      }
      return id;
    });
  }

  Future<void> deleteRecipe(int id) =>
      (delete(recipes)..where((r) => r.id.equals(id))).go();

  // ---------------- Settings ----------------

  Future<String?> getSetting(String key) async {
    final row = await (select(settings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String? value) => into(settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: Value(value)));

  Stream<String?> watchSetting(String key) {
    return (select(settings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }
}
