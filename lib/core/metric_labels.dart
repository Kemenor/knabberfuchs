import 'package:flutter/painting.dart' show FontWeight, TextSpan, TextStyle;

import '../domain/day_summary.dart';
import '../domain/nutrition.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// Localized standalone label for a tracked metric — one source for the
/// Targets screen headers, Day-card bars, and Trends chips.
String metricLabel(AppLocalizations l10n, TargetMetric m) => switch (m) {
  TargetMetric.kcal => l10n.metricCalories,
  TargetMetric.protein => l10n.macroProtein,
  TargetMetric.carb => l10n.macroCarbs,
  TargetMetric.fat => l10n.macroFat,
  TargetMetric.fiber => l10n.metricFiber,
  TargetMetric.satFat => l10n.metricSatFat,
  TargetMetric.sugar => l10n.metricSugar,
  TargetMetric.salt => l10n.metricSalt,
};

/// Abbreviated metric label for space-tight lines (meal header subtotals,
/// per-ingredient stats). kcal never appears here — it has its own slot
/// everywhere these lines show up.
String metricShortLabel(AppLocalizations l10n, TargetMetric m) => switch (m) {
  TargetMetric.kcal => l10n.metricCalories,
  TargetMetric.protein => l10n.metricShortProtein,
  TargetMetric.carb => l10n.metricShortCarb,
  TargetMetric.fat => l10n.metricShortFat,
  TargetMetric.fiber => l10n.metricShortFiber,
  TargetMetric.satFat => l10n.metricShortSatFat,
  TargetMetric.sugar => l10n.metricShortSugar,
  TargetMetric.salt => l10n.metricShortSalt,
};

/// Compact one-line nutrient summary as rich-text spans — "**P** 32 ·
/// **KH** 45 · **F** 8" for [metrics] (canonical enum order, kcal skipped).
/// Bold labels carry the emphasis; deliberately unitless: values are always
/// grams, and a single trailing "g" read as if it belonged to the last
/// nutrient only (tester feedback 2026-07-06). Empty when no metric is
/// enabled.
List<TextSpan> nutrientSpans(
  AppLocalizations l10n,
  Nutrition n,
  Set<TargetMetric> metrics,
) {
  final spans = <TextSpan>[];
  for (final m in TargetMetric.values) {
    if (m == TargetMetric.kcal || !metrics.contains(m)) continue;
    if (spans.isNotEmpty) spans.add(const TextSpan(text: ' · '));
    spans.add(
      TextSpan(
        text: metricShortLabel(l10n, m),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
    spans.add(TextSpan(text: ' ${gramsStr(metricValue(n, m))}'));
  }
  return spans;
}
