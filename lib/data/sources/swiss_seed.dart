import 'dart:convert';
import 'dart:io' show gzip;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../domain/enums.dart';
import '../db/database.dart';

const _assetPath = 'assets/swiss_foods.csv.gz';
const _versionKey = 'swissDatasetVersion';

/// Bump whenever assets/swiss_foods.csv.gz changes so existing installs
/// re-import (e.g. when the Italian names land).
const swissDatasetVersion = '1';

/// Minimal RFC-4180-ish CSV parser: handles quoted fields containing commas,
/// newlines, and doubled quotes. Good enough for our controlled asset.
List<List<String>> parseCsv(String input) {
  final rows = <List<String>>[];
  var field = StringBuffer();
  var row = <String>[];
  var inQuotes = false;
  var sawAny = false;

  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    sawAny = true;
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else {
      switch (c) {
        case '"':
          inQuotes = true;
        case ',':
          row.add(field.toString());
          field = StringBuffer();
        case '\n':
          row.add(field.toString());
          rows.add(row);
          row = <String>[];
          field = StringBuffer();
        case '\r':
          break; // ignore CR
        default:
          field.write(c);
      }
    }
  }
  if (sawAny && (field.isNotEmpty || row.isNotEmpty)) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

/// Parse the bundled Swiss FCDB CSV into catalog rows.
/// Columns: id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,
///          fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text
List<FoodsCompanion> parseSwissCsv(String csv) {
  final rows = parseCsv(csv);
  final out = <FoodsCompanion>[];
  String? s(String v) => v.trim().isEmpty ? null : v.trim();
  double? n(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());
  for (var i = 1; i < rows.length; i++) {
    // skip header
    final r = rows[i];
    if (r.length < 14) continue;
    final kcal = double.tryParse(r[5]);
    if (kcal == null) continue;
    final name = r[1].trim();
    if (name.isEmpty) continue;
    out.add(FoodsCompanion.insert(
      source: FoodSource.swissFcdb,
      externalId: Value(r[0]),
      name: name,
      nameDe: Value(s(r[2])),
      nameFr: Value(s(r[3])),
      nameIt: Value(s(r[4])),
      searchText: Value(s(r[13])),
      kcal100: kcal,
      protein100: Value(n(r[6])),
      carb100: Value(n(r[7])),
      fat100: Value(n(r[8])),
      fiber100: Value(n(r[9])),
      sugar100: Value(n(r[10])),
      satFat100: Value(n(r[11])),
      sodiumMg100: Value(n(r[12])),
    ));
  }
  return out;
}

/// Import the bundled Swiss Food Composition Database (FSVO/BLV) into the local
/// catalog. Runs on first launch and again whenever [swissDatasetVersion]
/// changes. Replaces the old English-only USDA generic layer (deletes both
/// previously-seeded Swiss and USDA rows; diary entries keep their snapshots,
/// so logged history is unaffected). Idempotent within a version. Returns the
/// number of rows imported (0 if up to date or asset missing).
Future<int> seedSwissIfNeeded(AppDatabase db, {AssetBundle? bundle}) async {
  if (await db.getSetting(_versionKey) == swissDatasetVersion) return 0;
  final b = bundle ?? rootBundle;
  try {
    final data = await b.load(_assetPath);
    final csv = utf8.decode(gzip.decode(data.buffer.asUint8List()));
    final companions = parseSwissCsv(csv);
    await db.transaction(() async {
      // Replace prior Swiss rows and retire the legacy USDA generic layer.
      // The entries FK is set-null on delete, so logged history is unaffected.
      await (db.delete(db.foods)
            ..where((f) =>
                f.source.equalsValue(FoodSource.swissFcdb) |
                f.source.equalsValue(FoodSource.usda)))
          .go();
      await db.batch((batch) {
        batch.insertAll(db.foods, companions, mode: InsertMode.insertOrIgnore);
      });
    });
    await db.setSetting(_versionKey, swissDatasetVersion);
    return companions.length;
  } catch (_) {
    // No asset bundled (e.g. dev build before the pipeline ran) — skip quietly.
    return 0;
  }
}
