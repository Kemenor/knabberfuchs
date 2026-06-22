import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Free add: log a one-off item by name + calories (optionally macros) without
/// searching the catalog or creating a persistent food. The entered values are
/// the totals for the portion — stored as a per-100 g snapshot with grams=100,
/// so the diary shows exactly what was typed. Returns true if something was
/// logged.
Future<bool?> showQuickAddSheet(
  BuildContext context,
  WidgetRef ref, {
  required String day,
  required MealType meal,
  Future<int?> Function()? resolveGroup,
  String? initialName,
  int? initialKcal,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _QuickAddSheet(
      day: day,
      meal: meal,
      resolveGroup: resolveGroup,
      initialName: initialName,
      initialKcal: initialKcal,
    ),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  final String day;
  final MealType meal;
  final Future<int?> Function()? resolveGroup;
  final String? initialName;
  final int? initialKcal;
  const _QuickAddSheet({
    required this.day,
    required this.meal,
    required this.resolveGroup,
    required this.initialName,
    required this.initialKcal,
  });

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  late final _name = TextEditingController(text: widget.initialName ?? '');
  late final _kcal =
      TextEditingController(text: widget.initialKcal?.toString() ?? '');
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  bool _showMacros = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _kcal, _protein, _carb, _fat]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _kcal, _protein, _carb, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _valid => _name.text.trim().isNotEmpty && (_num(_kcal) ?? 0) > 0;

  Future<void> _add() async {
    final groupId =
        widget.resolveGroup == null ? null : await widget.resolveGroup!();
    // Totals for the portion → store as per-100 g with grams=100.
    await ref.read(diaryRepositoryProvider).logSnapshot(
          name: _name.text.trim(),
          kcal100: _num(_kcal)!,
          protein100: _num(_protein),
          carb100: _num(_carb),
          fat100: _num(_fat),
          grams: 100,
          meal: widget.meal,
          day: widget.day,
          groupId: groupId,
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.quickAdd, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: widget.initialName == null ||
                  widget.initialName!.trim().isEmpty,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  labelText: l10n.quickAddName,
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kcal,
              autofocus: widget.initialName != null &&
                  widget.initialName!.trim().isNotEmpty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              decoration: InputDecoration(
                labelText: l10n.quickAddCalories,
                suffixText: l10n.unitKcal,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_showMacros) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _macroField(_protein, l10n.macroProtein)),
                  const SizedBox(width: 8),
                  Expanded(child: _macroField(_carb, l10n.macroCarbs)),
                  const SizedBox(width: 8),
                  Expanded(child: _macroField(_fat, l10n.macroFat)),
                ],
              ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showMacros = true),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.quickAddMacros),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid ? _add : null,
                child: Text(l10n.actionAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroField(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'g',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      );
}
