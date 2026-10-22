import 'dart:async';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/offline_pack_service.dart';
import 'package:calorie_tracker/data/offline/pack_auto_updater.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

RegionInfo _region(String code, String name, String version) => RegionInfo(
  code: code,
  name: name,
  countryTag: 'en:$name',
  version: version,
  products: 1,
  file: 'packs/$code/$version/region_$code.sqlite.gz',
  size: 1,
  sha256: 'x',
);

InstalledPack _installed(String code, String version) => InstalledPack(
  code: code,
  name: code,
  version: version,
  products: 1,
  sizeBytes: 1,
  installedAt: DateTime(2026),
);

/// Every seam of the updater as plain, inspectable state.
class _Harness {
  final settings = <String, String?>{};
  var installed = <InstalledPack>[];
  var manifestRegions = <RegionInfo>[];
  var unmetered = true;
  var now = DateTime(2026, 10, 23, 12);
  var manifestFetches = 0;
  final installs = <String>[];
  Object? Function(RegionInfo r)? installError;
  bool manifestFails = false;

  late final updater = PackAutoUpdater(
    readSetting: (k) async => settings[k],
    writeSetting: (k, v) async => settings[k] = v,
    installedPacks: () async => installed,
    fetchManifest: () async {
      manifestFetches++;
      if (manifestFails) throw Exception('offline');
      return OfflineManifest(
        baseUrl: 'https://example/main',
        attribution: '',
        regions: manifestRegions,
      );
    },
    install: (m, r) async {
      if (installError?.call(r) case final e?) throw e;
      installs.add(r.code);
    },
    isUnmetered: () async => unmetered,
    now: () => now,
  );
}

void main() {
  late _Harness h;

  setUp(() {
    h = _Harness()
      ..installed = [_installed('ch', 'a'), _installed('de', 'a')]
      ..manifestRegions = [
        _region('ch', 'Switzerland', 'b'),
        _region('de', 'Germany', 'a'),
        _region('fr', 'France', 'z'),
      ];
  });

  test('updates exactly the installed packs whose version moved', () async {
    expect(await h.updater.runIfDue(), ['Switzerland']);
    // de is current, fr isn't installed — neither is touched.
    expect(h.installs, ['ch']);
    expect(h.settings[PackAutoUpdater.lastCheckKey], isNotNull);
  });

  test('checks at most once per 24 h after a successful check', () async {
    await h.updater.runIfDue();
    h.now = h.now.add(const Duration(hours: 23));
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.manifestFetches, 1);

    h.now = h.now.add(const Duration(hours: 2));
    await h.updater.runIfDue();
    expect(h.manifestFetches, 2);
  });

  test('the throttle survives a restart (persisted, not in memory)', () async {
    await h.updater.runIfDue();
    final restarted = _Harness()
      ..settings.addAll(h.settings)
      ..installed = h.installed
      ..manifestRegions = h.manifestRegions
      ..now = h.now.add(const Duration(hours: 1));
    await restarted.updater.runIfDue();
    expect(restarted.manifestFetches, 0);
  });

  test('Wi-Fi only (the default) skips on mobile data, without '
      'counting it as an attempt', () async {
    h.unmetered = false;
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.manifestFetches, 0);

    // Back on Wi-Fi a minute later: runs straight away.
    h
      ..unmetered = true
      ..now = h.now.add(const Duration(minutes: 1));
    expect(await h.updater.runIfDue(), ['Switzerland']);
  });

  test('"any network" updates on mobile data', () async {
    h
      ..settings[PackAutoUpdate.settingKey] = 'any'
      ..unmetered = false;
    expect(await h.updater.runIfDue(), ['Switzerland']);
  });

  test('"off" never touches the network', () async {
    h.settings[PackAutoUpdate.settingKey] = 'off';
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.manifestFetches, 0);
  });

  test('no installed packs → no manifest fetch', () async {
    h.installed = [];
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.manifestFetches, 0);
  });

  test('a failed manifest fetch is retried after an hour, '
      'not on every resume, and never throws', () async {
    h.manifestFails = true;
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.settings[PackAutoUpdater.lastCheckKey], isNull);

    h.now = h.now.add(const Duration(minutes: 30));
    await h.updater.runIfDue();
    expect(h.manifestFetches, 1);

    h
      ..manifestFails = false
      ..now = h.now.add(const Duration(minutes: 31));
    expect(await h.updater.runIfDue(), ['Switzerland']);
    expect(h.manifestFetches, 2);
  });

  test('one failing pack doesn\'t stop the others, and leaves the check '
      'unrecorded so it is retried', () async {
    h.manifestRegions = [
      _region('ch', 'Switzerland', 'b'),
      _region('de', 'Germany', 'b'),
    ];
    h.installError = (r) => r.code == 'ch' ? Exception('broken') : null;
    expect(await h.updater.runIfDue(), ['Germany']);
    expect(h.settings[PackAutoUpdater.lastCheckKey], isNull);
  });

  test('a pack the user cancelled is not a failure: the check is recorded '
      'and the next try is the next daily check', () async {
    h.installError = (r) => InstallCancelledException();
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.settings[PackAutoUpdater.lastCheckKey], isNotNull);
  });

  test('a region dropped from the manifest keeps its installed copy', () async {
    h.manifestRegions = [_region('de', 'Germany', 'a')];
    expect(await h.updater.runIfDue(), isEmpty);
    expect(h.installs, isEmpty);
  });

  test('overlapping calls share one run', () async {
    final gate = Completer<void>();
    final installs = <String>[];
    final updater = PackAutoUpdater(
      readSetting: (_) async => null,
      writeSetting: (_, _) async {},
      installedPacks: () async => [_installed('ch', 'a')],
      fetchManifest: () async => OfflineManifest(
        baseUrl: '',
        attribution: '',
        regions: [_region('ch', 'Switzerland', 'b')],
      ),
      install: (m, r) async {
        await gate.future;
        installs.add(r.code);
      },
      isUnmetered: () async => true,
    );
    final first = updater.runIfDue();
    final second = updater.runIfDue();
    gate.complete();
    expect(await first, ['Switzerland']);
    expect(await second, ['Switzerland']);
    expect(installs, ['ch']);
  });

  test('PackAutoUpdate stores the Wi-Fi default as absent', () {
    expect(PackAutoUpdate.parse(null), PackAutoUpdate.wifi);
    expect(PackAutoUpdate.wifi.stored, isNull);
    for (final m in PackAutoUpdate.values) {
      expect(PackAutoUpdate.parse(m.stored), m);
    }
  });
}
