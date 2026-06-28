import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/db/database.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Settings → Targets. Metric-first: Calories, Protein, Carbohydrates, Fat —
/// each with an always-visible app-wide default Min/Max and an independently
/// expandable per-weekday breakdown. Every bound is optional.
class TargetsScreen extends ConsumerWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final l10n = AppLocalizations.of(context);
    final targetsAsync = ref.watch(targetsProvider);
    final defaultMin = ref.watch(defaultMinProvider).asData?.value;
    final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
    final macroDefaults =
        ref.watch(macroDefaultsProvider).asData?.value ?? const {};
    CalorieTarget md(TargetMetric m) =>
        macroDefaults[m] ?? const CalorieTarget(null, null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTargets)),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
        data: (targets) {
          Target rowFor(int wd) => targets.firstWhere((t) => t.weekday == wd);
          // Default-setting writer for a macro metric (kcal uses its own keys).
          void setMacroDefault(String key, double? v) =>
              db.setSetting(key, v?.toStringAsFixed(0));
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(l10n.settingsTargetsHelp),
              ),
              _MetricTargets(
                title: '${l10n.metricCalories} (${l10n.unitKcal})',
                keyPrefix: 'kcal',
                defaultMin: defaultMin,
                defaultMax: defaultMax,
                weekdayMin: (wd) => rowFor(wd).kcalMin,
                weekdayMax: (wd) => rowFor(wd).kcalMax,
                onDefaultMin: (v) =>
                    db.setSetting('defaultKcalMin', v?.toStringAsFixed(0)),
                onDefaultMax: (v) =>
                    db.setSetting('defaultKcalMax', v?.toStringAsFixed(0)),
                onWeekdayMin: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(kcalMin: Value(v))),
                onWeekdayMax: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(kcalMax: Value(v))),
              ),
              _MetricTargets(
                title: '${l10n.macroProtein} (g)',
                keyPrefix: 'protein',
                defaultMin: md(TargetMetric.protein).min,
                defaultMax: md(TargetMetric.protein).max,
                weekdayMin: (wd) => rowFor(wd).proteinMin,
                weekdayMax: (wd) => rowFor(wd).proteinMax,
                onDefaultMin: (v) => setMacroDefault('defaultProteinMin', v),
                onDefaultMax: (v) => setMacroDefault('defaultProteinMax', v),
                onWeekdayMin: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(proteinMin: Value(v))),
                onWeekdayMax: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(proteinMax: Value(v))),
              ),
              _MetricTargets(
                title: '${l10n.macroCarbs} (g)',
                keyPrefix: 'carb',
                defaultMin: md(TargetMetric.carb).min,
                defaultMax: md(TargetMetric.carb).max,
                weekdayMin: (wd) => rowFor(wd).carbMin,
                weekdayMax: (wd) => rowFor(wd).carbMax,
                onDefaultMin: (v) => setMacroDefault('defaultCarbMin', v),
                onDefaultMax: (v) => setMacroDefault('defaultCarbMax', v),
                onWeekdayMin: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(carbMin: Value(v))),
                onWeekdayMax: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(carbMax: Value(v))),
              ),
              _MetricTargets(
                title: '${l10n.macroFat} (g)',
                keyPrefix: 'fat',
                defaultMin: md(TargetMetric.fat).min,
                defaultMax: md(TargetMetric.fat).max,
                weekdayMin: (wd) => rowFor(wd).fatMin,
                weekdayMax: (wd) => rowFor(wd).fatMax,
                onDefaultMin: (v) => setMacroDefault('defaultFatMin', v),
                onDefaultMax: (v) => setMacroDefault('defaultFatMax', v),
                onWeekdayMin: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(fatMin: Value(v))),
                onWeekdayMax: (wd, v) =>
                    db.setTarget(wd, TargetsCompanion(fatMax: Value(v))),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One metric's block: a primary-colored header, the always-visible default
/// Min/Max row, then an expandable list of the 7 weekday overrides (whose hints
/// show the default they'd inherit).
class _MetricTargets extends StatelessWidget {
  final String title;
  final String keyPrefix;
  final double? defaultMin;
  final double? defaultMax;
  final double? Function(int weekday) weekdayMin;
  final double? Function(int weekday) weekdayMax;
  final ValueChanged<double?> onDefaultMin;
  final ValueChanged<double?> onDefaultMax;
  final void Function(int weekday, double? v) onWeekdayMin;
  final void Function(int weekday, double? v) onWeekdayMax;

  const _MetricTargets({
    required this.title,
    required this.keyPrefix,
    required this.defaultMin,
    required this.defaultMax,
    required this.weekdayMin,
    required this.weekdayMax,
    required this.onDefaultMin,
    required this.onDefaultMax,
    required this.onWeekdayMin,
    required this.onWeekdayMax,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        _TargetRow(
          label: l10n.settingsTargetDefault,
          keyPrefix: '$keyPrefix-default',
          initialMin: defaultMin,
          initialMax: defaultMax,
          onMin: onDefaultMin,
          onMax: onDefaultMax,
        ),
        ExpansionTile(
          leading: const Icon(Symbols.event_repeat_rounded),
          title: Text(l10n.settingsCustomizePerDay),
          subtitle: Text(l10n.settingsCustomizePerDaySub),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: [
            for (var wd = 0; wd < 7; wd++)
              _TargetRow(
                // Localized weekday name (Mon=0…Sun=6); 2024-01-01 was a Monday.
                label: DateFormat.EEEE(
                  lang,
                ).format(DateTime(2024, 1, 1).add(Duration(days: wd))),
                keyPrefix: '$keyPrefix-wd$wd',
                initialMin: weekdayMin(wd),
                initialMax: weekdayMax(wd),
                hintMin: defaultMin?.toStringAsFixed(0),
                hintMax: defaultMax?.toStringAsFixed(0),
                onMin: (v) => onWeekdayMin(wd, v),
                onMax: (v) => onWeekdayMax(wd, v),
              ),
          ],
        ),
      ],
    );
  }
}

/// A label + a Min and a Max numeric field (calories or grams).
class _TargetRow extends StatelessWidget {
  final String label;
  final String keyPrefix;
  final double? initialMin;
  final double? initialMax;
  final String? hintMin;
  final String? hintMax;
  final ValueChanged<double?> onMin;
  final ValueChanged<double?> onMax;

  const _TargetRow({
    required this.label,
    required this.keyPrefix,
    required this.initialMin,
    required this.initialMax,
    required this.onMin,
    required this.onMax,
    this.hintMin,
    this.hintMax,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 2,
            child: _TargetField(
              key: ValueKey('$keyPrefix-min'),
              initial: initialMin,
              hint: hintMin ?? l10n.settingsTargetMin,
              onChanged: onMin,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('–'),
          ),
          Expanded(
            flex: 2,
            child: _TargetField(
              key: ValueKey('$keyPrefix-max'),
              initial: initialMax,
              hint: hintMax ?? l10n.settingsTargetMax,
              onChanged: onMax,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small numeric field that reports a parsed value (or null when empty).
class _TargetField extends StatefulWidget {
  final double? initial;
  final String? hint;
  final ValueChanged<double?> onChanged;
  const _TargetField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.hint,
  });

  @override
  State<_TargetField> createState() => _TargetFieldState();
}

class _TargetFieldState extends State<_TargetField> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial == null ? '' : widget.initial!.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(isDense: true, hintText: widget.hint ?? '—'),
      onChanged: (v) {
        final parsed = v.trim().isEmpty ? null : double.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
