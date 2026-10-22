import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/offline_pack_service.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gated_pack_service.dart';

RegionInfo _region(String code) => RegionInfo(
  code: code,
  name: code,
  countryTag: '',
  version: '1',
  products: 1,
  file: '',
  size: 1,
  sha256: '',
);

final _manifest = OfflineManifest(baseUrl: '', attribution: '', regions: []);

void main() {
  late AppDatabase db;
  late RegionPackStore store;
  late GatedPackService service;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = RegionPackStore();
    service = GatedPackService(db, store);
    container = ProviderContainer(
      overrides: [offlinePackServiceProvider.overrideWithValue(service)],
    );
  });

  tearDown(() async {
    container.dispose();
    store.dispose();
    await db.close();
  });

  Map<String, double> state() => container.read(packInstallQueueProvider);
  Future<void> install(String code) => container
      .read(packInstallQueueProvider.notifier)
      .install(_manifest, _region(code));

  /// Let queued microtasks (the next install starting) run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('installs run one at a time, in order, with shared progress', () async {
    final ch = install('ch');
    final de = install('de');
    await settle();

    expect(service.started, ['ch']);
    expect(state(), {'ch': 0, 'de': 0}); // de shows as queued
    service.progressOf['ch']!(0.5);
    expect(state()['ch'], 0.5);

    service.gates['ch']!.complete();
    await ch;
    await settle();
    expect(service.started, ['ch', 'de']);
    expect(state().keys, ['de']);

    service.gates['de']!.complete();
    await de;
    expect(state(), isEmpty);
  });

  test('a region already queued is not queued twice', () async {
    final a = install('ch');
    final b = install('ch');
    await settle();
    service.gates['ch']!.complete();
    await Future.wait([a, b]);
    expect(service.started, ['ch']);
  });

  test('a failed install does not wedge the ones behind it', () async {
    final ch = install('ch');
    final de = install('de');
    await settle();
    service.gates['ch']!.completeError(Exception('broken'));
    await expectLater(ch, throwsException);
    await settle();
    expect(service.started, ['ch', 'de']);
    service.gates['de']!.complete();
    await de;
    expect(state(), isEmpty);
  });

  test('cancelling a queued region means it never starts', () async {
    final ch = install('ch');
    final de = install('de');
    await settle();
    container.read(packInstallQueueProvider.notifier).cancel('de');
    service.gates['ch']!.complete();
    await ch;
    await expectLater(de, throwsA(isA<InstallCancelledException>()));
    expect(service.started, ['ch']);
    expect(state(), isEmpty);
  });
}
