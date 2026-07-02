import 'dart:convert';
import 'dart:io' show gzip;

import 'nutrition.dart';

/// A self-contained, shareable recipe: carries each ingredient's per-100g
/// macros so the receiver needs no lookups (works for custom/USDA foods too).
class RecipeShareItem {
  final String name;
  final double grams;
  final double kcal100;
  final double? protein100;
  final double? carb100;
  final double? fat100;

  /// Per-100g tracked nutrients + open micros (fiber/satFat/sugar/salt keys —
  /// see `snapshotMicros100`). Optional in the share payload; decoders that
  /// predate it ignore the key.
  final Map<String, double>? micros100;

  const RecipeShareItem({
    required this.name,
    required this.grams,
    required this.kcal100,
    this.protein100,
    this.carb100,
    this.fat100,
    this.micros100,
  });

  Nutrition get nutrition => Nutrition.fromPer100g(
    kcal100: kcal100,
    protein100: protein100,
    carb100: carb100,
    fat100: fat100,
    micros100: micros100,
    grams: grams,
  );
}

class RecipeShare {
  final String name;
  final double servings;
  final List<RecipeShareItem> items;

  const RecipeShare({
    required this.name,
    required this.servings,
    required this.items,
  });

  Nutrition get total => Nutrition.sum(items.map((i) => i.nutrition));
  Nutrition get perServing {
    final t = total;
    final s = servings <= 0 ? 1 : servings;
    return Nutrition(
      kcal: t.kcal / s,
      protein: t.protein / s,
      carb: t.carb / s,
      fat: t.fat / s,
      micros: t.micros.map((k, v) => MapEntry(k, v / s)),
    );
  }

  double get totalGrams => items.fold(0.0, (sum, i) => sum + i.grams);
}

/// Compact, versioned, serverless codec for QR / file sharing.
/// Format: `CTR1:` + base64url( gzip( json ) ), with short JSON keys.
class RecipeCodec {
  static const prefix = 'CTR1:';

  static String encode(RecipeShare r) {
    final map = {
      'v': 1,
      'n': r.name,
      's': r.servings,
      'i': [
        for (final i in r.items)
          {
            'n': i.name,
            'g': i.grams,
            'k': i.kcal100,
            if (i.protein100 != null) 'p': i.protein100,
            if (i.carb100 != null) 'c': i.carb100,
            if (i.fat100 != null) 'f': i.fat100,
            if (i.micros100 != null && i.micros100!.isNotEmpty)
              'm': i.micros100,
          },
      ],
    };
    final gz = gzip.encode(utf8.encode(jsonEncode(map)));
    return prefix + base64Url.encode(gz);
  }

  /// Returns null if [text] isn't a valid recipe payload.
  static RecipeShare? decode(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith(prefix)) return null;
    try {
      final gz = base64Url.decode(trimmed.substring(prefix.length));
      final map = jsonDecode(utf8.decode(gzip.decode(gz)));
      if (map is! Map) return null;
      double? d(Object? v) => v == null ? null : (v as num).toDouble();
      final items = <RecipeShareItem>[];
      for (final raw in (map['i'] as List? ?? const [])) {
        if (raw is! Map) continue;
        items.add(
          RecipeShareItem(
            name: (raw['n'] ?? '').toString(),
            grams: d(raw['g']) ?? 0,
            kcal100: d(raw['k']) ?? 0,
            protein100: d(raw['p']),
            carb100: d(raw['c']),
            fat100: d(raw['f']),
            micros100: raw['m'] is Map
                ? (raw['m'] as Map).map(
                    (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                  )
                : null,
          ),
        );
      }
      return RecipeShare(
        name: (map['n'] ?? 'Recipe').toString(),
        servings: d(map['s']) ?? 1,
        items: items,
      );
    } catch (_) {
      return null;
    }
  }
}
