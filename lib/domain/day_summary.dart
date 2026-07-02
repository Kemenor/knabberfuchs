import 'package:collection/collection.dart';

import '../core/date_x.dart';
import '../data/db/database.dart';
import 'enums.dart';
import 'nutrition.dart';

/// A diary entry paired with its computed (absolute) nutrition.
class EntryView {
  final Entry entry;
  final Nutrition nutrition;

  EntryView(this.entry)
    : nutrition = Nutrition.fromPer100g(
        kcal100: entry.sKcal100,
        protein100: entry.sProtein100,
        carb100: entry.sCarb100,
        fat100: entry.sFat100,
        micros100: decodeMicros(entry.sMicrosJson),
        grams: entry.grams,
      );

  int get id => entry.id;
  String get name => entry.sName;
  double get grams => entry.grams;
  MealType get meal => entry.mealType;
}

/// An ad-hoc day-mode group (header) with its entries and subtotal.
class GroupView {
  final EntryGroup group;
  final List<EntryView> items;

  GroupView(this.group, this.items);

  int get id => group.id;
  String get name => group.name;
  Nutrition get subtotal => Nutrition.sum(items.map((e) => e.nutrition));
}

/// Where the day's total sits relative to its (optional) calorie bounds.
enum TargetStatus { none, under, inRange, over }

/// A resolved target as a min/max bound pair — used for calories *and* each
/// macro (the name is historical; it is a generic optional bound). Either bound
/// may be null.
class CalorieTarget {
  final double? min;
  final double? max;
  const CalorieTarget(this.min, this.max);
  bool get isEmpty => min == null && max == null;
}

/// The trackable metrics that can carry a target. Calories are in kcal; all
/// others are in grams. kcal/protein/carb/fat live as typed entry-snapshot
/// columns; fiber/satFat/sugar/salt ride the `sMicrosJson` blob keyed by the
/// enum name (see [snapshotMicros100]).
enum TargetMetric { kcal, protein, carb, fat, fiber, satFat, sugar, salt }

/// The nutrients beyond kcal/P/C/F that became trackable in Phase 15.
const microMetrics = [
  TargetMetric.fiber,
  TargetMetric.satFat,
  TargetMetric.sugar,
  TargetMetric.salt,
];

/// The per-100g micros blob written into every entry/recipe-item snapshot:
/// whatever open micros the food already carries, plus the tracked nutrients
/// from their typed food columns. Always written in full — the user's enabled
/// set only gates display, so enabling a nutrient later has data from today
/// backward.
Map<String, double> snapshotMicros100(Food f) => {
  ...decodeMicros(f.microsJson),
  if (f.fiber100 != null) TargetMetric.fiber.name: f.fiber100!,
  if (f.satFat100 != null) TargetMetric.satFat.name: f.satFat100!,
  if (f.sugar100 != null) TargetMetric.sugar.name: f.sugar100!,
  if (f.saltG100 != null) TargetMetric.salt.name: f.saltG100!,
};

/// The day's total for [m], pulled from an already-summed [Nutrition].
double metricValue(Nutrition n, TargetMetric m) => switch (m) {
  TargetMetric.kcal => n.kcal,
  TargetMetric.protein => n.protein,
  TargetMetric.carb => n.carb,
  TargetMetric.fat => n.fat,
  // Micro-backed metrics: absent from old entries reads as 0, same as an
  // unlogged day.
  _ => n.micros[m.name] ?? 0,
};

/// A [Target] row's (min, max) for [m] — null row or null bound both read null.
(double?, double?) targetRowBounds(Target? t, TargetMetric m) => switch (m) {
  TargetMetric.kcal => (t?.kcalMin, t?.kcalMax),
  TargetMetric.protein => (t?.proteinMin, t?.proteinMax),
  TargetMetric.carb => (t?.carbMin, t?.carbMax),
  TargetMetric.fat => (t?.fatMin, t?.fatMax),
  TargetMetric.fiber => (t?.fiberMin, t?.fiberMax),
  TargetMetric.satFat => (t?.satFatMin, t?.satFatMax),
  TargetMetric.sugar => (t?.sugarMin, t?.sugarMax),
  TargetMetric.salt => (t?.saltMin, t?.saltMax),
};

/// Fill fraction 0..1 for a metric's progress bar, or null when the metric has
/// no usable bound (→ draw no bar). The denominator is the max if set, else the
/// min — a floor (e.g. a protein goal) the bar fills toward and reads full at.
double? targetBarFraction(double value, CalorieTarget t) {
  final denom = t.max ?? t.min;
  if (denom == null || denom <= 0) return null;
  return (value / denom).clamp(0.0, 1.0);
}

/// Everything the day screen needs: flat list, meal groups, totals, target.
class DaySummary {
  final String day;
  final List<EntryView> entries;
  final double? kcalMin;
  final double? kcalMax;

  /// Resolved bounds per non-kcal metric; an absent key = no target. A map
  /// (not named fields) so new tracked nutrients don't grow the constructor.
  final Map<TargetMetric, CalorieTarget> metricTargets;

  DaySummary({
    required this.day,
    required this.entries,
    this.kcalMin,
    this.kcalMax,
    this.metricTargets = const {},
  });

  Nutrition get total => Nutrition.sum(entries.map((e) => e.nutrition));

  bool get hasTarget => kcalMin != null || kcalMax != null;

  /// kcal left before hitting the max (negative = over). Null when no max.
  double? get remainingToMax => kcalMax == null ? null : kcalMax! - total.kcal;

  /// kcal still needed to reach the min (positive = short). Null when no min.
  double? get shortOfMin => kcalMin == null ? null : kcalMin! - total.kcal;

  TargetStatus get status =>
      statusFor(total.kcal, CalorieTarget(kcalMin, kcalMax));

  /// The resolved target for any metric (kcal pulled from kcalMin/kcalMax).
  CalorieTarget targetFor(TargetMetric m) => m == TargetMetric.kcal
      ? CalorieTarget(kcalMin, kcalMax)
      : metricTargets[m] ?? const CalorieTarget(null, null);

  double valueFor(TargetMetric m) => metricValue(total, m);
  TargetStatus statusForMetric(TargetMetric m) =>
      statusFor(valueFor(m), targetFor(m));

  /// Bar fill 0..1 for [m], or null when it has no target (→ no bar drawn).
  double? barFractionFor(TargetMetric m) =>
      targetBarFraction(valueFor(m), targetFor(m));
}

/// Where [kcal] sits relative to a [target] (single source of truth shared by
/// the day screen and the trends charts).
TargetStatus statusFor(double kcal, CalorieTarget target) {
  if (target.max != null && kcal > target.max!) return TargetStatus.over;
  if (target.min != null && kcal < target.min!) return TargetStatus.under;
  if (!target.isEmpty) return TargetStatus.inRange;
  return TargetStatus.none;
}

/// One day's logged value for the charted metric, paired with its resolved
/// target and status — a point in the trends charts. [kcal] holds whichever
/// metric the chart is showing (kcal or a macro's grams).
class DayTrend {
  final DateTime date;
  final double kcal;
  final CalorieTarget target;
  final TargetStatus status;
  const DayTrend({
    required this.date,
    required this.kcal,
    required this.target,
    required this.status,
  });
}

/// One [DayTrend] per calendar day in [start, end] (inclusive) for [metric].
/// Days with no entries get 0; each day resolves its own weekday target,
/// falling back to [defaults]. [valueByDay] is keyed by 'YYYY-MM-DD'.
List<DayTrend> buildMetricDayTrends(
  DateTime start,
  DateTime end,
  Map<String, double> valueByDay,
  List<Target> targets,
  TargetMetric metric,
  CalorieTarget defaults,
) {
  final out = <DayTrend>[];
  var d = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  while (!d.isAfter(last)) {
    final value = valueByDay[DayKey.of(d)] ?? 0;
    // DateTime.weekday is Mon=1…Sun=7; resolveMetricTarget wants Mon=0…Sun=6.
    final target = resolveMetricTarget(targets, metric, defaults, d.weekday - 1);
    out.add(
      DayTrend(
        date: d,
        kcal: value,
        target: target,
        status: statusFor(value, target),
      ),
    );
    // Calendar step, not Duration: a 25 h DST day would repeat, a 23 h one skip.
    d = DateTime(d.year, d.month, d.day + 1);
  }
  return out;
}

/// Calorie convenience over [buildMetricDayTrends] (kept for existing callers).
List<DayTrend> buildDayTrends(
  DateTime start,
  DateTime end,
  Map<String, double> kcalByDay,
  List<Target> targets,
  double? defaultMin,
  double? defaultMax,
) => buildMetricDayTrends(
  start,
  end,
  kcalByDay,
  targets,
  TargetMetric.kcal,
  CalorieTarget(defaultMin, defaultMax),
);

/// How the chart aggregates a range of [dayCount] days: daily up to ~6 weeks,
/// weekly up to a year, monthly beyond.
enum TrendBucket { daily, weekly, monthly }

TrendBucket trendBucketFor(int dayCount) => dayCount <= 45
    ? TrendBucket.daily
    : dayCount <= 366
    ? TrendBucket.weekly
    : TrendBucket.monthly;

/// Reduce a bucket of consecutive days to one point: the average intake over its
/// *logged* days (0 = a gap) and the average target.
DayTrend _reduceBucket(List<DayTrend> chunk) {
  final logged = chunk.where((d) => d.kcal > 0).toList();
  final kcal = logged.isEmpty
      ? 0.0
      : logged.fold<double>(0, (s, d) => s + d.kcal) / logged.length;
  double? avgBound(double? Function(DayTrend) pick) {
    final vs = [
      for (final d in chunk)
        if (pick(d) != null) pick(d)!,
    ];
    return vs.isEmpty ? null : vs.reduce((a, b) => a + b) / vs.length;
  }

  final target = CalorieTarget(
    avgBound((d) => d.target.min),
    avgBound((d) => d.target.max),
  );
  return DayTrend(
    date: chunk.first.date,
    kcal: kcal,
    target: target,
    status: statusFor(kcal, target),
  );
}

/// Collapse a long daily series into weekly or monthly buckets (see
/// [trendBucketFor]) so a long range stays readable as a chart. Short ranges are
/// returned unchanged.
List<DayTrend> bucketTrends(List<DayTrend> daily) {
  switch (trendBucketFor(daily.length)) {
    case TrendBucket.daily:
      return daily;
    case TrendBucket.weekly:
      final out = <DayTrend>[];
      for (var i = 0; i < daily.length; i += 7) {
        final end = i + 7 < daily.length ? i + 7 : daily.length;
        out.add(_reduceBucket(daily.sublist(i, end)));
      }
      return out;
    case TrendBucket.monthly:
      final out = <DayTrend>[];
      var i = 0;
      while (i < daily.length) {
        final y = daily[i].date.year, m = daily[i].date.month;
        var j = i;
        while (j < daily.length &&
            daily[j].date.year == y &&
            daily[j].date.month == m) {
          j++;
        }
        out.add(_reduceBucket(daily.sublist(i, j)));
        i = j;
      }
      return out;
  }
}

/// Resolve a metric's bounds for a weekday: the weekday's own values if set,
/// otherwise the app-wide [defaults] for that metric.
CalorieTarget resolveMetricTarget(
  List<Target> targets,
  TargetMetric metric,
  CalorieTarget defaults,
  int weekdayIndex,
) {
  final t = targets.firstWhereOrNull((t) => t.weekday == weekdayIndex);
  final (min, max) = targetRowBounds(t, metric);
  return CalorieTarget(min ?? defaults.min, max ?? defaults.max);
}

/// Resolve the calorie bounds for a weekday (kcal convenience over
/// [resolveMetricTarget]; kept for the day + trends callers).
CalorieTarget resolveTarget(
  List<Target> targets,
  double? defaultMin,
  double? defaultMax,
  int weekdayIndex,
) => resolveMetricTarget(
  targets,
  TargetMetric.kcal,
  CalorieTarget(defaultMin, defaultMax),
  weekdayIndex,
);
