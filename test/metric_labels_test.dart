import 'package:calorie_tracker/core/metric_labels.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/domain/nutrition.dart';
import 'package:calorie_tracker/l10n/app_localizations_de.dart';
import 'package:calorie_tracker/l10n/app_localizations_en.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// The compact per-meal nutrient line (meal headers + detail-page ingredient
// rows, FEEDBACK.md 2026-07-03): enabled-set driven, canonical metric order,
// bold labels, no unit (a single trailing "g" read as if it belonged to the
// last nutrient only — tester feedback 2026-07-06).
void main() {
  const n = Nutrition(
    kcal: 640,
    protein: 32.4,
    carb: 45,
    fat: 8.2,
    micros: {'fiber': 6.5, 'salt': 1.3},
  );

  String plain(List<TextSpan> spans) => spans.map((s) => s.text).join();

  test('renders enabled metrics in canonical order, unitless', () {
    final spans = nutrientSpans(AppLocalizationsEn(), n, {
      TargetMetric.fat,
      TargetMetric.protein,
      TargetMetric.carb,
    });
    expect(plain(spans), 'P 32.4 · C 45 · F 8.2');
  });

  test('labels are bold, values and separators are not', () {
    final spans = nutrientSpans(AppLocalizationsEn(), n, {
      TargetMetric.protein,
      TargetMetric.carb,
    });
    // [label][ value][sep][label][ value]
    expect(spans, hasLength(5));
    for (final s in spans) {
      final isLabel = s.text == 'P' || s.text == 'C';
      expect(
        s.style?.fontWeight,
        isLabel ? FontWeight.w700 : isNull,
        reason: 'span "${s.text}"',
      );
    }
  });

  test('micro metrics read from the micros map; absent keys are 0', () {
    final spans = nutrientSpans(AppLocalizationsEn(), n, {
      TargetMetric.fiber,
      TargetMetric.sugar,
      TargetMetric.salt,
    });
    expect(plain(spans), 'Fib 6.5 · Sug 0 · Salt 1.3');
  });

  test('kcal never appears even if passed; empty set yields no spans', () {
    expect(
      nutrientSpans(AppLocalizationsEn(), n, {TargetMetric.kcal}),
      isEmpty,
    );
    expect(nutrientSpans(AppLocalizationsEn(), n, {}), isEmpty);
  });

  test('short labels localize (German carb abbreviation is KH)', () {
    final spans = nutrientSpans(AppLocalizationsDe(), n, {TargetMetric.carb});
    expect(plain(spans), startsWith('KH '));
  });
}
