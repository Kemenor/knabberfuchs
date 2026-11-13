import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'db/database.dart';

/// Minimal facade over the platform secure storage so tests can substitute an
/// in-memory map (the plugin's channel doesn't exist under `flutter test`).
abstract class SecureKeyValueStore {
  Future<void> delete(String key);
}

class _PluginSecureStore implements SecureKeyValueStore {
  // Same options the key was written with (Android EncryptedSharedPreferences,
  // iOS first_unlock_THIS_DEVICE) — a different configuration would look in
  // a different place and leave the key behind.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Settings the Gemini integration left behind (key fallback location,
/// model choice, consent version + time).
const legacyGeminiSettingKeys = {
  'geminiApiKey',
  'geminiModel',
  'geminiConsentVersion',
  'geminiConsentAt',
};

/// The Gemini key is gone (PLAN "AI bridge", 2026-11): the app no longer
/// talks to any AI, the user's own AI app does. Delete what a user who had
/// set a key still carries — the key in the platform keystore and the Gemini
/// settings — so no credential lingers on the device. Idempotent; runs at
/// every start. Remove (with `flutter_secure_storage`) one release after it
/// shipped.
Future<void> removeLegacyGeminiData(
  AppDatabase db, {
  SecureKeyValueStore? store,
}) async {
  try {
    await (store ?? _PluginSecureStore()).delete('geminiApiKey');
  } catch (_) {
    // A broken keystore must not block startup; the key is unusable anyway.
  }
  for (final k in legacyGeminiSettingKeys) {
    if (await db.getSetting(k) != null) await db.setSetting(k, null);
  }
}
