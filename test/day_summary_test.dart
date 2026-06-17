import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

Entry _entry({
  required int id,
  required MealType meal,
  required double grams,
  required double kcal100,
  double? protein100,
  String name = 'Food',
}) {
  return Entry(
    id: id,
    day: '2026-06-17',
    mealType: meal,
    grams: grams,
    sName: name,
    sKcal100: kcal100,
    sProtein100: protein100,
    sortIndex: 0,
    createdAt: DateTime(2026, 6, 17),
  );
}

void main() {
  group('DaySummary', () {
    final entries = [
      _entry(id: 1, meal: MealType.breakfast, grams: 100, kcal100: 200, protein100: 10),
      _entry(id: 2, meal: MealType.breakfast, grams: 50, kcal100: 100),
      _entry(id: 3, meal: MealType.dinner, grams: 200, kcal100: 150),
    ].map(EntryView.new).toList();

    test('total sums all entries', () {
      final s = DaySummary(day: '2026-06-17', entries: entries, kcalTarget: null);
      // 200 + 50 + 300 = 550
      expect(s.total.kcal, closeTo(550, 0.001));
      expect(s.total.protein, closeTo(10, 0.001));
    });

    test('groups by meal in display order, includes empty meals', () {
      final s = DaySummary(day: '2026-06-17', entries: entries, kcalTarget: null);
      final meals = s.meals;
      expect(meals.map((m) => m.meal).toList(), MealType.values);
      final breakfast = meals.firstWhere((m) => m.meal == MealType.breakfast);
      expect(breakfast.items.length, 2);
      expect(breakfast.subtotal.kcal, closeTo(250, 0.001));
      final lunch = meals.firstWhere((m) => m.meal == MealType.lunch);
      expect(lunch.isEmpty, isTrue);
    });

    test('remaining and over flags', () {
      final under = DaySummary(day: '2026-06-17', entries: entries, kcalTarget: 600);
      expect(under.remaining, closeTo(50, 0.001));
      expect(under.isOver, isFalse);

      final over = DaySummary(day: '2026-06-17', entries: entries, kcalTarget: 500);
      expect(over.remaining, closeTo(-50, 0.001));
      expect(over.isOver, isTrue);

      final none = DaySummary(day: '2026-06-17', entries: entries, kcalTarget: null);
      expect(none.remaining, isNull);
      expect(none.isOver, isFalse);
    });
  });

  group('resolveKcalTarget', () {
    final targets = [
      const Target(weekday: 0, kcal: 2200), // Monday: training day
      const Target(weekday: 2), // Wednesday: no override
    ];

    test('uses weekday override when set', () {
      expect(resolveKcalTarget(targets, 2000, 0), 2200);
    });

    test('falls back to default when weekday value null', () {
      expect(resolveKcalTarget(targets, 2000, 2), 2000);
    });

    test('falls back to default when weekday missing', () {
      expect(resolveKcalTarget(targets, 1800, 5), 1800);
    });

    test('null default yields null', () {
      expect(resolveKcalTarget(targets, null, 2), isNull);
    });
  });
}
