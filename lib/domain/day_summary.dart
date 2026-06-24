import 'package:collection/collection.dart';

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

  TargetStatus get status {
    final t = total.kcal;
    if (kcalMax != null && t > kcalMax!) return TargetStatus.over;
    if (kcalMin != null && t < kcalMin!) return TargetStatus.under;
    if (hasTarget) return TargetStatus.inRange;
    return TargetStatus.none;
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
