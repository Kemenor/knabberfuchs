import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/format.dart';
import '../../core/text_prompt_dialog.dart';
import '../../domain/weight.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'weight_format.dart';

const _cmPerInch = 2.54;

double? _parse(String? s) {
  final v = double.tryParse((s ?? '').trim().replaceAll(',', '.'));
  return v == null || v <= 0 ? null : v;
}

/// Settings → Weight: unit, height (for BMI milestones) and the goal weights.
class WeightSettingsScreen extends ConsumerWidget {
  const WeightSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final db = ref.watch(dbProvider);
    final unit = ref.watch(weightUnitProvider).asData?.value ?? WeightUnit.kg;
    final goals = ref.watch(weightGoalsProvider).asData?.value ?? const [];
    final height = ref.watch(heightCmProvider).asData?.value;
    final inches = unit == WeightUnit.lb;
    final heightUnit = inches ? l10n.unitIn : l10n.unitCm;
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    Future<void> editHeight() async {
      final shown = height == null
          ? null
          : (inches ? height / _cmPerInch : height);
      final text = await showTextPromptDialog(
        context,
        title: l10n.weightHeight,
        confirmLabel: l10n.actionSave,
        cancelLabel: l10n.actionCancel,
        initial: shown == null ? null : gramsStr(shown.roundToDouble()),
        suffixText: heightUnit,
        helperText: l10n.weightHeightSub,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: decimal,
      );
      if (text == null) return;
      final v = _parse(text);
      await db.setSetting(
        'heightCm',
        v == null ? null : '${inches ? v * _cmPerInch : v}',
      );
    }

    Future<void> addGoal() async {
      final text = await showTextPromptDialog(
        context,
        title: l10n.weightGoalAdd,
        confirmLabel: l10n.actionAdd,
        cancelLabel: l10n.actionCancel,
        suffixText: weightUnitLabel(l10n, unit),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: decimal,
      );
      final v = _parse(text);
      if (v == null || v >= 1000) return;
      await setWeightGoals(db, [...goals, unit.toKg(v)]);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.weightTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          FuchsbauSettingsCard(
            children: [
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.scale_rounded),
                title: Text(l10n.weightUnit),
                trailing: SegmentedButton<WeightUnit>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: WeightUnit.kg,
                      label: Text(l10n.unitKg),
                    ),
                    ButtonSegment(
                      value: WeightUnit.lb,
                      label: Text(l10n.unitLb),
                    ),
                  ],
                  selected: {unit},
                  onSelectionChanged: (s) =>
                      db.setSetting('weightUnit', s.first.name),
                ),
              ),
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.straighten_rounded),
                title: Text(l10n.weightHeight),
                subtitle: Text(
                  height == null
                      ? l10n.weightHeightSub
                      : l10n.weightValue(
                          gramsStr(
                            (inches ? height / _cmPerInch : height)
                                .roundToDouble(),
                          ),
                          heightUnit,
                        ),
                ),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: editHeight,
              ),
            ],
          ),
          FuchsbauSectionHeader(l10n.weightGoalsSection),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.weightGoalsHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          FuchsbauSettingsCard(
            children: [
              if (goals.isEmpty)
                ListTile(
                  contentPadding: fuchsbauCardRowPadding,
                  leading: const Icon(Symbols.flag_rounded),
                  title: Text(l10n.weightGoalsEmpty),
                ),
              for (final g in goals.reversed)
                ListTile(
                  contentPadding: fuchsbauCardRowPadding,
                  leading: const Icon(Symbols.flag_rounded),
                  title: Text(weightText(l10n, g, unit)),
                  trailing: IconButton(
                    tooltip: l10n.weightRemove,
                    icon: const Icon(Symbols.close_rounded),
                    onPressed: () => setWeightGoals(db, [...goals]..remove(g)),
                  ),
                ),
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.add_rounded),
                title: Text(l10n.weightGoalAdd),
                onTap: addGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
