import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/food_icon.dart';
import '../../core/format.dart';
import '../../core/metric_labels.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Read-only per-meal nutrition breakdown (grilled 2026-07-03): the meal's
/// totals for kcal + every enabled tracked nutrient, then each ingredient with
/// its own stats. Editing stays on the Day screen — this page only answers
/// "how much protein was breakfast?". Watches the live day summary so edits
/// made after opening (or a deleted meal) resolve instead of going stale.
class MealDetailScreen extends ConsumerWidget {
  final int groupId;
  const MealDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(dayGroupViewsProvider);
    final enabled =
        ref.watch(trackedNutrientsProvider).asData?.value ??
        defaultTrackedNutrients;

    GroupView? group;
    for (final g in groups) {
      if (g.id == groupId) group = g;
    }
    // Meal deleted while open (e.g. via a lagging snackbar action) — leave.
    if (group == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final subtotal = group.subtotal;

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.kcalValue(kcalStr(subtotal.kcal)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final m in TargetMetric.values)
                    if (m != TargetMetric.kcal && enabled.contains(m))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(metricLabel(l10n, m)),
                            Text(
                              l10n.gramsValue(
                                gramsStr(metricValue(subtotal, m)),
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              l10n.ingredients.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  _IngredientTile(view: group.items[i], enabled: enabled),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final EntryView view;
  final Set<TargetMetric> enabled;
  const _IngredientTile({required this.view, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final line = nutrientLine(l10n, view.nutrition, enabled);
    return ListTile(
      leading: Icon(
        foodIconFor(view.name),
        color: theme.colorScheme.primary,
      ),
      title: Text(view.name),
      subtitle: Text(
        line.isEmpty
            ? l10n.gramsValue(gramsStr(view.grams))
            : '${l10n.gramsValue(gramsStr(view.grams))} · $line',
      ),
      trailing: Text(l10n.kcalValue(kcalStr(view.nutrition.kcal))),
    );
  }
}
