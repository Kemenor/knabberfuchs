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
import 'crop_screen.dart';

/// Create a saved food: full nutrition form with an optional label scanner.
/// One screen for both "create custom food" (no barcode) and "add a product
/// for a not-found barcode" — with a barcode it's re-scannable and offers an
/// Open Food Facts contribution link. Pops the created [Food].
class FoodFormScreen extends ConsumerStatefulWidget {
  final String? barcode;
  const FoodFormScreen({super.key, this.barcode});

  @override
  ConsumerState<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends ConsumerState<FoodFormScreen> {
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

  bool get _hasBarcode => widget.barcode != null;

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _serving, _kcal, _protein, _carb, _fat,
      _fiber, _sugar, _satfat, _salt,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _val(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _scanLabel() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(l10n.addPhotoOfTable),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.addChooseGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
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
    final food = await ref.read(foodRepositoryProvider).createFood(
          barcode: widget.barcode,
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

  Future<void> _contributeToOff() async {
    // Open OFF for this barcode — App Links route to the OFF app if installed,
    // otherwise the browser. OFF handles its own login + submission.
    await launchUrl(
      Uri.parse(
          'https://world.openfoodfacts.org/cgi/product.pl?type=add&code=${widget.barcode}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasBarcode ? l10n.addProductTitle : l10n.manualTitle),
        actions: [TextButton(onPressed: _save, child: Text(l10n.actionSave))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_hasBarcode) ...[
            Text(l10n.addBarcodeLabel(widget.barcode!),
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
          ],
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _contributeToOff,
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: Text(l10n.addToOff),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.addToOffNote, style: theme.textTheme.bodySmall),
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
