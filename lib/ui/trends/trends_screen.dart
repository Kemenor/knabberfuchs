import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/status_color.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Weekly / monthly calorie history against the user's target. Each day is a bar
/// colored by its own status (under / in-range / over); the target band is drawn
/// from today's resolved target as a reference.
class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(trendRangeProvider);
    final trendsAsync = ref.watch(trendsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTrends)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TrendRange>(
              segments: [
                ButtonSegment(
                  value: TrendRange.week,
                  label: Text(l10n.trendsWeek),
                ),
                ButtonSegment(
                  value: TrendRange.month,
                  label: Text(l10n.trendsMonth),
                ),
              ],
              selected: {range},
              onSelectionChanged: (s) =>
                  ref.read(trendRangeProvider.notifier).set(s.first),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: trendsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
                data: (trends) => _TrendsBody(trends: trends, range: range),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendsBody extends StatelessWidget {
  final List<DayTrend> trends;
  final TrendRange range;
  const _TrendsBody({required this.trends, required this.range});

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
              Icons.insights_outlined,
              size: 48,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 12),
            Text(l10n.trendsEmpty, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final avg =
        logged.fold<double>(0, (s, t) => s + t.kcal) / logged.length;
    final withTarget =
        trends.where((t) => t.status != TargetStatus.none).toList();
    final inTarget =
        withTarget.where((t) => t.status == TargetStatus.inRange).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(
          avgKcal: avg,
          inTarget: inTarget,
          targetedDays: withTarget.length,
        ),
        const SizedBox(height: 16),
        Expanded(child: _Chart(trends: trends, range: range)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double avgKcal;
  final int inTarget;
  final int targetedDays;
  const _SummaryCard({
    required this.avgKcal,
    required this.inTarget,
    required this.targetedDays,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget stat(String value, String label) => Column(
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
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: stat(l10n.kcalValue(kcalStr(avgKcal)), l10n.trendsAvgPerDay),
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
  final TrendRange range;
  const _Chart({required this.trends, required this.range});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final isWeek = range == TrendRange.week;
    final barWidth = isWeek ? 18.0 : 6.0;

    // The target can differ per weekday. When every day in the window shares the
    // same bounds, draw one clean reference band; when they differ (customized
    // per-day goals), draw each day's own target zone behind its bar instead, so
    // the bar colors and the target shading always agree.
    final first = trends.first.target;
    final uniformTarget = trends.every(
      (t) => t.target.min == first.min && t.target.max == first.max,
    );
    final showBand = uniformTarget && !first.isEmpty;

    final maxKcal = trends.fold<double>(0, (m, t) => t.kcal > m ? t.kcal : m);
    final maxTarget = trends.fold<double>(
      0,
      (m, t) => (t.target.max ?? 0) > m ? (t.target.max ?? 0) : m,
    );
    final maxY = (maxKcal > maxTarget ? maxKcal : maxTarget) * 1.15;
    final topY = maxY < 100 ? 100.0 : maxY;
    final interval = topY <= 2000
        ? 500.0
        : (topY <= 5000 ? 1000.0 : 2000.0);

    final lines = <HorizontalLine>[
      if (showBand && first.max != null)
        HorizontalLine(
          y: first.max!,
          color: scheme.primary.withValues(alpha: 0.7),
          strokeWidth: 1.5,
          dashArray: [5, 4],
        ),
      if (showBand && first.min != null)
        HorizontalLine(
          y: first.min!,
          color: scheme.tertiary.withValues(alpha: 0.7),
          strokeWidth: 1.5,
          dashArray: [5, 4],
        ),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        minY: 0,
        maxY: topY,
        barGroups: [
          for (var i = 0; i < trends.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: trends[i].kcal,
                  color: statusColor(scheme, trends[i].status),
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                  // Per-day target zone (only when goals vary; otherwise the
                  // single dashed band above covers it).
                  backDrawRodData: BackgroundBarChartRodData(
                    show:
                        !showBand &&
                        (trends[i].target.min != null ||
                            trends[i].target.max != null),
                    fromY: trends[i].target.min ?? 0,
                    toY: trends[i].target.max ?? topY,
                    color: scheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
        ],
        extraLinesData: ExtraLinesData(horizontalLines: lines),
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
                if (value == 0) return const SizedBox.shrink();
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= trends.length) {
                  return const SizedBox.shrink();
                }
                final date = trends[i].date;
                // Week: every weekday initial. Month: day-of-month every 5th.
                final show = isWeek || i % 5 == 0;
                if (!show) return const SizedBox.shrink();
                final label = isWeek
                    ? DateFormat('EEE', locale).format(date)
                    : DateFormat('d', locale).format(date);
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
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, _, rod, _) {
              final t = trends[group.x];
              return BarTooltipItem(
                '${DateFormat.MMMd(locale).format(t.date)}\n'
                '${AppLocalizations.of(context).kcalValue(kcalStr(t.kcal))}',
                TextStyle(color: scheme.onInverseSurface, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }
}
