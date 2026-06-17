import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/date_x.dart';
import 'data/db/database.dart';
import 'data/repositories/diary_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/backup_service.dart';
import 'data/ocr/ocr_service.dart';
import 'data/offline/offline_pack_service.dart';
import 'data/offline/region_pack_store.dart';
import 'data/sources/off_api.dart';
import 'data/sources/usda_seed.dart';
import 'domain/day_summary.dart';
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
      ref.watch(dbProvider), ref.watch(regionPackStoreProvider)),
);

final installedPacksProvider = StreamProvider<List<InstalledPack>>(
  (ref) => ref.watch(dbProvider).watchInstalledPacks(),
);

final offlineManifestProvider = FutureProvider<OfflineManifest>(
  (ref) => ref.watch(offlinePackServiceProvider).fetchManifest(),
);

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(ref.watch(dbProvider), ref.watch(offApiProvider),
      ref.watch(regionPackStoreProvider)),
);

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepository(ref.watch(dbProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(
      ref.watch(dbProvider), ref.watch(diaryRepositoryProvider)),
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

/// One-time startup work: import the bundled USDA produce dataset on first run
/// and open any installed offline region packs.
final appStartupProvider = FutureProvider<void>((ref) async {
  await seedUsdaIfNeeded(ref.watch(dbProvider));
  await ref.read(offlinePackServiceProvider).syncStore();
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
    final name = 'Meal ${DateFormat('HH:mm').format(DateTime.now())}';
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

final activeGroupProvider =
    NotifierProvider<ActiveGroupNotifier, int?>(ActiveGroupNotifier.new);

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

/// Meal layout: true = fixed Breakfast/Lunch/Dinner/Snacks sections,
/// false = automatic per-add meal groups (track-by-day). Defaults to false.
final groupByMealProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(dbProvider)
      .watchSetting('groupByMeal')
      .map((v) => v == 'true'); // default false (track-by-day)
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
  final defaultMin = ref.watch(defaultMinProvider).asData?.value;
  final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
  final target =
      resolveTarget(targets, defaultMin, defaultMax, DayKey.weekdayIndex(day));

  return db.watchDay(day).map(
        (entries) => DaySummary(
          day: day,
          entries: entries.map(EntryView.new).toList(),
          kcalMin: target.min,
          kcalMax: target.max,
        ),
      );
});
