import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/legacy_gemini_cleanup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStore implements SecureKeyValueStore {
  final map = <String, String>{'geminiApiKey': 'AIza-secret'};
  @override
  Future<void> delete(String key) async => map.remove(key);
}

class _BrokenStore implements SecureKeyValueStore {
  @override
  Future<void> delete(String key) async => throw Exception('keystore gone');
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('deletes the stored key and every Gemini setting', () async {
    final store = _FakeStore();
    await db.setSetting('geminiApiKey', 'legacy-plaintext');
    await db.setSetting('geminiModel', 'gemini-3.5-flash');
    await db.setSetting('geminiConsentVersion', '1');
    await db.setSetting('geminiConsentAt', '2026-09-01T10:00:00');
    await db.setSetting('appLocale', 'de'); // unrelated — must survive

    await removeLegacyGeminiData(db, store: store);

    expect(store.map, isEmpty);
    for (final k in legacyGeminiSettingKeys) {
      expect(await db.getSetting(k), isNull, reason: k);
    }
    expect(await db.getSetting('appLocale'), 'de');
  });

  test('is idempotent and never blocks on a broken keystore', () async {
    await removeLegacyGeminiData(db, store: _BrokenStore());
    await removeLegacyGeminiData(db, store: _BrokenStore());
    expect(await db.getSetting('geminiModel'), isNull);
  });
}
