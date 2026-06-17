import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/db/database.dart';
import '../../providers.dart';
import '../scan/scan_screen.dart';
import 'food_search_list.dart';
import 'manual_food_screen.dart';
import 'offline_reminder.dart';

/// Search / scan / create a single food and pop it. Used to match an OCR
/// ingredient or add a recipe ingredient.
class FoodPickerScreen extends ConsumerWidget {
  final String title;
  const FoodPickerScreen({super.key, this.title = 'Select food'});

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final barcode = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (_) => const ScanScreen(formats: [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ]),
    ));
    if (barcode == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final hit = await ref.read(foodRepositoryProvider).lookupBarcode(barcode);
    if (!context.mounted) return;
    if (hit.food != null) {
      final reminder = offlinePackReminder(context, ref, hit.source);
      Navigator.of(context).pop(hit.food);
      reminder?.call(); // shows on the screen we return to
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text('No product found for $barcode')));
    }
  }

  Future<void> _createCustom(BuildContext context) async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const ManualFoodScreen()),
    );
    if (food != null && context.mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scan(context, ref),
          ),
        ],
      ),
      body: FoodSearchList(
        onPick: (food) => Navigator.of(context).pop(food),
        onCreateCustom: () => _createCustom(context),
      ),
    );
  }
}
