import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Free add: log a one-off item by name + calories (optionally macros) without
/// searching the catalog or creating a persistent food. The entered kcal/macros
/// are the totals for the portion. If a weight (g) is given (e.g. Gemini's
/// portion estimate via [initialWeight]), the entry stores that real weight with
/// a correct per-100 g snapshot, so it scales when edited; otherwise it falls
/// back to grams=100 (the typed totals shown verbatim). Returns true if logged.
Future<bool?> showQuickAddSheet(
  BuildContext context,
  WidgetRef ref, {
  required String day,
  required MealType meal,
  Future<int?> Function()? resolveGroup,
  String? initialName,
  int? initialKcal,
  double? initialProtein,
  double? initialCarb,
  double? initialFat,
  double? initialWeight,
  String? sourceLabel,
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
      initialProtein: initialProtein,
      initialCarb: initialCarb,
      initialFat: initialFat,
      initialWeight: initialWeight,
      sourceLabel: sourceLabel,
    ),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  final String day;
  final MealType meal;
  final Future<int?> Function()? resolveGroup;
  final String? initialName;
  final int? initialKcal;
  final double? initialProtein;
  final double? initialCarb;
  final double? initialFat;
  final double? initialWeight;
  final String? sourceLabel;
  const _QuickAddSheet({
    required this.day,
    required this.meal,
    required this.resolveGroup,
    required this.initialName,
    required this.initialKcal,
    required this.initialProtein,
    required this.initialCarb,
    required this.initialFat,
    required this.initialWeight,
    required this.sourceLabel,
  });

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  late final _name = TextEditingController(text: widget.initialName ?? '');
  late final _kcal =
      TextEditingController(text: widget.initialKcal?.toString() ?? '');
  late final _protein = TextEditingController(text: _g(widget.initialProtein));
  late final _carb = TextEditingController(text: _g(widget.initialCarb));
  late final _fat = TextEditingController(text: _g(widget.initialFat));
  late final _weight = TextEditingController(text: _g(widget.initialWeight));
  final _weightFocus = FocusNode();
  late bool _showMacros = widget.initialProtein != null ||
      widget.initialCarb != null ||
      widget.initialFat != null;

  /// The weight the current kcal/macro totals correspond to. Editing the weight
  /// scales the totals by (new / last) — so the fields track the real portion —
  /// then this updates. Editing kcal/macros directly leaves it (it just redefines
  /// the per-gram density at that weight). Null until a weight is first set.
  double? _lastWeight;

  static String _g(double? v) => v == null ? '' : gramsStr(v);

  @override
  void initState() {
    super.initState();
    _lastWeight = widget.initialWeight;
    for (final c in [_name, _kcal, _protein, _carb, _fat, _weight]) {
      c.addListener(() => setState(() {}));
    }
    // Scale on commit (focus leaves the field), not per keystroke — otherwise a
    // half-typed "6" on the way to "600" would briefly collapse the totals.
    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus) setState(_applyWeightScale);
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _kcal, _protein, _carb, _fat, _weight]) {
      c.dispose();
    }
    _weightFocus.dispose();
    super.dispose();
  }

  /// Rescale the kcal + macro totals to a newly-entered weight, keeping the
  /// per-gram values fixed. No-op if there's no prior weight to scale from, the
  /// new weight is invalid/zero, or it's unchanged.
  void _applyWeightScale() {
    final w = _num(_weight);
    final base = _lastWeight;
    if (w == null || w <= 0) return;
    if (base == null || base <= 0) {
      _lastWeight = w; // first real weight — adopt it as the basis, no scaling
      return;
    }
    if ((w - base).abs() < 0.01) return;
    final ratio = w / base;
    _scaleField(_kcal, ratio, decimals: false);
    _scaleField(_protein, ratio);
    _scaleField(_carb, ratio);
    _scaleField(_fat, ratio);
    _lastWeight = w;
  }

  void _scaleField(TextEditingController c, double ratio,
      {bool decimals = true}) {
    final v = _num(c);
    if (v == null) return;
    final scaled = v * ratio;
    c.text = decimals ? gramsStr(scaled) : scaled.round().toString();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _valid => _name.text.trim().isNotEmpty && (_num(_kcal) ?? 0) > 0;

  Future<void> _add() async {
    // Tapping "Add" doesn't blur the weight field, so commit any pending rescale
    // first (idempotent if the focus listener already ran).
    _applyWeightScale();
    final groupId =
        widget.resolveGroup == null ? null : await widget.resolveGroup!();
    // The fields hold portion totals. With a weight, store the real grams and a
    // correct per-100 g snapshot (total / grams * 100) so the entry scales when
    // edited; without one, fall back to grams=100 (totals shown verbatim).
    final w = _num(_weight);
    final grams = (w != null && w > 0) ? w : 100.0;
    final f = 100 / grams; // total → per-100 g
    double? per(TextEditingController c) {
      final v = _num(c);
      return v == null ? null : v * f;
    }

    await ref.read(diaryRepositoryProvider).logSnapshot(
          name: _name.text.trim(),
          kcal100: _num(_kcal)! * f,
          protein100: per(_protein),
          carb100: per(_carb),
          fat100: per(_fat),
          grams: grams,
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
            if (widget.sourceLabel != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 14, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 6),
                  Text(widget.sourceLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            ],
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _kcal,
                    autofocus: widget.initialName != null &&
                        widget.initialName!.trim().isNotEmpty,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.quickAddCalories,
                      suffixText: l10n.unitKcal,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _weight,
                    focusNode: _weightFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.quickAddWeight,
                      suffixText: 'g',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
