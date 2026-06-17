import 'enums.dart';

/// User-configurable meal windows (minutes since midnight) used to auto-label a
/// logged entry's meal in track-by-day mode. Anything outside a window is a
/// snack. Defaults are generic/Central-European; meal times vary by culture, so
/// these are editable in Settings.
class MealTimes {
  final int breakfastStart, breakfastEnd;
  final int lunchStart, lunchEnd;
  final int dinnerStart, dinnerEnd;

  const MealTimes({
    required this.breakfastStart,
    required this.breakfastEnd,
    required this.lunchStart,
    required this.lunchEnd,
    required this.dinnerStart,
    required this.dinnerEnd,
  });

  static const defaults = MealTimes(
    breakfastStart: 5 * 60, // 05:00
    breakfastEnd: 10 * 60 + 30, // 10:30
    lunchStart: 11 * 60 + 30, // 11:30
    lunchEnd: 14 * 60 + 30, // 14:30
    dinnerStart: 17 * 60, // 17:00
    dinnerEnd: 21 * 60 + 30, // 21:30
  );

  /// Meal for a given minute-of-day. First matching window wins; gaps are snacks.
  MealType inferAtMinutes(int m) {
    if (m >= breakfastStart && m < breakfastEnd) return MealType.breakfast;
    if (m >= lunchStart && m < lunchEnd) return MealType.lunch;
    if (m >= dinnerStart && m < dinnerEnd) return MealType.dinner;
    return MealType.snack;
  }

  MealType inferAt(DateTime t) => inferAtMinutes(t.hour * 60 + t.minute);
  MealType inferNow() => inferAt(DateTime.now());

  int startOf(MealType m) => switch (m) {
        MealType.breakfast => breakfastStart,
        MealType.lunch => lunchStart,
        MealType.dinner => dinnerStart,
        MealType.snack => 0,
      };
  int endOf(MealType m) => switch (m) {
        MealType.breakfast => breakfastEnd,
        MealType.lunch => lunchEnd,
        MealType.dinner => dinnerEnd,
        MealType.snack => 0,
      };

  /// Setting keys for each window edge.
  static String startKey(MealType m) => 'meal${_cap(m.name)}Start';
  static String endKey(MealType m) => 'meal${_cap(m.name)}End';
  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);

  factory MealTimes.fromSettings(Map<String, String?> s) {
    int v(String k, int d) => int.tryParse(s[k] ?? '') ?? d;
    return MealTimes(
      breakfastStart: v(startKey(MealType.breakfast), defaults.breakfastStart),
      breakfastEnd: v(endKey(MealType.breakfast), defaults.breakfastEnd),
      lunchStart: v(startKey(MealType.lunch), defaults.lunchStart),
      lunchEnd: v(endKey(MealType.lunch), defaults.lunchEnd),
      dinnerStart: v(startKey(MealType.dinner), defaults.dinnerStart),
      dinnerEnd: v(endKey(MealType.dinner), defaults.dinnerEnd),
    );
  }
}
