import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enums.dart';
import '../../domain/search_query.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Foods, Entries, EntryGroups, Targets, Recipes, RecipeItems, Settings,
    InstalledPacks, OcrMappings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'calorie_tracker'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed the 7 weekday target rows (all null = "use default").
          for (var wd = 0; wd < 7; wd++) {
            await into(targets).insert(TargetsCompanion.insert(weekday: Value(wd)));
          }
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Split single calorie target into min/max; carry the old value
            // forward as the maximum, and rename the default setting key.
            await m.addColumn(targets, targets.kcalMin);
            await m.addColumn(targets, targets.kcalMax);
            await customStatement('UPDATE targets SET kcal_max = kcal');
            await customStatement(
                "UPDATE settings SET key = 'defaultKcalMax' "
                "WHERE key = 'defaultKcalTarget'");
          }
          if (from < 3) {
            // Ad-hoc meal groups for track-by-day mode.
            await m.createTable(entryGroups);
            await m.addColumn(entries, entries.groupId);
          }
          if (from < 4) {
            // Installed offline region packs.
            await m.createTable(installedPacks);
          }
          if (from < 5) {
            // Remembered OCR ingredient-name -> food matches.
            await m.createTable(ocrMappings);
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

  /// Local-first search over the cached/bundled catalog.
  ///
  /// Tokenizes the query (with produce synonyms) and requires every token to
  /// appear in the name or brand — order-independent, so "sweet pepper" matches
  /// "Peppers, sweet, green, raw". Ranks favorites and frequently-used first,
  /// then shorter names so simple/raw entries beat prepared variants
  /// ("Potatoes, raw" before "Potatoes, au gratin, dry mix, ...").
  Future<List<Food>> searchFoodsLocal(String query, {int limit = 50}) {
    final tokens = searchTokens(query);
    return (select(foods)
          ..where((f) {
            Expression<bool> expr = const Constant(true);
            for (final t in tokens) {
              final like = '%${t.replaceAll('%', '').replaceAll('_', '')}%';
              expr = expr & (f.name.like(like) | f.brand.like(like));
            }
            return expr;
          })
          ..orderBy([
            (f) => OrderingTerm.desc(f.isFavorite),
            (f) => OrderingTerm.desc(f.usageCount),
            (f) => OrderingTerm.asc(f.name.length),
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

  Future<List<Food>> allCustomFoods() =>
      (select(foods)..where((f) => f.source.equalsValue(FoodSource.custom)))
          .get();

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

  Future<List<Entry>> allEntries() =>
      (select(entries)..orderBy([(e) => OrderingTerm.asc(e.day)])).get();

  Future<List<Entry>> entriesForGroup(int groupId) =>
      (select(entries)
            ..where((e) => e.groupId.equals(groupId))
            ..orderBy([(e) => OrderingTerm.asc(e.sortIndex), (e) => OrderingTerm.asc(e.id)]))
          .get();

  Future<int> addEntry(EntriesCompanion entry) => into(entries).insert(entry);

  Future<void> updateEntry(Entry entry) => update(entries).replace(entry);

  Future<void> deleteEntry(int id) =>
      (delete(entries)..where((e) => e.id.equals(id))).go();

  // ---------------- Entry groups (track-by-day) ----------------

  Stream<List<EntryGroup>> watchGroups(String day) => (select(entryGroups)
        ..where((g) => g.day.equals(day))
        ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
      .watch();

  Future<int> createEntryGroup(String day, String name) => into(entryGroups)
      .insert(EntryGroupsCompanion.insert(day: day, name: name));

  Future<EntryGroup?> entryGroupById(int id) =>
      (select(entryGroups)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<void> renameEntryGroup(int id, String name) =>
      (update(entryGroups)..where((g) => g.id.equals(id)))
          .write(EntryGroupsCompanion(name: Value(name)));

  Future<void> deleteEntryGroup(int id) =>
      (delete(entryGroups)..where((g) => g.id.equals(id))).go();

  /// Drop groups on [day] that no longer have any entries.
  Future<void> pruneEmptyGroups(String day) => customUpdate(
        'DELETE FROM entry_groups WHERE day = ? AND id NOT IN '
        '(SELECT group_id FROM entries WHERE group_id IS NOT NULL)',
        variables: [Variable.withString(day)],
        updates: {entryGroups},
      );

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

  Future<Recipe?> recipeById(int id) =>
      (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();

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

  /// Update a recipe's fields and replace its items.
  Future<void> updateRecipe(
      int id, RecipesCompanion recipe, List<RecipeItemsCompanion> items) async {
    await transaction(() async {
      await (update(recipes)..where((r) => r.id.equals(id))).write(recipe);
      await (delete(recipeItems)..where((i) => i.recipeId.equals(id))).go();
      for (final item in items) {
        await into(recipeItems).insert(item.copyWith(recipeId: Value(id)));
      }
    });
  }

  Future<void> deleteRecipe(int id) =>
      (delete(recipes)..where((r) => r.id.equals(id))).go();

  // ---------------- Installed offline packs ----------------

  Stream<List<InstalledPack>> watchInstalledPacks() =>
      (select(installedPacks)..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  Future<List<InstalledPack>> installedPacksList() =>
      select(installedPacks).get();

  Future<void> upsertInstalledPack(InstalledPacksCompanion pack) =>
      into(installedPacks).insertOnConflictUpdate(pack);

  Future<void> deleteInstalledPack(String code) =>
      (delete(installedPacks)..where((p) => p.code.equals(code))).go();

  // ---------------- OCR name -> food mappings ----------------

  Future<Food?> mappedFoodForOcr(String normalizedName) async {
    final m = await (select(ocrMappings)
          ..where((x) => x.normalizedName.equals(normalizedName)))
        .getSingleOrNull();
    if (m == null) return null;
    return foodById(m.foodId);
  }

  Future<void> setOcrMapping(String normalizedName, int foodId) =>
      into(ocrMappings).insertOnConflictUpdate(OcrMappingsCompanion.insert(
          normalizedName: normalizedName, foodId: foodId));

  // ---------------- Settings ----------------

  Future<List<Setting>> allSettings() => select(settings).get();

  Stream<List<Setting>> watchAllSettings() => select(settings).watch();

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
