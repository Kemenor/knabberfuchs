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

  test('weekdayIndex is Monday=0 .. Sunday=6', () {
    expect(DayKey.weekdayIndex('2026-06-15'), 0); // Monday
    expect(DayKey.weekdayIndex('2026-06-17'), 2); // Wednesday
    expect(DayKey.weekdayIndex('2026-06-21'), 6); // Sunday
  });
}
