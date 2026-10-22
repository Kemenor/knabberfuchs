import 'dart:async';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/pack_auto_updater.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/pack_auto_update_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a resume mid-update does not announce the result twice', (
    tester,
  ) async {
    final gate = Completer<void>();
    var installs = 0;
    final updater = PackAutoUpdater(
      readSetting: (_) async => null,
      writeSetting: (_, _) async {},
      installedPacks: () async => [
        InstalledPack(
          code: 'ch',
          name: 'Switzerland',
          version: 'old',
          products: 1,
          sizeBytes: 1,
          installedAt: DateTime(2026),
        ),
      ],
      fetchManifest: () async => OfflineManifest(
        baseUrl: '',
        attribution: '',
        regions: [
          RegionInfo(
            code: 'ch',
            name: 'Switzerland',
            countryTag: '',
            version: 'new',
            products: 1,
            file: '',
            size: 1,
            sha256: '',
          ),
        ],
      ),
      install: (_, _) async {
        installs++;
        await gate.future;
      },
      isUnmetered: () async => true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [packAutoUpdaterProvider.overrideWithValue(updater)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PackAutoUpdateHost(child: Scaffold()),
        ),
      ),
    );
    await tester.pump(); // post-frame check starts and blocks on the gate

    // Leave and come back while the update is still downloading.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    gate.complete();
    await tester.pumpAndSettle();

    expect(installs, 1);
    expect(find.text('Offline data updated: Switzerland'), findsOneWidget);
    // Let the snackbar's auto-dismiss timer run out, then confirm no second
    // one was queued behind it.
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Offline data updated: Switzerland'), findsNothing);
  });
}
