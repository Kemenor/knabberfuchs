import 'package:intl/intl.dart';

/// Day-key helpers. A "day" in this app is a local calendar day encoded as
/// 'YYYY-MM-DD' (used as the diary partition key).
class DayKey {
  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  /// 'YYYY-MM-DD' for the given date (local).
  static String of(DateTime date) => _fmt.format(date);

  static String today() => of(DateTime.now());

  static DateTime parse(String key) => _fmt.parseStrict(key);

  /// Shift a day-key by [days] (can be negative). Calendar arithmetic, not
  /// `Duration`: a DST day is 23/25 h long, so adding 24 h to a local midnight
  /// can land on the same (or a skipped) day.
  static String shift(String key, int days) {
    final d = parse(key);
    return of(DateTime(d.year, d.month, d.day + days));
  }

  /// Monday-first weekday index: Monday = 0 … Sunday = 6.
  static int weekdayIndex(String key) => parse(key).weekday - 1;
}
