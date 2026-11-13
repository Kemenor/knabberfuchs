import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../domain/weight.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'weight_format.dart';
import 'weight_settings_screen.dart';
import 'weight_sheet.dart';

/// "See trend →": Trends · Weight — the Trends tab when it's shown, else a
/// screen of its own (Trends can be hidden; weight still has its view).
void openWeightTrend(BuildContext context, WidgetRef ref) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst);
  if (ref.read(showTrendsProvider).asData?.value ?? true) {
    ref.read(trendsViewProvider.notifier).set(TrendsView.weight);
    ref.read(homeTabProvider.notifier).set(HomeTab.trends);
  } else {
    nav.push(MaterialPageRoute(builder: (_) => const WeightTrendScreen()));
  }
}

/// The weight view as its own screen (Trends tab hidden).
class WeightTrendScreen extends ConsumerWidget {
  const WeightTrendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.weightTitle)),
      body: const WeightTrendView(),
      floatingActionButton: AddWeightFab(heroTag: 'weightScreenAdd'),
    );
  }
}

/// "Add weight" — logs for today.
class AddWeightFab extends ConsumerWidget {
  const AddWeightFab({super.key, required this.heroTag});
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: () => showWeightSheet(context, ref, day: DayKey.today()),
        icon: const Icon(Symbols.add_rounded),
        label: Text(AppLocalizations.of(context).weightAdd),
      );
}

/// Trends · Weight (PLAN B.5): the 7-day average leads; cards, a chart of
/// faded daily dots under the bold average line with dashed milestones, and
/// a calendar-week list that opens to its days.
class WeightTrendView extends ConsumerWidget {
  const WeightTrendView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final series = ref.watch(weightSeriesProvider);
    if (series.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.monitor_weight_rounded,
                size: 48,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 12),
              Text(l10n.weightEmpty, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    final unit = ref.watch(weightUnitProvider).asData?.value ?? WeightUnit.kg;
    final goals = ref.watch(weightGoalsProvider).asData?.value ?? const [];
    final height = ref.watch(heightCmProvider).asData?.value;
    final range = ref.watch(weightRangeProvider);
    final today = DayKey.today();
    final latestDay = series.latestUpTo(today) ?? series.days.last;
    // The trend "now": today's 7-day average, or the last one there was.
    final trendDay = series.averageAt(today) != null ? today : latestDay;
    final trend = series.averageAt(trendDay);
    final direction = weightDirection(goals, trend);
    final milestones = weightMilestones(
      goals: goals,
      trend: trend,
      heightCm: height,
    );
    final rangeStart = range.days == null
        ? series.days.first
        : DayKey.shift(today, -(range.days! - 1));
    final firstWeekday = switch (MaterialLocalizations.of(
      context,
    ).firstDayOfWeekIndex) {
      0 => DateTime.sunday,
      final i => i,
    };
    final weeks = calendarWeeks(
      series,
      today: today,
      from: rangeStart.compareTo(series.days.first) < 0
          ? series.days.first
          : rangeStart,
      firstWeekday: firstWeekday,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        SegmentedButton<WeightRange>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: WeightRange.month,
              label: Text(l10n.weightRange1M),
            ),
            ButtonSegment(
              value: WeightRange.quarter,
              label: Text(l10n.weightRange3M),
            ),
            ButtonSegment(
              value: WeightRange.year,
              label: Text(l10n.weightRange1Y),
            ),
            ButtonSegment(
              value: WeightRange.all,
              label: Text(l10n.weightRangeAll),
            ),
          ],
          selected: {range},
          onSelectionChanged: (s) =>
              ref.read(weightRangeProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 12),
        _Cards(
          series: series,
          unit: unit,
          trend: trend,
          trendDay: trendDay,
          latestDay: latestDay,
          direction: direction,
          milestones: milestones,
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: _WeightChart(
                    series: series,
                    start: rangeStart,
                    end: today,
                    unit: unit,
                    milestones: milestones,
                    direction: direction,
                  ),
                ),
                const SizedBox(height: 8),
                _Legend(showMilestones: milestones.isNotEmpty),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.weightWeeks, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final w in weeks)
                _WeekTile(
                  week: w,
                  series: series,
                  unit: unit,
                  direction: direction,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cards extends ConsumerWidget {
  const _Cards({
    required this.series,
    required this.unit,
    required this.trend,
    required this.trendDay,
    required this.latestDay,
    required this.direction,
    required this.milestones,
  });

  final WeightSeries series;
  final WeightUnit unit;
  final double? trend;
  final String trendDay;
  final String latestDay;
  final WeightDirection direction;
  final List<WeightMilestone> milestones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final week = series.weekChangeAt(trendDay);
    final first = series.firstAverage;
    final latest = series.daily[latestDay]!;

    final avgCard = _StatCard(
      label: l10n.weightCardAverage,
      value: trend == null ? '—' : weightText(l10n, trend!, unit),
      sub: week == null
          ? (trend == null ? l10n.weightNoAverageYet : null)
          : l10n.weightVsLastWeek(weightChangeText(l10n, week, unit)),
      subColor: week == null
          ? null
          : towardColor(context, isToward(week, direction)),
      big: true,
    );
    final latestCard = _StatCard(
      label: l10n.weightCardLatest,
      value: weightText(l10n, latest, unit),
      sub: dayLabel(context, latestDay),
    );
    final since = trend != null && first != null ? trend! - first.kg : null;
    final sinceCard = _StatCard(
      label: l10n.weightCardSinceStart,
      value: since == null ? '—' : weightChangeText(l10n, since, unit),
      valueColor: since == null
          ? null
          : towardColor(context, isToward(since, direction)),
      sub: first == null
          ? null
          : l10n.weightSinceFrom(
              weightText(l10n, first.kg, unit),
              DateFormat.yMMMd(locale).format(DayKey.parse(first.day)),
            ),
    );

    final Widget goalCard;
    if (direction == WeightDirection.none || trend == null) {
      goalCard = _StatCard(
        label: l10n.weightCardGoal,
        value: l10n.weightNoGoal,
        sub: l10n.weightSetGoal,
        subColor: Theme.of(context).colorScheme.secondary,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WeightSettingsScreen())),
      );
    } else {
      final next = nextMilestone(milestones, trend!, direction);
      if (next == null) {
        goalCard = _StatCard(
          label: l10n.weightCardNext,
          value: l10n.weightGoalReached,
        );
      } else {
        final eta = weeksToMilestone(series, trendDay, next.kg, direction);
        final toGo = l10n.weightToGo(
          weightText(l10n, (trend! - next.kg).abs(), unit),
        );
        goalCard = _StatCard(
          label: l10n.weightCardNext,
          value: weightText(l10n, next.kg, unit),
          tag: milestoneLabel(l10n, next, direction),
          sub: eta == null ? toGo : '$toGo · ${l10n.weightEta(eta)}',
        );
      }
    }

    Widget pair(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      ),
    );
    return Column(
      children: [
        pair(avgCard, latestCard),
        const SizedBox(height: 8),
        pair(sinceCard, goalCard),
      ],
    );
  }
}

/// "Goal", "BMI < 30", or null for a plain milestone.
String? milestoneLabel(
  AppLocalizations l10n,
  WeightMilestone m,
  WeightDirection direction,
) {
  if (m.isGoal) return l10n.weightGoalLabel;
  final bmi = m.bmi;
  if (bmi == null) return null;
  final v = NumberFormat.decimalPattern(l10n.localeName).format(bmi);
  return direction == WeightDirection.gain
      ? l10n.weightBmiAtLeast(v)
      : l10n.weightBmiUnder(v);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    this.tag,
    this.valueColor,
    this.subColor,
    this.big = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String? sub;
  final String? tag;
  final Color? valueColor;
  final Color? subColor;
  final bool big;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.outline;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style:
                      (big
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: valueColor,
                          ),
                ),
              ),
              if (tag != null)
                Text(
                  tag!,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(
                  sub!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subColor ?? muted,
                    fontWeight: subColor != null ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.showMilestones});
  final bool showMilestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.bodySmall?.copyWith(color: scheme.outline);
    Widget item(Widget mark, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        item(
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.outline.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
          ),
          l10n.weightLegendWeighIn,
        ),
        item(
          Container(width: 16, height: 3, color: scheme.primary),
          l10n.weightCardAverage,
        ),
        if (showMilestones)
          item(
            SizedBox(
              width: 16,
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Container(width: 4, height: 2, color: scheme.secondary),
                    if (i < 2) const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
            l10n.weightLegendMilestones,
          ),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.series,
    required this.start,
    required this.end,
    required this.unit,
    required this.milestones,
    required this.direction,
  });

  final WeightDirection direction;
  final WeightSeries series;
  final String start;
  final String end;
  final WeightUnit unit;
  final List<WeightMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final days = <String>[
      for (var d = start; d.compareTo(end) <= 0; d = DayKey.shift(d, 1)) d,
    ];
    final n = days.length;
    final dots = <FlSpot>[];
    final avg = <FlSpot>[];
    final values = <double>[];
    for (var i = 0; i < n; i++) {
      final v = series.daily[days[i]];
      if (v != null) {
        final y = unit.fromKg(v);
        dots.add(FlSpot(i.toDouble(), y));
        values.add(y);
      }
      final a = series.averageAt(days[i]);
      avg.add(
        a == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), unit.fromKg(a)),
      );
    }
    if (values.isEmpty) {
      return Center(
        child: Text(
          l10n.weightEmptyRange,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      );
    }
    final lo0 = values.reduce(math.min);
    final hi0 = values.reduce(math.max);
    // Milestones just outside the data still show if they're close (the next
    // one usually is); far ones would flatten the line.
    final pad = math.max(1.0, (hi0 - lo0) * 0.15);
    final shown = [
      for (final m in milestones)
        if (unit.fromKg(m.kg) >= lo0 - pad * 2 &&
            unit.fromKg(m.kg) <= hi0 + pad * 2)
          m,
    ];
    final ys = [...values, for (final m in shown) unit.fromKg(m.kg)];
    final minY = (ys.reduce(math.min) - pad / 2).floorToDouble();
    final maxY = (ys.reduce(math.max) + pad / 2).ceilToDouble();
    final span = maxY - minY;
    final interval = span <= 4
        ? 1.0
        : span <= 10
        ? 2.0
        : span <= 25
        ? 5.0
        : 10.0;

    final lastDot = dots.last;

    return Semantics(
      label: l10n.a11yWeightChart,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, n - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          lineBarsData: [
            // Daily weigh-ins: faded dots, no line.
            LineChartBarData(
              spots: dots,
              barWidth: 0,
              color: Colors.transparent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: spot == lastDot ? 4.5 : (n > 120 ? 1.8 : 2.8),
                  color: spot == lastDot
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: 0.45),
                  strokeWidth: spot == lastDot ? 2 : 0,
                  strokeColor: scheme.surface,
                ),
              ),
            ),
            // The 7-day average: the line that matters.
            LineChartBarData(
              spots: avg,
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: scheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              for (final m in shown)
                HorizontalLine(
                  y: unit.fromKg(m.kg),
                  color: scheme.secondary.withValues(alpha: 0.8),
                  strokeWidth: 1.2,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 4, bottom: 2),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.secondary,
                    ),
                    labelResolver: (_) {
                      final tag = milestoneLabel(l10n, m, direction);
                      final w = weightText(l10n, m.kg, unit);
                      return tag == null ? w : '$w · $tag';
                    },
                  ),
                ),
            ],
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.round().toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if ((value - i).abs() > 0.01) return const SizedBox.shrink();
                  // Three labels: start, middle, today.
                  final mid = (n - 1) ~/ 2;
                  if (i != 0 && i != mid && i != n - 1) {
                    return const SizedBox.shrink();
                  }
                  final date = DayKey.parse(days[i]);
                  final label = DateFormat(
                    n > 400 ? 'MMM yy' : 'd MMM',
                    locale,
                  ).format(date);
                  return SideTitleWidget(
                    meta: meta,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (touched) => [
                for (final s in touched)
                  LineTooltipItem(
                    s.barIndex == 0
                        ? '${DateFormat.MMMd(locale).format(DayKey.parse(days[s.x.round()]))}\n'
                              '${l10n.weightValue(macroStr(s.y), weightUnitLabel(l10n, unit))}'
                        : '${l10n.weightCardAverage}: '
                              '${l10n.weightValue(macroStr(s.y), weightUnitLabel(l10n, unit))}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    required this.week,
    required this.series,
    required this.unit,
    required this.direction,
  });

  final WeightWeek week;
  final WeightSeries series;
  final WeightUnit unit;
  final WeightDirection direction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final fmt = DateFormat.MMMd(locale);
    final range =
        '${fmt.format(DayKey.parse(week.start))} – '
        '${fmt.format(DayKey.parse(DayKey.shift(week.start, 6)))}';
    final change = week.change;
    return ExpansionTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(week.isCurrent ? l10n.weightSoFar(range) : range),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            week.mean == null ? '—' : weightText(l10n, week.mean!, unit),
            style: theme.textTheme.titleSmall,
          ),
          if (change != null) ...[
            const SizedBox(width: 8),
            Text(
              weightChangeText(l10n, change, unit),
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    towardColor(context, isToward(change, direction)) ??
                    theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(width: 4),
          Icon(Symbols.expand_more_rounded, color: theme.colorScheme.outline),
        ],
      ),
      children: [
        for (final d in week.days.reversed)
          Consumer(
            builder: (context, ref, _) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(dayLabel(context, d)),
              trailing: Text(
                series.daily[d] == null
                    ? '—'
                    : weightText(l10n, series.daily[d]!, unit),
              ),
              onTap: () => showWeightSheet(context, ref, day: d),
            ),
          ),
      ],
    );
  }
}
