import 'package:drift/drift.dart';

import '../core/format.dart';
import '../domain/enums.dart';
import '../domain/meal_type_i18n.dart';
import '../domain/nutrition.dart';
import 'db/database.dart';

/// Backup schema version, carried in the manifest so future versions can
/// migrate an older export on import. v2 adds entryGroups + entry.groupId and
/// replaces the legacy target `kcal` field with `kcalMin`/`kcalMax`. Fields
/// added later within v2 restore to null/defaults when absent, so the version
/// is unchanged: per-macro target bounds (`proteinMin/Max`, `carbMin/Max`,
/// `fatMin/Max`) and the custom-food `barcode`/`externalId`/`densityGPerMl`/
/// `usageCount`/`lastUsedAt` columns.
const backupSchemaVersion = 2;

/// Thrown when a backup was written by a newer app version than this build
/// can read. A [FormatException] subtype so generic format handling still
/// applies, while the import UI can catch it specifically and show a
/// localized "update the app" message instead of the raw exception text.
class BackupVersionException extends FormatException {
  BackupVersionException(int version)
    : super(
        'Backup schema version $version is newer than this app supports '
        '(max $backupSchemaVersion). Update the app, then import again.',
      );
}

/// Settings that hold credentials (currently the Gemini API key; see
/// `geminiKeySetting` in providers.dart). The backup ZIP is unencrypted and
/// goes through the share sheet, so these are stripped from the export, never
/// imported, and preserved on-device across a restore.
const _credentialSettingKeys = {'geminiApiKey'};

int _ms(DateTime d) => d.millisecondsSinceEpoch;
DateTime _dt(Object? v) =>
    DateTime.fromMillisecondsSinceEpoch((v as num?)?.toInt() ?? 0);
double? _d(Object? v) => v == null ? null : (v as num).toDouble();

/// A target bound read from a backup: an *absent* key stays [Value.absent] so
/// restoring an older export never null-overwrites bounds it predates, while
/// a present-but-null key still restores as "no target set".
Value<double?> _bound(Map<dynamic, dynamic> t, String key) =>
    t.containsKey(key) ? Value(_d(t[key])) : const Value.absent();

// ---------------- Export ----------------

/// Serialize all user data to a JSON-friendly map. Cached OFF/USDA foods are
/// omitted (re-fetchable / re-seeded); entries carry their own nutrition
/// snapshot, so nothing is lost.
Future<Map<String, dynamic>> buildBackupMap(
  AppDatabase db, {
  required DateTime exportedAt,
}) async {
  final entries = await db.allEntries();
  final groups = await db.select(db.entryGroups).get();
  final customFoods = await db.allCustomFoods();
  final recipes = await db.allRecipes();
  final targets = await db.allTargets();
  final settings = await db.allSettings();

  final recipeItems = <Map<String, dynamic>>[];
  for (final r in recipes) {
    for (final it in await db.itemsForRecipe(r.id)) {
      recipeItems.add({
        'id': it.id,
        'recipeId': it.recipeId,
        'sName': it.sName,
        'grams': it.grams,
        'sKcal100': it.sKcal100,
        'sProtein100': it.sProtein100,
        'sCarb100': it.sCarb100,
        'sFat100': it.sFat100,
        'sMicrosJson': it.sMicrosJson,
        'sortIndex': it.sortIndex,
      });
    }
  }

  return {
    'schemaVersion': backupSchemaVersion,
    'exportedAt': _ms(exportedAt),
    'entryGroups': [
      for (final g in groups)
        {
          'id': g.id,
          'day': g.day,
          'name': g.name,
          'createdAt': _ms(g.createdAt),
        },
    ],
    'entries': [
      for (final e in entries)
        {
          'id': e.id,
          'day': e.day,
          'groupId': e.groupId,
          'mealType': e.mealType.index,
          'grams': e.grams,
          'sName': e.sName,
          'sKcal100': e.sKcal100,
          'sProtein100': e.sProtein100,
          'sCarb100': e.sCarb100,
          'sFat100': e.sFat100,
          'sMicrosJson': e.sMicrosJson,
          'sortIndex': e.sortIndex,
          'createdAt': _ms(e.createdAt),
        },
    ],
    'customFoods': [
      for (final f in customFoods)
        {
          'id': f.id,
          'name': f.name,
          'brand': f.brand,
          'barcode': f.barcode,
          'externalId': f.externalId,
          'servingG': f.servingG,
          'servingLabel': f.servingLabel,
          'densityGPerMl': f.densityGPerMl,
          'kcal100': f.kcal100,
          'protein100': f.protein100,
          'carb100': f.carb100,
          'fat100': f.fat100,
          'fiber100': f.fiber100,
          'sugar100': f.sugar100,
          'satFat100': f.satFat100,
          'sodiumMg100': f.sodiumMg100,
          'saltG100': f.saltG100,
          'microsJson': f.microsJson,
          'isFavorite': f.isFavorite,
          'usageCount': f.usageCount,
          'lastUsedAt': f.lastUsedAt == null ? null : _ms(f.lastUsedAt!),
        },
    ],
    'recipes': [
      for (final r in recipes)
        {'id': r.id, 'name': r.name, 'servings': r.servings, 'note': r.note},
    ],
    'recipeItems': recipeItems,
    'targets': [
      for (final t in targets)
        {
          'weekday': t.weekday,
          'kcalMin': t.kcalMin,
          'kcalMax': t.kcalMax,
          'proteinMin': t.proteinMin,
          'proteinMax': t.proteinMax,
          'carbMin': t.carbMin,
          'carbMax': t.carbMax,
          'fatMin': t.fatMin,
          'fatMax': t.fatMax,
        },
    ],
    'settings': {
      for (final s in settings)
        if (!_credentialSettingKeys.contains(s.key)) s.key: s.value,
    },
  };
}

/// Human/spreadsheet-friendly CSV of every logged entry.
String buildEntriesCsv(List<Entry> entries) {
  String esc(String s) {
    // Neutralize spreadsheet formula injection: a cell a spreadsheet would
    // evaluate (leading = + - @) gets a leading apostrophe so it stays text.
    if (s.isNotEmpty && '=+-@'.contains(s[0])) s = "'$s";
    return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final rows = <String>['day,meal,food,grams,kcal,protein_g,carb_g,fat_g'];
  for (final e in entries) {
    final n = Nutrition.fromPer100g(
      kcal100: e.sKcal100,
      protein100: e.sProtein100,
      carb100: e.sCarb100,
      fat100: e.sFat100,
      grams: e.grams,
    );
    rows.add(
      [
        e.day,
        mealTypeLabel(e.mealType, 'en'), // stable English for CSV portability
        esc(e.sName),
        gramsCsv(e.grams),
        kcalCsv(n.kcal),
        macroCsv(n.protein),
        macroCsv(n.carb),
        macroCsv(n.fat),
      ].join(','),
    );
  }
  return rows.join('\n');
}

// ---------------- Import ----------------

/// Replace all user data with the contents of a backup map. Cached OFF/USDA
/// foods are left untouched; restored entries have their food link cleared
/// (snapshots preserve nutrition), avoiding dangling references.
///
/// Honors the map's `schemaVersion`: v1 exports are migrated on the fly
/// (mirroring the DB v2 migration), and an export written by a *newer* app is
/// rejected with a [BackupVersionException] before anything is touched.
Future<void> restoreBackupMap(AppDatabase db, Map<String, dynamic> map) async {
  final version = (map['schemaVersion'] as num?)?.toInt() ?? 1;
  if (version > backupSchemaVersion) {
    throw BackupVersionException(version);
  }
  await db.transaction(() async {
    await db.delete(db.entries).go();
    await db.delete(db.entryGroups).go();
    await db.delete(db.recipeItems).go();
    await db.delete(db.recipes).go();
    await (db.delete(
      db.foods,
    )..where((f) => f.source.equalsValue(FoodSource.custom))).go();
    await (db.delete(
      db.settings,
    )..where((s) => s.key.isNotIn(_credentialSettingKeys))).go();

    // No explicit id: the foods table keeps its seed/OFF-cache rows, so the
    // exported id may already be taken. Nothing in the backup references
    // custom-food ids (entries drop foodId), so autoincrement is safe.
    for (final f in (map['customFoods'] as List? ?? const [])) {
      await db
          .into(db.foods)
          .insert(
            FoodsCompanion(
              source: const Value(FoodSource.custom),
              externalId: Value(f['externalId'] as String?),
              barcode: Value(f['barcode'] as String?),
              name: Value(f['name'] as String),
              brand: Value(f['brand'] as String?),
              servingG: Value(_d(f['servingG'])),
              servingLabel: Value(f['servingLabel'] as String?),
              densityGPerMl: Value(_d(f['densityGPerMl'])),
              kcal100: Value(_d(f['kcal100']) ?? 0),
              protein100: Value(_d(f['protein100'])),
              carb100: Value(_d(f['carb100'])),
              fat100: Value(_d(f['fat100'])),
              fiber100: Value(_d(f['fiber100'])),
              sugar100: Value(_d(f['sugar100'])),
              satFat100: Value(_d(f['satFat100'])),
              sodiumMg100: Value(_d(f['sodiumMg100'])),
              saltG100: Value(_d(f['saltG100'])),
              microsJson: Value(f['microsJson'] as String?),
              isFavorite: Value((f['isFavorite'] as bool?) ?? false),
              usageCount: Value((f['usageCount'] as num?)?.toInt() ?? 0),
              lastUsedAt: Value(
                f['lastUsedAt'] == null ? null : _dt(f['lastUsedAt']),
              ),
            ),
          );
    }

    for (final r in (map['recipes'] as List? ?? const [])) {
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion(
              id: Value((r['id'] as num).toInt()),
              name: Value(r['name'] as String),
              servings: Value(_d(r['servings']) ?? 1),
              note: Value(r['note'] as String?),
            ),
          );
    }

    for (final it in (map['recipeItems'] as List? ?? const [])) {
      await db
          .into(db.recipeItems)
          .insert(
            RecipeItemsCompanion(
              id: Value((it['id'] as num).toInt()),
              recipeId: Value((it['recipeId'] as num).toInt()),
              sName: Value(it['sName'] as String),
              grams: Value(_d(it['grams']) ?? 0),
              sKcal100: Value(_d(it['sKcal100']) ?? 0),
              sProtein100: Value(_d(it['sProtein100'])),
              sCarb100: Value(_d(it['sCarb100'])),
              sFat100: Value(_d(it['sFat100'])),
              sMicrosJson: Value(it['sMicrosJson'] as String?),
              sortIndex: Value((it['sortIndex'] as num?)?.toInt() ?? 0),
            ),
          );
    }

    // Groups before entries: entries.groupId has a FK onto entry_groups.
    for (final g in (map['entryGroups'] as List? ?? const [])) {
      await db
          .into(db.entryGroups)
          .insert(
            EntryGroupsCompanion(
              id: Value((g['id'] as num).toInt()),
              day: Value(g['day'] as String),
              name: Value(g['name'] as String),
              createdAt: Value(_dt(g['createdAt'])),
            ),
          );
    }

    for (final e in (map['entries'] as List? ?? const [])) {
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion(
              id: Value((e['id'] as num).toInt()),
              day: Value(e['day'] as String),
              groupId: Value((e['groupId'] as num?)?.toInt()),
              mealType: Value(MealType.values[(e['mealType'] as num).toInt()]),
              grams: Value(_d(e['grams']) ?? 0),
              sName: Value(e['sName'] as String),
              sKcal100: Value(_d(e['sKcal100']) ?? 0),
              sProtein100: Value(_d(e['sProtein100'])),
              sCarb100: Value(_d(e['sCarb100'])),
              sFat100: Value(_d(e['sFat100'])),
              sMicrosJson: Value(e['sMicrosJson'] as String?),
              sortIndex: Value((e['sortIndex'] as num?)?.toInt() ?? 0),
              createdAt: Value(_dt(e['createdAt'])),
            ),
          );
    }

    for (final t in (map['targets'] as List? ?? const [])) {
      final m = t as Map;
      await db
          .into(db.targets)
          .insertOnConflictUpdate(
            TargetsCompanion(
              weekday: Value((m['weekday'] as num).toInt()),
              kcalMin: _bound(m, 'kcalMin'),
              // v1 carried a single `kcal` target; the DB v2 migration turned
              // it into the upper bound.
              kcalMax: _bound(m, version < 2 ? 'kcal' : 'kcalMax'),
              proteinMin: _bound(m, 'proteinMin'),
              proteinMax: _bound(m, 'proteinMax'),
              carbMin: _bound(m, 'carbMin'),
              carbMax: _bound(m, 'carbMax'),
              fatMin: _bound(m, 'fatMin'),
              fatMax: _bound(m, 'fatMax'),
            ),
          );
    }

    final settings = (map['settings'] as Map?) ?? const {};
    for (final entry in settings.entries) {
      var key = entry.key.toString();
      // Mirror the DB v2 migration's settings-key rename.
      if (version < 2 && key == 'defaultKcalTarget') key = 'defaultKcalMax';
      if (_credentialSettingKeys.contains(key)) continue;
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: key,
              value: Value(entry.value as String?),
            ),
          );
    }
  });
}
