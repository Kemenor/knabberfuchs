import 'package:drift/drift.dart';

import '../../domain/enums.dart';

/// Catalog of known foods: OFF cache, bundled USDA, and user-created custom foods.
/// All nutrition is stored per 100 g; per-entry amounts are computed from grams.
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get source => intEnum<FoodSource>()();

  /// Stable id within the source: barcode for OFF, fdcId for USDA, null for custom.
  TextColumn get externalId => text().nullable()();
  TextColumn get barcode => text().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 400)();
  TextColumn get brand => text().nullable()();
  TextColumn get locale => text().nullable()();

  /// Optional serving size for the "1 serving = N g" quick-pick chips.
  RealColumn get servingG => real().nullable()();
  TextColumn get servingLabel => text().nullable()();

  RealColumn get kcal100 => real()();
  RealColumn get protein100 => real().nullable()();
  RealColumn get carb100 => real().nullable()();
  RealColumn get fat100 => real().nullable()();
  RealColumn get fiber100 => real().nullable()();
  RealColumn get sugar100 => real().nullable()();
  RealColumn get satFat100 => real().nullable()();
  RealColumn get sodiumMg100 => real().nullable()();
  RealColumn get saltG100 => real().nullable()();

  /// Extra micronutrients as a JSON map (nutrient key -> per-100g amount).
  TextColumn get microsJson => text().nullable()();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// One row per (source, externalId). NULL externalIds (custom foods) stay distinct
  /// under SQLite semantics, so unlimited custom foods are fine.
  @override
  List<Set<Column>> get uniqueKeys => [
        {source, externalId},
      ];
}

/// An ad-hoc meal group for track-by-day mode: consecutive adds form a group
/// (header + ingredients). Not a saved cookbook recipe. Time-based default name.
class EntryGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text().withLength(min: 10, max: 10)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A logged food on a given day. Carries a nutrition snapshot so editing or
/// re-caching the source food never rewrites history.
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local calendar day as 'YYYY-MM-DD'.
  TextColumn get day => text().withLength(min: 10, max: 10)();
  IntColumn get mealType => intEnum<MealType>()();

  /// In track-by-day mode, the ad-hoc group this entry belongs to (null in
  /// meal mode, where mealType organizes the day instead).
  IntColumn get groupId => integer()
      .nullable()
      .references(EntryGroups, #id, onDelete: KeyAction.cascade)();

  /// Convenience link back to the catalog food (nullable; snapshot is the source of truth).
  IntColumn get foodId =>
      integer().nullable().references(Foods, #id, onDelete: KeyAction.setNull)();

  RealColumn get grams => real()();

  // --- snapshot (per 100 g) taken at log time ---
  TextColumn get sName => text()();
  RealColumn get sKcal100 => real()();
  RealColumn get sProtein100 => real().nullable()();
  RealColumn get sCarb100 => real().nullable()();
  RealColumn get sFat100 => real().nullable()();
  TextColumn get sMicrosJson => text().nullable()();

  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Optional calorie target per weekday (0 = Monday … 6 = Sunday).
/// Both bounds are optional: a minimum (for people who need to eat *enough*)
/// and a maximum. Missing values fall back to the `defaultKcalMin` /
/// `defaultKcalMax` settings. (`kcal` is a legacy v1 column, migrated into
/// kcalMax; kept to avoid a destructive migration.)
class Targets extends Table {
  IntColumn get weekday => integer()();
  RealColumn get kcal => real().nullable()();
  RealColumn get kcalMin => real().nullable()();
  RealColumn get kcalMax => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get carb => real().nullable()();
  RealColumn get fat => real().nullable()();

  @override
  Set<Column> get primaryKey => {weekday};
}

/// A reusable recipe (built from a meal or selected foods).
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  RealColumn get servings => real().withDefault(const Constant(1))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecipeItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get sName => text()();
  RealColumn get grams => real()();
  RealColumn get sKcal100 => real()();
  RealColumn get sProtein100 => real().nullable()();
  RealColumn get sCarb100 => real().nullable()();
  RealColumn get sFat100 => real().nullable()();
  TextColumn get sMicrosJson => text().nullable()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
}

/// A downloaded offline OFF region pack (the .sqlite file lives on disk).
class InstalledPacks extends Table {
  TextColumn get code => text()(); // country code, e.g. 'ch'
  TextColumn get name => text()();
  TextColumn get version => text()();
  IntColumn get products => integer()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get installedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {code};
}

/// Remembers which food an OCR'd ingredient name was matched to, so the same
/// name auto-matches next time. Keyed by the normalized name.
class OcrMappings extends Table {
  TextColumn get normalizedName => text()();
  IntColumn get foodId =>
      integer().references(Foods, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {normalizedName};
}

/// Simple key/value store for app preferences.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
