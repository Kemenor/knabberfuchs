import 'package:calorie_tracker/data/health/health_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// entryRecordWindow is the one pure piece of the health sync: it decides the
/// timestamps every record gets, and a wrong clamp silently corrupts what
/// lands in Health Connect / HealthKit (records on the wrong day, or future
/// records the stores reject).
void main() {
  final dayStart = DateTime(2026, 7, 3);
  final dayEnd = DateTime(2026, 7, 4);

  ({DateTime start, DateTime end}) window({
    required DateTime createdAt,
    int index = 0,
    DateTime? now,
  }) => entryRecordWindow(
    createdAt: createdAt,
    index: index,
    dayStart: dayStart,
    dayEnd: dayEnd,
    now: now ?? DateTime(2026, 7, 6, 10), // well past the day by default
  );

  test('an in-day log time is kept, start is one minute before end', () {
    final loggedAt = DateTime(2026, 7, 3, 13, 5);
    final w = window(createdAt: loggedAt);
    expect(w.end, loggedAt);
    expect(w.start, loggedAt.subtract(const Duration(minutes: 1)));
  });

  test('an unset/1970 log time falls back to noon slots that keep order', () {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    expect(window(createdAt: epoch).end, DateTime(2026, 7, 3, 12, 0));
    expect(window(createdAt: epoch, index: 2).end, DateTime(2026, 7, 3, 12, 2));
  });

  test('a log time after the day (moved entry) falls back to noon', () {
    final w = window(createdAt: DateTime(2026, 7, 5, 9));
    expect(w.end, DateTime(2026, 7, 3, 12, 0));
  });

  test('today: a future log time falls back, never a future record', () {
    final now = DateTime(2026, 7, 3, 14, 0);
    final w = window(createdAt: DateTime(2026, 7, 3, 18), now: now);
    expect(w.end, DateTime(2026, 7, 3, 12, 0));
    expect(w.end.isBefore(now), isTrue);
  });

  test('today before noon: the fallback slot itself clamps to now', () {
    final now = DateTime(2026, 7, 3, 8, 0);
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final w = window(createdAt: epoch, now: now);
    expect(w.end, now);
    expect(w.start, now.subtract(const Duration(minutes: 1)));
  });

  test('createdAt exactly at day end is out of range, not kept', () {
    final w = window(createdAt: dayEnd);
    expect(w.end, DateTime(2026, 7, 3, 12, 0));
  });

  test('window edges never leave the day (past day, many entries)', () {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    for (var i = 0; i < 50; i++) {
      final w = window(createdAt: epoch, index: i);
      expect(w.end.isAfter(dayEnd), isFalse, reason: 'entry $i end');
      expect(w.start.isBefore(dayStart), isFalse, reason: 'entry $i start');
    }
  });
}
