import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/settings/offline_regions_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gated_pack_service.dart';

RegionInfo _region(String code, String name, String version) => RegionInfo(
  code: code,
  name: name,
  countryTag: 'en:${name.toLowerCase()}',
  version: version,
  products: 1,
  file: 'packs/$code/$version/region_$code.sqlite.gz',
  size: 1,
  sha256: 'x',
);

InstalledPack _installed(String code, String version, DateTime at) =>
    InstalledPack(
      code: code,
      name: code,
      version: version,
      products: 1,
      sizeBytes: 1,
      installedAt: at,
    );

void main() {
  late GatedPackService service;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = RegionPackStore();
    addTearDown(() async {
      store.dispose();
      await db.close();
    });
    service = GatedPackService(db, store);
    container = ProviderContainer(
      overrides: [
        offlinePackServiceProvider.overrideWithValue(service),
        offlineManifestProvider.overrideWith(
          (ref) async => OfflineManifest(
            baseUrl: '',
            attribution: '',
            regions: [
              _region('ch', 'Switzerland', 'new'),
              _region('de', 'Germany', 'new'),
              _region('fr', 'France', 'cur'),
              _region('it', 'Italy', 'cur'),
            ],
          ),
        ),
        installedPacksProvider.overrideWith(
          (ref) => Stream.value([
            _installed('ch', 'old', DateTime(2026, 9, 1)),
            _installed('de', 'old', DateTime(2026, 9, 1)),
            _installed('fr', 'cur', DateTime(2026, 10, 12)),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OfflineRegionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('"Update all" queues every outdated region and reports once', (
    tester,
  ) async {
    await pump(tester);

    // A current install says when its data is from.
    expect(find.textContaining('updated 12 Oct'), findsOneWidget);

    await tester.tap(find.text('Update 2 regions'));
    await tester.pump();
    // Both rows show a ring (one downloading, one queued); the button is gone.
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.text('Update 2 regions'), findsNothing);
    expect(service.started, ['ch']);

    service.gates['ch']!.complete();
    await tester.pump();
    await tester.pump();
    expect(service.started, ['ch', 'de']);
    service.gates['de']!.complete();
    await tester.pumpAndSettle();

    expect(
      find.text('Offline data updated: Switzerland, Germany'),
      findsOneWidget,
    );
    // Let the snackbar's auto-dismiss timer run out.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('an install started elsewhere (the auto-updater) shows its '
      'ring on the screen', (tester) async {
    await pump(tester);

    // Queue directly, as PackAutoUpdater does — not through the screen.
    final done = container
        .read(packInstallQueueProvider.notifier)
        .install(
          OfflineManifest(baseUrl: '', attribution: '', regions: []),
          _region('ch', 'Switzerland', 'new'),
        );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Only Germany is left for the button.
    expect(find.text('Update 1 region'), findsOneWidget);

    service.gates['ch']!.complete();
    await done;
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
