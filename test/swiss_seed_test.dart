import 'package:calorie_tracker/data/sources/swiss_seed.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
