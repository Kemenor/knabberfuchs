import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../domain/weight.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'weight_format.dart';
import 'weight_sheet.dart';

/// The weight row at the foot of the Day summary card (PLAN B.3): the trend
/// leads — "87.0 kg 7-day · −0.5 kg this week" — with the day's own weigh-in
/// small underneath, or "Add today's weight" before it. Tap → Weight sheet.
/// Renders nothing while "Track weight" is off.
class WeightDayRow extends ConsumerWidget {
  const WeightDayRow({super.key, required this.day});
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(trackWeightProvider).asData?.value ?? false)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(weightUnitProvider).asData?.value ?? WeightUnit.kg;
    final series = ref.watch(weightSeriesProvider);
    final goals = ref.watch(weightGoalsProvider).asData?.value ?? const [];
    final counting = countingWeighIn(
      ref.watch(dayWeighInsProvider(day)).asData?.value ?? const [],
    );
    final avg = series.averageAt(day);
    final change = series.weekChangeAt(day);
    final direction = weightDirection(goals, avg);
    final today = day == DayKey.today();

    final big = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final small = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
    );
    final Widget top = avg != null
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: weightText(l10n, avg, unit), style: big),
                TextSpan(text: ' ${l10n.weightSevenDay}', style: small),
                if (change != null) ...[
                  TextSpan(text: ' · ', style: small),
                  TextSpan(
                    text: l10n.weightThisWeek(
                      weightChangeText(l10n, change, unit),
                    ),
                    style: small?.copyWith(
                      color: towardColor(context, isToward(change, direction)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          )
        : Text(
            counting != null
                ? weightText(l10n, counting.value, unit)
                : l10n.weightTitle,
            style: big,
          );
    final Widget bottom = counting == null
        ? Text(
            today ? l10n.weightAddToday : l10n.weightAddForDay,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          )
        : Text(
            avg != null
                ? l10n.weightDayValue(
                    dayLabel(context, day),
                    weightText(l10n, counting.value, unit),
                  )
                : l10n.weightNoAverageYet,
            style: small,
          );

    return Column(
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        InkWell(
          onTap: () => showWeightSheet(context, ref, day: day),
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Symbols.monitor_weight_rounded,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [top, const SizedBox(height: 2), bottom],
                  ),
                ),
                Icon(
                  counting == null
                      ? Symbols.add_rounded
                      : Symbols.chevron_right_rounded,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
