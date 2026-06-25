import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/status_color.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Calorie history against the user's target: a line of daily intake over a
/// shaded target band, each day's dot colored by its status (under / in-range /
/// over). Pick Week / Month / a custom range, and step through periods.
class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = ref.watch(trendRangeProvider);
    final trendsAsync = ref.watch(trendsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTrends)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                if (s.first == TrendMode.custom) {
                  pickCustomRange(context, ref, window);
                } else {
                  ref.read(trendRangeProvider.notifier).setMode(s.first);
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
                data: (trends) => _TrendsBody(trends: trends),
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
          icon: const Icon(Icons.edit_calendar_outlined, size: 18),
          label: Text(label),
          onPressed: () => pickCustomRange(context, ref, window),
        ),
      );
    }
    final notifier = ref.read(trendRangeProvider.notifier);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
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
          icon: const Icon(Icons.chevron_right),
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

class _TrendsBody extends StatelessWidget {
  final List<DayTrend> trends;
  const _TrendsBody({required this.trends});

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
        Expanded(child: _Chart(trends: trends)),
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
  const _Chart({required this.trends});

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

    return LineChart(
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
                color: statusColor(scheme, trends[spot.x.round()].status),
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
                final label = dense
                    ? DateFormat('d/M', locale).format(trends[i].date)
                    : DateFormat('EEE', locale).format(trends[i].date);
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
                    '${l10n.kcalValue(kcalStr(trends[s.x.round()].kcal))}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                  )
                else
                  null,
            ],
          ),
        ),
      ),
    );
  }
}
