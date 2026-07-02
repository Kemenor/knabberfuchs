import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/nutrition.dart' show decodeMicros, encodeMicros;
import '../../domain/recipe_share.dart';
import '../db/database.dart';
import 'diary_repository.dart';

/// Recipes: build, list, import (from a shared payload), and log portions to
/// days. A "portion" is logged as a single snapshot entry whose grams = a
/// fraction of the recipe's total weight (density is constant), so the same
/// recipe can be split across several days (batch-cooking use case).
class RecipeRepository {
  final AppDatabase db;
  final DiaryRepository diary;

  RecipeRepository(this.db, this.diary);

  Stream<List<Recipe>> watchRecipes() => db.watchRecipes();

  Future<List<RecipeItem>> items(int recipeId) => db.itemsForRecipe(recipeId);

  /// Build the self-contained share model from stored rows.
  RecipeShare toShare(Recipe recipe, List<RecipeItem> items) => RecipeShare(
    name: recipe.name,
    servings: recipe.servings,
    items: [
      for (final i in items)
        RecipeShareItem(
          name: i.sName,
          grams: i.grams,
          kcal100: i.sKcal100,
          protein100: i.sProtein100,
          carb100: i.sCarb100,
          fat100: i.sFat100,
          micros100: decodeMicros(i.sMicrosJson),
        ),
    ],
  );

  Future<int> create({
    required String name,
    required double servings,
    required List<RecipeShareItem> items,
  }) {
    return db.createRecipe(
      RecipesCompanion.insert(name: name, servings: Value(servings)),
      [
        for (var idx = 0; idx < items.length; idx++)
          RecipeItemsCompanion.insert(
            recipeId: 0, // set inside createRecipe
            sName: items[idx].name,
            grams: items[idx].grams,
            sKcal100: items[idx].kcal100,
            sProtein100: Value(items[idx].protein100),
            sCarb100: Value(items[idx].carb100),
            sFat100: Value(items[idx].fat100),
            sMicrosJson: Value(encodeMicros(items[idx].micros100 ?? const {})),
            sortIndex: Value(idx),
          ),
      ],
    );
  }

  Future<void> update({
    required int id,
    required String name,
    required double servings,
    required List<RecipeShareItem> items,
  }) {
    return db.updateRecipe(
      id,
      RecipesCompanion(name: Value(name), servings: Value(servings)),
      [
        for (var idx = 0; idx < items.length; idx++)
          RecipeItemsCompanion.insert(
            recipeId: 0, // set inside updateRecipe
            sName: items[idx].name,
            grams: items[idx].grams,
            sKcal100: items[idx].kcal100,
            sProtein100: Value(items[idx].protein100),
            sCarb100: Value(items[idx].carb100),
            sFat100: Value(items[idx].fat100),
            sMicrosJson: Value(encodeMicros(items[idx].micros100 ?? const {})),
            sortIndex: Value(idx),
          ),
      ],
    );
  }

  Future<int> importShare(RecipeShare share) =>
      create(name: share.name, servings: share.servings, items: share.items);

  Future<void> delete(int id) => db.deleteRecipe(id);

  /// Log a portion of [share] (by weight in grams) into a day/meal: each
  /// ingredient is logged as its own entry, scaled by the portion's fraction of
  /// the whole recipe, into [groupId] (the meal group, named after the recipe).
  Future<void> logPortionGrams({
    required RecipeShare share,
    required double grams,
    required MealType meal,
    required String day,
    int? groupId,
  }) async {
    final totalG = share.totalGrams;
    if (totalG <= 0 || grams <= 0) return;
    final factor =
        grams / totalG; // fraction of the whole recipe in this portion
    // One transaction so an interruption can't leave a partial meal group.
    await db.transaction(() async {
      for (final item in share.items) {
        final g = item.grams * factor;
        if (g <= 0) continue;
        await diary.logSnapshot(
          name: item.name,
          kcal100: item.kcal100,
          protein100: item.protein100,
          carb100: item.carb100,
          fat100: item.fat100,
          microsJson: encodeMicros(item.micros100 ?? const {}),
          grams: g,
          meal: meal,
          day: day,
          groupId: groupId,
        );
      }
    });
  }

  /// Convenience: grams for one of [servings] equal portions.
  double portionGramsForServings(RecipeShare share) => share.servings <= 0
      ? share.totalGrams
      : share.totalGrams / share.servings;
}
