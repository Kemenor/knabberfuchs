import 'dart:io';

import 'package:health/health.dart' as h;

import '../../domain/enums.dart';
import '../../domain/nutrition.dart' show decodeMicros;
import '../db/database.dart';

/// Write-only Health Connect sync: pushes each day's logged nutrition (calories
/// + macros) as meal records. Opt-in; a no-op until enabled and authorized.
class HealthService {
  final h.Health _health = h.Health();
  bool _configured = false;

  /// Cached opt-in flag (mirrors the 'healthSync' setting).
  bool enabled = false;

  /// Cached opt-in flag for the energy read-back (mirrors the
  /// 'healthEnergyRead' setting) — a separate grant from write-sync.
  bool energyReadEnabled = false;

  // iOS HealthKit's umbrella NUTRITION type expands the permission sheet to ~40
  // dietary sub-types (every vitamin/mineral), even though we only ever write
  // energy + macros. So on iOS request exactly those four. Health Connect
  // (Android) exposes nutrition as a single permission, so the umbrella type is
  // correct there and keeps the existing behaviour. writeMeal still works with
  // only the four granular grants — saving a food correlation needs share access
  // to its contained sample types, not the correlation type itself.
  static final List<h.HealthDataType> _types = Platform.isIOS
      ? const [
          h.HealthDataType.DIETARY_ENERGY_CONSUMED,
          h.HealthDataType.DIETARY_PROTEIN_CONSUMED,
          h.HealthDataType.DIETARY_CARBS_CONSUMED,
          h.HealthDataType.DIETARY_FATS_CONSUMED,
        ]
      : const [h.HealthDataType.NUTRITION];
  // Android needs only WRITE: Health Connect deletes our own records by time
  // range without a read grant. iOS must keep READ_WRITE — the plugin's
  // delete() runs an HKSampleQuery, which needs read authorization; WRITE-only
  // would make every re-sync silently duplicate meals instead of replacing
  // them.
  static final List<h.HealthDataAccess> _perms = List.filled(
    _types.length,
    Platform.isIOS ? h.HealthDataAccess.READ_WRITE : h.HealthDataAccess.WRITE,
  );

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Whether a health store is available to sync to. iOS always ships HealthKit;
  /// on Android this depends on Health Connect being installed. (getHealthConnect-
  /// SdkStatus is Android-only, so it must not be called on iOS.)
  Future<bool> isAvailable() async {
    await _ensureConfigured();
    if (Platform.isIOS) return true;
    final status = await _health.getHealthConnectSdkStatus();
    return status == h.HealthConnectSdkStatus.sdkAvailable;
  }

  /// Prompt for nutrition write access. Returns true if granted.
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    return _health.requestAuthorization(_types, permissions: _perms);
  }

  /// The energy read-back reads only active energy (never TOTAL/BMR — the
  /// static target already encodes maintenance; grilled 2026-07-02).
  static const _energyTypes = [h.HealthDataType.ACTIVE_ENERGY_BURNED];

  /// Prompt for active-energy read access. Returns true if granted.
  Future<bool> requestEnergyReadPermission() async {
    await _ensureConfigured();
    return _health.requestAuthorization(
      _energyTypes,
      permissions: const [h.HealthDataAccess.READ],
    );
  }

  Future<void> refreshEnabled(AppDatabase db) async {
    enabled = (await db.getSetting('healthSync')) == 'true';
    energyReadEnabled = (await db.getSetting('healthEnergyRead')) == 'true';
    if (enabled || energyReadEnabled) await _ensureConfigured();
  }

  /// Active energy burned on [day] in kcal, via the platform aggregate API —
  /// Health Connect / HealthKit dedupe multi-source (phone + watch) records
  /// through their own priority system, so never sum raw records here.
  /// Returns 0 on any failure (feature off, permission revoked, store
  /// missing, no data) — callers then show the plain static target.
  Future<double> activeEnergyFor(String day) async {
    if (!energyReadEnabled) return 0;
    await _ensureConfigured();
    final d = DateTime.parse(day);
    final start = DateTime(d.year, d.month, d.day);
    // Next calendar midnight, not +24 h (DST; same as syncDay's window).
    final end = DateTime(d.year, d.month, d.day + 1);
    try {
      final points = await _health.getHealthAggregateDataFromTypes(
        types: _energyTypes,
        startDate: start,
        endDate: end,
      );
      var sum = 0.0;
      for (final p in points) {
        final v = p.value;
        if (v is h.NumericHealthValue) sum += v.numericValue.toDouble();
      }
      return sum > 0 ? sum : 0;
    } catch (_) {
      return 0; // revoked / unavailable / platform quirk — static target
    }
  }

  /// Re-sync one day: delete our nutrition records for that day, then write the
  /// current entries. Idempotent. Swallows errors (revoked permission / no HC).
  Future<void> syncDay(String day, List<Entry> entries) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final d = DateTime.parse(day); // 'YYYY-MM-DD' -> local midnight
    final start = DateTime(d.year, d.month, d.day);
    // Next calendar midnight, not +24 h: a 25 h DST day would leave its last
    // hour outside the delete window and duplicate entries on re-sync.
    final end = DateTime(d.year, d.month, d.day + 1);
    try {
      for (final t in _types) {
        await _health.delete(type: t, startTime: start, endTime: end);
      }
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        final factor = e.grams / 100.0;
        // Anchor on the real moment the entry was logged (editable via
        // back-dating). HC rejects future records, and startT must stay >=
        // the day's start or the record lands on the wrong day. So cap the
        // window at min(now, end); when the log time is unset / out of range /
        // future, fall back to a stable in-day slot (noon, spread a minute
        // apart to keep order), then clamp the tail to the cap.
        final upper = now.isBefore(end) ? now : end;
        var endT = e.createdAt;
        if (endT.isBefore(start) || !endT.isBefore(upper)) {
          endT = start.add(Duration(hours: 12, minutes: i));
        }
        if (!endT.isBefore(upper)) endT = upper;
        final startT = endT.subtract(const Duration(minutes: 1));
        final micros = decodeMicros(e.sMicrosJson);
        double? micro(String key) =>
            micros[key] == null ? null : micros[key]! * factor;
        await _health.writeMeal(
          mealType: _mealType(e.mealType),
          startTime: startT,
          endTime: endT,
          name: e.sName,
          caloriesConsumed: e.sKcal100 * factor,
          protein: e.sProtein100 == null ? null : e.sProtein100! * factor,
          carbohydrates: e.sCarb100 == null ? null : e.sCarb100! * factor,
          fatTotal: e.sFat100 == null ? null : e.sFat100! * factor,
          // Phase 15 tracked nutrients, when the snapshot has them. The
          // stores take sodium, not salt: g sodium = g salt / 2.5.
          fiber: micro('fiber'),
          fatSaturated: micro('satFat'),
          sugar: micro('sugar'),
          sodium: micro('salt') == null ? null : micro('salt')! / 2.5,
        );
      }
    } catch (_) {
      // Permission revoked or Health Connect unavailable — ignore.
    }
  }

  /// Sync the day only if the user has the feature enabled.
  Future<void> maybeSyncDay(String day, List<Entry> entries) async {
    if (!enabled) return;
    await syncDay(day, entries);
  }

  /// Full resync: wipe everything this app ever wrote, then re-push every day
  /// that has entries. The wipe (rather than per-day delete+rewrite alone)
  /// also clears days whose entries were since deleted, so the health store
  /// ends up matching the diary exactly — the fix for "a wrong number already
  /// synced" without needing per-day granularity.
  Future<void> resyncAll(AppDatabase db) async {
    await deleteAll();
    final byDay = <String, List<Entry>>{};
    for (final e in await db.allEntries()) {
      byDay.putIfAbsent(e.day, () => []).add(e);
    }
    for (final entry in byDay.entries) {
      await syncDay(entry.key, entry.value);
    }
  }

  /// Remove everything we ever wrote (used when turning the feature off).
  Future<void> deleteAll() async {
    await _ensureConfigured();
    try {
      for (final t in _types) {
        await _health.delete(
          type: t,
          startTime: DateTime(2000),
          endTime: DateTime.now().add(const Duration(days: 1)),
        );
      }
    } catch (_) {}
  }

  h.MealType _mealType(MealType m) => switch (m) {
    MealType.breakfast => h.MealType.BREAKFAST,
    MealType.lunch => h.MealType.LUNCH,
    MealType.dinner => h.MealType.DINNER,
    MealType.snack => h.MealType.SNACK,
  };
}
