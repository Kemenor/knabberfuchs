import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/meal_times.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const t = MealTimes.defaults;

  test('infers meal from time of day, gaps are snacks', () {
    expect(t.inferAtMinutes(8 * 60), MealType.breakfast); // 08:00
    expect(t.inferAtMinutes(12 * 60), MealType.lunch); // 12:00
    expect(t.inferAtMinutes(18 * 60), MealType.dinner); // 18:00
    expect(t.inferAtMinutes(15 * 60), MealType.snack); // 15:00 gap
    expect(t.inferAtMinutes(2 * 60), MealType.snack); // 02:00 night
    expect(t.inferAtMinutes(23 * 60), MealType.snack); // 23:00 late
  });

  test('window edges are half-open [start, end)', () {
    expect(t.inferAtMinutes(t.breakfastStart), MealType.breakfast);
    expect(t.inferAtMinutes(t.breakfastEnd), MealType.snack);
  });

  test('round-trips through settings, custom (later Spanish dinner)', () {
    final spain = {
      MealTimes.startKey(MealType.dinner): '1200', // 20:00
      MealTimes.endKey(MealType.dinner): '1410', // 23:30
    };
    final mt = MealTimes.fromSettings(spain);
    expect(mt.inferAtMinutes(18 * 60), MealType.snack); // 18:00 not dinner yet
    expect(mt.inferAtMinutes(21 * 60), MealType.dinner); // 21:00 dinner
    // unset windows fall back to defaults
    expect(mt.breakfastStart, MealTimes.defaults.breakfastStart);
  });
}
