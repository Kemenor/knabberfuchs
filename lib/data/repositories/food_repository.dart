import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/database.dart';
import '../ml/food_kcal_fallback.dart';
import '../offline/region_pack_store.dart';
import '../sources/off_api.dart';

/// How a scanned barcode was resolved (for the offline-pack nudge).
enum BarcodeSource { cache, pack, online, none }

class BarcodeHit {
  final Food? food;
  final BarcodeSource source;

  /// OFF `countries_tags[0]` for an online hit (e.g. `en:switzerland`); lets the
  /// offline-pack nudge deep-link to the product's region. Null otherwise.
  final String? countryTag;
  const BarcodeHit(this.food, this.source, {this.countryTag});
}

/// Food lookup across the layered sources:
/// local catalog (custom / USDA / scan-cache) + offline region packs -> OFF live.
class FoodRepository {
  final AppDatabase db;
  final OffApi off;
  final RegionPackStore packs;

  FoodRepository(this.db, this.off, this.packs);

  /// Instant, network-free search over the local catalog + downloaded region
  /// packs, deduped by barcode (local cached rows win over pack rows).
  Future<List<Food>> searchLocal(String query) async {
    // Empty query = the default list: show recently used foods (newest first),
    // not a random slice of the bundled catalog. Empty for a fresh user.
    if (query.trim().isEmpty) return db.recentFoods();
    final local = await db.searchFoodsLocal(query);
    final fromPacks = packs.search(query);
    final seen = <String>{};
    final merged = <Food>[];
    for (final f in [...local, ...fromPacks]) {
      final key = f.barcode ?? 'id:${f.id}:${f.name}';
      if (seen.add(key)) merged.add(f);
    }
    merged.sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      if (a.usageCount != b.usageCount) {
        return b.usageCount.compareTo(a.usageCount);
      }
      return a.name.length.compareTo(b.name.length);
    });
    return merged.take(50).toList();
  }

  /// Rough kcal estimate for a recognized dish [label]: the best local-catalog
  /// match's kcal/100 g scaled to one portion (its serving size, or a 300 g
  /// plate default). Null if nothing matches. Always shown to the user as an
  /// editable estimate, never logged blindly.
  Future<int?> estimateKcalForLabel(String label) async {
    // The model's labels are specific ("Neapolitan pizza"); the catalog AND-
    // matches all tokens, so try the full label first, then fall back to the
    // head noun (usually the last word: "pizza", "rice") for a looser match.
    final queries = <String>[label];
    final words = label.split(RegExp(r'[\s\-,]+')).where((w) => w.isNotEmpty);
    if (words.length > 1) queries.add(words.last);
    Food? hit;
    for (final q in queries) {
      final hits = await searchLocal(q);
      if (hits.isNotEmpty) {
        hit = hits.first;
        break;
      }
    }
    // Category fallback for the portion size + as a last-resort estimate: most
    // generic-catalog rows have no serving size, so without this almost every
    // guess used a flat 300 g plate. portionForLabel() maps the dish category
    // to a realistic weight (and energy density when nothing matches at all).
    final fallback = portionForLabel(label);
    if (hit == null) return fallback?.kcal;
    final grams = hit.servingG ?? fallback?.grams ?? 300;
    return (hit.kcal100 * grams / 100).round();
  }

  /// Persist a food if it's a synthetic search/pack hit (id 0), returning the
  /// stored row. A no-op for foods already in the catalog.
  Future<Food> ensurePersisted(Food food) async {
    if (food.id != 0) return food;
    final id = await db.upsertFood(
      FoodsCompanion.insert(
        source: food.source,
        externalId: Value(food.externalId),
        barcode: Value(food.barcode),
        name: food.name,
        brand: Value(food.brand),
        locale: Value(food.locale),
        servingG: Value(food.servingG),
        servingLabel: Value(food.servingLabel),
        kcal100: food.kcal100,
        protein100: Value(food.protein100),
        carb100: Value(food.carb100),
        fat100: Value(food.fat100),
        fiber100: Value(food.fiber100),
        sugar100: Value(food.sugar100),
        satFat100: Value(food.satFat100),
        sodiumMg100: Value(food.sodiumMg100),
        saltG100: Value(food.saltG100),
        microsJson: Value(food.microsJson),
      ),
    );
    return (await db.foodById(id))!;
  }

  /// Online OFF search (debounced by caller). Caches every result locally and
  /// returns the freshly cached rows.
  Future<List<Food>> searchOnline(String query) async {
    final remote = await off.search(query);
    final ids = <int>[];
    for (final companion in remote) {
      ids.add(await db.upsertFood(companion));
    }
    final foods = <Food>[];
    for (final id in ids) {
      final f = await db.foodById(id);
      if (f != null) foods.add(f);
    }
    return foods;
  }

  /// Resolve a scanned barcode: cache first, then OFF. Caches a hit.
  /// Returns null if the product is unknown everywhere.
  Future<BarcodeHit> lookupBarcode(String barcode) async {
    final cached = await db.foodByExternal(FoodSource.openFoodFacts, barcode);
    if (cached != null) return BarcodeHit(cached, BarcodeSource.cache);
    final mine = await db.foodByExternal(FoodSource.custom, barcode);
    if (mine != null) return BarcodeHit(mine, BarcodeSource.cache);
    final fromPack = packs.lookupBarcode(barcode);
    if (fromPack != null) {
      return BarcodeHit(await ensurePersisted(fromPack), BarcodeSource.pack);
    }
    final remote = await off.productByBarcode(barcode);
    if (remote == null) return const BarcodeHit(null, BarcodeSource.none);
    final id = await db.upsertFood(remote.food);
    return BarcodeHit(
      await db.foodById(id),
      BarcodeSource.online,
      countryTag: remote.countryTag,
    );
  }

  /// Create (or update) a user food. With a [barcode] it's keyed by that
  /// barcode (so a re-scan finds it) and re-adding the same barcode updates the
  /// row; without one, every save is a distinct custom food. Both are
  /// [FoodSource.custom].
  Future<Food> createFood({
    String? barcode,
    required String name,
    String? brand,
    required double kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    double? fiber100,
    double? sugar100,
    double? satFat100,
    double? saltG100,
    double? servingG,
    String? servingLabel,
    double? densityGPerMl,
  }) async {
    final id = await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        externalId: Value(barcode),
        barcode: Value(barcode),
        name: name,
        brand: Value(brand),
        kcal100: kcal100,
        protein100: Value(protein100),
        carb100: Value(carb100),
        fat100: Value(fat100),
        fiber100: Value(fiber100),
        sugar100: Value(sugar100),
        satFat100: Value(satFat100),
        saltG100: Value(saltG100),
        servingG: Value(servingG),
        servingLabel: Value(servingLabel),
        densityGPerMl: Value(densityGPerMl),
      ),
    );
    return (await db.foodById(id))!;
  }

  /// Overwrite an existing custom food. Same field set as [createFood];
  /// nullable values are written explicitly so a cleared field really clears.
  /// Diary entries are untouched — they log per-100g snapshots by design.
  Future<Food> updateFood(
    int id, {
    String? barcode,
    required String name,
    String? brand,
    required double kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    double? fiber100,
    double? sugar100,
    double? satFat100,
    double? saltG100,
    double? servingG,
    String? servingLabel,
    double? densityGPerMl,
  }) async {
    await db.updateFoodById(
      id,
      FoodsCompanion(
        externalId: Value(barcode),
        barcode: Value(barcode),
        name: Value(name),
        brand: Value(brand),
        kcal100: Value(kcal100),
        protein100: Value(protein100),
        carb100: Value(carb100),
        fat100: Value(fat100),
        fiber100: Value(fiber100),
        sugar100: Value(sugar100),
        satFat100: Value(satFat100),
        saltG100: Value(saltG100),
        servingG: Value(servingG),
        servingLabel: Value(servingLabel),
        densityGPerMl: Value(densityGPerMl),
      ),
    );
    return (await db.foodById(id))!;
  }

  /// Delete a custom food (see [AppDatabase.deleteFoodById] for why diary and
  /// recipe history are untouched).
  Future<void> deleteFood(int id) => db.deleteFoodById(id);

  Future<void> toggleFavorite(Food food) =>
      db.setFavorite(food.id, !food.isFavorite);
}
