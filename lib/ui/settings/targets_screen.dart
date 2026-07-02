import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/metric_labels.dart';
import '../../data/db/database.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// A weekday-override write for one bound of one metric (kcal has its own
/// setting-backed defaults, so this only covers the Targets-table columns).
TargetsCompanion _weekdayCompanion(TargetMetric m, bool isMax, double? v) {
  final val = Value(v);
  return switch ((m, isMax)) {
    (TargetMetric.kcal, false) => TargetsCompanion(kcalMin: val),
    (TargetMetric.kcal, true) => TargetsCompanion(kcalMax: val),
    (TargetMetric.protein, false) => TargetsCompanion(proteinMin: val),
    (TargetMetric.protein, true) => TargetsCompanion(proteinMax: val),
    (TargetMetric.carb, false) => TargetsCompanion(carbMin: val),
    (TargetMetric.carb, true) => TargetsCompanion(carbMax: val),
    (TargetMetric.fat, false) => TargetsCompanion(fatMin: val),
    (TargetMetric.fat, true) => TargetsCompanion(fatMax: val),
    (TargetMetric.fiber, false) => TargetsCompanion(fiberMin: val),
    (TargetMetric.fiber, true) => TargetsCompanion(fiberMax: val),
    (TargetMetric.satFat, false) => TargetsCompanion(satFatMin: val),
    (TargetMetric.satFat, true) => TargetsCompanion(satFatMax: val),
    (TargetMetric.sugar, false) => TargetsCompanion(sugarMin: val),
    (TargetMetric.sugar, true) => TargetsCompanion(sugarMax: val),
    (TargetMetric.salt, false) => TargetsCompanion(saltMin: val),
    (TargetMetric.salt, true) => TargetsCompanion(saltMax: val),
  };
}

/// Settings → Targets. A "Tracked nutrients" chip row picks which nutrients
/// are on (kcal is fixed; toggling off hides the block but keeps its bounds),
/// then one block per enabled metric: an always-visible app-wide default
/// Min/Max and an independently expandable per-weekday breakdown. Every bound
/// is optional.
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
    final tracked =
        ref.watch(trackedNutrientsProvider).asData?.value ??
        defaultTrackedNutrients;
    CalorieTarget md(TargetMetric m) =>
        macroDefaults[m] ?? const CalorieTarget(null, null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTargets)),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
        data: (targets) {
          Target rowFor(int wd) => targets.firstWhere((t) => t.weekday == wd);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.settingsTrackedNutrients,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  l10n.settingsTrackedNutrientsSub,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in TargetMetric.values)
                      if (m != TargetMetric.kcal)
                        FilterChip(
                          label: Text(metricLabel(l10n, m)),
                          selected: tracked.contains(m),
                          onSelected: (on) => setTrackedNutrients(db, {
                            ...tracked.where((t) => t != m),
                            if (on) m,
                          }),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(l10n.settingsTargetsHelp),
              ),
              // kcal first (always on), then the enabled nutrients.
              for (final m in TargetMetric.values)
                if (m == TargetMetric.kcal || tracked.contains(m))
                  _MetricTargets(
                    title: m == TargetMetric.kcal
                        ? '${l10n.metricCalories} (${l10n.unitKcal})'
                        : '${metricLabel(l10n, m)} (g)',
                    keyPrefix: m.name,
                    defaultMin: m == TargetMetric.kcal
                        ? defaultMin
                        : md(m).min,
                    defaultMax: m == TargetMetric.kcal
                        ? defaultMax
                        : md(m).max,
                    weekdayMin: (wd) => targetRowBounds(rowFor(wd), m).$1,
                    weekdayMax: (wd) => targetRowBounds(rowFor(wd), m).$2,
                    onDefaultMin: (v) => db.setSetting(
                      defaultSettingKey(m, max: false),
                      v?.toStringAsFixed(0),
                    ),
                    onDefaultMax: (v) => db.setSetting(
                      defaultSettingKey(m, max: true),
                      v?.toStringAsFixed(0),
                    ),
                    onWeekdayMin: (wd, v) =>
                        db.setTarget(wd, _weekdayCompanion(m, false, v)),
                    onWeekdayMax: (wd, v) =>
                        db.setTarget(wd, _weekdayCompanion(m, true, v)),
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
          metric: title,
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
                metric: title,
                // Localized weekday name (Mon=0…Sun=6); 2024-01-01 was a Monday.
                label: DateFormat.EEEE(
                  lang,
                ).format(DateTime(2024, 1, 1 + wd)),
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
  final String metric;
  final String label;
  final String keyPrefix;
  final double? initialMin;
  final double? initialMax;
  final String? hintMin;
  final String? hintMax;
  final ValueChanged<double?> onMin;
  final ValueChanged<double?> onMax;

  const _TargetRow({
    required this.metric,
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
              semanticLabel: '$metric, $label, ${l10n.settingsTargetMin}',
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
              semanticLabel: '$metric, $label, ${l10n.settingsTargetMax}',
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
  final String? semanticLabel;
  final ValueChanged<double?> onChanged;
  const _TargetField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.hint,
    this.semanticLabel,
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
    return Semantics(
      textField: true,
      label: widget.semanticLabel,
      child: TextField(
        controller: _c,
        textAlign: TextAlign.end,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(isDense: true, hintText: widget.hint ?? '—'),
        onChanged: (v) {
          final parsed = v.trim().isEmpty ? null : double.tryParse(v.trim());
          widget.onChanged(parsed);
        },
      ),
    );
  }
}
