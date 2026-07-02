import 'package:calorie_tracker/core/date_x.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('of formats yyyy-MM-dd', () {
    expect(DayKey.of(DateTime(2026, 6, 7)), '2026-06-07');
  });

  test('shift handles month and year boundaries', () {
    expect(DayKey.shift('2026-06-30', 1), '2026-07-01');
    expect(DayKey.shift('2026-01-01', -1), '2025-12-31');
    expect(DayKey.shift('2026-06-17', 0), '2026-06-17');
  });

  // Real DST coverage needs a transitioning zone: CI runs these files again
  // with TZ=Europe/Zurich (see test.yml); on UTC they still pass as plain
  // calendar checks. Europe/Zurich 2026: spring-forward Mar 29 (23 h day),
  // fall-back Oct 25 (25 h day).
  test('shift steps exactly one calendar day across DST transitions', () {
    expect(DayKey.shift('2026-03-28', 1), '2026-03-29');
    expect(DayKey.shift('2026-03-29', 1), '2026-03-30');
    expect(DayKey.shift('2026-03-30', -1), '2026-03-29');
    expect(DayKey.shift('2026-10-24', 1), '2026-10-25');
    expect(DayKey.shift('2026-10-25', 1), '2026-10-26');
    expect(DayKey.shift('2026-10-26', -1), '2026-10-25');
  });

  test('shift spanning a DST transition lands on the right calendar day', () {
    expect(DayKey.shift('2026-10-20', 10), '2026-10-30');
    expect(DayKey.shift('2026-10-30', -10), '2026-10-20');
    expect(DayKey.shift('2026-03-25', 7), '2026-04-01');
  });

  test('weekdayIndex is Monday=0 .. Sunday=6', () {
    expect(DayKey.weekdayIndex('2026-06-15'), 0); // Monday
    expect(DayKey.weekdayIndex('2026-06-17'), 2); // Wednesday
    expect(DayKey.weekdayIndex('2026-06-21'), 6); // Sunday
  });
}
