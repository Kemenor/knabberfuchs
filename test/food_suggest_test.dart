import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
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
}
