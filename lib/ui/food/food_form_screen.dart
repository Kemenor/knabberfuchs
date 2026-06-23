import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/snackbar.dart';
import '../../data/db/database.dart';
import '../../data/ocr/image_preprocess.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../scan/scan_screen.dart';
import 'crop_screen.dart';
import 'image_source_sheet.dart';

/// Create a saved food: one full nutrition form for everything. The barcode is
/// just an optional field (type it, or tap the icon to scan one) — with a value
/// the food is re-scannable. Pass [barcode] to pre-fill it (e.g. from a
/// not-found scan). Pops the [Food].
class FoodFormScreen extends ConsumerStatefulWidget {
  final String? barcode;
  const FoodFormScreen({super.key, this.barcode});

  @override
  ConsumerState<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends ConsumerState<FoodFormScreen> {
  late final _barcode = TextEditingController(text: widget.barcode ?? '');
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _serving = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  final _sugar = TextEditingController();
  final _satfat = TextEditingController();
  final _salt = TextEditingController();
  bool _ocrBusy = false;

  bool get _hasBarcode => _barcode.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Rebuild so the "share to Open Food Facts" hint follows the barcode field.
    _barcode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [
      _barcode, _name, _brand, _serving, _kcal, _protein, _carb, _fat,
      _fiber, _sugar, _satfat, _salt,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _val(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (code != null && code.trim().isNotEmpty && mounted) {
      _barcode.text = code.trim();
    }
  }

  Future<void> _scanLabel() async {
    final l10n = AppLocalizations.of(context);
    final source = await pickImageSource(context, cameraLabel: l10n.addPhotoOfTable);
    if (source == null || !mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final img = await ImagePicker().pickImage(source: source);
    if (img == null || !mounted) return;

    // Crop to just the nutrition table for much better OCR.
    final bytes = await img.readAsBytes();
    final cropped = await navigator.push<Uint8List>(
        MaterialPageRoute(builder: (_) => CropScreen(image: bytes)));
    if (cropped == null || !mounted) return;
    final processed = preprocessLabelImage(cropped);
    final path = '${(await getTemporaryDirectory()).path}/label_ocr.jpg';
    await File(path).writeAsBytes(processed, flush: true);

    setState(() => _ocrBusy = true);
    try {
      final n = await ref.read(ocrServiceProvider).nutritionFromImage(path);
      void set(TextEditingController c, double? v) {
        if (v != null) c.text = gramsStr(v);
      }

      set(_kcal, n.kcal100);
      set(_protein, n.protein100);
      set(_carb, n.carb100);
      set(_fat, n.fat100);
      set(_fiber, n.fiber100);
      set(_sugar, n.sugar100);
      set(_satfat, n.satFat100);
      set(_salt, n.saltG100);
      messenger.showAutoSnackBar(SnackBar(
          content: Text(
              n.hasAny ? l10n.addFilledFromLabel : l10n.addCouldntRead)));
    } finally {
      if (mounted) setState(() => _ocrBusy = false);
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final kcal = _val(_kcal);
    if (name.isEmpty || kcal == null) {
      messenger.showAutoSnackBar(
          SnackBar(content: Text(l10n.addNameEnergyRequired)));
      return;
    }
    final barcode = _barcode.text.trim();
    final food = await ref.read(foodRepositoryProvider).createFood(
          barcode: barcode.isEmpty ? null : barcode,
          name: name,
          brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
          kcal100: kcal,
          protein100: _val(_protein),
          carb100: _val(_carb),
          fat100: _val(_fat),
          fiber100: _val(_fiber),
          sugar100: _val(_sugar),
          satFat100: _val(_satfat),
          saltG100: _val(_salt),
          servingG: _val(_serving),
        );
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.foodFormTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'foodSaveFab',
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: Text(l10n.actionSave),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          TextField(
            controller: _barcode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.barcodeField,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: l10n.scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanBarcode,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: l10n.addProductName,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brand,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: l10n.manualBrandOptional,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _numField(_serving, l10n.addServingSize, 'g'),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.addNutritionPer100, style: theme.textTheme.titleSmall),
              const Spacer(),
              _ocrBusy
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : OutlinedButton.icon(
                      onPressed: _scanLabel,
                      icon: const Icon(Icons.document_scanner_outlined, size: 18),
                      label: Text(l10n.addScanLabel),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          _numField(_kcal, l10n.addEnergy, 'kcal'),
          const SizedBox(height: 12),
          _numField(_protein, l10n.addProtein, 'g'),
          const SizedBox(height: 12),
          _numField(_carb, l10n.addCarbohydrate, 'g'),
          const SizedBox(height: 12),
          _numField(_fat, l10n.addFat, 'g'),
          const SizedBox(height: 12),
          _numField(_sugar, l10n.addSugars, 'g'),
          const SizedBox(height: 12),
          _numField(_satfat, l10n.addSaturates, 'g'),
          const SizedBox(height: 12),
          _numField(_fiber, l10n.addFibre, 'g'),
          const SizedBox(height: 12),
          _numField(_salt, l10n.addSalt, 'g'),
          if (_hasBarcode) ...[
            const SizedBox(height: 20),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(
                    'https://world.openfoodfacts.org/how-to-add-a-product'),
                mode: LaunchMode.externalApplication,
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.volunteer_activism_outlined,
                        size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                          children: [
                            TextSpan(text: '${l10n.shareToOff} '),
                            TextSpan(
                              text: l10n.shareToOffLink,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, String suffix) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
