import 'dart:io';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Upgrade tests for the hand-written SQL migration chain in AppDatabase.
//
// Each fixture is a real on-disk SQLite file built with the schema a device
// on that version actually had (reconstructed from git history of
// lib/data/db/tables.dart + database.dart: v1 5caae3d, v2 f1b07fe,
// v3 c49b1a7, v4 c761a76, v5 c9bc508, v6 f311723, v7 3376f1a, v8 1e1002c,
// v9 79d7e13, v10 4e027c6, v11 cb45c53), seeded with realistic rows and
// stamped with PRAGMA user_version. Opening AppDatabase over the file runs
// the real onUpgrade; assertions are on the migrated DATA.

/// drift's `currentDateAndTime` default for INTEGER-stored date-times.
const _epochNow = "CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)";

/// `foods` as drift created it at each historical version: v6 added
/// last_used_at, v7 the multilingual columns, v9 the density.
String _foodsDdl({
  required bool lastUsedAt,
  required bool multilingual,
  required bool density,
}) {
  final cols = [
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT',
    'source INTEGER NOT NULL',
    'external_id TEXT NULL',
    'barcode TEXT NULL',
    'name TEXT NOT NULL',
    'brand TEXT NULL',
    'locale TEXT NULL',
    if (multilingual) ...[
      'name_de TEXT NULL',
      'name_fr TEXT NULL',
      'name_it TEXT NULL',
      'search_text TEXT NULL',
    ],
    'serving_g REAL NULL',
    'serving_label TEXT NULL',
    if (density) 'density_g_per_ml REAL NULL',
    'kcal100 REAL NOT NULL',
    'protein100 REAL NULL',
    'carb100 REAL NULL',
    'fat100 REAL NULL',
    'fiber100 REAL NULL',
    'sugar100 REAL NULL',
    'sat_fat100 REAL NULL',
    'sodium_mg100 REAL NULL',
    'salt_g100 REAL NULL',
    'micros_json TEXT NULL',
    'is_favorite INTEGER NOT NULL DEFAULT 0 CHECK (is_favorite IN (0, 1))',
    'usage_count INTEGER NOT NULL DEFAULT 0',
    if (lastUsedAt) 'last_used_at INTEGER NULL',
    'updated_at INTEGER NOT NULL DEFAULT ($_epochNow)',
    'UNIQUE (source, external_id)',
  ];
  return 'CREATE TABLE foods (${cols.join(', ')});';
}

/// `entries`: v3 added the group_id FK.
String _entriesDdl({required bool groupId}) {
  final cols = [
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT',
    'day TEXT NOT NULL',
    'meal_type INTEGER NOT NULL',
    if (groupId)
      'group_id INTEGER NULL REFERENCES entry_groups (id) ON DELETE CASCADE',
    'food_id INTEGER NULL REFERENCES foods (id) ON DELETE SET NULL',
    'grams REAL NOT NULL',
    's_name TEXT NOT NULL',
    's_kcal100 REAL NOT NULL',
    's_protein100 REAL NULL',
    's_carb100 REAL NULL',
    's_fat100 REAL NULL',
    's_micros_json TEXT NULL',
    'sort_index INTEGER NOT NULL DEFAULT 0',
    'created_at INTEGER NOT NULL DEFAULT ($_epochNow)',
  ];
  return 'CREATE TABLE entries (${cols.join(', ')});';
}

/// `targets`: v1 had a single nullable kcal (+ never-surfaced protein/carb/
/// fat); v2 appended kcal_min/kcal_max; v10 dropped kcal; v11 swapped the
/// legacy macro columns for per-macro min/max.
String _targetsDdl({required bool legacyKcal, required bool kcalMinMax}) {
  final cols = [
    'weekday INTEGER NOT NULL',
    if (legacyKcal) 'kcal REAL NULL',
    'protein REAL NULL',
    'carb REAL NULL',
    'fat REAL NULL',
    if (kcalMinMax) ...['kcal_min REAL NULL', 'kcal_max REAL NULL'],
    'PRIMARY KEY (weekday)',
  ];
  return 'CREATE TABLE targets (${cols.join(', ')});';
}

// Unchanged since their introduction (recipes/recipe_items/settings at v1,
// entry_groups at v3, installed_packs at v4, ocr_mappings at v5).
const _recipesDdl =
    'CREATE TABLE recipes ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'name TEXT NOT NULL, '
    'servings REAL NOT NULL DEFAULT 1, '
    'note TEXT NULL, '
    'created_at INTEGER NOT NULL DEFAULT ($_epochNow));';

const _recipeItemsDdl =
    'CREATE TABLE recipe_items ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, '
    's_name TEXT NOT NULL, '
    'grams REAL NOT NULL, '
    's_kcal100 REAL NOT NULL, '
    's_protein100 REAL NULL, '
    's_carb100 REAL NULL, '
    's_fat100 REAL NULL, '
    's_micros_json TEXT NULL, '
    'sort_index INTEGER NOT NULL DEFAULT 0);';

const _settingsDdl =
    'CREATE TABLE settings ('
    '"key" TEXT NOT NULL, value TEXT NULL, PRIMARY KEY ("key"));';

const _entryGroupsDdl =
    'CREATE TABLE entry_groups ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'day TEXT NOT NULL, '
    'name TEXT NOT NULL, '
    'created_at INTEGER NOT NULL DEFAULT ($_epochNow));';

const _installedPacksDdl =
    'CREATE TABLE installed_packs ('
    'code TEXT NOT NULL, '
    'name TEXT NOT NULL, '
    'version TEXT NOT NULL, '
    'products INTEGER NOT NULL, '
    'size_bytes INTEGER NOT NULL, '
    'installed_at INTEGER NOT NULL DEFAULT ($_epochNow), '
    'PRIMARY KEY (code));';

String _schemaV1() => [
  _foodsDdl(lastUsedAt: false, multilingual: false, density: false),
  _entriesDdl(groupId: false),
  _targetsDdl(legacyKcal: true, kcalMinMax: false),
  _recipesDdl,
  _recipeItemsDdl,
  _settingsDdl,
].join('\n');

const _ocrMappingsDdl =
    'CREATE TABLE ocr_mappings ('
    'normalized_name TEXT NOT NULL, '
    'food_id INTEGER NOT NULL REFERENCES foods (id) ON DELETE CASCADE, '
    'updated_at INTEGER NOT NULL DEFAULT ($_epochNow), '
    'PRIMARY KEY (normalized_name));';

/// Full schema for v6 and later (all tables exist from v5 on):
/// v6 (multilingual/density off, legacyKcal on), v7 (+ multilingual),
/// v10 (+ density, kcal dropped).
String _schemaV6Plus({
  required bool multilingual,
  required bool density,
  required bool legacyKcal,
}) => [
  _foodsDdl(lastUsedAt: true, multilingual: multilingual, density: density),
  _entryGroupsDdl,
  _entriesDdl(groupId: true),
  _targetsDdl(legacyKcal: legacyKcal, kcalMinMax: true),
  _recipesDdl,
  _recipeItemsDdl,
  _installedPacksDdl,
  _ocrMappingsDdl,
  _settingsDdl,
].join('\n');

String _schemaV6() =>
    _schemaV6Plus(multilingual: false, density: false, legacyKcal: true);

String _schemaV7() =>
    _schemaV6Plus(multilingual: true, density: false, legacyKcal: true);

String _schemaV10() =>
    _schemaV6Plus(multilingual: true, density: true, legacyKcal: false);

void main() {
  late Directory tmp;
  AppDatabase? db;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('migration_test');
  });

  tearDown(() async {
    await db?.close();
    db = null;
    await tmp.delete(recursive: true);
  });

  /// Writes a fixture DB at [version], then opens the real [AppDatabase] over
  /// it — the first query runs the v[version] -> v11 migration chain.
  AppDatabase openFixture(
    int version,
    String schema,
    void Function(sqlite.Database raw) seed,
  ) {
    final path = '${tmp.path}/calorie_tracker_v$version.sqlite';
    final raw = sqlite.sqlite3.open(path);
    raw.execute(schema);
    seed(raw);
    raw.execute('PRAGMA user_version = $version');
    raw.close();
    return db = AppDatabase(NativeDatabase(File(path)));
  }

  Future<int> count(AppDatabase d, String table) async {
    final row = await d.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
    return row.read<int>('c');
  }

  Future<Set<String>> columnsOf(AppDatabase d, String table) async {
    final rows = await d
        .customSelect("SELECT name FROM pragma_table_info('$table')")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  Future<void> expectFkIntegrity(AppDatabase d) async {
    expect(await d.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  }

  Future<void> expectSchemaVersion11(AppDatabase d) async {
    final row = await d.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 11);
  }

  test('v1 -> latest: kcal target carries into kcal_max, usda layer purged', () async {
    final d = openFixture(1, _schemaV1(), (raw) {
      // onCreate seeded the 7 weekday rows; the user set a Monday goal.
      for (var wd = 0; wd < 7; wd++) {
        raw.execute('INSERT INTO targets (weekday, kcal) VALUES (?, ?)', [
          wd,
          wd == 0 ? 1800 : null,
        ]);
      }
      raw.execute(
        "INSERT INTO settings (\"key\", value) VALUES ('defaultKcalTarget', '2000')",
      );
      raw.execute(
        'INSERT INTO foods '
        '(id, source, external_id, name, kcal100, usage_count, updated_at) VALUES '
        "(1, 0, '7610000000001', 'Cola', 42, 0, 1700000000), "
        "(2, 1, 'fdc-broccoli', 'Broccoli, raw', 34, 3, 1700000100), "
        "(3, 2, NULL, 'Grandma soup', 55, 5, 1700000200)",
      );
      raw.execute(
        'INSERT INTO entries '
        '(day, meal_type, food_id, grams, s_name, s_kcal100, created_at) VALUES '
        "('2025-01-15', 1, 2, 150, 'Broccoli, raw', 34, 1700000300), "
        "('2025-01-15', 2, 3, 300, 'Grandma soup', 55, 1700000400)",
      );
      raw.execute(
        'INSERT INTO recipes (id, name, servings, created_at) '
        "VALUES (1, 'Porridge', 2, 1700000500)",
      );
      raw.execute(
        'INSERT INTO recipe_items (recipe_id, s_name, grams, s_kcal100, sort_index) '
        "VALUES (1, 'Oats', 50, 389, 0), (1, 'Milk', 200, 64, 1)",
      );
    });

    // v2: the single kcal goal became the maximum; the default-setting key
    // was renamed.
    final targets = await d.allTargets();
    expect(targets, hasLength(7));
    final monday = targets.singleWhere((t) => t.weekday == 0);
    expect(monday.kcalMax, 1800);
    expect(monday.kcalMin, isNull);
    expect(
      targets.where((t) => t.weekday != 0).every((t) => t.kcalMax == null),
      isTrue,
    );
    expect(await d.getSetting('defaultKcalMax'), '2000');
    expect(await d.getSetting('defaultKcalTarget'), isNull);

    // v8: the bundled USDA layer (old source 1) is purged, not relabelled as
    // a custom food; the other rows decode to the same semantic source.
    expect(await count(d, 'foods'), 2);
    expect(await d.foodByExternal(FoodSource.custom, 'fdc-broccoli'), isNull);
    final cola = await d.foodByExternal(FoodSource.openFoodFacts, '7610000000001');
    expect(cola, isNotNull);
    final soup = (await d.allCustomFoods()).single;
    expect(soup.name, 'Grandma soup');

    // v6: last_used_at was seeded from updated_at for previously-used foods.
    expect(soup.lastUsedAt, soup.updatedAt);
    expect(cola!.lastUsedAt, isNull);

    // Diary history: the usda-linked entry loses only its catalog link (the
    // snapshot is the source of truth); the custom-linked entry keeps both.
    final dayEntries = await d.watchDay('2025-01-15').first;
    expect(dayEntries, hasLength(2));
    expect(dayEntries[0].sName, 'Broccoli, raw');
    expect(dayEntries[0].grams, 150);
    expect(dayEntries[0].foodId, isNull);
    expect(dayEntries[1].sName, 'Grandma soup');
    expect(dayEntries[1].foodId, soup.id);

    // Recipes ride through the whole chain untouched.
    final recipe = await d.recipeById(1);
    expect(recipe!.name, 'Porridge');
    expect(recipe.servings, 2);
    expect((await d.itemsForRecipe(1)).map((i) => i.sName), ['Oats', 'Milk']);

    // v3-v5 tables exist and are usable.
    final gid = await d.createEntryGroup('2025-01-16', 'Lunch');
    expect((await d.entryGroupById(gid))!.name, 'Lunch');

    // v10/v11: legacy target columns are gone; the new per-macro ones work.
    final targetCols = await columnsOf(d, 'targets');
    expect(targetCols, isNot(contains('kcal')));
    expect(targetCols, isNot(contains('protein')));
    await d.setTarget(2, const TargetsCompanion(proteinMin: Value(120)));
    expect((await d.targetForWeekday(2))!.proteinMin, 120);

    await expectFkIntegrity(d);
    await expectSchemaVersion11(d);
  });

  test('v6 -> latest: usda purge + enum renumbering keep semantics', () async {
    final d = openFixture(6, _schemaV6(), (raw) {
      // Old numbering: off:0, usda:1, custom:2, userContributed:3.
      raw.execute(
        'INSERT INTO foods (id, source, external_id, barcode, name, kcal100, '
        'is_favorite, usage_count, last_used_at, updated_at) VALUES '
        "(1, 0, '7610000000001', '7610000000001', 'Cola', 42, 0, 1, 1700000100, 1700000000), "
        "(2, 1, 'fdc-spinach', NULL, 'Spinach, raw', 23, 1, 6, 1700000200, 1700000000), "
        "(3, 2, NULL, NULL, 'My bread', 250, 0, 2, 1700000300, 1700000000), "
        "(4, 3, NULL, '4001234567890', 'Scanned bar', 480, 0, 0, NULL, 1700000000)",
      );
      raw.execute(
        'INSERT INTO ocr_mappings (normalized_name, food_id, updated_at) '
        "VALUES ('spinach', 2, 1700000400), ('bread', 3, 1700000400)",
      );
      raw.execute(
        'INSERT INTO entries '
        '(day, meal_type, food_id, grams, s_name, s_kcal100, created_at) VALUES '
        "('2025-06-01', 0, 2, 100, 'Spinach, raw', 23, 1700000500), "
        "('2025-06-01', 3, 4, 40, 'Scanned bar', 480, 1700000600)",
      );
    });

    // The usda row is deleted (even a favorited one) — never relabelled.
    expect(await count(d, 'foods'), 3);
    expect(await d.foodByExternal(FoodSource.custom, 'fdc-spinach'), isNull);

    // Every surviving row decodes to the same semantic source as before:
    // off stays off; custom and userContributed merge into custom.
    expect(
      await d.foodByExternal(FoodSource.openFoodFacts, '7610000000001'),
      isNotNull,
    );
    final customs = await d.allCustomFoods();
    expect(customs.map((f) => f.name).toSet(), {'My bread', 'Scanned bar'});
    expect(
      customs.singleWhere((f) => f.name == 'Scanned bar').barcode,
      '4001234567890',
    );

    // The declared referential actions are applied by hand during the
    // migration (FKs are off until beforeOpen): ocr_mappings cascade,
    // entries.food_id set-null — snapshots untouched.
    expect(await count(d, 'ocr_mappings'), 1);
    expect(await d.mappedFoodForOcr('spinach'), isNull);
    expect((await d.mappedFoodForOcr('bread'))!.name, 'My bread');
    final dayEntries = await d.watchDay('2025-06-01').first;
    expect(dayEntries, hasLength(2));
    expect(dayEntries[0].sName, 'Spinach, raw');
    expect(dayEntries[0].foodId, isNull);
    expect(dayEntries[1].sName, 'Scanned bar');
    expect(dayEntries[1].foodId, 4);

    await expectFkIntegrity(d);
    await expectSchemaVersion11(d);
  });

  test('v7 -> latest: devices that went through v7 lose nothing', () async {
    final d = openFixture(7, _schemaV7(), (raw) {
      // The v7 Swiss seeder already purged usda rows and inserted swissFcdb
      // (old source 4) — so no source-1 rows exist on this device.
      raw.execute(
        'INSERT INTO foods (id, source, external_id, barcode, name, name_de, '
        'name_fr, search_text, kcal100, usage_count, last_used_at, updated_at) VALUES '
        "(1, 0, '7610000000001', '7610000000001', 'Cola', NULL, NULL, NULL, 42, 1, 1700000100, 1700000000), "
        "(2, 2, NULL, NULL, 'My bread', NULL, NULL, NULL, 250, 2, 1700000200, 1700000000), "
        "(3, 3, NULL, '4001234567890', 'Scanned bar', NULL, NULL, NULL, 480, 0, NULL, 1700000000), "
        "(4, 4, 'S1103', NULL, 'Apple, raw', 'Apfel, roh', 'Pomme, crue', "
        "'apple apfel pomme', 52, 3, 1700000300, 1700000000)",
      );
      raw.execute(
        "INSERT INTO settings (\"key\", value) VALUES ('swissDatasetVersion', '1')",
      );
      raw.execute(
        'INSERT INTO ocr_mappings (normalized_name, food_id, updated_at) '
        "VALUES ('apple', 4, 1700000400)",
      );
      raw.execute(
        'INSERT INTO entries '
        '(day, meal_type, food_id, grams, s_name, s_kcal100, created_at) VALUES '
        "('2025-06-20', 2, 4, 120, 'Apple, raw', 52, 1700000500)",
      );
    });

    // Nothing is deleted; every row decodes to its old semantic source
    // (off -> off, custom/userContributed -> custom, swissFcdb -> swissFcdb).
    expect(await count(d, 'foods'), 4);
    expect(
      await d.foodByExternal(FoodSource.openFoodFacts, '7610000000001'),
      isNotNull,
    );
    expect(
      (await d.allCustomFoods()).map((f) => f.name).toSet(),
      {'My bread', 'Scanned bar'},
    );
    final apple = await d.foodByExternal(FoodSource.swissFcdb, 'S1103');
    expect(apple, isNotNull);
    expect(apple!.nameDe, 'Apfel, roh');
    expect(apple.searchText, 'apple apfel pomme');

    expect((await d.mappedFoodForOcr('apple'))!.id, apple.id);
    final entry = (await d.watchDay('2025-06-20').first).single;
    expect(entry.foodId, apple.id);
    expect(entry.grams, 120);

    await expectFkIntegrity(d);
    await expectSchemaVersion11(d);
  });

  test('v10 -> latest: DROP COLUMN keeps kcal targets and food data', () async {
    final d = openFixture(10, _schemaV10(), (raw) {
      // Legacy protein/carb/fat (never surfaced, about to be dropped) hold
      // values here to prove the drop can't bleed into neighbouring columns.
      for (var wd = 0; wd < 7; wd++) {
        raw.execute(
          'INSERT INTO targets (weekday, protein, carb, fat, kcal_min, kcal_max) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [wd, wd == 0 ? 99 : null, null, null, wd == 0 ? 1500 : null, wd == 0 ? 2200 : 2000],
        );
      }
      // New numbering already applies at v10: off:0, custom:1, swissFcdb:2.
      raw.execute(
        'INSERT INTO foods (id, source, external_id, name, name_de, '
        'search_text, serving_g, serving_label, density_g_per_ml, kcal100, '
        'is_favorite, usage_count, last_used_at, updated_at) VALUES '
        "(1, 2, 'S1058', 'Olive oil', 'Olivenöl', 'olive oil olivenöl', 15, "
        "'1 tbsp', 0.92, 884, 0, 4, 1700000100, 1700000000), "
        "(2, 1, NULL, 'My smoothie', NULL, NULL, NULL, NULL, NULL, 65, "
        '1, 2, 1700000200, 1700000000)',
      );
      raw.execute(
        'INSERT INTO entries '
        '(day, meal_type, food_id, grams, s_name, s_kcal100, created_at) VALUES '
        "('2025-06-25', 0, 2, 350, 'My smoothie', 65, 1700000300)",
      );
    });

    // Every kcal bound survives the protein/carb/fat DROP COLUMNs; the new
    // per-macro columns start out null and are writable.
    final targets = await d.allTargets();
    expect(targets, hasLength(7));
    final monday = targets.singleWhere((t) => t.weekday == 0);
    expect(monday.kcalMin, 1500);
    expect(monday.kcalMax, 2200);
    expect(
      targets.where((t) => t.weekday != 0).every((t) => t.kcalMax == 2000),
      isTrue,
    );
    expect(
      targets.every(
        (t) =>
            t.proteinMin == null &&
            t.proteinMax == null &&
            t.carbMin == null &&
            t.carbMax == null &&
            t.fatMin == null &&
            t.fatMax == null,
      ),
      isTrue,
    );
    await d.setTarget(
      1,
      const TargetsCompanion(proteinMin: Value(140), fatMax: Value(70)),
    );
    final tuesday = await d.targetForWeekday(1);
    expect(tuesday!.proteinMin, 140);
    expect(tuesday.fatMax, 70);
    final targetCols = await columnsOf(d, 'targets');
    expect(targetCols, isNot(contains('protein')));
    expect(targetCols, contains('protein_min'));

    // Foods and diary ride through untouched (v10 -> v11 only alters targets).
    final oil = await d.foodByExternal(FoodSource.swissFcdb, 'S1058');
    expect(oil!.densityGPerMl, 0.92);
    expect(oil.nameDe, 'Olivenöl');
    expect(oil.servingG, 15);
    final smoothie = (await d.allCustomFoods()).single;
    expect(smoothie.name, 'My smoothie');
    expect(smoothie.isFavorite, isTrue);
    final entry = (await d.watchDay('2025-06-25').first).single;
    expect(entry.foodId, smoothie.id);
    expect(entry.grams, 350);

    await expectFkIntegrity(d);
    await expectSchemaVersion11(d);
  });
}
