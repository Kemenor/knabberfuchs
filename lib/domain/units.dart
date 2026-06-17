/// Amount units for logging. Volume units convert to grams via a density
/// (g/ml); default 1.0 (water-like) is a reasonable approximation for most
/// tracked liquids. Entries are always stored in grams — the unit is only an
/// input convenience.
enum AmountUnit { grams, milliliters, teaspoon, tablespoon, cup }

extension AmountUnitX on AmountUnit {
  String get label => switch (this) {
        AmountUnit.grams => 'g',
        AmountUnit.milliliters => 'ml',
        AmountUnit.teaspoon => 'tsp',
        AmountUnit.tablespoon => 'tbsp',
        AmountUnit.cup => 'cup',
      };

  /// Milliliters per unit (1 for grams — treated as g directly).
  double get _ml => switch (this) {
        AmountUnit.grams => 1,
        AmountUnit.milliliters => 1,
        AmountUnit.teaspoon => 5,
        AmountUnit.tablespoon => 15,
        AmountUnit.cup => 240,
      };

  bool get isVolume => this != AmountUnit.grams;

  /// Convert [amount] of this unit to grams, using [density] g/ml for volumes.
  double toGrams(double amount, {double density = 1.0}) =>
      this == AmountUnit.grams ? amount : amount * _ml * density;
}
