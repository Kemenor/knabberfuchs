import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../../domain/enums.dart';
import '../db/database.dart';
import 'rate_limiter.dart';

/// Thin client over the Open Food Facts REST API.
///
/// Maps products straight into [FoodsCompanion] rows so callers can cache them.
/// Every call goes through a [TokenBucket] to honour OFF's per-minute limits
/// (15/min product reads, 10/min searches). OFF needs no API key.
class OffApi {
  final http.Client _client;
  final TokenBucket productBucket;
  final TokenBucket searchBucket;

  static const _host = 'world.openfoodfacts.org';
  static const _fields =
      'code,product_name,product_name_en,brands,nutriments,serving_quantity,serving_size,lang';
  // OFF asks every app to identify itself.
  static const _headers = {
    'User-Agent': 'CalorieTracker/0.1 (Android; contact developer@knabberfuchs.ch)',
  };

  OffApi({
    http.Client? client,
    TokenBucket? productBucket,
    TokenBucket? searchBucket,
  }) : _client = client ?? http.Client(),
       productBucket =
           productBucket ??
           TokenBucket(capacity: 15, window: const Duration(minutes: 1)),
       searchBucket =
           searchBucket ??
           TokenBucket(capacity: 10, window: const Duration(minutes: 1));

  /// Look up a single product by barcode. Returns null if unknown / no energy.
  Future<FoodsCompanion?> productByBarcode(String barcode) async {
    await productBucket.acquire();
    final uri = Uri.https(_host, '/api/v2/product/$barcode.json', {
      'fields': _fields,
    });
    try {
      final res = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) return null;
      if (body['status'] == 0 || body['product'] == null) return null;
      return _mapProduct(body['product'] as Map<String, dynamic>, barcode);
    } catch (_) {
      return null; // network failure, timeout, or non-JSON body
    }
  }

  /// Full-text search. Caller must debounce — this is the 10/min endpoint.
  Future<List<FoodsCompanion>> search(String query, {int pageSize = 20}) async {
    if (query.trim().isEmpty) return const [];
    await searchBucket.acquire();
    final uri = Uri.https(_host, '/cgi/search.pl', {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$pageSize',
      'fields': _fields,
    });
    try {
      final res = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) return const [];
      final products = (body['products'] as List?) ?? const [];
      final out = <FoodsCompanion>[];
      for (final p in products) {
        if (p is! Map<String, dynamic>) continue;
        final mapped = _mapProduct(p, (p['code'] ?? '').toString());
        if (mapped != null) out.add(mapped);
      }
      return out;
    } catch (_) {
      return const []; // network failure, timeout, or non-JSON body
    }
  }

  FoodsCompanion? _mapProduct(Map<String, dynamic> p, String barcode) {
    final name = (p['product_name'] ?? p['product_name_en'] ?? '')
        .toString()
        .trim();
    if (name.isEmpty || barcode.isEmpty) return null;

    final n = (p['nutriments'] as Map?) ?? const {};
    double? val(String k) {
      final v = n[k];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final kcal = val('energy-kcal_100g');
    if (kcal == null) return null; // no energy -> not useful for a calorie app

    final sodiumG = val('sodium_100g');
    String? str(String key) {
      final v = (p[key] ?? '').toString().trim();
      return v.isEmpty ? null : v;
    }

    return FoodsCompanion.insert(
      source: FoodSource.openFoodFacts,
      externalId: Value(barcode),
      barcode: Value(barcode),
      name: name,
      brand: Value(str('brands')),
      locale: Value(str('lang')),
      servingG: Value(val('serving_quantity')),
      servingLabel: Value(str('serving_size')),
      kcal100: kcal,
      protein100: Value(val('proteins_100g')),
      carb100: Value(val('carbohydrates_100g')),
      fat100: Value(val('fat_100g')),
      fiber100: Value(val('fiber_100g')),
      sugar100: Value(val('sugars_100g')),
      satFat100: Value(val('saturated-fat_100g')),
      sodiumMg100: Value(sodiumG == null ? null : sodiumG * 1000),
      saltG100: Value(val('salt_100g')),
      microsJson: const Value(null),
    );
  }

  void close() => _client.close();
}
