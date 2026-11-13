/// Where a food record came from. Stored as the enum index (drift intEnum), so
/// the order is load-bearing — a DB migration renumbers existing rows whenever
/// it changes (see schema v8).
enum FoodSource {
  /// Fetched from the Open Food Facts live API (packaged / barcoded products).
  openFoodFacts,

  /// Entered by the user. Covers both barcodeless custom foods and products the
  /// user added for a missing barcode (those just also carry a [barcode], which
  /// is what makes them re-scannable). Merged from the old `custom` +
  /// `userContributed` since there's no direct OFF upload to distinguish them.
  custom,

  /// From the bundled Swiss Food Composition Database (FSVO/BLV) — curated,
  /// multilingual whole foods.
  swissFcdb,
}

/// What a body measurement measures. Stored as the enum index — append only.
enum MeasurementKind { weight }

/// Where a body measurement came from. Stored as the enum index — append only.
enum MeasurementSource {
  /// Typed into knabberfuchs.
  manual,

  /// Imported from Health Connect / Apple Health (a scale, another app).
  health,
}

/// Meal a diary entry belongs to. Order matters: it's the display order.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  /// Monday-first weekday helper lives elsewhere; this is just a label key.
  String get labelKey => name;
}

extension MealTypeLabel on MealType {
  String get label => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snacks',
  };

  /// Singular form, used when naming a single meal ("Snack 14:02").
  String get title => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
  };
}
