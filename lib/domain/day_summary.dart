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

/// A resolved calorie target: either bound may be null (optional).
class CalorieTarget {
  final double? min;
  final double? max;
  const CalorieTarget(this.min, this.max);
  bool get isEmpty => min == null && max == null;
}

/// Everything the day screen needs: flat list, meal groups, totals, target.
class DaySummary {
  final String day;
  final List<EntryView> entries;
  final double? kcalMin;
  final double? kcalMax;

  DaySummary({
    required this.day,
    required this.entries,
    this.kcalMin,
    this.kcalMax,
  });

  Nutrition get total => Nutrition.sum(entries.map((e) => e.nutrition));

  bool get hasTarget => kcalMin != null || kcalMax != null;

  /// kcal left before hitting the max (negative = over). Null when no max.
  double? get remainingToMax => kcalMax == null ? null : kcalMax! - total.kcal;

  /// kcal still needed to reach the min (positive = short). Null when no min.
  double? get shortOfMin => kcalMin == null ? null : kcalMin! - total.kcal;

  TargetStatus get status =>
      statusFor(total.kcal, CalorieTarget(kcalMin, kcalMax));
}

/// Where [kcal] sits relative to a [target] (single source of truth shared by
/// the day screen and the trends charts).
TargetStatus statusFor(double kcal, CalorieTarget target) {
  if (target.max != null && kcal > target.max!) return TargetStatus.over;
  if (target.min != null && kcal < target.min!) return TargetStatus.under;
  if (!target.isEmpty) return TargetStatus.inRange;
  return TargetStatus.none;
}

/// One day's logged kcal paired with its resolved target and status — a point
/// in the trends charts.
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

/// One [DayTrend] per calendar day in [start, end] (inclusive). Days with no
/// entries get 0 kcal; each day resolves its own weekday target. [kcalByDay] is
/// keyed by 'YYYY-MM-DD' (see AppDatabase.watchDailyKcal).
List<DayTrend> buildDayTrends(
  DateTime start,
  DateTime end,
  Map<String, double> kcalByDay,
  List<Target> targets,
  double? defaultMin,
  double? defaultMax,
) {
  final out = <DayTrend>[];
  var d = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  while (!d.isAfter(last)) {
    final kcal = kcalByDay[DayKey.of(d)] ?? 0;
    // DateTime.weekday is Mon=1…Sun=7; resolveTarget wants Mon=0…Sun=6.
    final target = resolveTarget(targets, defaultMin, defaultMax, d.weekday - 1);
    out.add(
      DayTrend(
        date: d,
        kcal: kcal,
        target: target,
        status: statusFor(kcal, target),
      ),
    );
    d = d.add(const Duration(days: 1));
  }
  return out;
}

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

/// Resolve the calorie bounds for a weekday: the weekday's own values if set,
/// otherwise the app-wide defaults.
CalorieTarget resolveTarget(
  List<Target> targets,
  double? defaultMin,
  double? defaultMax,
  int weekdayIndex,
) {
  final t = targets.firstWhereOrNull((t) => t.weekday == weekdayIndex);
  return CalorieTarget(t?.kcalMin ?? defaultMin, t?.kcalMax ?? defaultMax);
}
