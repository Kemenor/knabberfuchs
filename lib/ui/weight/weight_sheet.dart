import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/snackbar.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/weight.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'weight_format.dart';
import 'weight_trend_view.dart';

/// The Weight sheet for [day] (PLAN Part B.3): log a weigh-in, see the day's
/// weigh-ins and pick which one counts, edit or remove them. Opened from the
/// Day row, the Trends "Add weight" FAB and a Trends week's day rows.
Future<void> showWeightSheet(
  BuildContext context,
  WidgetRef ref, {
  required String day,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => WeightSheet(day: day),
);

class WeightSheet extends ConsumerStatefulWidget {
  const WeightSheet({super.key, required this.day});
  final String day;

  @override
  ConsumerState<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<WeightSheet> {
  final _value = TextEditingController();
  late TimeOfDay _time;

  /// The weigh-in being edited (made in the app); null = adding a new one.
  BodyMeasurement? _editing;

  @override
  void initState() {
    super.initState();
    // Today: now. Another day (a forgotten weigh-in): the morning.
    _time = widget.day == DayKey.today()
        ? TimeOfDay.now()
        : const TimeOfDay(hour: 8, minute: 0);
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  double? get _parsed {
    final v = double.tryParse(_value.text.trim().replaceAll(',', '.'));
    return v == null || v <= 0 || v >= 1000 ? null : v;
  }

  DateTime _at(TimeOfDay t) {
    final d = DayKey.parse(widget.day);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _save(WeightUnit unit) async {
    final v = _parsed;
    if (v == null) return;
    final db = ref.read(dbProvider);
    final health = ref.read(healthServiceProvider);
    final kg = unit.toKg(v);
    final at = _at(_time);
    final editing = _editing;
    if (mounted) Navigator.pop(context);
    if (editing != null) {
      await db.updateWeight(editing.id, day: widget.day, at: at, kg: kg);
      // Health copy (with "Write my weights" on): replace it.
      await health.maybeDeleteWeight(editing.measuredAt);
    } else {
      await db.addWeight(day: widget.day, at: at, kg: kg);
    }
    await health.maybeWriteWeight(at, kg);
  }

  void _startEdit(BodyMeasurement row, WeightUnit unit) {
    setState(() {
      _editing = row;
      _value.text = weightNumber(row.value, unit);
      _time = TimeOfDay.fromDateTime(row.measuredAt);
    });
  }

  Future<void> _remove(BodyMeasurement row) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(dbProvider);
    if (_editing?.id == row.id) {
      setState(() {
        _editing = null;
        _value.clear();
      });
    }
    final health = ref.read(healthServiceProvider);
    final manual = row.source == MeasurementSource.manual;
    await db.removeWeight(row.id);
    // Made here → its Health copy goes too; from Health → only hidden here.
    if (manual) await health.maybeDeleteWeight(row.measuredAt);
    messenger.showAutoSnackBar(
      SnackBar(
        content: Text(l10n.weightRemoved),
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () async {
            await db.restoreWeight(row);
            if (manual) {
              await health.maybeWriteWeight(row.measuredAt, row.value);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(weightUnitProvider).asData?.value ?? WeightUnit.kg;
    final rows =
        ref.watch(dayWeighInsProvider(widget.day)).asData?.value ?? const [];
    final counting = countingWeighIn(rows);
    final avg = ref.watch(weightSeriesProvider).averageAt(widget.day);
    final locale = Localizations.localeOf(context).languageCode;
    final today = DayKey.today();
    // "Today, 13 Nov" — dayLabel already carries the date for other days.
    final dateLine =
        widget.day == today || widget.day == DayKey.shift(today, -1)
        ? l10n.weightSheetDate(
            dayLabel(context, widget.day),
            DateFormat.MMMd(locale).format(DayKey.parse(widget.day)),
          )
        : dayLabel(context, widget.day);
    final ready = _parsed != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.weightTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                dateLine,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _value,
                autofocus: rows.isEmpty,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(unit),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Symbols.monitor_weight_rounded),
                  suffixText: weightUnitLabel(l10n, unit),
                  labelText: _editing == null
                      ? l10n.weightTitle
                      : l10n.weightEditing(
                          TimeOfDay.fromDateTime(
                            _editing!.measuredAt,
                          ).format(context),
                        ),
                ),
              ),
              Row(
                children: [
                  Text(
                    l10n.weightTime(_time.format(context)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (t != null) setState(() => _time = t);
                    },
                    child: Text(l10n.weightChangeTime),
                  ),
                ],
              ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(l10n.weightWeighIns, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final r in rows)
                        _WeighInTile(
                          row: r,
                          unit: unit,
                          counts: r.id == counting?.id,
                          editing: r.id == _editing?.id,
                          onCount: () =>
                              ref.read(dbProvider).setCountsForDay(r.id),
                          onEdit: () => _startEdit(r, unit),
                          onRemove: () => _remove(r),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (avg != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.weightSheetAverage(weightText(l10n, avg, unit)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => openWeightTrend(context, ref),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Symbols.arrow_forward_rounded, size: 18),
                      label: Text(l10n.weightSeeTrend),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: ready ? () => _save(unit) : null,
                icon: const Icon(Symbols.check_rounded),
                label: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One weigh-in in the sheet: value, "counts" marker, time · source, ⋮.
class _WeighInTile extends StatelessWidget {
  const _WeighInTile({
    required this.row,
    required this.unit,
    required this.counts,
    required this.editing,
    required this.onCount,
    required this.onEdit,
    required this.onRemove,
  });

  final BodyMeasurement row;
  final WeightUnit unit;
  final bool counts;
  final bool editing;
  final VoidCallback onCount;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fromHealth = row.source == MeasurementSource.health;
    final time = TimeOfDay.fromDateTime(row.measuredAt).format(context);
    final source = fromHealth
        ? l10n.weightSourceHealth(
            Platform.isIOS ? 'Apple Health' : 'Health Connect',
          )
        : l10n.weightSourceHere;
    return ListTile(
      selected: editing,
      leading: Icon(
        counts ? Symbols.check_circle_rounded : Symbols.schedule_rounded,
        color: counts ? scheme.tertiary : scheme.outline,
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(weightText(l10n, row.value, unit)),
          if (counts)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                row.countsForDay
                    ? l10n.weightCountsChosen
                    : l10n.weightCountsFirst,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text('$time · $source'),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Symbols.more_vert_rounded, size: 20),
        onSelected: (v) => switch (v) {
          'count' => onCount(),
          'edit' => onEdit(),
          _ => onRemove(),
        },
        itemBuilder: (_) => [
          if (!counts)
            PopupMenuItem(value: 'count', child: Text(l10n.weightCountThis)),
          // Health owns the numbers it wrote: hide them, don't edit them.
          if (!fromHealth)
            PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
          PopupMenuItem(value: 'remove', child: Text(l10n.weightRemove)),
        ],
      ),
    );
  }
}
