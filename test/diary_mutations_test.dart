import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/repositories/diary_repository.dart';
import 'package:calorie_tracker/domain/day_summary.dart' show EntryView;
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/nutrition.dart' show decodeMicros;
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });
  tearDown(() => db.close());

  /// A two-ingredient meal group on 2026-06-17 plus an unrelated ungrouped
  /// entry that mutations must never touch.
  Future<int> seedGroup() async {
    final gid = await db.createEntryGroup('2026-06-17', 'Chili night');
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-06-17',
        mealType: MealType.dinner,
        groupId: Value(gid),
        grams: 300,
        sName: 'Beans',
        sKcal100: 100,
      ),
    );
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-06-17',
        mealType: MealType.dinner,
        groupId: Value(gid),
        grams: 600,
        sName: 'Beef',
        sKcal100: 250,
      ),
    );
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-06-17',
        mealType: MealType.snack,
        grams: 50,
        sName: 'Honey',
        sKcal100: 304,
      ),
    );
    return gid;
  }

  group('logFood snapshot', () {
    test('writes the tracked nutrients into the micros blob', () async {
      final id = await db.upsertFood(
        FoodsCompanion.insert(
          source: FoodSource.custom,
          name: 'Vollkornbrot',
          kcal100: 220,
          fiber100: const Value(7.5),
          satFat100: const Value(0.4),
          sugar100: const Value(2.1),
          saltG100: const Value(1.2),
        ),
      );
      final food = (await db.foodById(id))!;
      await repo.logFood(
        food: food,
        grams: 80,
        meal: MealType.breakfast,
        day: '2026-07-02',
      );

      final entry = (await db.watchDay('2026-07-02').first).single;
      expect(decodeMicros(entry.sMicrosJson), {
        'fiber': 7.5,
        'satFat': 0.4,
        'sugar': 2.1,
        'salt': 1.2,
      });
      // Aggregation scales by grams like the macros (80 g of 7.5 g/100g).
      final n = EntryView(entry).nutrition;
      expect(n.micros['fiber'], closeTo(6.0, 1e-9));
    });
  });

  group('scaleGroup', () {
    test('multiplies grams of every group entry, snapshots unchanged', () async {
      final gid = await seedGroup();
      await repo.scaleGroup(groupId: gid, factor: 0.6);

      final items = await db.entriesForGroup(gid);
      expect(
        items.firstWhere((e) => e.sName == 'Beans').grams,
        closeTo(180, 0.001),
      );
      expect(
        items.firstWhere((e) => e.sName == 'Beef').grams,
        closeTo(360, 0.001),
      );
      // Per-100 g snapshots are not rescaled.
      expect(items.map((e) => e.sKcal100), containsAll([100, 250]));

      // The ungrouped entry on the same day is untouched.
      final honey = (await db.allEntries()).firstWhere(
        (e) => e.sName == 'Honey',
      );
      expect(honey.grams, 50);
    });

    test('factor 1 and non-positive factors are no-ops', () async {
      final gid = await seedGroup();
      await repo.scaleGroup(groupId: gid, factor: 1);
      await repo.scaleGroup(groupId: gid, factor: 0);
      await repo.scaleGroup(groupId: gid, factor: -0.5);

      final items = await db.entriesForGroup(gid);
      expect(items.map((e) => e.grams), containsAll([300, 600]));
    });
  });

  group('mergeGroups', () {
    test('moves entries after the target\'s own and deletes the source', () async {
      final gid = await seedGroup();
      final target = await db.createEntryGroup('2026-06-17', 'Lunch');
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-06-17',
          mealType: MealType.lunch,
          groupId: Value(target),
          grams: 200,
          sName: 'Salad',
          sKcal100: 40,
          sortIndex: const Value(3),
        ),
      );

      await repo.mergeGroups(fromGroupId: gid, toGroupId: target);

      // Source group is gone; nothing cascaded away.
      expect(await db.entryGroupById(gid), isNull);
      final items = await db.entriesForGroup(target);
      expect(items.map((e) => e.sName), ['Salad', 'Beans', 'Beef']);
      // Moved entries append after the target's max sortIndex, adopt its
      // meal type, and keep their nutrition.
      expect(items.map((e) => e.sortIndex), [3, 4, 5]);
      expect(items.map((e) => e.mealType).toSet(), {MealType.lunch});
      expect(
        items.firstWhere((e) => e.sName == 'Beef').grams,
        600,
      );

      // The ungrouped entry is untouched.
      final honey = (await db.allEntries()).firstWhere(
        (e) => e.sName == 'Honey',
      );
      expect(honey.groupId, isNull);
    });

    test('re-files entries onto the target\'s day when it differs', () async {
      final gid = await seedGroup();
      final target = await db.createEntryGroup('2026-06-18', 'Leftovers');

      await repo.mergeGroups(fromGroupId: gid, toGroupId: target);

      final items = await db.entriesForGroup(target);
      expect(items, hasLength(2));
      for (final e in items) {
        expect(e.day, '2026-06-18');
        // An empty target has no meal type to adopt; the source's stays.
        expect(e.mealType, MealType.dinner);
      }
    });

    test('merging into itself or a missing group is a no-op', () async {
      final gid = await seedGroup();
      await repo.mergeGroups(fromGroupId: gid, toGroupId: gid);
      await repo.mergeGroups(fromGroupId: gid, toGroupId: 9999);

      expect(await db.entryGroupById(gid), isNotNull);
      expect(await db.entriesForGroup(gid), hasLength(2));
    });
  });

  group('editEntryGroup', () {
    test('renames, re-files onto the new day and spreads entry times', () async {
      final gid = await seedGroup();
      final time = DateTime(2026, 6, 20, 11, 0);
      await db.editEntryGroup(
        id: gid,
        name: 'Brunch',
        day: '2026-06-20',
        time: time,
        mealType: MealType.lunch,
      );

      final g = await db.entryGroupById(gid);
      expect(g!.name, 'Brunch');
      expect(g.day, '2026-06-20');
      expect(g.createdAt, time);

      final items = await db.entriesForGroup(gid);
      expect(items, hasLength(2));
      for (final e in items) {
        expect(e.day, '2026-06-20');
        expect(e.mealType, MealType.lunch);
      }
      // Entry times are spread a minute apart so downstream consumers
      // (Health sync) keep their order.
      expect(items[0].createdAt, time);
      expect(items[1].createdAt, time.add(const Duration(minutes: 1)));

      // The ungrouped entry stays on the original day.
      final honey = (await db.allEntries()).firstWhere(
        (e) => e.sName == 'Honey',
      );
      expect(honey.day, '2026-06-17');
      expect(honey.mealType, MealType.snack);
    });
  });
}
