import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The AI disclosure gate. A Gemini key is a developer credential on the
/// user's own Google account, so the key field and the link to Google AI
/// Studio stay hidden until the current disclosure has been accepted
/// (2026-08-30).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [dbProvider.overrideWith((ref) => db)],
    );
    // Keep the settings stream alive for the whole test, then poll — same
    // pattern as widget_test/active_group_test.
    final sub = container.listen(geminiConsentProvider, (_, _) {});
    addTearDown(sub.close);
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  /// Wait for the consent stream to settle on [want].
  Future<void> expectConsent(bool want) async {
    for (var i = 0; i < 200; i++) {
      if (container.read(geminiConsentProvider).asData?.value == want) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('expected consent=$want, got ${container.read(geminiConsentProvider)}');
  }

  test('no acceptance stored → gated', () => expectConsent(false));

  test('accepting the current version opens the gate', () async {
    await db.setSetting(geminiConsentSetting, '$geminiConsentVersion');
    await expectConsent(true);
  });

  test('an older acceptance re-asks', () async {
    // The whole point of storing a version: text the user never saw must not
    // be covered by a tap on an earlier disclosure.
    await db.setSetting(geminiConsentSetting, '${geminiConsentVersion - 1}');
    await expectConsent(false);
  });

  test('a newer acceptance still counts', () async {
    await db.setSetting(geminiConsentSetting, '${geminiConsentVersion + 1}');
    await expectConsent(true);
  });

  test('garbage in the setting is treated as not accepted', () async {
    await db.setSetting(geminiConsentSetting, 'yes');
    await expectConsent(false);
  });

  test('withdrawing consent closes the gate again', () async {
    await db.setSetting(geminiConsentSetting, '$geminiConsentVersion');
    await expectConsent(true);
    await db.setSetting(geminiConsentSetting, null);
    await expectConsent(false);
  });
}
