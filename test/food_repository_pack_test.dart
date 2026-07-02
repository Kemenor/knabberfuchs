import 'dart:io';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'region_pack_fixture.dart';

/// OffApi stand-in that never touches the network and records what the
/// repository asked for.
class _StubOffApi extends OffApi {
  final List<String> barcodeCalls = [];
  int searchCalls = 0;
  ({FoodsCompanion food, String? countryTag})? barcodeResult;

  @override
  Future<({FoodsCompanion food, String? countryTag})?> productByBarcode(
    String barcode,
  ) async {
    barcodeCalls.add(barcode);
    return barcodeResult;
  }

  @override
  Future<List<FoodsCompanion>> search(String query, {int pageSize = 20}) async {
    searchCalls++;
    return const [];
  }
}

void main() {
  late Directory tmp;
  late AppDatabase db;
  late RegionPackStore store;
  late _StubOffApi off;
  late FoodRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('pack_fixture');
    db = AppDatabase(NativeDatabase.memory());
    store = RegionPackStore();
    off = _StubOffApi();
    repo = FoodRepository(db, off, store);
  });

  tearDown(() async {
    store.dispose();
    await db.close();
    await tmp.delete(recursive: true);
  });

  String installFixture(List<PackProduct> products, {String code = 'ch'}) {
    final path = '${tmp.path}/region_${code}_test.sqlite';
    writeRegionPackFixture(path, products);
    store.setPacks({code: path});
    return path;
  }

  test('searchLocal reads every pack column the store maps', () async {
    installFixture([
      const PackProduct(
        barcode: '7610000000001',
        name: 'Chocomel',
        brand: 'TestBrand',
        servingG: 250,
        kcal100: 95,
        protein100: 3.3,
        carb100: 12.5,
        fat100: 2.8,
        fiber100: 0.4,
        sugar100: 11.9,
        satfat100: 1.8,
        sodiumMg100: 45,
        salt100: 0.11,
      ),
    ]);

    final results = await repo.searchLocal('chocomel');
    expect(results, hasLength(1));
    final f = results.single;
    expect(f.id, 0, reason: 'pack results are synthetic until persisted');
    expect(f.source, FoodSource.openFoodFacts);
    expect(f.barcode, '7610000000001');
    expect(f.name, 'Chocomel');
    expect(f.brand, 'TestBrand');
    expect(f.servingG, 250);
    expect(f.servingLabel, '1 bottle');
    expect(f.kcal100, 95);
    expect(f.protein100, 3.3);
    expect(f.carb100, 12.5);
    expect(f.fat100, 2.8);
    expect(f.fiber100, 0.4);
    expect(f.sugar100, 11.9);
    expect(f.satFat100, 1.8);
    expect(f.sodiumMg100, 45);
    expect(f.saltG100, 0.11);
  });

  test('searchLocal keeps multiple id-0 pack rows apart', () async {
    installFixture([
      const PackProduct(barcode: '1000001', name: 'Yogurt Nature'),
      const PackProduct(barcode: '1000002', name: 'Yogurt Vanilla'),
      const PackProduct(barcode: '1000003', name: 'Yogurt Mocha'),
    ]);

    final results = await repo.searchLocal('yogurt');
    expect(results, hasLength(3));
    expect(
      results.map((f) => f.barcode).toSet(),
      {'1000001', '1000002', '1000003'},
    );
  });

  test('searchLocal dedupes by barcode with cached rows winning', () async {
    installFixture([
      const PackProduct(barcode: '2000001', name: 'Bircher Pack Variant'),
    ]);
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.openFoodFacts,
        externalId: const Value('2000001'),
        barcode: const Value('2000001'),
        name: 'Bircher Cached Variant',
        kcal100: 120,
      ),
    );

    final results = await repo.searchLocal('bircher');
    expect(results, hasLength(1));
    expect(results.single.name, 'Bircher Cached Variant');
    expect(results.single.id, isNot(0));
  });

  test('lookupBarcode prefers the local cache and never calls OFF', () async {
    installFixture([
      const PackProduct(barcode: '3000001', name: 'Pack Muesli'),
    ]);
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.openFoodFacts,
        externalId: const Value('3000001'),
        barcode: const Value('3000001'),
        name: 'Cached Muesli',
        kcal100: 380,
      ),
    );

    final hit = await repo.lookupBarcode('3000001');
    expect(hit.source, BarcodeSource.cache);
    expect(hit.food?.name, 'Cached Muesli');
    expect(off.barcodeCalls, isEmpty);
  });

  test('lookupBarcode falls back to the pack and persists the hit', () async {
    installFixture([
      const PackProduct(barcode: '4000001', name: 'Pack-only Biscuit'),
    ]);

    final hit = await repo.lookupBarcode('4000001');
    expect(hit.source, BarcodeSource.pack);
    expect(hit.food?.name, 'Pack-only Biscuit');
    expect(hit.food?.id, isNot(0), reason: 'pack hits must be persisted');
    expect(off.barcodeCalls, isEmpty);

    // Second scan resolves from the cache the first one created.
    final again = await repo.lookupBarcode('4000001');
    expect(again.source, BarcodeSource.cache);
  });

  test('lookupBarcode goes online only when cache and packs miss', () async {
    installFixture([
      const PackProduct(barcode: '5000001', name: 'Unrelated Pack Item'),
    ]);
    off.barcodeResult = (
      food: FoodsCompanion.insert(
        source: FoodSource.openFoodFacts,
        externalId: const Value('9999999'),
        barcode: const Value('9999999'),
        name: 'Online Lemonade',
        kcal100: 44,
      ),
      countryTag: 'en:france',
    );

    final hit = await repo.lookupBarcode('9999999');
    expect(hit.source, BarcodeSource.online);
    expect(hit.food?.name, 'Online Lemonade');
    expect(hit.countryTag, 'en:france');
    expect(off.barcodeCalls, ['9999999']);
  });

  test('lookupBarcode reports none when every layer misses', () async {
    final hit = await repo.lookupBarcode('0000000');
    expect(hit.source, BarcodeSource.none);
    expect(hit.food, isNull);
    expect(off.barcodeCalls, ['0000000']);
  });
}
