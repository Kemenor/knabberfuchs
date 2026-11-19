import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/search_query.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = FoodRepository(db, OffApi(), RegionPackStore());
    await repo.createFood(name: 'Kidney beans', kcal100: 127);
    await repo.createFood(name: 'Beef mince', kcal100: 250);
    await repo.createFood(name: 'Olive oil', kcal100: 884);
  });
  tearDown(() => db.close());

  test('a name that matches as a whole is suggested directly', () async {
    expect((await repo.suggestFor('olive oil'))?.name, 'Olive oil');
  });

  test('a long recipe name falls back to its most specific word', () async {
    // "drained" is a preparation word; "kidney" finds the beans.
    expect(
      (await repo.suggestFor('kidney beans, drained'))?.name,
      'Kidney beans',
    );
    // "lean" is skipped, "mince" (the longest word) finds the beef.
    expect((await repo.suggestFor('lean beef mince'))?.name, 'Beef mince');
  });

  test('nothing plausible → no suggestion', () async {
    expect(await repo.suggestFor('saffron threads'), isNull);
  });

  group('AI-bridge matching (seen on device, 1.7.0 testing)', () {
    setUp(() async {
      await repo.createFood(name: 'Beef mince 5%', kcal100: 137);
      // Swiss catalog rows carry their translations in search_text.
      for (final (id, name, text) in [
        ('t1', 'Ground meat sauce', 'ground meat sauce bolognaisesauce'),
        ('t2', 'Chocolate powder', 'chocolate powder schokoladenpulver'),
      ]) {
        await db.upsertFood(
          FoodsCompanion.insert(
            source: FoodSource.swissFcdb,
            externalId: Value(id),
            name: name,
            kcal100: 300,
            searchText: Value(text),
          ),
        );
      }
    });

    test('a food named exactly like the ingredient wins', () async {
      // "mince" used to be rewritten to "ground", so the exact custom food
      // never matched and "Ground meat sauce" was offered instead.
      expect((await repo.suggestFor('Beef mince 5%'))?.name, 'Beef mince 5%');
    });

    test('one shared generic word is not a suggestion', () async {
      expect(await repo.suggestFor('Chili powder'), isNull);
    });

    test('a one-word alias adds a spelling instead of replacing it', () {
      expect(searchTokenVariants('beef mince'), [
        ['beef'],
        ['ground', 'mince'],
      ]);
    });
  });
}
