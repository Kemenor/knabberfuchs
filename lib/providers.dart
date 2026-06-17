import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/date_x.dart';
import 'data/db/database.dart';
import 'data/repositories/diary_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/sources/off_api.dart';
import 'domain/day_summary.dart';

// ---------------- Infrastructure ----------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final offApiProvider = Provider<OffApi>((ref) {
  final off = OffApi();
  ref.onDispose(off.close);
  return off;
});

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(ref.watch(dbProvider), ref.watch(offApiProvider)),
);

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepository(ref.watch(dbProvider)),
);

// ---------------- Settings ----------------

final defaultTargetProvider = StreamProvider<double?>((ref) {
  return ref
      .watch(dbProvider)
      .watchSetting('defaultKcalTarget')
      .map((v) => v == null ? null : double.tryParse(v));
});

final targetsProvider = StreamProvider<List<Target>>(
  (ref) => ref.watch(dbProvider).watchTargets(),
);

/// Day view layout: true = grouped by meal, false = flat chronological list.
final groupByMealProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(dbProvider)
      .watchSetting('groupByMeal')
      .map((v) => v != 'false'); // default true
});

// ---------------- Day selection & summary ----------------

class SelectedDayNotifier extends Notifier<String> {
  @override
  String build() => DayKey.today();

  void set(String day) => state = day;
  void shift(int by) => state = DayKey.shift(state, by);
  void today() => state = DayKey.today();
}

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, String>(SelectedDayNotifier.new);

final daySummaryProvider = StreamProvider<DaySummary>((ref) {
  final db = ref.watch(dbProvider);
  final day = ref.watch(selectedDayProvider);
  final targets = ref.watch(targetsProvider).asData?.value ?? const [];
  final defaultTarget = ref.watch(defaultTargetProvider).asData?.value;
  final kcalTarget =
      resolveKcalTarget(targets, defaultTarget, DayKey.weekdayIndex(day));

  return db.watchDay(day).map(
        (entries) => DaySummary(
          day: day,
          entries: entries.map(EntryView.new).toList(),
          kcalTarget: kcalTarget,
        ),
      );
});
