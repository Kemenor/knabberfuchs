import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// Whether the meal picker should be shown (track-by-meal mode).
bool _askMeal(WidgetRef ref) =>
    ref.read(groupByMealProvider).asData?.value ?? true;

/// Sheet to log a catalog [food] into [day]/[meal].
Future<bool?> showLogFoodSheet(
  BuildContext context,
  WidgetRef ref, {
  required Food food,
  required String day,
  required MealType meal,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSheet(
      title: 'Add food',
      submitLabel: 'Add',
      name: food.name,
      brand: food.brand,
      kcal100: food.kcal100,
      protein100: food.protein100,
      carb100: food.carb100,
      fat100: food.fat100,
      servingG: food.servingG,
      servingLabel: food.servingLabel,
      initialGrams: food.servingG ?? 100,
      initialMeal: meal,
      askMeal: _askMeal(ref),
      onSubmit: (g, m) => ref
          .read(diaryRepositoryProvider)
          .logFood(food: food, grams: g, meal: m, day: day),
    ),
  );
}

/// Sheet to edit an existing diary [entry] (grams + meal, or delete).
void showEditEntrySheet(BuildContext context, WidgetRef ref, Entry entry) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSheet(
      title: 'Edit entry',
      submitLabel: 'Save',
      name: entry.sName,
      brand: null,
      kcal100: entry.sKcal100,
      protein100: entry.sProtein100,
      carb100: entry.sCarb100,
      fat100: entry.sFat100,
      servingG: null,
      servingLabel: null,
      initialGrams: entry.grams,
      initialMeal: entry.mealType,
      askMeal: _askMeal(ref),
      onSubmit: (g, m) =>
          ref.read(diaryRepositoryProvider).editEntry(entry, grams: g, meal: m),
      onDelete: () => ref.read(diaryRepositoryProvider).deleteEntry(entry.id),
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
  final double initialGrams;
  final MealType initialMeal;
  final bool askMeal;
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
    required this.initialMeal,
    required this.askMeal,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  late final TextEditingController _grams =
      TextEditingController(text: gramsStr(widget.initialGrams));
  late MealType _meal = widget.initialMeal;

  double get _g => double.tryParse(_grams.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    _grams.dispose();
    super.dispose();
  }

  void _setGrams(double g) {
    _grams.text = gramsStr(g);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kcal = widget.kcal100 * _g / 100;
    final chips = <double>{50, 100, 150, 200, if (widget.servingG != null) widget.servingG!}
        .toList()
      ..sort();

    return Padding(
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
          Text('${kcalStr(widget.kcal100)} kcal / 100 g',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _grams,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    suffixText: 'g',
                    border: OutlineInputBorder(),
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
                  Text('kcal', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final c in chips)
                ActionChip(
                  label: Text(widget.servingG == c
                      ? '1 serving (${gramsStr(c)} g)'
                      : '${gramsStr(c)} g'),
                  onPressed: () => _setGrams(c),
                ),
            ],
          ),
          if (widget.askMeal) ...[
            const SizedBox(height: 16),
            Text('Meal', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final m in MealType.values)
                  ChoiceChip(
                    label: Text(m.label),
                    selected: _meal == m,
                    onSelected: (_) => setState(() => _meal = m),
                  ),
              ],
            ),
          ],
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
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _g <= 0
                    ? null
                    : () async {
                        await widget.onSubmit(_g, _meal);
                        if (context.mounted) Navigator.of(context).pop(true);
                      },
                child: Text(widget.submitLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
