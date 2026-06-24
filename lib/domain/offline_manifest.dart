/// Parsed `manifest.json` from the offline-packs dataset.
class OfflineManifest {
  final String baseUrl;
  final String attribution;
  final List<RegionInfo> regions;

  OfflineManifest({
    required this.baseUrl,
    required this.attribution,
    required this.regions,
  });

  factory OfflineManifest.fromJson(Map<String, dynamic> j) => OfflineManifest(
    baseUrl: (j['baseUrl'] ?? '') as String,
    attribution: (j['attribution'] ?? '') as String,
    regions: [
      for (final r in (j['regions'] as List? ?? const []))
        RegionInfo.fromJson(r as Map<String, dynamic>),
    ],
  );
}

/// One downloadable region in the manifest.
class RegionInfo {
  final String code;
  final String name;
  final String countryTag;
  final String version;
  final int products;
  final String file; // path within the dataset
  final int size; // gzipped bytes
  final String sha256;

  RegionInfo({
    required this.code,
    required this.name,
    required this.countryTag,
    required this.version,
    required this.products,
    required this.file,
    required this.size,
    required this.sha256,
  });

  factory RegionInfo.fromJson(Map<String, dynamic> j) => RegionInfo(
    code: j['code'] as String,
    name: j['name'] as String,
    countryTag: (j['country_tag'] ?? '') as String,
    version: j['version'].toString(),
    products: (j['products'] as num?)?.toInt() ?? 0,
    file: j['file'] as String,
    size: (j['size'] as num?)?.toInt() ?? 0,
    sha256: (j['sha256'] ?? '') as String,
  );

  String downloadUrl(String baseUrl) => '$baseUrl/$file';
}
