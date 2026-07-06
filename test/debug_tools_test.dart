import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/debug/debug_tools.dart';
import 'package:calorie_tracker/domain/nutrition.dart' show decodeMicros;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The debug-menu data tools (hidden developer section, FEEDBACK.md
// 2026-07-03). File-size stats and DB export need a real file + path_provider,
// so those stay emulator-verified; everything DB-shaped is covered here.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  test('seedTestData populates a grouped, partly micros-rich diary', () async {
    final n = await seedTestData(db);
    expect(n, greaterThan(80)); // 21 days × 2-3 meals × 2-4 entries
    expect(await count('entries'), n);
    expect(await count('entry_groups'), greaterThan(40));
    expect(await count('recipes'), 1);
    expect(await count('recipe_items'), 3);
    expect((await db.allCustomFoods()).length, 2);

    // Entries are grouped, day-keyed, and mix micros-rich with micros-less.
    final entries = await db.allEntries();
    expect(entries.every((e) => e.groupId != null), isTrue);
    expect(entries.any((e) => decodeMicros(e.sMicrosJson).isNotEmpty), isTrue);
    expect(entries.any((e) => e.sMicrosJson == null), isTrue);

    // Recipe items carry full snapshots (they feed the meal detail page).
    final items = await db.itemsForRecipe(
      (await db.allRecipes()).single.id,
    );
    expect(items.every((i) => decodeMicros(i.sMicrosJson).isNotEmpty), isTrue);

    // Re-seeding is additive but must not throw (deterministic data).
    await seedTestData(db);
    expect(await count('entries'), 2 * n);
  });

  test('shiftDiary moves days and timestamps together', () async {
    await seedTestData(db, days: 3);
    final before = await db.allEntries();
    await shiftDiary(db, 10);
    final after = await db.allEntries();
    for (var i = 0; i < before.length; i++) {
      final expected = DateTime.parse(
        before[i].day,
      ).subtract(const Duration(days: 10));
      expect(after[i].day, expected.toIso8601String().substring(0, 10));
      expect(
        before[i].createdAt.difference(after[i].createdAt),
        const Duration(days: 10),
      );
    }
    // Groups moved with their entries (same day keys).
    final groupDays = {
      for (final g in await db.watchGroups(after.first.day).first) g.day,
    };
    expect(groupDays, {after.first.day});
  });

  test('wipeAllData resets to first-run: empty tables, 7 blank targets',
      () async {
    await seedTestData(db);
    await db.setSetting('healthSync', 'true');
    await wipeAllData(db);

    for (final table in [
      'entries',
      'entry_groups',
      'recipes',
      'recipe_items',
      'foods',
      'settings',
      'ocr_mappings',
      'installed_packs',
    ]) {
      expect(await count(table), 0, reason: table);
    }
    final targets = await db.allTargets();
    expect(targets.length, 7);
    expect(
      targets.every((t) => t.kcalMin == null && t.kcalMax == null),
      isTrue,
    );
    // Settings gone ⇒ the Swiss seeder re-imports on next launch.
    expect(await db.getSetting('healthSync'), isNull);
  });

  test('dbStats reports schema version and row counts', () async {
    await seedTestData(db, days: 2);
    final stats = await dbStats(db);
    expect(stats['schema version'], '15');
    expect(stats['recipes'], '1 rows');
    expect(stats['targets'], '7 rows');
  });
}
