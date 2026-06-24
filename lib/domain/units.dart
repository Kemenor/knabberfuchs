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

  /// Quick-pick chip values, sensible for this unit.
  List<double> get quickAmounts => switch (this) {
    AmountUnit.grams => const [50, 100, 150, 200],
    AmountUnit.milliliters => const [100, 200, 250, 500],
    AmountUnit.teaspoon => const [1, 2, 3],
    AmountUnit.tablespoon => const [1, 2, 3],
    AmountUnit.cup => const [0.5, 1, 2],
  };

  /// A reasonable default amount to seed when switching to this unit.
  double get typicalAmount => switch (this) {
    AmountUnit.grams => 100,
    AmountUnit.milliliters => 200,
    AmountUnit.teaspoon => 1,
    AmountUnit.tablespoon => 1,
    AmountUnit.cup => 1,
  };
}
