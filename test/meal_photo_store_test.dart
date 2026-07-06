import 'dart:io';
import 'dart:typed_data';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/meal_photo_store.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory docs;
  late MealPhotoStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    docs = Directory.systemTemp.createTempSync('meal_photos_test');
    store = MealPhotoStore(db, documentsDir: () async => docs);
  });
  tearDown(() async {
    await db.close();
    docs.deleteSync(recursive: true);
  });

  Future<void> logWithPhoto(String name) async {
    await db.addEntry(
      EntriesCompanion.insert(
        day: '2026-07-06',
        mealType: MealType.lunch,
        grams: 100,
        sName: 'Pasta',
        sKcal100: 150,
        photoPath: Value(name),
      ),
    );
  }

  test('save writes the bytes and returns a resolvable file name', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final name = await store.save(bytes);
    final file = File('${await store.photosDirPath()}/$name');
    expect(await file.readAsBytes(), bytes);
  });

  test('sweepOrphans deletes old unreferenced files only', () async {
    final dir = Directory('${docs.path}/meal_photos')
      ..createSync(recursive: true);
    final old = DateTime.now().subtract(const Duration(days: 2));
    File('${dir.path}/kept.jpg')
      ..writeAsBytesSync([1])
      ..setLastModifiedSync(old);
    File('${dir.path}/orphan.jpg')
      ..writeAsBytesSync([2])
      ..setLastModifiedSync(old);
    // Young orphan: could be a photo saved moments before its entry commits.
    File('${dir.path}/fresh.jpg').writeAsBytesSync([3]);
    await logWithPhoto('kept.jpg');

    await store.sweepOrphans();

    expect(File('${dir.path}/kept.jpg').existsSync(), isTrue);
    expect(File('${dir.path}/fresh.jpg').existsSync(), isTrue);
    expect(File('${dir.path}/orphan.jpg').existsSync(), isFalse);
  });
}
