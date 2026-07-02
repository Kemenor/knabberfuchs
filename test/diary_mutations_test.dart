import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/repositories/diary_repository.dart';
import 'package:calorie_tracker/domain/enums.dart';
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
