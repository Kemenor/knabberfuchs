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

  test(
    'splits a meal into equal portions across days, replacing the original',
    () async {
      final gid = await db.createEntryGroup('2026-06-17', 'Batch chili');
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-06-17',
          mealType: MealType.snack,
          groupId: Value(gid),
          grams: 300,
          sName: 'Beans',
          sKcal100: 100,
        ),
      );
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-06-17',
          mealType: MealType.snack,
          groupId: Value(gid),
          grams: 600,
          sName: 'Beef',
          sKcal100: 250,
        ),
      );
      // An unrelated ungrouped entry on the same day must NOT be touched.
      await db.addEntry(
        EntriesCompanion.insert(
          day: '2026-06-17',
          mealType: MealType.snack,
          grams: 50,
          sName: 'Honey',
          sKcal100: 304,
        ),
      );

      await repo.splitGroupAcrossDays(
        groupId: gid,
        days: ['2026-06-17', '2026-06-18', '2026-06-19'],
      );

      // original group is gone
      expect(await db.entryGroupById(gid), isNull);

      // the ungrouped entry survives
      final honey = (await db.allEntries())
          .where((e) => e.sName == 'Honey')
          .toList();
      expect(honey.length, 1);
      expect(honey.single.grams, 50);

      // one new group per day, each with both ingredients at 1/3 grams
      for (final day in ['2026-06-17', '2026-06-18', '2026-06-19']) {
        expect((await db.watchGroups(day).first).length, 1, reason: day);
        final entries = await db.watchDay(day).first;
        expect(
          entries.firstWhere((e) => e.sName == 'Beans').grams,
          closeTo(100, 0.001),
        );
        expect(
          entries.firstWhere((e) => e.sName == 'Beef').grams,
          closeTo(200, 0.001),
        );
      }
    },
  );
}
