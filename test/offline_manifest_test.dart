import 'dart:convert';

import 'package:calorie_tracker/domain/offline_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const raw = '''
  {
    "schema": 1,
    "baseUrl": "https://example/resolve/main",
    "attribution": "Data from Open Food Facts, ODbL.",
    "regions": [
      {"code":"ch","name":"Switzerland","country_tag":"en:switzerland",
       "version":"20260617","products":86026,
       "file":"packs/ch/20260617/region_ch.sqlite.gz","size":6083384,
       "sha256":"abc123","deltas":[]}
    ]
  }''';

  test('parses manifest + region and builds download URL', () {
    final m = OfflineManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(m.baseUrl, 'https://example/resolve/main');
    expect(m.attribution, contains('Open Food Facts'));
    expect(m.regions, hasLength(1));
    final r = m.regions.single;
    expect(r.code, 'ch');
    expect(r.name, 'Switzerland');
    expect(r.version, '20260617');
    expect(r.products, 86026);
    expect(r.size, 6083384);
    expect(r.sha256, 'abc123');
    expect(
      r.downloadUrl(m.baseUrl),
      'https://example/resolve/main/packs/ch/20260617/region_ch.sqlite.gz',
    );
  });

  test('tolerates missing optional fields', () {
    final m = OfflineManifest.fromJson(
      jsonDecode('{"regions":[]}') as Map<String, dynamic>,
    );
    expect(m.regions, isEmpty);
    expect(m.baseUrl, '');
  });
}
