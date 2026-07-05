import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/enums.dart';
import '../../domain/nutrition.dart' show encodeMicros;
import '../db/database.dart';
import '../offline/offline_pack_service.dart';

/// Developer/tester tools behind the hidden debug menu (FEEDBACK.md
/// 2026-07-03). Deliberately English-only and never store-advertised.

/// Wipe every table back to first-run state (targets re-seeded to the 7 empty
/// weekday rows, settings cleared so the Swiss seeder re-imports on next
/// launch). Children first so the runtime FK constraints never trip.
///
/// [packs] removes installed offline packs properly first — closing the
/// store's open handles and deleting the multi-MB region_*.sqlite files.
/// Clearing only the installed_packs rows left pack search alive from the
/// open handles until restart and orphaned the files forever.
Future<void> wipeAllData(AppDatabase db, {OfflinePackService? packs}) async {
  if (packs != null) {
    for (final pack in await db.installedPacksList()) {
      await packs.remove(pack.code);
    }
  }
  await db.transaction(() async {
    for (final table in [
      'entries',
      'entry_groups',
      'recipe_items',
      'recipes',
      'ocr_mappings',
      'foods',
      'installed_packs',
      'targets',
      'settings',
    ]) {
      await db.customStatement('DELETE FROM $table');
    }
    for (var wd = 0; wd < 7; wd++) {
      await db.customStatement('INSERT INTO targets (weekday) VALUES (?)', [
        wd,
      ]);
    }
  });
}

/// One seeded food: name + per-100g values (micros keyed by TargetMetric name).
class _SeedFood {
  final String name;
  final double kcal, protein, carb, fat;
  final Map<String, double> micros;
  const _SeedFood(
    this.name,
    this.kcal,
    this.protein,
    this.carb,
    this.fat, [
    this.micros = const {},
  ]);
}

// Realistic per-100g values; a mix of micros-rich and micros-less rows so the
// tracked-nutrient surfaces (day card, trends, meal header) show both states.
const _seedFoods = [
  _SeedFood('Vollkornbrot', 220, 8.5, 41, 1.7, {
    'fiber': 7.5,
    'sugar': 2.1,
    'satFat': 0.3,
    'salt': 1.2,
  }),
  _SeedFood('Skyr', 63, 11, 4, 0.2, {'sugar': 4.0, 'satFat': 0.1}),
  _SeedFood('Banane', 89, 1.1, 23, 0.3, {'fiber': 2.6, 'sugar': 12.2}),
  _SeedFood('Haferflocken', 372, 13.5, 58.7, 7, {
    'fiber': 10,
    'sugar': 0.7,
    'satFat': 1.2,
  }),
  _SeedFood('Poulet-Brust', 165, 31, 0, 3.6, {'satFat': 1.0}),
  _SeedFood('Reis, gekocht', 130, 2.7, 28, 0.3),
  _SeedFood('Brokkoli', 34, 2.8, 7, 0.4, {'fiber': 2.6, 'sugar': 1.7}),
  _SeedFood('Olivenöl', 884, 0, 0, 100, {'satFat': 14}),
  _SeedFood('Apfel', 52, 0.3, 14, 0.2, {'fiber': 2.4, 'sugar': 10.4}),
  _SeedFood('Erdnussbutter', 588, 25, 20, 50, {
    'fiber': 6,
    'sugar': 9,
    'satFat': 10,
    'salt': 1.2,
  }),
  _SeedFood('Pasta, gekocht', 158, 5.8, 31, 0.9, {'fiber': 1.8}),
  _SeedFood('Tomatensauce', 29, 1.5, 5, 0.2, {'sugar': 4.1, 'salt': 0.9}),
];

const _mealNames = ['Frühstück', 'Mittagessen', 'Abendessen'];

/// Seed [days] past days of realistic diary data (grouped meals, varied
/// portions, micros-rich and micros-less snapshots), two custom foods and a
/// recipe. Deterministic — no randomness, so repeated seeds look the same.
/// Returns the number of entries created.
Future<int> seedTestData(AppDatabase db, {int days = 21}) async {
  var entryCount = 0;
  final today = DateTime.now();

  // Two editable custom foods so the food form / edit paths have subjects.
  for (final f in [_seedFoods[0], _seedFoods[9]]) {
    await db.upsertFood(
      FoodsCompanion.insert(
        source: FoodSource.custom,
        name: 'Test ${f.name}',
        kcal100: f.kcal,
        protein100: Value(f.protein),
        carb100: Value(f.carb),
        fat100: Value(f.fat),
        fiber100: Value(f.micros['fiber']),
        sugar100: Value(f.micros['sugar']),
        satFat100: Value(f.micros['satFat']),
        saltG100: Value(f.micros['salt']),
      ),
    );
  }

  await db.transaction(() async {
    for (var d = days; d >= 1; d--) {
      // Calendar step, not Duration: near a DST boundary a 23/25-hour day
      // would skip or repeat a day string (same rule as DayKey.shift).
      final date = DateTime(today.year, today.month, today.day - d);
      final day =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      // 2 meals on every 5th day (a light day), else 3.
      final meals = d % 5 == 0 ? 2 : 3;
      for (var m = 0; m < meals; m++) {
        final at = DateTime(date.year, date.month, date.day, 8 + m * 5, 30);
        final gid = await db.createEntryGroup(day, _mealNames[m]);
        await db.customStatement(
          'UPDATE entry_groups SET created_at = ? WHERE id = ?',
          [at.millisecondsSinceEpoch ~/ 1000, gid],
        );
        final items = 2 + (d + m) % 3; // 2-4 ingredients per meal
        for (var i = 0; i < items; i++) {
          final f = _seedFoods[(d * 3 + m * 5 + i * 7) % _seedFoods.length];
          // Portion varies by slot: staples big, oils/spreads small.
          final grams = f.kcal > 500
              ? 10.0 + (i * 5) % 15
              : 60.0 + ((d + i) * 17) % 180;
          await db.addEntry(
            EntriesCompanion.insert(
              day: day,
              mealType: MealType.values[m], // breakfast / lunch / dinner
              groupId: Value(gid),
              grams: grams,
              sName: f.name,
              sKcal100: f.kcal,
              sProtein100: Value(f.protein),
              sCarb100: Value(f.carb),
              sFat100: Value(f.fat),
              // Every 4th day predates micros tracking — snapshot has none,
              // which keeps the "0.0 g on old days" state reproducible.
              sMicrosJson: Value(d % 4 == 0 ? null : encodeMicros(f.micros)),
              sortIndex: Value(i),
              createdAt: Value(at.add(Duration(minutes: i))),
            ),
          );
          entryCount++;
        }
      }
    }
  });

  // One recipe with micros-complete item snapshots.
  await db.createRecipe(
    RecipesCompanion.insert(name: 'Test Porridge', servings: Value(2)),
    [
      for (final (i, f) in [
        _seedFoods[3],
        _seedFoods[2],
        _seedFoods[1],
      ].indexed)
        RecipeItemsCompanion.insert(
          recipeId: 0, // replaced by createRecipe
          sName: f.name,
          grams: [50.0, 120.0, 150.0][i],
          sKcal100: f.kcal,
          sProtein100: Value(f.protein),
          sCarb100: Value(f.carb),
          sFat100: Value(f.fat),
          sMicrosJson: Value(encodeMicros(f.micros)),
          sortIndex: Value(i),
        ),
    ],
  );
  return entryCount;
}

/// Shift the whole diary [days] back in time (entries + their groups, day
/// strings and timestamps) — ages the data to exercise Trends windows and
/// weekday targets. Positive = into the past.
Future<void> shiftDiary(AppDatabase db, int days) async {
  if (days == 0) return;
  final mod = "'${-days} days'";
  await db.transaction(() async {
    await db.customStatement(
      'UPDATE entries SET day = date(day, $mod), created_at = created_at - ?',
      [days * 86400],
    );
    await db.customStatement(
      'UPDATE entry_groups SET day = date(day, $mod), '
      'created_at = created_at - ?',
      [days * 86400],
    );
  });
}

/// Per-table row counts + schema version + DB file size, for the inspector.
Future<Map<String, String>> dbStats(AppDatabase db) async {
  final stats = <String, String>{};
  final version = await db.customSelect('PRAGMA user_version').getSingle();
  stats['schema version'] = '${version.read<int>('user_version')}';
  for (final table in [
    'foods',
    'entries',
    'entry_groups',
    'recipes',
    'recipe_items',
    'targets',
    'settings',
    'installed_packs',
    'ocr_mappings',
  ]) {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    stats[table] = '${row.read<int>('c')} rows';
  }
  // Best-effort: path_provider has no platform channel under `flutter test`,
  // and an in-memory DB has no file at all.
  try {
    final file = File(await debugDbPath());
    if (await file.exists()) {
      final kb = (await file.length()) / 1024;
      stats['file size'] = kb >= 1024
          ? '${(kb / 1024).toStringAsFixed(1)} MB'
          : '${kb.toStringAsFixed(0)} KB';
    }
  } catch (_) {}
  return stats;
}

/// Where drift_flutter put the database (its documented default location).
Future<String> debugDbPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'calorie_tracker.sqlite');
}

/// Write a consistent single-file snapshot of the DB (VACUUM INTO — safe while
/// open, folds in the WAL) and return its path for sharing.
Future<String> exportDbSnapshot(AppDatabase db) async {
  final dir = await getTemporaryDirectory();
  final out = p.join(dir.path, 'knabberfuchs-debug.sqlite');
  final f = File(out);
  if (await f.exists()) await f.delete(); // VACUUM INTO refuses to overwrite
  // Path is app-controlled (no user input); quotes required by VACUUM INTO.
  await db.customStatement("VACUUM INTO '$out'");
  return out;
}
