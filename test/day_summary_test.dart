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
      _entry(
        id: 1,
        meal: MealType.breakfast,
        grams: 100,
        kcal100: 200,
        protein100: 10,
      ),
      _entry(id: 2, meal: MealType.breakfast, grams: 50, kcal100: 100),
      _entry(id: 3, meal: MealType.dinner, grams: 200, kcal100: 150),
    ].map(EntryView.new).toList();

    test('total sums all entries', () {
      final s = DaySummary(day: '2026-06-17', entries: entries);
      // 200 + 50 + 300 = 550
      expect(s.total.kcal, closeTo(550, 0.001));
      expect(s.total.protein, closeTo(10, 0.001));
    });

    // total is 550 kcal for the shared entries.
    test('over max', () {
      final s = DaySummary(day: '2026-06-17', entries: entries, kcalMax: 500);
      expect(s.status, TargetStatus.over);
      expect(s.remainingToMax, closeTo(-50, 0.001));
    });

    test('in range', () {
      final s = DaySummary(
        day: '2026-06-17',
        entries: entries,
        kcalMin: 400,
        kcalMax: 600,
      );
      expect(s.status, TargetStatus.inRange);
      expect(s.remainingToMax, closeTo(50, 0.001));
    });

    test('under min', () {
      final s = DaySummary(day: '2026-06-17', entries: entries, kcalMin: 800);
      expect(s.status, TargetStatus.under);
      expect(s.shortOfMin, closeTo(250, 0.001));
    });

    test('no target', () {
      final s = DaySummary(day: '2026-06-17', entries: entries);
      expect(s.status, TargetStatus.none);
      expect(s.hasTarget, isFalse);
    });
  });

  group('resolveTarget', () {
    final targets = [
      const Target(weekday: 0, kcalMin: 2400, kcalMax: 2800), // training day
      const Target(weekday: 2), // no override
    ];

    test('uses weekday override when set', () {
      final t = resolveTarget(targets, 1800, 2200, 0);
      expect(t.min, 2400);
      expect(t.max, 2800);
    });

    test('falls back to defaults when weekday values null', () {
      final t = resolveTarget(targets, 1800, 2200, 2);
      expect(t.min, 1800);
      expect(t.max, 2200);
    });

    test('falls back to defaults when weekday missing', () {
      final t = resolveTarget(targets, 1800, 2200, 5);
      expect(t.min, 1800);
      expect(t.max, 2200);
    });

    test('null defaults yield empty target', () {
      final t = resolveTarget(targets, null, null, 2);
      expect(t.isEmpty, isTrue);
    });
  });
}
