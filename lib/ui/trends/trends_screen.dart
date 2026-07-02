import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/format.dart';
import '../../core/metric_labels.dart';
import '../../core/status_color.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Intake history for the chosen metric (calories or a macro) against the
/// user's target: a line of daily values over a shaded target band, each day's
/// dot colored by its status (under / in-range / over). A metric toggle picks
/// kcal/P/C/F; Week / Month / a custom range steps through periods.
class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = ref.watch(trendRangeProvider);
    final tracked =
        ref.watch(trackedNutrientsProvider).asData?.value ??
        defaultTrackedNutrients;
    // A selection whose nutrient was since disabled falls back to kcal (the
    // provider applies the same coercion to the charted series).
    final selected = ref.watch(selectedTrendMetricProvider);
    final metric =
        selected == TargetMetric.kcal || tracked.contains(selected)
        ? selected
        : TargetMetric.kcal;
    final trendsAsync = ref.watch(trendsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTrends)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable single-select chips: kcal + the enabled nutrients.
            // (Replaced the 4-slot SegmentedButton when the metric list became
            // user-configurable — Phase 15.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final m in TargetMetric.values)
                    if (m == TargetMetric.kcal || tracked.contains(m))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            m == TargetMetric.kcal
                                ? l10n.unitKcal
                                : metricLabel(l10n, m),
                          ),
                          selected: metric == m,
                          onSelected: (_) => ref
                              .read(selectedTrendMetricProvider.notifier)
                              .set(m),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TrendMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TrendMode.week,
                  label: Text(l10n.trendsWeek),
                ),
                ButtonSegment(
                  value: TrendMode.month,
                  label: Text(l10n.trendsMonth),
                ),
                ButtonSegment(
                  value: TrendMode.custom,
                  label: Text(l10n.trendsCustom),
                ),
              ],
              selected: {window.mode},
              onSelectionChanged: (s) {
                final notifier = ref.read(trendRangeProvider.notifier);
                if (s.first != TrendMode.custom) {
                  notifier.setMode(s.first);
                  return;
                }
                // Reuse the last custom range if there is one; otherwise pick.
                final saved = notifier.savedCustom;
                if (saved != null) {
                  notifier.setCustom(saved.start, saved.end);
                } else {
                  pickCustomRange(context, ref, window);
                }
              },
            ),
            const SizedBox(height: 8),
            _RangeHeader(window: window),
            const SizedBox(height: 8),
            Expanded(
              child: trendsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
                data: (trends) => _TrendsBody(trends: trends, metric: metric),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Open the system date-range picker and store the chosen custom range; leaves
/// the window unchanged if the user cancels.
Future<void> pickCustomRange(
  BuildContext context,
  WidgetRef ref,
  TrendWindow current,
) async {
  final now = DateTime.now();
  final last = DateTime(now.year, now.month, now.day);
  DateTime clamp(DateTime d) => d.isAfter(last) ? last : d;
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: last,
    initialDateRange: DateTimeRange(
      start: clamp(current.start),
      end: clamp(current.end),
    ),
  );
  if (picked != null) {
    ref.read(trendRangeProvider.notifier).setCustom(picked.start, picked.end);
  }
}

/// The current period's date label, with prev/next arrows for week/month. In
/// custom mode the label is a button that re-opens the range picker.
class _RangeHeader extends ConsumerWidget {
  final TrendWindow window;
  const _RangeHeader({required this.window});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final label = _rangeLabel(window.start, window.end, locale);

    if (window.mode == TrendMode.custom) {
      return Center(
        child: TextButton.icon(
          icon: const Icon(Symbols.edit_calendar_rounded, size: 18),
          label: Text(label),
          onPressed: () => pickCustomRange(context, ref, window),
        ),
      );
    }
    final notifier = ref.read(trendRangeProvider.notifier);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Symbols.chevron_left_rounded),
          tooltip: AppLocalizations.of(context).a11yPreviousPeriod,
          onPressed: notifier.older,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
        ),
        IconButton(
          icon: const Icon(Symbols.chevron_right_rounded),
          tooltip: AppLocalizations.of(context).a11yNextPeriod,
          onPressed: window.isCurrent ? null : notifier.newer,
        ),
      ],
    );
  }
}

String _rangeLabel(DateTime s, DateTime e, String locale) {
  final fmt = s.year == e.year
      ? DateFormat.MMMd(locale)
      : DateFormat.yMMMd(locale);
  return '${fmt.format(s)} – ${fmt.format(e)}';
}

/// Format a metric value with its unit: "1850 kcal" for calories, "82 g" for a
/// macro.
String _metricValue(AppLocalizations l10n, TargetMetric m, double v) =>
    m == TargetMetric.kcal ? l10n.kcalValue(kcalStr(v)) : '${macroStr(v)} g';

/// A "nice" y-axis gridline interval (~≤6 lines) that suits both the kcal range
/// (thousands) and macro grams (tens to low hundreds).
double _niceInterval(double topY) {
  const List<double> steps = [10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000];
  for (final s in steps) {
    if (topY / s <= 6) return s;
  }
  return 10000;
}

class _TrendsBody extends StatelessWidget {
  final List<DayTrend> trends;
  final TargetMetric metric;
  const _TrendsBody({required this.trends, required this.metric});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final logged = trends.where((t) => t.kcal > 0).toList();

    if (logged.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.insights_rounded,
              size: 48,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 12),
            Text(l10n.trendsEmpty, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Summary is computed on the daily data; the chart collapses long ranges
    // into weekly buckets so they stay readable.
    final avg = logged.fold<double>(0, (s, t) => s + t.kcal) / logged.length;
    final withTarget =
        trends.where((t) => t.status != TargetStatus.none).toList();
    final inTarget =
        withTarget.where((t) => t.status == TargetStatus.inRange).length;
    final bucket = trendBucketFor(trends.length);
    final points = bucketTrends(trends);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(
          avgKcal: avg,
          inTarget: inTarget,
          targetedDays: withTarget.length,
          metric: metric,
        ),
        const SizedBox(height: 12),
        if (bucket != TrendBucket.daily) ...[
          Text(
            bucket == TrendBucket.monthly
                ? l10n.trendsMonthlyAvg
                : l10n.trendsWeeklyAvg,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Expanded(child: _Chart(trends: points, bucket: bucket, metric: metric)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double avgKcal;
  final int inTarget;
  final int targetedDays;
  final TargetMetric metric;
  const _SummaryCard({
    required this.avgKcal,
    required this.inTarget,
    required this.targetedDays,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget stat(String value, String label) => MergeSemantics(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: stat(
                _metricValue(l10n, metric, avgKcal),
                l10n.trendsAvgPerDay,
              ),
            ),
            if (targetedDays > 0)
              Expanded(
                child: stat('$inTarget / $targetedDays', l10n.trendsDaysInTarget),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<DayTrend> trends;
  final TrendBucket bucket;
  final TargetMetric metric;
  const _Chart({
    required this.trends,
    required this.bucket,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    // Label/dot density adapts to how many days are shown (week vs a long range).
    final dense = trends.length > 8;
    final labelStep = dense ? (trends.length / 6).ceil() : 1;
    final hasTarget = trends.any((t) => !t.target.isEmpty);

    final maxValue = trends.fold<double>(0, (m, t) => t.kcal > m ? t.kcal : m);
    final maxTarget = trends.fold<double>(
      0,
      (m, t) => (t.target.max ?? 0) > m ? (t.target.max ?? 0) : m,
    );
    final rawMax = maxValue > maxTarget ? maxValue : maxTarget;
    // Floor so an empty/low chart isn't degenerate — kcal sits in the
    // thousands, macros in the tens, salt in single grams.
    final topY = rawMax <= 0
        ? switch (metric) {
            TargetMetric.kcal => 100.0,
            TargetMetric.salt => 5.0,
            _ => 50.0,
          }
        : rawMax * 1.15;
    final interval = _niceInterval(topY);

    // Intake line — a gap (null spot) on un-logged days so the line breaks
    // rather than dropping to zero.
    final intake = [
      for (var i = 0; i < trends.length; i++)
        trends[i].kcal > 0
            ? FlSpot(i.toDouble(), trends[i].kcal)
            : FlSpot.nullSpot,
    ];
    // The target band: a filled area between each day's min and max — flat when
    // goals are uniform, sloped when they vary per weekday. Days without a goal
    // break the band. Always visible (it sits behind the line), so overshooting
    // never hides it.
    FlSpot edge(int i, double? bound, double fallback) => trends[i].target.isEmpty
        ? FlSpot.nullSpot
        : FlSpot(i.toDouble(), bound ?? fallback);
    final bandMin = [
      for (var i = 0; i < trends.length; i++) edge(i, trends[i].target.min, 0),
    ];
    final bandMax = [
      for (var i = 0; i < trends.length; i++)
        edge(i, trends[i].target.max, topY),
    ];

    return Semantics(
      label: l10n.a11yTrendsChart,
      child: LineChart(
      LineChartData(
        minX: -0.4,
        maxX: trends.length - 1 + 0.4,
        minY: 0,
        maxY: topY,
        lineBarsData: [
          // Intake line, dots colored by that day's status.
          LineChartBarData(
            spots: intake,
            isCurved: false,
            color: scheme.outline,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, index) => FlDotCirclePainter(
                radius: dense ? 2.5 : 4.5,
                color: statusColor(context, trends[spot.x.round()].status),
                strokeWidth: 0,
              ),
            ),
          ),
          // Invisible band edges — only the fill between them shows.
          if (hasTarget) ...[
            LineChartBarData(
              spots: bandMin,
              barWidth: 0,
              color: Colors.transparent,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: bandMax,
              barWidth: 0,
              color: Colors.transparent,
              dotData: const FlDotData(show: false),
            ),
          ],
        ],
        betweenBarsData: [
          if (hasTarget)
            BetweenBarsData(
              fromIndex: 1,
              toIndex: 2,
              color: scheme.primary.withValues(alpha: 0.13),
            ),
        ],
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
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value <= 0 || value > topY) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
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
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= trends.length || (value - i).abs() > 0.01) {
                  return const SizedBox.shrink();
                }
                // Short ranges show weekday initials; longer ones thin out to
                // ~6 labels, anchored from the right so the latest day (the
                // focal point) is always labeled.
                if ((trends.length - 1 - i) % labelStep != 0) {
                  return const SizedBox.shrink();
                }
                final date = trends[i].date;
                final label = switch (bucket) {
                  // Months by name (with year if the range spans years).
                  TrendBucket.monthly => DateFormat(
                    trends.first.date.year != trends.last.date.year
                        ? 'MMM yy'
                        : 'MMM',
                    locale,
                  ).format(date),
                  TrendBucket.weekly => DateFormat('d/M', locale).format(date),
                  TrendBucket.daily => dense
                      ? DateFormat('d/M', locale).format(date)
                      : DateFormat('EEE', locale).format(date),
                };
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
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
                if (s.barIndex == 0)
                  LineTooltipItem(
                    '${DateFormat.MMMd(locale).format(trends[s.x.round()].date)}\n'
                    '${_metricValue(l10n, metric, trends[s.x.round()].kcal)}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                  )
                else
                  null,
            ],
          ),
        ),
      ),
      ),
    );
  }
}
