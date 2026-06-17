import 'dart:convert';

/// Immutable nutrition totals (absolute amounts, not per-100g).
/// Energy in kcal; macros in grams; [micros] is an open map of
/// nutrient-key -> amount for whatever extras a source provides.
class Nutrition {
  final double kcal;
  final double protein;
  final double carb;
  final double fat;
  final Map<String, double> micros;

  const Nutrition({
    this.kcal = 0,
    this.protein = 0,
    this.carb = 0,
    this.fat = 0,
    this.micros = const {},
  });

  static const zero = Nutrition();

  /// Scale a per-100g profile to an absolute amount for [grams].
  factory Nutrition.fromPer100g({
    required double kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    Map<String, double>? micros100,
    required double grams,
  }) {
    final f = grams / 100.0;
    return Nutrition(
      kcal: kcal100 * f,
      protein: (protein100 ?? 0) * f,
      carb: (carb100 ?? 0) * f,
      fat: (fat100 ?? 0) * f,
      micros: micros100 == null
          ? const {}
          : micros100.map((k, v) => MapEntry(k, v * f)),
    );
  }

  Nutrition operator +(Nutrition other) {
    final m = <String, double>{...micros};
    other.micros.forEach((k, v) => m[k] = (m[k] ?? 0) + v);
    return Nutrition(
      kcal: kcal + other.kcal,
      protein: protein + other.protein,
      carb: carb + other.carb,
      fat: fat + other.fat,
      micros: m,
    );
  }

  /// Sum a list of nutrition values.
  static Nutrition sum(Iterable<Nutrition> items) =>
      items.fold(zero, (acc, n) => acc + n);

  @override
  String toString() =>
      'Nutrition(kcal: ${kcal.toStringAsFixed(0)}, P: ${protein.toStringAsFixed(1)}, '
      'C: ${carb.toStringAsFixed(1)}, F: ${fat.toStringAsFixed(1)})';
}

/// Parse a micros JSON blob (nutrient-key -> number) into a typed map.
Map<String, double> decodeMicros(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    final raw = jsonDecode(json);
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
  } catch (_) {
    return const {};
  }
}

String? encodeMicros(Map<String, double> micros) =>
    micros.isEmpty ? null : jsonEncode(micros);
