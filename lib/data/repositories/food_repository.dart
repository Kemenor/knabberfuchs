import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/database.dart';
import '../offline/region_pack_store.dart';
import '../sources/off_api.dart';

/// How a scanned barcode was resolved (for the offline-pack nudge).
enum BarcodeSource { cache, pack, online, none }

class BarcodeHit {
  final Food? food;
  final BarcodeSource source;
  const BarcodeHit(this.food, this.source);
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

  /// Persist a food if it's a synthetic search/pack hit (id 0), returning the
  /// stored row. A no-op for foods already in the catalog.
  Future<Food> ensurePersisted(Food food) async {
    if (food.id != 0) return food;
    final id = await db.upsertFood(FoodsCompanion.insert(
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
    ));
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
    final fromPack = packs.lookupBarcode(barcode);
    if (fromPack != null) {
      return BarcodeHit(await ensurePersisted(fromPack), BarcodeSource.pack);
    }
    final remote = await off.productByBarcode(barcode);
    if (remote == null) return const BarcodeHit(null, BarcodeSource.none);
    final id = await db.upsertFood(remote);
    return BarcodeHit(await db.foodById(id), BarcodeSource.online);
  }

  Future<Food> createCustomFood({
    required String name,
    String? brand,
    required double kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    double? servingG,
    String? servingLabel,
  }) async {
    final id = await db.upsertFood(FoodsCompanion.insert(
      source: FoodSource.custom,
      name: name,
      brand: Value(brand),
      kcal100: kcal100,
      protein100: Value(protein100),
      carb100: Value(carb100),
      fat100: Value(fat100),
      servingG: Value(servingG),
      servingLabel: Value(servingLabel),
    ));
    return (await db.foodById(id))!;
  }

  Future<void> toggleFavorite(Food food) =>
      db.setFavorite(food.id, !food.isFavorite);
}
