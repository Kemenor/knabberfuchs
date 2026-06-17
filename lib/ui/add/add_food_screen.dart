import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';
import '../food/food_search_list.dart';
import '../food/offline_reminder.dart';
import '../food/log_food_sheet.dart';
import '../food/manual_food_screen.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    final hit = await ref.read(foodRepositoryProvider).lookupBarcode(barcode);
    if (!context.mounted) return;
    if (hit.food != null) {
      final reminder = offlinePackReminder(context, ref, hit.source);
      await _pick(context, ref, hit.food!);
      reminder?.call(); // after the log sheet closes, so it isn't hidden
    } else {
      messenger.showAutoSnackBar(
          SnackBar(content: Text('No product found for $barcode')));
    }
  }

  Future<void> _createCustom(BuildContext context, WidgetRef ref) async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const ManualFoodScreen()),
    );
    if (food != null && context.mounted) await _pick(context, ref, food);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scan(context, ref),
          ),
        ],
      ),
      body: FoodSearchList(
        onPick: (food) => _pick(context, ref, food),
        onCreateCustom: () => _createCustom(context, ref),
      ),
    );
  }
}
