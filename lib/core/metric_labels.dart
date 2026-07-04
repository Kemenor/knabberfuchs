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

/// Compact one-line nutrient summary ("P 32 · KH 45 · F 8 g") for [metrics]
/// (canonical enum order, kcal skipped), all grams so the unit rides once at
/// the end. Empty when no metric is enabled.
String nutrientLine(
  AppLocalizations l10n,
  Nutrition n,
  Set<TargetMetric> metrics,
) {
  final parts = [
    for (final m in TargetMetric.values)
      if (m != TargetMetric.kcal && metrics.contains(m))
        '${metricShortLabel(l10n, m)} ${gramsStr(metricValue(n, m))}',
  ];
  return parts.isEmpty ? '' : '${parts.join(' · ')} g';
}
