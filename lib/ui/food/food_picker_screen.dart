import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../scan/scan_screen.dart';
import 'food_form_screen.dart';
import 'food_search_list.dart';
import 'offline_reminder.dart';

/// Search / scan / create a single food and pop it. Used to match an OCR
/// ingredient or add a recipe ingredient.
class FoodPickerScreen extends ConsumerWidget {
  final String? title;

  /// Pre-fill the search box (e.g. with the OCR ingredient name) so the user
  /// doesn't retype what we already parsed.
  final String? initialQuery;
  const FoodPickerScreen({super.key, this.title, this.initialQuery});

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
    final hit = await ref.read(foodRepositoryProvider).lookupBarcode(barcode);
    if (!context.mounted) return;
    if (hit.food != null) {
      final reminder = offlinePackReminder(context, ref, hit.source);
      Navigator.of(context).pop(hit.food);
      reminder?.call(); // shows on the screen we return to
    } else {
      final created = await Navigator.of(context).push<Food>(MaterialPageRoute(
          builder: (_) => FoodFormScreen(barcode: barcode)));
      if (created != null && context.mounted) Navigator.of(context).pop(created);
    }
  }

  Future<void> _createCustom(BuildContext context) async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const FoodFormScreen()),
    );
    if (food != null && context.mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.selectFood)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pickerScanFab',
        tooltip: l10n.scanBarcode,
        onPressed: () => _scan(context, ref),
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: FoodSearchList(
        initialQuery: initialQuery,
        onPick: (food) => Navigator.of(context).pop(food),
        onCreateCustom: () => _createCustom(context),
      ),
    );
  }
}
