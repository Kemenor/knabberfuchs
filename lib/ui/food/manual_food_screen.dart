import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Create a custom food (nutrition entered per 100 g). Pops the created Food.
class ManualFoodScreen extends ConsumerStatefulWidget {
  const ManualFoodScreen({super.key});

  @override
  ConsumerState<ManualFoodScreen> createState() => _ManualFoodScreenState();
}

class _ManualFoodScreenState extends ConsumerState<ManualFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  final _serving = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _brand, _kcal, _protein, _carb, _fat, _serving]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final food = await ref.read(foodRepositoryProvider).createCustomFood(
          name: _name.text.trim(),
          brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
          kcal100: _num(_kcal)!,
          protein100: _num(_protein),
          carb100: _num(_carb),
          fat100: _num(_fat),
          servingG: _num(_serving),
        );
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manualTitle),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.actionSave)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.manualNameRequired,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.manualRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: InputDecoration(
                labelText: l10n.manualBrandOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.manualPer100,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            _numField(_kcal, l10n.manualCalories, required: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numField(_protein, l10n.manualProtein)),
                const SizedBox(width: 12),
                Expanded(child: _numField(_carb, l10n.manualCarbs)),
                const SizedBox(width: 12),
                Expanded(child: _numField(_fat, l10n.manualFat)),
              ],
            ),
            const SizedBox(height: 20),
            _numField(_serving, l10n.manualServing),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l10n.manualSaveFood)),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label,
      {bool required = false}) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return l10n.manualRequired;
        }
        if (v != null && v.trim().isNotEmpty && _num(c) == null) {
          return l10n.manualInvalidNumber;
        }
        return null;
      },
    );
  }
}
