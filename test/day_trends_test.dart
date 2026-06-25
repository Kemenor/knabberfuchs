import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:flutter_test/flutter_test.dart';

/// A weekday target row (Mon=0…Sun=6) with optional bounds.
Target _wd(int weekday, {double? min, double? max}) =>
    Target(weekday: weekday, kcalMin: min, kcalMax: max);

void main() {
  test('buildDayTrends fills every day in range, 0 kcal when missing', () {
    final start = DateTime(2026, 6, 15); // Mon
    final end = DateTime(2026, 6, 21); // Sun
    final trends = buildDayTrends(
      start,
      end,
      {'2026-06-15': 1800, '2026-06-17': 2500},
      const [],
      null,
      null,
    );
    expect(trends.length, 7);
    expect(trends.first.date, start);
    expect(trends.last.date, end);
    expect(trends[0].kcal, 1800);
    expect(trends[1].kcal, 0); // no entry that day
    expect(trends[2].kcal, 2500);
    // No targets configured anywhere -> status none.
    expect(trends.every((t) => t.status == TargetStatus.none), isTrue);
  });

  test('resolves the default target and classifies status per day', () {
    final start = DateTime(2026, 6, 15);
    final end = DateTime(2026, 6, 17);
    final trends = buildDayTrends(
      start,
      end,
      {'2026-06-15': 1500, '2026-06-16': 2000, '2026-06-17': 2600},
      const [],
      1800, // default min
      2400, // default max
    );
    expect(trends[0].status, TargetStatus.under); // 1500 < 1800
    expect(trends[1].status, TargetStatus.inRange); // 1800..2400
    expect(trends[2].status, TargetStatus.over); // 2600 > 2400
  });

  test('per-weekday override beats the default', () {
    // 2026-06-20 is a Saturday (weekday 6 -> index 5). Give Saturday a higher
    // ceiling so 2600 is in range there but over on a default day.
    final sat = DateTime(2026, 6, 20);
    final trends = buildDayTrends(
      sat,
      sat,
      {'2026-06-20': 2600},
      [_wd(5, min: 2000, max: 3000)],
      1800,
      2400,
    );
    expect(trends.single.target.max, 3000);
    expect(trends.single.status, TargetStatus.inRange);
  });

  test('statusFor boundary: equal to a bound is in range', () {
    expect(statusFor(2000, const CalorieTarget(1800, 2000)), TargetStatus.inRange);
    expect(statusFor(1800, const CalorieTarget(1800, 2000)), TargetStatus.inRange);
    expect(statusFor(2001, const CalorieTarget(1800, 2000)), TargetStatus.over);
    expect(statusFor(1799, const CalorieTarget(1800, 2000)), TargetStatus.under);
    expect(statusFor(2000, const CalorieTarget(null, null)), TargetStatus.none);
  });
}
