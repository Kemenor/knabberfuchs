import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../domain/offline_manifest.dart';
import '../db/database.dart';
import 'region_pack_store.dart';

/// Downloads / verifies / installs / removes offline OFF region packs and keeps
/// the [RegionPackStore] in sync. The dataset is public, so no auth is used.
class OfflinePackService {
  final AppDatabase db;
  final RegionPackStore store;

  static const manifestUrl =
      'https://huggingface.co/datasets/Knabberfuchs/offline-packs/resolve/main/manifest.json';

  OfflinePackService(this.db, this.store);

  Future<OfflineManifest> fetchManifest() async {
    final res = await http.get(Uri.parse(manifestUrl));
    if (res.statusCode != 200) {
      throw Exception('Manifest unavailable (${res.statusCode})');
    }
    return OfflineManifest.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<Directory> _packsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final packs = Directory('${dir.path}/packs');
    if (!await packs.exists()) await packs.create(recursive: true);
    return packs;
  }

  String _packPath(String dirPath, String code) =>
      '$dirPath/region_$code.sqlite';

  /// Download a region pack with progress (0..1), verify its sha256, decompress,
  /// write it to disk, record it, and re-open it in the store.
  Future<void> install(
    OfflineManifest manifest,
    RegionInfo region, {
    void Function(double progress)? onProgress,
  }) async {
    final req = http.Request(
      'GET',
      Uri.parse(region.downloadUrl(manifest.baseUrl)),
    );
    final resp = await http.Client().send(req);
    if (resp.statusCode != 200) {
      throw Exception('Download failed (${resp.statusCode})');
    }
    final total = resp.contentLength ?? region.size;
    final builder = BytesBuilder(copy: false);
    var received = 0;
    await for (final chunk in resp.stream) {
      builder.add(chunk);
      received += chunk.length;
      if (onProgress != null && total > 0) onProgress(received / total);
    }
    final gz = builder.toBytes();

    if (region.sha256.isNotEmpty &&
        sha256.convert(gz).toString() != region.sha256) {
      throw Exception('Checksum mismatch — download corrupted');
    }

    final raw = Uint8List.fromList(gzip.decode(gz));
    final dir = await _packsDir();
    await File(_packPath(dir.path, region.code)).writeAsBytes(raw, flush: true);

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
  }

  Future<void> remove(String code) async {
    final dir = await _packsDir();
    final f = File(_packPath(dir.path, code));
    if (await f.exists()) await f.delete();
    await db.deleteInstalledPack(code);
    await syncStore();
  }

  /// Map of installed code -> existing file path (drops records with no file).
  Future<Map<String, String>> installedPaths() async {
    final dir = await _packsDir();
    final out = <String, String>{};
    for (final p in await db.installedPacksList()) {
      final path = _packPath(dir.path, p.code);
      if (await File(path).exists()) out[p.code] = path;
    }
    return out;
  }

  /// Open all installed packs in the store (call at startup).
  Future<void> syncStore() async => store.setPacks(await installedPaths());
}
