import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/food_name.dart';
import '../../domain/portion_units.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Sheet to log a catalog [food] into [day]. [meal] is the inferred meal tag
/// (for Health Connect); the user no longer picks it here.
Future<bool?> showLogFoodSheet(
  BuildContext context,
  WidgetRef ref, {
  required Food food,
  required String day,
  required MealType meal,
  Future<int?> Function()? resolveGroup,
}) {
  final displayName = food.localizedNameOf(context);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSheet(
      title: AppLocalizations.of(context).dayAddFood,
      submitLabel: AppLocalizations.of(context).actionAdd,
      name: displayName,
      brand: food.brand,
      kcal100: food.kcal100,
      protein100: food.protein100,
      carb100: food.carb100,
      fat100: food.fat100,
      servingG: food.servingG,
      servingLabel: food.servingLabel,
      density: food.densityGPerMl,
      initialGrams: food.servingG ?? 100,
      meal: meal,
      onSubmit: (g, m) async {
        final groupId = resolveGroup == null ? null : await resolveGroup();
        await ref.read(diaryRepositoryProvider).logFood(
            food: food,
            grams: g,
            meal: m,
            day: day,
            groupId: groupId,
            displayName: displayName);
      },
    ),
  );
}

/// Amount picker reusing the same sheet UI (unit selector, quick-picks, serving,
/// live kcal) but returning the chosen grams instead of logging — used for
/// recipe ingredients so they match the add-food flow.
Future<double?> showAmountSheet(
  BuildContext context, {
  required String name,
  String? brand,
  required double kcal100,
  double? protein100,
  double? carb100,
  double? fat100,
  double? servingG,
  String? servingLabel,
  double? initialGrams,
  String? submitLabel,
}) async {
  double? result;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSheet(
      title: AppLocalizations.of(context).amountLabel,
      submitLabel: submitLabel ?? AppLocalizations.of(context).actionAdd,
      name: name,
      brand: brand,
      kcal100: kcal100,
      protein100: protein100,
      carb100: carb100,
      fat100: fat100,
      servingG: servingG,
      servingLabel: servingLabel,
      initialGrams: initialGrams ?? servingG ?? 100,
      meal: MealType.snack,
      onSubmit: (g, _) async => result = g,
    ),
  );
  return ok == true ? result : null;
}

/// Sheet to edit an existing diary [entry] (grams, or delete).
void showEditEntrySheet(BuildContext context, WidgetRef ref, Entry entry) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSheet(
      title: AppLocalizations.of(context).editEntryTitle,
      submitLabel: AppLocalizations.of(context).actionSave,
      name: entry.sName,
      brand: null,
      kcal100: entry.sKcal100,
      protein100: entry.sProtein100,
      carb100: entry.sCarb100,
      fat100: entry.sFat100,
      servingG: null,
      servingLabel: null,
      initialGrams: entry.grams,
      meal: entry.mealType,
      onSubmit: (g, m) =>
          ref.read(diaryRepositoryProvider).editEntry(entry, grams: g, meal: m),
      onDelete: () async {
        await ref.read(diaryRepositoryProvider).deleteEntry(entry.id);
        await ref.read(dbProvider).pruneEmptyGroups(entry.day);
      },
    ),
  );
}

class _LogSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String name;
  final String? brand;
  final double kcal100;
  final double? protein100;
  final double? carb100;
  final double? fat100;
  final double? servingG;
  final String? servingLabel;
  final double? density;
  final double initialGrams;
  final MealType meal;
  final Future<void> Function(double grams, MealType meal) onSubmit;
  final Future<void> Function()? onDelete;

  const _LogSheet({
    required this.title,
    required this.submitLabel,
    required this.name,
    required this.brand,
    required this.kcal100,
    required this.protein100,
    required this.carb100,
    required this.fat100,
    required this.servingG,
    required this.servingLabel,
    required this.initialGrams,
    required this.meal,
    required this.onSubmit,
    this.density,
    this.onDelete,
  });

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  // Liquids (those with a density) open in millilitres; everything else in
  // grams, defaulting to the food's serving/portion weight.
  late AmountUnit _unit =
      widget.density != null ? AmountUnit.milliliters : AmountUnit.grams;
  late final TextEditingController _amountCtrl = TextEditingController(
      text: gramsStr(_unit == AmountUnit.grams
          ? widget.initialGrams
          : _unit.typicalAmount));

  double get _amount =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _grams => _unit.toGrams(_amount, density: widget.density ?? 1.0);

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _setGrams(double g) {
    setState(() {
      _unit = AmountUnit.grams;
      _amountCtrl.text = gramsStr(g);
    });
  }

  /// Set the amount in the current unit (used by the unit-aware quick-picks).
  void _setAmount(double a) =>
      setState(() => _amountCtrl.text = gramsStr(a));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final grams = _grams;
    final kcal = widget.kcal100 * grams / 100;

    // SafeArea keeps the buttons clear of the system nav bar (3-button mode);
    // viewInsets handles the keyboard. Together they cover both at once.
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name,
              style: theme.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (widget.brand != null)
            Text(widget.brand!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(l10n.kcalPer100(kcalStr(widget.kcal100)),
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.amountLabel,
                    suffixText: _unit.label,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(kcalStr(kcal),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(l10n.unitKcal, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (final u in AmountUnit.values)
                ChoiceChip(
                  label: Text(u.label),
                  selected: _unit == u,
                  onSelected: (_) => setState(() {
                    _unit = u;
                    _amountCtrl.text = gramsStr(u.typicalAmount);
                  }),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (_unit.isVolume)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  widget.density != null
                      ? l10n.volumeDensity(
                          gramsStr(grams), widget.density!.toString())
                      : l10n.volumeApprox(gramsStr(grams)),
                  style: theme.textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              // Natural portion leads the row and shows selected while it's the
              // chosen amount (it's the default on open), so it reads as the
              // active pick rather than an afterthought.
              if (_unit == AmountUnit.grams && widget.servingG != null)
                Builder(builder: (_) {
                  // Swiss curated foods carry a known unit key ("medium") →
                  // "1 medium · 300 g". OFF foods carry a free-text serving_size
                  // ("30 g") → plain "1 serving (30 g)".
                  final unit = widget.servingLabel == null
                      ? null
                      : portionUnitLabel(l10n, widget.servingLabel!);
                  return ChoiceChip(
                    label: Text(unit != null
                        ? l10n.portionChip(unit, gramsStr(widget.servingG!))
                        : l10n.oneServing(gramsStr(widget.servingG!))),
                    selected: _grams == widget.servingG,
                    onSelected: (_) => _setGrams(widget.servingG!),
                  );
                }),
              for (final c in _unit.quickAmounts)
                ActionChip(
                  label: Text('${gramsStr(c)} ${_unit.label}'),
                  onPressed: () => _setAmount(c),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.onDelete != null)
                TextButton.icon(
                  onPressed: () async {
                    await widget.onDelete!();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.actionDelete),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _grams <= 0
                    ? null
                    : () async {
                        await widget.onSubmit(_grams, widget.meal);
                        if (context.mounted) Navigator.of(context).pop(true);
                      },
                child: Text(widget.submitLabel),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
