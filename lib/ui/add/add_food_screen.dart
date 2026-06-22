import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../food/food_form_screen.dart';
import '../food/food_search_list.dart';
import '../food/offline_reminder.dart';
import '../food/log_food_sheet.dart';
import '../food/quick_add_sheet.dart';
import '../scan/scan_screen.dart';

/// Search + add a food to [day]/[meal].
class AddFoodScreen extends ConsumerWidget {
  final String day;
  final MealType meal;

  /// Track-by-day mode: resolves the target group at log time (null = meal mode).
  final Future<int?> Function()? resolveGroup;

  const AddFoodScreen({
    super.key,
    required this.day,
    required this.meal,
    this.resolveGroup,
  });

  Future<void> _pick(BuildContext context, WidgetRef ref, Food food) async {
    // Search hits from region packs are synthetic (id 0) — persist before logging.
    final persisted = await ref.read(foodRepositoryProvider).ensurePersisted(food);
    if (!context.mounted) return;
    final added = await showLogFoodSheet(context, ref,
        food: persisted, day: day, meal: meal, resolveGroup: resolveGroup);
    if (added == true && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (barcode == null || !context.mounted) return;
    final hit = await ref.read(foodRepositoryProvider).lookupBarcode(barcode);
    if (!context.mounted) return;
    if (hit.food != null) {
      final reminder = offlinePackReminder(context, ref, hit.source);
      await _pick(context, ref, hit.food!);
      reminder?.call(); // after the log sheet closes, so it isn't hidden
    } else {
      // Not found anywhere — let the user add it (and optionally send to OFF).
      final created = await Navigator.of(context).push<Food>(MaterialPageRoute(
          builder: (_) => FoodFormScreen(barcode: barcode)));
      if (created != null && context.mounted) await _pick(context, ref, created);
    }
  }

  Future<void> _createCustom(BuildContext context, WidgetRef ref) async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const FoodFormScreen()),
    );
    if (food != null && context.mounted) await _pick(context, ref, food);
  }

  Future<void> _quickAdd(BuildContext context, WidgetRef ref, String name) async {
    final added = await showQuickAddSheet(context, ref,
        day: day, meal: meal, resolveGroup: resolveGroup, initialName: name);
    if (added == true && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dayAddFood)),
      body: FoodSearchList(
        onPick: (food) => _pick(context, ref, food),
        onCreateCustom: () => _createCustom(context, ref),
        onQuickAdd: (name) => _quickAdd(context, ref, name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addFoodScanFab',
        onPressed: () => _scan(context, ref),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l10n.scanBarcode),
      ),
    );
  }
}
