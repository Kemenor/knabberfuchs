import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/weight.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;
BodyMeasurement _w(
  String day,
  double kg, {
  int hour = 7,
  bool counts = false,
  bool hidden = false,
}) {
  final d = DayKey.parse(day);
  return BodyMeasurement(
    id: ++_id,
    kind: MeasurementKind.weight,
    day: day,
    measuredAt: DateTime(d.year, d.month, d.day, hour),
    value: kg,
    source: MeasurementSource.manual,
    countsForDay: counts,
    hidden: hidden,
  );
}

void main() {
  group('the day value', () {
    test('first of the day counts, unless another is chosen', () {
      final rows = [
        _w('2026-11-13', 87.6, hour: 12),
        _w('2026-11-13', 86.9, hour: 7),
        _w('2026-11-12', 87.0),
        _w('2026-11-12', 88.0, hour: 20, counts: true),
        _w('2026-11-11', 80.0, hidden: true),
      ];
      expect(dailyWeights(rows), {'2026-11-13': 86.9, '2026-11-12': 88.0});
    });
  });

  group('7-day average', () {
    test('needs three values; gaps are skipped, not zero', () {
      final s = WeightSeries.from([_w('2026-11-10', 88), _w('2026-11-12', 87)]);
      expect(s.averageAt('2026-11-13'), isNull);
      final s3 = WeightSeries.from([
        _w('2026-11-06', 90), // a week before 11-13 → out of the window
        _w('2026-11-08', 88),
        _w('2026-11-10', 87),
        _w('2026-11-13', 86),
      ]);
      expect(s3.averageAt('2026-11-13'), closeTo(87, 1e-9));
    });

    test('change vs the week before, and the first average', () {
      final rows = [
        for (var i = 0; i < 14; i++)
          _w(DayKey.shift('2026-11-01', i), 90 - i * 0.1),
      ];
      final s = WeightSeries.from(rows);
      expect(s.weekChangeAt('2026-11-14'), closeTo(-0.7, 1e-9));
      expect(s.firstAverage!.day, '2026-11-03');
      expect(s.firstAverage!.kg, closeTo(89.9, 1e-9));
    });
  });

  test('calendar weeks: newest first, current week so far, change', () {
    final s = WeightSeries.from([
      _w('2026-11-02', 90), // Mon
      _w('2026-11-04', 89), // → week of 2 Nov: 89.5
      _w('2026-11-10', 88), // week of 9 Nov: 88
      _w('2026-11-12', 87), // Thu (today) → week of 9 Nov mean 87.5
    ]);
    final weeks = calendarWeeks(
      s,
      today: '2026-11-12',
      from: '2026-11-02',
      firstWeekday: DateTime.monday,
    );
    expect(weeks.map((w) => w.start), ['2026-11-09', '2026-11-02']);
    expect(weeks[0].isCurrent, isTrue);
    expect(weeks[0].days, hasLength(4)); // Mon–Thu
    expect(weeks[0].mean, 87.5);
    expect(weeks[0].change, -2.0);
    expect(weeks[1].change, isNull); // nothing the week before
    // A Sunday-first locale shifts the boundaries.
    expect(weekStartOf('2026-11-12', DateTime.sunday), '2026-11-08');
  });

  group('goals', () {
    test('the farthest goal sets the direction; none without one', () {
      expect(weightDirection(const [85, 75], 87), WeightDirection.lose);
      expect(weightDirection(const [92], 87), WeightDirection.gain);
      expect(weightDirection(const [], 87), WeightDirection.none);
      expect(weightDirection(const [80], null), WeightDirection.none);
      expect(isToward(-0.4, WeightDirection.lose), isTrue);
      expect(isToward(-0.4, WeightDirection.gain), isFalse);
      expect(isToward(-0.4, WeightDirection.none), isNull);
    });

    test('milestones: goals + BMI boundaries on the way; the next one', () {
      // 1.75 m: BMI 30 = 91.9 kg, 25 = 76.6 kg.
      final ms = weightMilestones(
        goals: const [85, 75],
        trend: 95,
        heightCm: 175,
      );
      expect(ms.map((m) => m.kg.toStringAsFixed(1)), [
        '75.0',
        '76.6',
        '85.0',
        '91.9',
      ]);
      expect(ms.first.isGoal, isTrue);
      expect(ms.last.bmi, 30);
      final next = nextMilestone(ms, 88, WeightDirection.lose)!;
      expect(next.kg, 85);
      expect(nextMilestone(ms, 74, WeightDirection.lose), isNull);
      expect(weightMilestones(goals: const [], trend: 90), isEmpty);
    });

    test('weeks to the next milestone only on a steady trend', () {
      final steady = WeightSeries.from([
        for (var i = 0; i < 28; i++)
          _w(DayKey.shift('2026-10-17', i), 90 - i * 0.1),
      ]);
      // avg today ≈ 87.6, −0.7 kg/week → 85 in ~4 weeks.
      expect(
        weeksToMilestone(steady, '2026-11-13', 85, WeightDirection.lose),
        4,
      );
      expect(
        weeksToMilestone(steady, '2026-11-13', 95, WeightDirection.gain),
        isNull,
      );
    });
  });

  test('units: region default and conversion', () {
    expect(defaultWeightUnit('US'), WeightUnit.lb);
    expect(defaultWeightUnit('CH'), WeightUnit.kg);
    expect(parseWeightUnit('kg', 'US'), WeightUnit.kg);
    expect(WeightUnit.lb.fromKg(100), closeTo(220.46, 0.01));
    expect(WeightUnit.lb.toKg(220.462), closeTo(100, 0.001));
  });
}
