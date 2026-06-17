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

/// Entries of one meal plus their subtotal.
class MealGroup {
  final MealType meal;
  final List<EntryView> items;

  MealGroup(this.meal, this.items);

  Nutrition get subtotal => Nutrition.sum(items.map((e) => e.nutrition));
  bool get isEmpty => items.isEmpty;
}

/// Everything the day screen needs: flat list, meal groups, totals, target.
class DaySummary {
  final String day;
  final List<EntryView> entries;
  final double? kcalTarget;

  DaySummary({
    required this.day,
    required this.entries,
    required this.kcalTarget,
  });

  Nutrition get total => Nutrition.sum(entries.map((e) => e.nutrition));

  /// kcal left before hitting the target (negative = over). Null when no target.
  double? get remaining =>
      kcalTarget == null ? null : kcalTarget! - total.kcal;

  bool get isOver => remaining != null && remaining! < 0;

  /// All meals in display order (includes empty meals for the grouped view).
  List<MealGroup> get meals => MealType.values
      .map((m) => MealGroup(m, entries.where((e) => e.meal == m).toList()))
      .toList();
}

/// Resolve the kcal target for a weekday: the weekday's own value if set,
/// otherwise the app-wide default.
double? resolveKcalTarget(
  List<Target> targets,
  double? defaultKcal,
  int weekdayIndex,
) {
  final t = targets.firstWhereOrNull((t) => t.weekday == weekdayIndex);
  return t?.kcal ?? defaultKcal;
}
