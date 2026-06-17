import 'package:intl/intl.dart';

/// Day-key helpers. A "day" in this app is a local calendar day encoded as
/// 'YYYY-MM-DD' (used as the diary partition key).
class DayKey {
  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  /// 'YYYY-MM-DD' for the given date (local).
  static String of(DateTime date) => _fmt.format(date);

  static String today() => of(DateTime.now());

  static DateTime parse(String key) => _fmt.parseStrict(key);

  /// Shift a day-key by [days] (can be negative).
  static String shift(String key, int days) =>
      of(parse(key).add(Duration(days: days)));

  /// Monday-first weekday index: Monday = 0 … Sunday = 6.
  static int weekdayIndex(String key) => parse(key).weekday - 1;

  /// Human label like "Today", "Yesterday", or "Mon, 17 Jun".
  static String label(String key) {
    final date = parse(key);
    final todayKey = today();
    if (key == todayKey) return 'Today';
    if (key == shift(todayKey, -1)) return 'Yesterday';
    if (key == shift(todayKey, 1)) return 'Tomorrow';
    return DateFormat('EEE, d MMM').format(date);
  }
}

const List<String> kWeekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
