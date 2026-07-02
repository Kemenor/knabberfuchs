import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../domain/offline_manifest.dart';
import '../db/database.dart';
import 'region_pack_store.dart';

/// Thrown when the user aborts an in-flight [OfflinePackService.install].
class InstallCancelledException implements Exception {}

/// Cooperative cancel flag for [OfflinePackService.install]; the download
/// checks it between chunks and before each commit step.
class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// Downloads / verifies / installs / removes offline OFF region packs and keeps
/// the [RegionPackStore] in sync. The dataset is public, so no auth is used.
class OfflinePackService {
  final AppDatabase db;
  final RegionPackStore store;

  /// One short-lived client per request so every code path closes it.
  final http.Client Function() _newClient;
  final Future<Directory> Function() _documentsDir;

  static const manifestUrl =
      'https://huggingface.co/datasets/Knabberfuchs/offline-packs/resolve/main/manifest.json';

  /// Request timeout, and max gap between download chunks (matches OffApi).
  static const _timeout = Duration(seconds: 10);

  OfflinePackService(
    this.db,
    this.store, {
    http.Client Function()? clientFactory,
    Future<Directory> Function()? documentsDir,
  }) : _newClient = clientFactory ?? http.Client.new,
       _documentsDir = documentsDir ?? getApplicationDocumentsDirectory;

  Future<OfflineManifest> fetchManifest() async {
    final client = _newClient();
    try {
      final res = await client.get(Uri.parse(manifestUrl)).timeout(_timeout);
      if (res.statusCode != 200) {
        throw Exception('Manifest unavailable (${res.statusCode})');
      }
      return OfflineManifest.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    } finally {
      client.close();
    }
  }

  Future<Directory> _packsDir() async {
    final dir = await _documentsDir();
    final packs = Directory('${dir.path}/packs');
    if (!await packs.exists()) await packs.create(recursive: true);
    return packs;
  }

  /// The version is part of the filename so an update lands at a *new* path:
  /// the store swaps handles on paths, never re-reading a rewritten file
  /// through a stale one.
  static String _packFileName(String code, String version) =>
      'region_${code}_${version.replaceAll(RegExp('[^A-Za-z0-9._-]'), '-')}'
      '.sqlite';

  /// Filename used before pack files carried their version.
  static String _legacyFileName(String code) => 'region_$code.sqlite';

  /// Download a region pack with progress (0..1), verify its sha256,
  /// decompress, write it to disk, record it, and re-open it in the store.
  /// A [cancelToken] aborts with [InstallCancelledException] before anything
  /// is committed.
  Future<void> install(
    OfflineManifest manifest,
    RegionInfo region, {
    void Function(double progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    void checkCancelled() {
      if (cancelToken?.isCancelled ?? false) throw InstallCancelledException();
    }

    checkCancelled();
    final gz = await _downloadGz(
      Uri.parse(region.downloadUrl(manifest.baseUrl)),
      region.size,
      onProgress,
      checkCancelled,
    );
    checkCancelled();

    // Checksum + gunzip run off the UI isolate — a pack is several MB.
    final expected = region.sha256;
    final raw = await Isolate.run(() {
      if (expected.isNotEmpty && sha256.convert(gz).toString() != expected) {
        throw Exception('Checksum mismatch — download corrupted');
      }
      return Uint8List.fromList(gzip.decode(gz));
    });
    checkCancelled();

    final dir = await _packsDir();
    final path = '${dir.path}/${_packFileName(region.code, region.version)}';
    // Write-then-rename so a crash mid-write never leaves a half-written file
    // at a path the store would try to open.
    final tmp = File('$path.tmp');
    try {
      await tmp.writeAsBytes(raw, flush: true);
      checkCancelled();
      await tmp.rename(path);
    } finally {
      if (await tmp.exists()) await tmp.delete();
    }

    await db.upsertInstalledPack(
      InstalledPacksCompanion.insert(
        code: region.code,
        name: region.name,
        version: region.version,
        products: region.products,
        sizeBytes: raw.length,
      ),
    );
    await syncStore();
    // Only after the store has switched to the new file: drop the previous
    // version's file (and any pre-versioning legacy file).
    await _deleteStaleFiles(dir, region.code, keep: path);
  }

  Future<Uint8List> _downloadGz(
    Uri url,
    int fallbackSize,
    void Function(double progress)? onProgress,
    void Function() checkCancelled,
  ) async {
    final client = _newClient();
    try {
      final resp = await client
          .send(http.Request('GET', url))
          .timeout(_timeout);
      if (resp.statusCode != 200) {
        throw Exception('Download failed (${resp.statusCode})');
      }
      final total = resp.contentLength ?? fallbackSize;
      final builder = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in resp.stream.timeout(_timeout)) {
        checkCancelled();
        builder.add(chunk);
        received += chunk.length;
        if (onProgress != null && total > 0) onProgress(received / total);
      }
      return builder.takeBytes();
    } finally {
      client.close();
    }
  }

  Future<void> remove(String code) async {
    final dir = await _packsDir();
    await db.deleteInstalledPack(code);
    await syncStore();
    await _deleteStaleFiles(dir, code, keep: null);
  }

  /// Delete every pack file belonging to [code] except [keep] (pass null to
  /// delete them all): older versions and the legacy unversioned name.
  Future<void> _deleteStaleFiles(
    Directory dir,
    String code, {
    required String? keep,
  }) async {
    await for (final entry in dir.list()) {
      if (entry is! File || entry.path == keep) continue;
      final name = entry.uri.pathSegments.last;
      final isPackFile =
          name == _legacyFileName(code) ||
          (name.startsWith('region_${code}_') &&
              (name.endsWith('.sqlite') || name.endsWith('.sqlite.tmp')));
      if (!isPackFile) continue;
      try {
        await entry.delete();
      } catch (_) {
        // best-effort cleanup; an orphan is retried on the next install/remove
      }
    }
  }

  /// Map of installed code -> existing file path (drops records with no file).
  Future<Map<String, String>> installedPaths() async {
    final dir = await _packsDir();
    final out = <String, String>{};
    for (final p in await db.installedPacksList()) {
      final versioned = '${dir.path}/${_packFileName(p.code, p.version)}';
      if (await File(versioned).exists()) {
        out[p.code] = versioned;
        continue;
      }
      // Packs installed before filenames carried the version.
      final legacy = '${dir.path}/${_legacyFileName(p.code)}';
      if (await File(legacy).exists()) out[p.code] = legacy;
    }
    return out;
  }

  /// Open all installed packs in the store (call at startup).
  Future<void> syncStore() async => store.setPacks(await installedPaths());
}
