import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/gemini_key_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStore implements SecureKeyValueStore {
  final map = <String, String>{};
  @override
  Future<String?> read(String key) async => map[key];
  @override
  Future<void> write(String key, String value) async => map[key] = value;
  @override
  Future<void> delete(String key) async => map.remove(key);
}

void main() {
  late AppDatabase db;
  late _FakeStore fake;
  late GeminiKeyStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fake = _FakeStore();
    store = GeminiKeyStore(db, store: fake);
  });
  tearDown(() => db.close());

  test('reads null when nothing is stored anywhere', () async {
    expect(await store.read(), isNull);
    expect(fake.map, isEmpty);
  });

  test(
    'migrates a legacy key out of the settings table on first read',
    () async {
      // Pre-2026-07 layout: plaintext key in the diary DB (which OS device
      // backups include).
      await db.setSetting('geminiApiKey', 'legacy-key');

      expect(await store.read(), 'legacy-key');
      expect(fake.map['geminiApiKey'], 'legacy-key');
      expect(
        await db.getSetting('geminiApiKey'),
        isNull,
        reason: 'the next OS backup must no longer carry the credential',
      );

      // Second read comes from secure storage, not the DB.
      await db.setSetting('geminiApiKey', 'stale-should-be-ignored');
      expect(await store.read(), 'legacy-key');
    },
  );

  test('write trims, stores securely, and never touches the DB', () async {
    await store.write('  new-key  ');
    expect(fake.map['geminiApiKey'], 'new-key');
    expect(await db.getSetting('geminiApiKey'), isNull);
    expect(await store.read(), 'new-key');
  });

  test('blank or null write clears the key everywhere', () async {
    await store.write('some-key');
    await store.write('   ');
    expect(fake.map, isEmpty);
    expect(await store.read(), isNull);

    // Clearing also removes a lingering legacy copy.
    await db.setSetting('geminiApiKey', 'lingering');
    await store.write(null);
    expect(await db.getSetting('geminiApiKey'), isNull);
  });
}
