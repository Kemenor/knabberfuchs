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

  group('resolveMetricTarget (macros)', () {
    final targets = [
      const Target(weekday: 0, proteinMin: 140), // protein floor on Monday
      const Target(weekday: 2), // no overrides
    ];

    test('weekday macro override wins, unset bound takes default', () {
      final t = resolveMetricTarget(
        targets,
        TargetMetric.protein,
        const CalorieTarget(100, 180),
        0,
      );
      expect(t.min, 140); // override
      expect(t.max, 180); // default (no weekday max)
    });

    test('falls back to macro defaults when weekday has none', () {
      final t = resolveMetricTarget(
        targets,
        TargetMetric.carb,
        const CalorieTarget(null, 250),
        2,
      );
      expect(t.min, isNull);
      expect(t.max, 250);
    });
  });

  group('targetBarFraction', () {
    test('floor (min only) fills toward the min', () {
      expect(targetBarFraction(80, const CalorieTarget(120, null)), closeTo(2 / 3, 1e-9));
    });
    test('over the floor clamps to full', () {
      expect(targetBarFraction(150, const CalorieTarget(120, null)), 1.0);
    });
    test('max is the denominator when both bounds are set', () {
      expect(targetBarFraction(50, const CalorieTarget(40, 100)), 0.5);
    });
    test('no bound → no bar', () {
      expect(targetBarFraction(50, const CalorieTarget(null, null)), isNull);
    });
    test('zero/negative denominator → no bar', () {
      expect(targetBarFraction(50, const CalorieTarget(0, null)), isNull);
    });
  });

  group('DaySummary per-metric', () {
    // Shared entries total 10 g protein, 0 carb/fat.
    final entries = [
      _entry(
        id: 1,
        meal: MealType.breakfast,
        grams: 100,
        kcal100: 200,
        protein100: 10,
      ),
    ].map(EntryView.new).toList();

    test('value / status / bar for a protein floor', () {
      final s = DaySummary(
        day: '2026-06-17',
        entries: entries,
        metricTargets: const {TargetMetric.protein: CalorieTarget(20, null)},
      );
      expect(s.valueFor(TargetMetric.protein), closeTo(10, 1e-9));
      expect(s.statusForMetric(TargetMetric.protein), TargetStatus.under);
      expect(s.barFractionFor(TargetMetric.protein), 0.5); // 10 / 20
    });

    test('targetless macro has no status and no bar', () {
      final s = DaySummary(day: '2026-06-17', entries: entries);
      expect(s.statusForMetric(TargetMetric.fat), TargetStatus.none);
      expect(s.barFractionFor(TargetMetric.fat), isNull);
    });

    test('kcal metric reads kcalMin/kcalMax', () {
      final s = DaySummary(
        day: '2026-06-17',
        entries: entries,
        kcalMin: 100,
        kcalMax: 300,
      );
      final t = s.targetFor(TargetMetric.kcal);
      expect(t.min, 100);
      expect(t.max, 300);
    });
  });

  group('shiftTarget (activity adjustment)', () {
    test('moves BOTH bounds by the burned amount', () {
      final t = shiftTarget(const CalorieTarget(1600, 1900), 320);
      expect(t.min, 1920);
      expect(t.max, 2220);
    });

    test('null bounds stay null; zero/negative burn is a no-op', () {
      final t = shiftTarget(const CalorieTarget(null, 1900), 320);
      expect(t.min, isNull);
      expect(t.max, 2220);
      expect(shiftTarget(const CalorieTarget(1600, 1900), 0).min, 1600);
      expect(shiftTarget(const CalorieTarget(1600, 1900), -50).max, 1900);
    });

    test('status is computed against the shifted band', () {
      // 2 000 kcal eaten: over a static 1 900 max, but in range once a
      // 320 kcal run shifts the band ("eat back your exercise").
      const eaten = 2000.0;
      const static_ = CalorieTarget(1600, 1900);
      expect(statusFor(eaten, static_), TargetStatus.over);
      expect(
        statusFor(eaten, shiftTarget(static_, 320)),
        TargetStatus.inRange,
      );
    });

    test('an unmoved min would lie on training days — the shift fixes it', () {
      // 1 700 eaten, min 1 600: "minimum reached" statically, but after a
      // 500 kcal session the shifted min (2 100) correctly reads under.
      const eaten = 1700.0;
      const static_ = CalorieTarget(1600, null);
      expect(statusFor(eaten, static_), TargetStatus.inRange);
      expect(
        statusFor(eaten, shiftTarget(static_, 500)),
        TargetStatus.under,
      );
    });
  });
}
