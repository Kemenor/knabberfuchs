import 'dart:convert';

import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A realistic OFF v2 product payload (string numerics happen in real OFF
/// responses, so the fixture keeps some values as strings on purpose).
Map<String, dynamic> _product() => {
  'code': '7610200025678',
  'product_name': 'Rösti',
  'product_name_en': 'Hash browns',
  'brands': 'Migros',
  'lang': 'de',
  'serving_size': '250 g (1/2 Packung)',
  'nutriments': {
    'energy-kcal_100g': '112', // string numeric
    'proteins_100g': 2.5,
    'carbohydrates_100g': '15.0', // string numeric
    'fat_100g': 4.6,
    'fiber_100g': 1.8,
    'sugars_100g': 0.6,
    'saturated-fat_100g': 0.5,
    'sodium_100g': 0.24,
    'salt_100g': 0.6,
  },
  'countries_tags': ['en:switzerland', 'en:france'],
};

OffApi _api(http.Client client) => OffApi(client: client);

MockClient _productClient(Map<String, dynamic> body, {int status = 200}) =>
    MockClient((req) async {
      expect(req.url.host, 'world.openfoodfacts.org');
      expect(req.headers['User-Agent'], contains('Knabberfuchs'));
      return http.Response(
        jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      );
    });

void main() {
  group('productByBarcode', () {
    test('maps a full product, incl. string numerics and sodium g->mg', () async {
      final api = _api(_productClient({'status': 1, 'product': _product()}));
      final r = await api.productByBarcode('7610200025678');
      expect(r, isNotNull);
      final f = r!.food;
      expect(f.name.value, 'Rösti'); // product_name wins over the en fallback
      expect(f.barcode.value, '7610200025678');
      expect(f.externalId.value, '7610200025678');
      expect(f.brand.value, 'Migros');
      expect(f.locale.value, 'de');
      expect(f.servingLabel.value, '250 g (1/2 Packung)');
      expect(f.kcal100.value, 112); // parsed from the string numeric
      expect(f.protein100.value, 2.5);
      expect(f.carb100.value, 15.0); // parsed from the string numeric
      expect(f.fat100.value, 4.6);
      expect(f.fiber100.value, 1.8);
      expect(f.sugar100.value, 0.6);
      expect(f.satFat100.value, 0.5);
      expect(f.sodiumMg100.value, closeTo(240, 0.001)); // sodium_100g * 1000
      expect(f.saltG100.value, 0.6);
      expect(r.countryTag, 'en:switzerland'); // first of countries_tags
    });

    test('kJ-only products are rejected (no energy-kcal -> null)', () async {
      final p = _product();
      p['nutriments'] = {'energy_100g': 468}; // kJ; there is no kJ fallback
      final api = _api(_productClient({'status': 1, 'product': p}));
      expect(await api.productByBarcode('7610200025678'), isNull);
    });

    test('missing product_name falls back to product_name_en', () async {
      final p = _product()..remove('product_name');
      final api = _api(_productClient({'status': 1, 'product': p}));
      final r = await api.productByBarcode('7610200025678');
      expect(r!.food.name.value, 'Hash browns');
    });

    test('a product with no name at all is rejected', () async {
      final p = _product()
        ..remove('product_name')
        ..remove('product_name_en');
      final api = _api(_productClient({'status': 1, 'product': p}));
      expect(await api.productByBarcode('7610200025678'), isNull);
    });

    test('absent countries_tags yields a null countryTag', () async {
      final p = _product()..remove('countries_tags');
      final api = _api(_productClient({'status': 1, 'product': p}));
      final r = await api.productByBarcode('7610200025678');
      expect(r, isNotNull);
      expect(r!.countryTag, isNull);
    });

    test('status == 0 (unknown barcode) -> null', () async {
      final api = _api(
        _productClient({'status': 0, 'status_verbose': 'product not found'}),
      );
      expect(await api.productByBarcode('0000000000000'), isNull);
    });

    test('non-200 and non-JSON responses -> null, no throw', () async {
      expect(
        await _api(
          _productClient({'status': 1, 'product': _product()}, status: 404),
        ).productByBarcode('7610200025678'),
        isNull,
      );
      final htmlApi = _api(
        MockClient((_) async => http.Response('<html>rate limited</html>', 200)),
      );
      expect(await htmlApi.productByBarcode('7610200025678'), isNull);
    });
  });

  group('search', () {
    test('maps products, skipping unusable ones', () async {
      final noKcal = _product()
        ..['code'] = '111'
        ..['nutriments'] = {'proteins_100g': 1.0};
      final noName = _product()
        ..['code'] = '222'
        ..remove('product_name')
        ..remove('product_name_en');
      final noCode = _product()..remove('code');
      final enOnly = _product()
        ..['code'] = '333'
        ..remove('product_name');
      final api = _api(
        MockClient((req) async {
          expect(req.url.path, '/cgi/search.pl');
          expect(req.url.queryParameters['search_terms'], 'rösti');
          return http.Response(
            jsonEncode({
              'products': [
                _product(),
                noKcal,
                noName,
                noCode,
                'garbage', // non-map list items must be skipped
                enOnly,
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final out = await api.search('rösti');
      expect(out, hasLength(2));
      expect(out[0].name.value, 'Rösti');
      expect(out[0].barcode.value, '7610200025678'); // from the `code` field
      expect(out[1].name.value, 'Hash browns');
      expect(out[1].barcode.value, '333');
    });

    test('blank query returns [] without hitting the network', () async {
      final api = _api(MockClient((_) async => fail('no request expected')));
      expect(await api.search('   '), isEmpty);
    });

    test('non-200 and malformed bodies -> [], no throw', () async {
      expect(
        await _api(
          MockClient((_) async => http.Response('teapot', 418)),
        ).search('milk'),
        isEmpty,
      );
      expect(
        await _api(
          MockClient((_) async => http.Response('[1,2,3]', 200)),
        ).search('milk'),
        isEmpty,
      );
    });
  });
}
