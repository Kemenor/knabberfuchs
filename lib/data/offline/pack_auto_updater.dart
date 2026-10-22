import '../../domain/offline_manifest.dart';
import '../db/database.dart';
import 'offline_pack_service.dart' show InstallCancelledException;

/// When installed region packs update themselves — the `offlinePackAutoUpdate`
/// setting. Absent = [wifi], so the default never spends mobile data (the
/// biggest packs are ~57 MB).
enum PackAutoUpdate {
  wifi,
  any,
  off;

  static const settingKey = 'offlinePackAutoUpdate';

  static PackAutoUpdate parse(String? v) => switch (v) {
    'any' => any,
    'off' => off,
    _ => wifi,
  };

  /// The stored value; the default is stored as absent.
  String? get stored => this == wifi ? null : name;
}

/// Brings installed region packs up to the manifest's versions without the
/// user opening the Offline regions screen. Run on app open and resume; it
/// decides for itself whether a check is due.
///
/// Pack versions are content hashes, so "differs from the manifest" means the
/// data really changed — a weekly rebuild of identical data updates nothing.
///
/// Every dependency is a function so tests drive it with fakes: no plugins,
/// network or clock.
class PackAutoUpdater {
  PackAutoUpdater({
    required this.readSetting,
    required this.writeSetting,
    required this.installedPacks,
    required this.fetchManifest,
    required this.install,
    required this.isUnmetered,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Future<String?> Function(String key) readSetting;
  final Future<void> Function(String key, String? value) writeSetting;
  final Future<List<InstalledPack>> Function() installedPacks;
  final Future<OfflineManifest> Function() fetchManifest;
  final Future<void> Function(OfflineManifest, RegionInfo) install;

  /// Whether the current connection is Wi-Fi/ethernet (not mobile data).
  final Future<bool> Function() isUnmetered;
  final DateTime Function() _now;

  /// Packs are rebuilt weekly; one manifest fetch a day is plenty.
  static const checkInterval = Duration(hours: 24);

  /// After a failed attempt (offline, server error, a download that broke
  /// off), wait this long before the next — so flipping between apps doesn't
  /// re-download a pack on every resume.
  static const retryInterval = Duration(hours: 1);

  /// Epoch millis of the last check that completed — manifest fetched and
  /// every outdated pack installed.
  static const lastCheckKey = 'offlinePackLastCheck';

  DateTime? _lastAttempt;
  Future<List<String>>? _running;

  /// Check and update if due. Returns the names of the regions that were
  /// updated (empty when nothing was due or nothing changed). Never throws:
  /// a failure is retried on a later run.
  Future<List<String>> runIfDue() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<List<String>> _run() async {
    try {
      final now = _now();
      final mode = PackAutoUpdate.parse(
        await readSetting(PackAutoUpdate.settingKey),
      );
      if (mode == PackAutoUpdate.off) return const [];

      final last = int.tryParse(await readSetting(lastCheckKey) ?? '');
      if (last != null &&
          now.difference(DateTime.fromMillisecondsSinceEpoch(last)) <
              checkInterval) {
        return const [];
      }
      if (_lastAttempt case final t? when now.difference(t) < retryInterval) {
        return const [];
      }

      // Nothing installed → nothing to keep fresh, and no reason to touch the
      // network at all.
      final installed = await installedPacks();
      if (installed.isEmpty) return const [];

      if (mode == PackAutoUpdate.wifi && !await isUnmetered()) {
        // Not an attempt: try again as soon as the user is back on Wi-Fi.
        return const [];
      }

      _lastAttempt = now;
      final manifest = await fetchManifest();
      final byCode = {for (final r in manifest.regions) r.code: r};
      final updated = <String>[];
      var failed = false;
      for (final pack in installed) {
        // A region dropped from the manifest keeps its installed copy —
        // removing data is the user's call, not the updater's.
        final region = byCode[pack.code];
        if (region == null || region.version == pack.version) continue;
        try {
          await install(manifest, region);
          updated.add(region.name);
        } on InstallCancelledException {
          // The user stopped it on the regions screen: respect that until
          // the next daily check rather than retrying within the hour.
        } catch (_) {
          failed = true; // the rest still get their chance
        }
      }
      if (!failed) {
        await writeSetting(lastCheckKey, '${now.millisecondsSinceEpoch}');
      }
      return updated;
    } catch (_) {
      return const [];
    }
  }
}
