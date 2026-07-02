import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/offline_pack_service.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'region_pack_fixture.dart';

void main() {
  late Directory docs;
  late AppDatabase db;
  late RegionPackStore store;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('offline_service');
    db = AppDatabase(NativeDatabase.memory());
    store = RegionPackStore();
  });

  tearDown(() async {
    store.dispose();
    await db.close();
    await docs.delete(recursive: true);
  });

  /// Service whose HTTP layer serves [byUrl] and whose packs live under a
  /// per-test temp dir — the seams added for exactly these tests.
  OfflinePackService buildService(Map<String, List<int>> byUrl) =>
      OfflinePackService(
        db,
        store,
        clientFactory: () => MockClient((req) async {
          final body = byUrl[req.url.toString()];
          if (body == null) return http.Response('missing', 404);
          return http.Response.bytes(body, 200);
        }),
        documentsDir: () async => docs,
      );

  /// Gzipped single-product pack + its sha256, built from a real SQLite file.
  ({Uint8List gz, String sha}) gzPack({
    required String barcode,
    required String name,
  }) {
    final path = '${docs.path}/fixture_${name.hashCode}.sqlite';
    writeRegionPackFixture(path, [PackProduct(barcode: barcode, name: name)]);
    final raw = File(path).readAsBytesSync();
    File(path).deleteSync();
    final gz = Uint8List.fromList(gzip.encode(raw));
    return (gz: gz, sha: sha256.convert(gz).toString());
  }

  RegionInfo region({
    required int size,
    required String sha,
    String version = '1',
  }) => RegionInfo(
    code: 'ch',
    name: 'Switzerland',
    countryTag: 'en:switzerland',
    version: version,
    products: 1,
    file: 'packs/ch/$version/region_ch.sqlite.gz',
    size: size,
    sha256: sha,
  );

  OfflineManifest manifest(RegionInfo r) => OfflineManifest(
    baseUrl: 'https://example/main',
    attribution: 'Data from Open Food Facts, ODbL.',
    regions: [r],
  );

  Set<String> packFileNames() {
    final d = Directory('${docs.path}/packs');
    if (!d.existsSync()) return {};
    return d.listSync().map((e) => e.uri.pathSegments.last).toSet();
  }

  test('fetchManifest parses the manifest and fails on non-200', () async {
    final ok = buildService({
      OfflinePackService.manifestUrl: utf8.encode(
        jsonEncode({
          'baseUrl': 'https://example/main',
          'attribution': 'ODbL',
          'regions': [
            {
              'code': 'ch',
              'name': 'Switzerland',
              'country_tag': 'en:switzerland',
              'version': '1',
              'products': 1,
              'file': 'packs/ch/1/region_ch.sqlite.gz',
              'size': 1,
              'sha256': 'a',
            },
          ],
        }),
      ),
    });
    final m = await ok.fetchManifest();
    expect(m.regions.single.code, 'ch');

    final missing = buildService({});
    await expectLater(missing.fetchManifest(), throwsException);
  });

  test('install verifies, writes a versioned file, and opens it', () async {
    final pack = gzPack(barcode: '7610001', name: 'Rivella');
    final r = region(size: pack.gz.length, sha: pack.sha);
    final service = buildService({
      'https://example/main/${r.file}': pack.gz,
    });

    final progress = <double>[];
    await service.install(manifest(r), r, onProgress: progress.add);

    expect(progress, isNotEmpty);
    expect(progress.last, closeTo(1.0, 1e-9));
    expect(packFileNames(), {'region_ch_1.sqlite'});
    final installed = await db.installedPacksList();
    expect(installed.single.code, 'ch');
    expect(installed.single.version, '1');
    expect(store.lookupBarcode('7610001')?.name, 'Rivella');
  });

  test('install rejects a bad checksum and commits nothing', () async {
    final pack = gzPack(barcode: '7610001', name: 'Rivella');
    final r = region(size: pack.gz.length, sha: 'deadbeef');
    final service = buildService({
      'https://example/main/${r.file}': pack.gz,
    });

    await expectLater(
      service.install(manifest(r), r),
      throwsA(predicate((e) => '$e'.contains('Checksum'))),
    );
    expect(packFileNames(), isEmpty);
    expect(await db.installedPacksList(), isEmpty);
    expect(store.isEmpty, isTrue);
  });

  test('updating a pack swaps to the new file and drops the old', () async {
    final v1 = gzPack(barcode: '7610001', name: 'Old Name');
    final v2 = gzPack(barcode: '7610001', name: 'New Name');
    final r1 = region(size: v1.gz.length, sha: v1.sha, version: '1');
    final r2 = region(size: v2.gz.length, sha: v2.sha, version: '2');
    final service = buildService({
      'https://example/main/${r1.file}': v1.gz,
      'https://example/main/${r2.file}': v2.gz,
    });

    await service.install(manifest(r1), r1);
    expect(store.lookupBarcode('7610001')?.name, 'Old Name');

    await service.install(manifest(r2), r2);
    expect(store.lookupBarcode('7610001')?.name, 'New Name');
    expect(packFileNames(), {'region_ch_2.sqlite'});
    expect((await db.installedPacksList()).single.version, '2');
  });

  test('remove deletes the file, the record, and the open handle', () async {
    final pack = gzPack(barcode: '7610001', name: 'Rivella');
    final r = region(size: pack.gz.length, sha: pack.sha);
    final service = buildService({
      'https://example/main/${r.file}': pack.gz,
    });
    await service.install(manifest(r), r);

    await service.remove('ch');
    expect(packFileNames(), isEmpty);
    expect(await db.installedPacksList(), isEmpty);
    expect(store.isEmpty, isTrue);
    expect(store.lookupBarcode('7610001'), isNull);
  });

  test('a cancelled install aborts before committing anything', () async {
    final pack = gzPack(barcode: '7610001', name: 'Rivella');
    final r = region(size: pack.gz.length, sha: pack.sha);
    final service = buildService({
      'https://example/main/${r.file}': pack.gz,
    });

    final token = CancellationToken()..cancel();
    await expectLater(
      service.install(manifest(r), r, cancelToken: token),
      throwsA(isA<InstallCancelledException>()),
    );
    expect(packFileNames(), isEmpty);
    expect(await db.installedPacksList(), isEmpty);
    expect(store.isEmpty, isTrue);
  });

  test('syncStore opens packs at the legacy unversioned path', () async {
    final packsDir = Directory('${docs.path}/packs')..createSync();
    writeRegionPackFixture('${packsDir.path}/region_ch.sqlite', [
      const PackProduct(barcode: '7610001', name: 'Legacy Rivella'),
    ]);
    await db.upsertInstalledPack(
      InstalledPacksCompanion.insert(
        code: 'ch',
        name: 'Switzerland',
        version: '20250101',
        products: 1,
        sizeBytes: 1,
      ),
    );

    final service = buildService({});
    await service.syncStore();
    expect(store.lookupBarcode('7610001')?.name, 'Legacy Rivella');
  });
}
