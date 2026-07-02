import 'dart:io';
import 'dart:typed_data';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/sources/swiss_seed.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';

/// Serves the real on-disk asset the way release builds can: as a ByteData
/// *view* at a nonzero offset into a larger buffer (with trailing bytes). This
/// reproduces the once-shipped regression where ignoring offset/length handed
/// gzip trailing garbage and seeding silently failed.
class _OffsetFileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    final padded = Uint8List(bytes.length + 32)..setAll(16, bytes);
    return ByteData.view(padded.buffer, 16, bytes.length);
  }
}

void main() {
  group('parseSwissCsv', () {
    test('parses localized names, search text and nutrients', () {
      const csv =
          'id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text\n'
          '273,Almond,Mandel,Amande,,624,25.6,7.8,52.1,10.6,6.6,4.1,1.1,almond mandel amande\n';
      final rows = parseSwissCsv(csv);
      expect(rows, hasLength(1));
      final f = rows.single;
      expect(f.source.value, FoodSource.swissFcdb);
      expect(f.externalId.value, '273');
      expect(f.name.value, 'Almond'); // English is the canonical/fallback
      expect(f.nameDe.value, 'Mandel');
      expect(f.nameFr.value, 'Amande');
      expect(f.nameIt.value, isNull); // Italian not yet available
      expect(f.searchText.value, 'almond mandel amande');
      expect(f.kcal100.value, 624);
      expect(f.protein100.value, 25.6);
      expect(f.satFat100.value, 4.1);
      expect(f.sodiumMg100.value, 1.1);
    });

    test('skips header and rows without a kcal value', () {
      const csv =
          'id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text\n'
          '1,No Energy,Ohne,Sans,,,1,2,3,,,,,no energy\n'
          '2,Good,Gut,Bon,,100,1,2,3,,,,,good gut bon\n';
      final rows = parseSwissCsv(csv);
      expect(rows, hasLength(1));
      expect(rows.single.name.value, 'Good');
    });

    test('reads natural-portion and density columns when present', () {
      const csv =
          'id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text,serving_g,serving_unit,density\n'
          '10,"Cucumber, raw",Gurke,Concombre,Cetriolo,12,0.6,2,0.2,,,,,cucumber gurke,300,medium,\n'
          '12,"Olive oil",Olivenoel,,,884,,,,,,,,olive oil,,,0.92\n'
          '11,Custom,Eigen,,,50,,,,,,,,custom,,,\n';
      final rows = parseSwissCsv(csv);
      expect(rows[0].servingG.value, 300);
      expect(rows[0].servingLabel.value, 'medium');
      expect(rows[0].densityGPerMl.value, isNull);
      expect(rows[1].densityGPerMl.value, 0.92); // olive oil
      // empty trailing columns stay null
      expect(rows[2].servingG.value, isNull);
      expect(rows[2].densityGPerMl.value, isNull);
    });

    test('older 14-column rows (no portion columns) still parse', () {
      const csv =
          'id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text\n'
          '273,Almond,Mandel,Amande,,624,25.6,7.8,52.1,,,,,almond\n';
      final f = parseSwissCsv(csv).single;
      expect(f.name.value, 'Almond');
      expect(f.servingG.value, isNull);
    });

    test('leaves missing nutrients null', () {
      const csv =
          'id,name_en,name_de,name_fr,name_it,kcal100,protein100,carb100,fat100,fiber100,sugar100,satfat100,sodium_mg100,search_text\n'
          '5,Water,Wasser,Eau,,0,,,,,,,,water wasser eau\n';
      final f = parseSwissCsv(csv).single;
      expect(f.kcal100.value, 0);
      expect(f.protein100.value, isNull);
      expect(f.fiber100.value, isNull);
    });
  });

  group('seedSwissIfNeeded (real asset)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('imports the full bundled dataset from an offset ByteData view',
        () async {
      final imported = await seedSwissIfNeeded(db, bundle: _OffsetFileBundle());
      expect(imported, 1190);

      final foods = await db.select(db.foods).get();
      expect(foods.length, 1190);
      expect(foods.every((f) => f.source == FoodSource.swissFcdb), isTrue);

      // A known row survives the whole pipeline (gzip -> CSV -> insert).
      final almond = foods.singleWhere((f) => f.externalId == '273');
      expect(almond.name, 'Almond');
      expect(almond.nameDe, 'Mandel');
      expect(almond.nameIt, 'Mandorle');
      expect(almond.kcal100, 624);
      expect(almond.fat100, 52.1);
      expect(almond.servingG, 30);
      expect(almond.servingLabel, 'handful');
      expect(almond.sodiumMg100, isNull);

      // Idempotent within a dataset version: a second call is a no-op.
      expect(await seedSwissIfNeeded(db, bundle: _OffsetFileBundle()), 0);
      expect((await db.select(db.foods).get()).length, 1190);
    });
  });
}
