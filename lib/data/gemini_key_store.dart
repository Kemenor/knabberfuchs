import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'db/database.dart';

/// Minimal facade over the platform secure storage so tests can substitute an
/// in-memory map (the plugin's channel doesn't exist under `flutter test`).
abstract class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _PluginSecureStore implements SecureKeyValueStore {
  // Android: EncryptedSharedPreferences via Keystore. Its pref file is also
  // excluded from OS backups in data_extraction_rules.xml — a restored
  // ciphertext would be undecryptable on another device anyway (the Keystore
  // master key never leaves the hardware).
  // iOS: first_unlock_THIS_DEVICE keeps the Keychain item out of cross-device
  // restores.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// The user's Gemini API key, stored in the platform keystore (Android
/// Keystore / iOS Keychain) instead of the settings table: the diary DB is
/// included in OS device backups (Google Drive / iCloud), and a credential
/// must not ride along. The in-app backup export already strips it
/// (backup.dart), and old exports containing it are neutralized on import.
class GeminiKeyStore {
  static const _storageKey = 'geminiApiKey';

  /// Pre-2026-07 location: the settings table inside the diary DB. Migrated
  /// into secure storage on first read, then deleted so the next OS backup no
  /// longer carries it.
  static const _legacySettingKey = 'geminiApiKey';

  final AppDatabase _db;
  final SecureKeyValueStore _store;

  GeminiKeyStore(this._db, {SecureKeyValueStore? store})
    : _store = store ?? _PluginSecureStore();

  /// The stored key, or null when unset/blank. Migrates a legacy plaintext
  /// key out of the settings table on first call.
  Future<String?> read() async {
    var v = await _store.read(_storageKey);
    if (v == null) {
      final legacy = (await _db.getSetting(_legacySettingKey))?.trim();
      if (legacy != null && legacy.isNotEmpty) {
        await _store.write(_storageKey, legacy);
        await _db.setSetting(_legacySettingKey, null);
        v = legacy;
      }
    }
    final trimmed = v?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Store (trimmed) or clear (null/blank) the key. Always removes any legacy
  /// copy from the settings table.
  Future<void> write(String? value) async {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      await _store.delete(_storageKey);
    } else {
      await _store.write(_storageKey, v);
    }
    await _db.setSetting(_legacySettingKey, null);
  }
}
