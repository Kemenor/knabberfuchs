import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/database.dart';
import '../sources/off_api.dart';

/// Food lookup across the layered sources:
/// local cache (incl. bundled USDA produce) -> Open Food Facts live.
class FoodRepository {
  final AppDatabase db;
  final OffApi off;

  FoodRepository(this.db, this.off);

  /// Instant, network-free search over the local catalog (search-as-you-type).
  Future<List<Food>> searchLocal(String query) => db.searchFoodsLocal(query);

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
  Future<Food?> lookupBarcode(String barcode) async {
    final cached = await db.foodByExternal(FoodSource.openFoodFacts, barcode);
    if (cached != null) return cached;
    final remote = await off.productByBarcode(barcode);
    if (remote == null) return null;
    final id = await db.upsertFood(remote);
    return db.foodById(id);
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
