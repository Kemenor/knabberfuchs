import 'package:calorie_tracker/core/metric_labels.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/domain/nutrition.dart';
import 'package:calorie_tracker/l10n/app_localizations_de.dart';
import 'package:calorie_tracker/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

// The compact per-meal nutrient line (meal headers + detail-page ingredient
// rows, FEEDBACK.md 2026-07-03): enabled-set driven, canonical metric order,
// single trailing unit.
void main() {
  const n = Nutrition(
    kcal: 640,
    protein: 32.4,
    carb: 45,
    fat: 8.2,
    micros: {'fiber': 6.5, 'salt': 1.3},
  );

  test('renders enabled metrics in canonical order with one trailing g', () {
    final line = nutrientLine(AppLocalizationsEn(), n, {
      TargetMetric.fat,
      TargetMetric.protein,
      TargetMetric.carb,
    });
    expect(line, 'P 32.4 · C 45 · F 8.2 g');
  });

  test('micro metrics read from the micros map; absent keys are 0', () {
    final line = nutrientLine(AppLocalizationsEn(), n, {
      TargetMetric.fiber,
      TargetMetric.sugar,
      TargetMetric.salt,
    });
    expect(line, 'Fib 6.5 · Sug 0 · Salt 1.3 g');
  });

  test('kcal never appears even if passed; empty set yields empty line', () {
    expect(
      nutrientLine(AppLocalizationsEn(), n, {TargetMetric.kcal}),
      isEmpty,
    );
    expect(nutrientLine(AppLocalizationsEn(), n, {}), isEmpty);
  });

  test('short labels localize (German carb abbreviation is KH)', () {
    final line = nutrientLine(AppLocalizationsDe(), n, {TargetMetric.carb});
    expect(line, startsWith('KH '));
  });
}
