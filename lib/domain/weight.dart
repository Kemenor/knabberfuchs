import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../core/date_x.dart';
import '../data/db/database.dart';

// Weight tracking maths (PLAN-ai-bridge-and-weight.md, Part B). Everything
// here is pure: weigh-ins in, numbers out. Stored values are kg.

/// The display unit. Values are always stored in kg.
enum WeightUnit {
  kg,
  lb;

  static const _kgPerLb = 0.45359237;

  double fromKg(double kg) => this == WeightUnit.kg ? kg : kg / _kgPerLb;
  double toKg(double v) => this == WeightUnit.kg ? v : v * _kgPerLb;
}

/// Countries that weigh in pounds (US, Liberia, Myanmar); everyone else kg.
WeightUnit defaultWeightUnit(String? countryCode) =>
    const {'US', 'LR', 'MM'}.contains(countryCode?.toUpperCase())
    ? WeightUnit.lb
    : WeightUnit.kg;

/// The `weightUnit` setting, falling back to the region's default.
WeightUnit parseWeightUnit(String? setting, String? countryCode) =>
    switch (setting) {
      'kg' => WeightUnit.kg,
      'lb' => WeightUnit.lb,
      _ => defaultWeightUnit(countryCode),
    };

/// The weigh-in that stands for its day: the one the user chose ("Count this
/// one"), else the day's first. [dayRows] are one day's visible weigh-ins.
BodyMeasurement? countingWeighIn(Iterable<BodyMeasurement> dayRows) {
  BodyMeasurement? best;
  for (final r in dayRows) {
    if (r.hidden) continue;
    if (best == null ||
        (r.countsForDay && !best.countsForDay) ||
        (r.countsForDay == best.countsForDay && _earlier(r, best))) {
      best = r;
    }
  }
  return best;
}

bool _earlier(BodyMeasurement a, BodyMeasurement b) =>
    a.measuredAt.isBefore(b.measuredAt) ||
    (a.measuredAt == b.measuredAt && a.id < b.id);

/// The day's value for every day with a visible weigh-in.
Map<String, double> dailyWeights(Iterable<BodyMeasurement> rows) {
  final byDay = <String, List<BodyMeasurement>>{};
  for (final r in rows) {
    if (!r.hidden) (byDay[r.day] ??= []).add(r);
  }
  return {
    for (final e in byDay.entries) e.key: countingWeighIn(e.value)!.value,
  };
}

/// A minimum of values in a 7-day window before it gets an average, so one
/// or two weigh-ins don't pose as a trend.
const minValuesForAverage = 3;

/// Daily weights plus the trend maths over them.
class WeightSeries {
  WeightSeries(this.daily) : days = daily.keys.toList()..sort();

  factory WeightSeries.from(Iterable<BodyMeasurement> rows) =>
      WeightSeries(dailyWeights(rows));

  /// day → kg (the day's counting weigh-in).
  final Map<String, double> daily;

  /// Days with a value, oldest first.
  final List<String> days;

  bool get isEmpty => days.isEmpty;

  /// The 7-day average ending on [day]: the mean of the days in the trailing
  /// week that have a value, from [minValuesForAverage] values on — gaps
  /// don't make it jump. Null with fewer.
  double? averageAt(String day) {
    var sum = 0.0;
    var n = 0;
    for (var i = 0; i < 7; i++) {
      final v = daily[DayKey.shift(day, -i)];
      if (v != null) {
        sum += v;
        n++;
      }
    }
    return n >= minValuesForAverage ? sum / n : null;
  }

  /// Change of the 7-day average against the week before.
  double? weekChangeAt(String day) {
    final now = averageAt(day);
    final before = averageAt(DayKey.shift(day, -7));
    return now == null || before == null ? null : now - before;
  }

  /// The latest day with a value on or before [day].
  String? latestUpTo(String day) {
    for (var i = days.length - 1; i >= 0; i--) {
      if (days[i].compareTo(day) <= 0) return days[i];
    }
    return null;
  }

  /// The first 7-day average there is ("since start" counts from the trend,
  /// not from a single, possibly noisy, first weigh-in).
  ({String day, double kg})? get firstAverage {
    if (days.isEmpty) return null;
    final last = days.last;
    for (var d = days.first; d.compareTo(last) <= 0; d = DayKey.shift(d, 1)) {
      final a = averageAt(d);
      if (a != null) return (day: d, kg: a);
    }
    return null;
  }
}

/// One calendar week in the Weight view's list.
class WeightWeek {
  const WeightWeek({
    required this.start,
    required this.days,
    required this.mean,
    required this.change,
    required this.isCurrent,
  });

  /// First day of the week (the locale's first weekday).
  final String start;

  /// The week's days, oldest first — the current week stops at today.
  final List<String> days;

  /// Mean of the week's daily values; null for a week without weigh-ins.
  final double? mean;

  /// [mean] minus the week before's; null if either is missing.
  final double? change;

  /// The week containing today ("so far").
  final bool isCurrent;
}

/// The start of [day]'s week, for a week that begins on [firstWeekday]
/// (DateTime.monday … DateTime.sunday).
String weekStartOf(String day, int firstWeekday) {
  final d = DayKey.parse(day);
  return DayKey.shift(day, -((d.weekday - firstWeekday) % 7));
}

/// Calendar weeks from the one containing [today] back to the one
/// containing [from], newest first. Weeks — not a rolling window — so a
/// row doesn't change every day.
List<WeightWeek> calendarWeeks(
  WeightSeries s, {
  required String today,
  required String from,
  required int firstWeekday,
}) {
  final starts = <String>[];
  final first = weekStartOf(from, firstWeekday);
  for (
    var w = weekStartOf(today, firstWeekday);
    w.compareTo(first) >= 0;
    w = DayKey.shift(w, -7)
  ) {
    starts.add(w);
  }
  // One more (older) week, only for the oldest row's change.
  final means = [
    for (final w in [...starts, DayKey.shift(first, -7)]) _mean(s, w),
  ];
  return [
    for (var i = 0; i < starts.length; i++)
      WeightWeek(
        start: starts[i],
        days: [
          for (var k = 0; k < 7; k++)
            if (DayKey.shift(starts[i], k).compareTo(today) <= 0)
              DayKey.shift(starts[i], k),
        ],
        mean: means[i],
        change: means[i] == null || means[i + 1] == null
            ? null
            : means[i]! - means[i + 1]!,
        isCurrent: i == 0,
      ),
  ];
}

double? _mean(WeightSeries s, String weekStart) {
  var sum = 0.0;
  var n = 0;
  for (var k = 0; k < 7; k++) {
    final v = s.daily[DayKey.shift(weekStart, k)];
    if (v != null) {
      sum += v;
      n++;
    }
  }
  return n == 0 ? null : sum / n;
}

/// What the user is working toward — decides which way is "toward".
enum WeightDirection { lose, gain, none }

/// The goal that decides the direction: the one farthest from the trend
/// (the list's other entries are milestones on the way).
double? finalGoal(List<double> goals, double? trend) {
  if (goals.isEmpty || trend == null) return null;
  return goals.reduce((a, b) => (a - trend).abs() >= (b - trend).abs() ? a : b);
}

/// Below the trend → lose, above → gain; no goal (or no trend yet) → none,
/// which keeps every number neutral.
WeightDirection weightDirection(List<double> goals, double? trend) {
  final goal = finalGoal(goals, trend);
  if (goal == null || trend == null || goal == trend) {
    return WeightDirection.none;
  }
  return goal < trend ? WeightDirection.lose : WeightDirection.gain;
}

/// Whether a change goes toward the goal; null without a goal or for no
/// change (neutral colour) — under 50 g, which displays as ±0.0 anyway.
bool? isToward(double change, WeightDirection direction) => switch (direction) {
  WeightDirection.none => null,
  _ when change.abs() < 0.05 => null,
  WeightDirection.lose => change < 0,
  WeightDirection.gain => change > 0,
};

/// A dashed line on the chart: one of the user's goal weights, or a BMI
/// boundary on the way to the goal.
class WeightMilestone {
  const WeightMilestone(this.kg, {this.isGoal = false, this.bmi});
  final double kg;

  /// The final goal (labelled "Goal").
  final bool isGoal;

  /// Set for a BMI boundary ("BMI < 30" when losing, "BMI ≥ 18.5" gaining).
  final double? bmi;
}

/// BMI boundaries worth passing on the way: down through obese/overweight
/// when losing, up out of underweight when gaining.
const _bmiLose = [30.0, 25.0];
const _bmiGain = [18.5];

/// The user's goals plus BMI boundaries between the trend and the final
/// goal (with a height set), sorted by weight. Empty without a direction.
List<WeightMilestone> weightMilestones({
  required List<double> goals,
  required double? trend,
  double? heightCm,
}) {
  final direction = weightDirection(goals, trend);
  if (direction == WeightDirection.none) return const [];
  final goal = finalGoal(goals, trend)!;
  final out = [for (final g in goals) WeightMilestone(g, isGoal: g == goal)];
  if (heightCm != null && heightCm > 0) {
    final m2 = math.pow(heightCm / 100, 2).toDouble();
    for (final bmi in direction == WeightDirection.lose ? _bmiLose : _bmiGain) {
      final kg = bmi * m2;
      final between = direction == WeightDirection.lose
          ? kg < trend! && kg > goal
          : kg > trend! && kg < goal;
      if (between) out.add(WeightMilestone(kg, bmi: bmi));
    }
  }
  return out..sort((a, b) => a.kg.compareTo(b.kg));
}

/// The next milestone in the goal's direction; null once the goal is passed.
WeightMilestone? nextMilestone(
  List<WeightMilestone> milestones,
  double trend,
  WeightDirection direction,
) => switch (direction) {
  WeightDirection.lose => milestones.lastWhereOrNull((m) => m.kg < trend),
  WeightDirection.gain => milestones.firstWhereOrNull((m) => m.kg > trend),
  WeightDirection.none => null,
};

/// "~N weeks at this pace" — only when each of the last three weeks moved the
/// trend toward [target]; a stall or a wobble shows just the distance.
int? weeksToMilestone(
  WeightSeries s,
  String today,
  double target,
  WeightDirection direction,
) {
  if (direction == WeightDirection.none) return null;
  final a = [
    for (var w = 0; w <= 3; w++) s.averageAt(DayKey.shift(today, -7 * w)),
  ];
  if (a.contains(null)) return null;
  for (var w = 0; w < 3; w++) {
    if (isToward(a[w]! - a[w + 1]!, direction) != true) return null;
  }
  final perWeek = (a[0]! - a[3]!).abs() / 3;
  final weeks = ((a[0]! - target).abs() / perWeek).round();
  return math.max(1, weeks);
}
