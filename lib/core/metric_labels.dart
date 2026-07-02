import '../domain/day_summary.dart';
import '../l10n/app_localizations.dart';

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
