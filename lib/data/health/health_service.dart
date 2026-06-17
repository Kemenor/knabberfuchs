import 'package:health/health.dart' as h;

import '../../domain/enums.dart';
import '../db/database.dart';

/// Write-only Health Connect sync: pushes each day's logged nutrition (calories
/// + macros) as meal records. Opt-in; a no-op until enabled and authorized.
class HealthService {
  final h.Health _health = h.Health();
  bool _configured = false;

  /// Cached opt-in flag (mirrors the 'healthSync' setting).
  bool enabled = false;

  static const _types = [h.HealthDataType.NUTRITION];
  static const _perms = [h.HealthDataAccess.READ_WRITE];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Whether Health Connect is installed/available on this device.
  Future<bool> isAvailable() async {
    await _ensureConfigured();
    final status = await _health.getHealthConnectSdkStatus();
    return status == h.HealthConnectSdkStatus.sdkAvailable;
  }

  /// Prompt for nutrition write access. Returns true if granted.
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    return _health.requestAuthorization(_types, permissions: _perms);
  }

  Future<void> refreshEnabled(AppDatabase db) async {
    enabled = (await db.getSetting('healthSync')) == 'true';
    if (enabled) await _ensureConfigured();
  }

  /// Re-sync one day: delete our nutrition records for that day, then write the
  /// current entries. Idempotent. Swallows errors (revoked permission / no HC).
  Future<void> syncDay(String day, List<Entry> entries) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final d = DateTime.parse(day); // 'YYYY-MM-DD' -> local midnight
    final start = DateTime(d.year, d.month, d.day);
    final end = start.add(const Duration(days: 1));
    try {
      await _health.delete(
          type: h.HealthDataType.NUTRITION, startTime: start, endTime: end);
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        final factor = e.grams / 100.0;
        // A representative time in the day, but never in the future — Health
        // Connect rejects future-dated records. Entries are spread a minute apart.
        var endT = start.add(Duration(hours: _hour(e.mealType), minutes: i));
        if (endT.isAfter(now)) {
          endT = now.subtract(Duration(minutes: entries.length - i));
        }
        final startT = endT.subtract(const Duration(minutes: 1));
        await _health.writeMeal(
          mealType: _mealType(e.mealType),
          startTime: startT,
          endTime: endT,
          name: e.sName,
          caloriesConsumed: e.sKcal100 * factor,
          protein: e.sProtein100 == null ? null : e.sProtein100! * factor,
          carbohydrates: e.sCarb100 == null ? null : e.sCarb100! * factor,
          fatTotal: e.sFat100 == null ? null : e.sFat100! * factor,
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

  /// Remove everything we ever wrote (used when turning the feature off).
  Future<void> deleteAll() async {
    await _ensureConfigured();
    try {
      await _health.delete(
        type: h.HealthDataType.NUTRITION,
        startTime: DateTime(2000),
        endTime: DateTime.now().add(const Duration(days: 1)),
      );
    } catch (_) {}
  }

  int _hour(MealType m) => switch (m) {
        MealType.breakfast => 8,
        MealType.lunch => 12,
        MealType.dinner => 19,
        MealType.snack => 15,
      };

  h.MealType _mealType(MealType m) => switch (m) {
        MealType.breakfast => h.MealType.BREAKFAST,
        MealType.lunch => h.MealType.LUNCH,
        MealType.dinner => h.MealType.DINNER,
        MealType.snack => h.MealType.SNACK,
      };
}
