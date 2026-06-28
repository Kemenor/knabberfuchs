import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/date_x.dart';
import 'core/locale.dart';
import 'data/db/database.dart';
import 'data/repositories/diary_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/backup_service.dart';
import 'data/health/health_service.dart';
import 'data/ml/food_classifier.dart';
import 'data/ml/gemini_service.dart';
import 'data/ocr/ocr_service.dart';
import 'data/offline/offline_pack_service.dart';
import 'data/offline/region_pack_store.dart';
import 'data/sources/off_api.dart';
import 'data/sources/swiss_seed.dart';
import 'domain/day_summary.dart';
import 'domain/meal_times.dart';
import 'domain/meal_type_i18n.dart';
import 'domain/offline_manifest.dart';

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

final regionPackStoreProvider = Provider<RegionPackStore>((ref) {
  final store = RegionPackStore();
  ref.onDispose(store.dispose);
  return store;
});

final offlinePackServiceProvider = Provider<OfflinePackService>(
  (ref) => OfflinePackService(
    ref.watch(dbProvider),
    ref.watch(regionPackStoreProvider),
  ),
);

final installedPacksProvider = StreamProvider<List<InstalledPack>>(
  (ref) => ref.watch(dbProvider).watchInstalledPacks(),
);

final offlineManifestProvider = FutureProvider<OfflineManifest>(
  (ref) => ref.watch(offlinePackServiceProvider).fetchManifest(),
);

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(
    ref.watch(dbProvider),
    ref.watch(offApiProvider),
    ref.watch(regionPackStoreProvider),
  ),
);

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepository(ref.watch(dbProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(
    ref.watch(dbProvider),
    ref.watch(diaryRepositoryProvider),
  ),
);

final recipesProvider = StreamProvider<List<Recipe>>(
  (ref) => ref.watch(recipeRepositoryProvider).watchRecipes(),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(dbProvider)),
);

final ocrServiceProvider = Provider<OcrService>((ref) {
  final s = OcrService();
  ref.onDispose(s.dispose);
  return s;
});

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

/// App version string for the About screen, e.g. "1.0.3 (4)".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final foodClassifierProvider = Provider<FoodClassifier>((ref) {
  final c = FoodClassifier();
  ref.onDispose(c.dispose);
  return c;
});

const geminiKeySetting = 'geminiApiKey';

/// When 'true', photo recognition always uses the on-device model and never
/// uploads to Gemini, even if a key is configured. Only surfaced in settings
/// once a key exists. Default (null/false) = use Gemini, fall back on-device.
const aiOnDeviceOnlySetting = 'aiOnDeviceOnly';

/// Preferred Gemini model to try first (the service always falls back to
/// gemini-2.5-flash on a 503/timeout). Null = use the reliable default.
const geminiModelSetting = 'geminiModel';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final s = GeminiService();
  ref.onDispose(s.dispose);
  return s;
});

final healthSyncEnabledProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(dbProvider).watchSetting('healthSync').map((v) => v == 'true'),
);

/// Raw entries for the selected day (used to drive Health Connect auto-sync).
final selectedDayEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(dbProvider);
  return db.watchDay(ref.watch(selectedDayProvider));
});

/// One-time startup work: import the bundled USDA produce dataset on first run
/// and open any installed offline region packs.
final appStartupProvider = FutureProvider<void>((ref) async {
  await seedSwissIfNeeded(ref.watch(dbProvider));
  await ref.read(offlinePackServiceProvider).syncStore();
  await ref.read(healthServiceProvider).refreshEnabled(ref.read(dbProvider));
});

// ---------------- Track-by-day groups ----------------

/// Ad-hoc groups for the selected day, oldest first.
final dayGroupsStreamProvider = StreamProvider<List<EntryGroup>>((ref) {
  final db = ref.watch(dbProvider);
  return db.watchGroups(ref.watch(selectedDayProvider));
});

/// Groups zipped with their entries, for the by-day day view.
final dayGroupViewsProvider = Provider<List<GroupView>>((ref) {
  final groups = ref.watch(dayGroupsStreamProvider).asData?.value ?? const [];
  final summary = ref.watch(daySummaryProvider).asData?.value;
  if (summary == null) return const [];
  final byGroup = <int, List<EntryView>>{};
  for (final e in summary.entries) {
    final gid = e.entry.groupId;
    if (gid != null) (byGroup[gid] ??= []).add(e);
  }
  return [for (final g in groups) GroupView(g, byGroup[g.id] ?? const [])];
});

/// By-day entries not attached to any group (legacy data before grouping).
final ungroupedDayEntriesProvider = Provider<List<EntryView>>((ref) {
  final summary = ref.watch(daySummaryProvider).asData?.value;
  if (summary == null) return const [];
  return summary.entries.where((e) => e.entry.groupId == null).toList();
});

/// Owns the "currently-editing" group: which group consecutive adds flow into,
/// persisted with a last-activity timestamp so a 15-min timeout survives the
/// app being backgrounded.
class ActiveGroupNotifier extends Notifier<int?> {
  static const _idKey = 'activeGroupId';
  static const _atKey = 'activeGroupAt';
  static const timeout = Duration(minutes: 15);

  AppDatabase get _db => ref.read(dbProvider);

  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final idStr = await _db.getSetting(_idKey);
    if (idStr == null) return;
    if (await _expired()) {
      await _clear();
      return;
    }
    state = int.tryParse(idStr);
  }

  Future<bool> _expired() async {
    final at = int.tryParse(await _db.getSetting(_atKey) ?? '') ?? 0;
    return DateTime.now().millisecondsSinceEpoch - at > timeout.inMilliseconds;
  }

  /// Active group for [day], creating a time-named one if none is active (or it
  /// expired / belongs to another day). Returns the group id to log into.
  Future<int> ensureGroup(String day) async {
    final current = state;
    if (current != null && !(await _expired())) {
      final g = await _db.entryGroupById(current);
      if (g != null && g.day == day) {
        await _touch(current);
        return current;
      }
    }
    final now = DateTime.now();
    final settings = {
      for (final s in await _db.watchAllSettings().first) s.key: s.value,
    };
    final mt = MealTimes.fromSettings(settings);
    // Localize the auto-name at creation in the active UI language (no
    // BuildContext here, so resolve the locale code directly).
    final locale = resolveUiLocale(settings['appLocale']);
    final name =
        '${mealTypeTitle(mt.inferAt(now), locale)} '
        '${DateFormat('HH:mm').format(now)}';
    final id = await _db.createEntryGroup(day, name);
    await _setActive(id);
    return id;
  }

  Future<void> reopen(int groupId) => _setActive(groupId);

  Future<void> end() async {
    state = null;
    await _clear();
  }

  /// Re-check on app resume; clears if the active group has timed out.
  Future<void> refreshTimeout() async {
    if (state != null && await _expired()) await end();
  }

  Future<void> _setActive(int id) async {
    state = id;
    await _touch(id);
  }

  Future<void> _touch(int id) async {
    await _db.setSetting(_idKey, '$id');
    await _db.setSetting(_atKey, '${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _clear() async {
    await _db.setSetting(_idKey, null);
    await _db.setSetting(_atKey, null);
  }
}

final activeGroupProvider = NotifierProvider<ActiveGroupNotifier, int?>(
  ActiveGroupNotifier.new,
);

/// Session-only set of meal-group ids the user has collapsed in the day
/// overview. Not persisted — resets on app restart / day change.
class CollapsedGroupsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void toggle(int groupId) {
    final next = {...state};
    if (!next.remove(groupId)) next.add(groupId);
    state = next;
  }
}

final collapsedGroupsProvider =
    NotifierProvider<CollapsedGroupsNotifier, Set<int>>(
      CollapsedGroupsNotifier.new,
    );

// ---------------- Settings ----------------

final defaultMinProvider = StreamProvider<double?>((ref) {
  return ref
      .watch(dbProvider)
      .watchSetting('defaultKcalMin')
      .map((v) => v == null ? null : double.tryParse(v));
});

final defaultMaxProvider = StreamProvider<double?>((ref) {
  return ref
      .watch(dbProvider)
      .watchSetting('defaultKcalMax')
      .map((v) => v == null ? null : double.tryParse(v));
});

final targetsProvider = StreamProvider<List<Target>>(
  (ref) => ref.watch(dbProvider).watchTargets(),
);

/// App-wide default macro target bounds (the `default<Macro>Min/Max` settings).
/// kcal defaults stay in [defaultMinProvider] / [defaultMaxProvider].
final macroDefaultsProvider =
    StreamProvider<Map<TargetMetric, CalorieTarget>>((ref) {
      return ref.watch(dbProvider).watchAllSettings().map((rows) {
        final s = {for (final r in rows) r.key: r.value};
        double? n(String k) => s[k] == null ? null : double.tryParse(s[k]!);
        return {
          TargetMetric.protein: CalorieTarget(
            n('defaultProteinMin'),
            n('defaultProteinMax'),
          ),
          TargetMetric.carb: CalorieTarget(
            n('defaultCarbMin'),
            n('defaultCarbMax'),
          ),
          TargetMetric.fat: CalorieTarget(n('defaultFatMin'), n('defaultFatMax')),
        };
      });
    });

/// The UI language override. `null` = follow the device locale; otherwise a
/// `Locale` built from the stored language code ('en'/'de'/'fr'/'it').
final localeProvider = StreamProvider<Locale?>(
  (ref) => ref
      .watch(dbProvider)
      .watchSetting('appLocale')
      .map((v) => (v == null || v.isEmpty || v == 'system') ? null : Locale(v)),
);

/// The user-selected typeface (DESIGN.md §2 accessibility picker), persisted as
/// the `appFont` setting (stores the enum `name`); defaults to Figtree.
final fontProvider = StreamProvider<FuchsbauFont>(
  (ref) => ref.watch(dbProvider).watchSetting('appFont').map(
        (v) => FuchsbauFont.values.firstWhere(
          (f) => f.name == v,
          orElse: () => FuchsbauFont.figtree,
        ),
      ),
);

/// Light / dark / follow-system, persisted as the `appThemeMode` setting;
/// defaults to following the OS (ThemeMode.system).
final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref.watch(dbProvider).watchSetting('appThemeMode').map(
        (v) => switch (v) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
      ),
);

/// User-configured meal windows. Used to auto-label a new meal group (its name)
/// and to tag entries for Health Connect.
final mealTimesProvider = StreamProvider<MealTimes>(
  (ref) => ref
      .watch(dbProvider)
      .watchAllSettings()
      .map(
        (rows) =>
            MealTimes.fromSettings({for (final s in rows) s.key: s.value}),
      ),
);

// ---------------- Day selection & summary ----------------

class SelectedDayNotifier extends Notifier<String> {
  @override
  String build() => DayKey.today();

  void set(String day) => state = day;
  void shift(int by) => state = DayKey.shift(state, by);
  void today() => state = DayKey.today();
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, String>(
  SelectedDayNotifier.new,
);

/// HomeShell bottom-nav tab index. Day is always 0; the remaining tabs depend
/// on whether the Trends tab is enabled ([showTrendsProvider]) — Day, Recipes,
/// [Trends], Settings. A provider so flows like "log a recipe portion to a day"
/// can jump to the Day tab (index 0) on the day they just logged to.
class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int index) => state = index;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(
  HomeTabNotifier.new,
);

final daySummaryProvider = StreamProvider<DaySummary>((ref) {
  final db = ref.watch(dbProvider);
  final day = ref.watch(selectedDayProvider);
  final targets = ref.watch(targetsProvider).asData?.value ?? const [];
  final defaultMin = ref.watch(defaultMinProvider).asData?.value;
  final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
  final macroDefaults =
      ref.watch(macroDefaultsProvider).asData?.value ?? const {};
  final wd = DayKey.weekdayIndex(day);
  final target = resolveTarget(targets, defaultMin, defaultMax, wd);
  CalorieTarget macro(TargetMetric m) => resolveMetricTarget(
    targets,
    m,
    macroDefaults[m] ?? const CalorieTarget(null, null),
    wd,
  );

  return db
      .watchDay(day)
      .map(
        (entries) => DaySummary(
          day: day,
          entries: entries.map(EntryView.new).toList(),
          kcalMin: target.min,
          kcalMax: target.max,
          proteinTarget: macro(TargetMetric.protein),
          carbTarget: macro(TargetMetric.carb),
          fatTarget: macro(TargetMetric.fat),
        ),
      );
});

// ---------------- Trends ----------------

/// Which window the trends charts show.
enum TrendMode { week, month, custom }

/// The resolved trends window: a [mode], how many whole periods back it sits
/// from today ([offset], for week/month), and the inclusive [start]–[end] dates.
class TrendWindow {
  final TrendMode mode;
  final int offset;
  final DateTime start;
  final DateTime end;
  const TrendWindow(this.mode, this.offset, this.start, this.end);

  /// True when this is the latest period (so "newer" navigation is disabled).
  bool get isCurrent => mode != TrendMode.custom && offset == 0;
  int get days => end.difference(start).inDays + 1;
}

class TrendRangeNotifier extends Notifier<TrendWindow> {
  static const _customKey = 'trendCustomRange';

  /// The last custom range the user picked, loaded from settings — so tapping
  /// "Custom" reopens it instead of starting over. Week/Month aren't persisted:
  /// the screen always opens on the current week.
  ({DateTime start, DateTime end})? _savedCustom;
  ({DateTime start, DateTime end})? get savedCustom => _savedCustom;

  @override
  TrendWindow build() {
    _loadCustom();
    return preset(TrendMode.week, 0);
  }

  Future<void> _loadCustom() async {
    final raw = await ref.read(dbProvider).getSetting(_customKey);
    if (raw == null) return;
    final p = raw.split(':');
    if (p.length != 2) return;
    final s = DateTime.tryParse(p[0]);
    final e = DateTime.tryParse(p[1]);
    if (s != null && e != null) _savedCustom = (start: s, end: e);
  }

  /// A week/month window [offset] whole periods before today.
  TrendWindow preset(TrendMode mode, int offset) {
    final today = DayKey.parse(DayKey.today());
    final len = mode == TrendMode.month ? 30 : 7;
    final end = today.subtract(Duration(days: len * offset));
    final start = end.subtract(Duration(days: len - 1));
    return TrendWindow(mode, offset, start, end);
  }

  /// Switch Week/Month (resets to the current, latest period).
  void setMode(TrendMode mode) => state = preset(mode, 0);

  /// Step to the older adjacent period.
  void older() {
    if (state.mode == TrendMode.custom) return;
    state = preset(state.mode, state.offset + 1);
  }

  /// Step to the newer adjacent period (no-op once at the latest).
  void newer() {
    if (state.mode == TrendMode.custom || state.offset == 0) return;
    state = preset(state.mode, state.offset - 1);
  }

  /// Pick an arbitrary inclusive range (dates normalized to local midnight) and
  /// remember it for next time.
  void setCustom(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    state = TrendWindow(TrendMode.custom, 0, s, e);
    _savedCustom = (start: s, end: e);
    ref.read(dbProvider).setSetting(_customKey, '${DayKey.of(s)}:${DayKey.of(e)}');
  }
}

final trendRangeProvider = NotifierProvider<TrendRangeNotifier, TrendWindow>(
  TrendRangeNotifier.new,
);

/// Which metric the Trends chart plots. In-memory (resets to kcal each launch);
/// the Trends screen's SegmentedButton drives it.
class SelectedTrendMetricNotifier extends Notifier<TargetMetric> {
  @override
  TargetMetric build() => TargetMetric.kcal;
  void set(TargetMetric m) => state = m;
}

final selectedTrendMetricProvider =
    NotifierProvider<SelectedTrendMetricNotifier, TargetMetric>(
      SelectedTrendMetricNotifier.new,
    );

/// Per-day value (for the selected metric) vs that metric's target for the
/// chosen window, gap-filled so every day has a point.
final trendsProvider = StreamProvider<List<DayTrend>>((ref) {
  final db = ref.watch(dbProvider);
  final w = ref.watch(trendRangeProvider);
  final metric = ref.watch(selectedTrendMetricProvider);
  final targets = ref.watch(targetsProvider).asData?.value ?? const [];
  final defaultMin = ref.watch(defaultMinProvider).asData?.value;
  final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
  final macroDefaults =
      ref.watch(macroDefaultsProvider).asData?.value ?? const {};
  final defaults = metric == TargetMetric.kcal
      ? CalorieTarget(defaultMin, defaultMax)
      : (macroDefaults[metric] ?? const CalorieTarget(null, null));
  double pick(
    ({String day, double kcal, double protein, double carb, double fat}) r,
  ) => switch (metric) {
    TargetMetric.kcal => r.kcal,
    TargetMetric.protein => r.protein,
    TargetMetric.carb => r.carb,
    TargetMetric.fat => r.fat,
  };
  return db
      .watchDailyTotals(DayKey.of(w.start), DayKey.of(w.end))
      .map(
        (rows) => buildMetricDayTrends(
          w.start,
          w.end,
          {for (final r in rows) r.day: pick(r)},
          targets,
          metric,
          defaults,
        ),
      );
});

/// Whether the Trends tab is shown (default on; only an explicit 'false' hides).
final showTrendsProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(dbProvider).watchSetting('showTrends').map((v) => v != 'false'),
);
