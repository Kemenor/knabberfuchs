import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../domain/day_summary.dart';
import '../../domain/enums.dart';
import '../../domain/meal_times.dart';
import '../../domain/nutrition.dart';
import '../../domain/recipe_share.dart';
import '../../providers.dart';
import '../add/add_food_screen.dart';
import '../food/log_food_sheet.dart';
import '../recipes/recipes_screen.dart';
import '../settings/settings_screen.dart';
import 'split_meal_sheet.dart';

class DayScreen extends ConsumerStatefulWidget {
  const DayScreen({super.key});

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(activeGroupProvider.notifier).refreshTimeout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(selectedDayProvider);
    final summaryAsync = ref.watch(daySummaryProvider);
    final groupByMeal = ref.watch(groupByMealProvider).asData?.value ?? false;

    // Push this day's nutrition to Health Connect whenever its entries change
    // (no-op unless the user enabled sync in Settings).
    ref.listen(selectedDayEntriesProvider, (_, next) {
      final entries = next.asData?.value;
      if (entries != null) {
        ref.read(healthServiceProvider).maybeSyncDay(day, entries);
      }
    });

    void shiftDay(int by) => ref.read(selectedDayProvider.notifier).shift(by);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => ref.read(selectedDayProvider.notifier).today(),
          child: Text(DayKey.label(day)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => shiftDay(-1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => shiftDay(1),
          ),
          IconButton(
            tooltip: 'Recipes',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecipesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (summary) => _DayBody(summary: summary, groupByMeal: groupByMeal),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => groupByMeal
            ? addFoodToMeal(context, day, MealType.snack)
            : addFoodByDay(context, ref, day),
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
    );
  }
}

/// Push the add-food flow for a fixed meal (meal mode).
void addFoodToMeal(BuildContext context, String day, MealType meal) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AddFoodScreen(day: day, meal: meal)),
  );
}

/// Push the add-food flow for track-by-day mode; the target group (active or a
/// new time-named one) is resolved at log time so empty groups never linger.
void addFoodByDay(BuildContext context, WidgetRef ref, String day) {
  final meal = (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
      .inferNow();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddFoodScreen(
        day: day,
        meal: meal,
        resolveGroup: () =>
            ref.read(activeGroupProvider.notifier).ensureGroup(day),
      ),
    ),
  );
}

class _DayBody extends ConsumerWidget {
  final DaySummary summary;
  final bool groupByMeal;
  const _DayBody({required this.summary, required this.groupByMeal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = <Widget>[_SummaryCard(summary: summary)];

    if (groupByMeal) {
      children.addAll([
        for (final m in summary.meals) _MealSection(group: m, day: summary.day),
      ]);
    } else {
      final groups = ref.watch(dayGroupViewsProvider);
      final ungrouped = ref.watch(ungroupedDayEntriesProvider);
      if (groups.isEmpty && ungrouped.isEmpty) {
        children.add(const Padding(
          padding: EdgeInsets.all(48),
          child: Center(
            child: Text(
              'Tap + to start a meal.\nEverything you add flows into it '
              'until you tap ✓ (or 15 min pass).',
              textAlign: TextAlign.center,
            ),
          ),
        ));
      } else {
        children.addAll([
          for (final g in groups) _GroupSection(group: g, day: summary.day),
          for (final e in ungrouped) _EntryTile(view: e, day: summary.day),
        ]);
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: children,
    );
  }
}

String _rangeLabel(DaySummary s) {
  final mn = s.kcalMin, mx = s.kcalMax;
  if (mn != null && mx != null) return 'Target ${kcalStr(mn)}–${kcalStr(mx)} kcal';
  if (mx != null) return 'Target ${kcalStr(mx)} kcal';
  if (mn != null) return 'Minimum ${kcalStr(mn)} kcal';
  return '';
}

class _SummaryCard extends StatelessWidget {
  final DaySummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.total;
    final status = summary.status;
    final color = switch (status) {
      TargetStatus.over => theme.colorScheme.error,
      TargetStatus.under => theme.colorScheme.tertiary,
      TargetStatus.inRange => theme.colorScheme.primary,
      TargetStatus.none => theme.colorScheme.onSurfaceVariant,
    };
    final statusText = switch (status) {
      TargetStatus.over => '${kcalStr(-summary.remainingToMax!)} over',
      TargetStatus.under => '${kcalStr(summary.shortOfMin!)} to go',
      TargetStatus.inRange => summary.kcalMax != null
          ? '${kcalStr(summary.remainingToMax!)} left'
          : 'minimum reached',
      TargetStatus.none => '',
    };

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(kcalStr(total.kcal),
                    style: theme.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('kcal', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (summary.hasTarget)
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            if (summary.kcalMax != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.kcalMax == 0
                      ? 0
                      : (total.kcal / summary.kcalMax!).clamp(0.0, 1.0),
                  minHeight: 8,
                  color: status == TargetStatus.over
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
            ],
            if (summary.hasTarget) ...[
              const SizedBox(height: 4),
              Text(_rangeLabel(summary), style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            _MacroRow(total: total),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final Nutrition total;
  const _MacroRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _macro(context, 'Protein', total.protein),
        _macro(context, 'Carbs', total.carb),
        _macro(context, 'Fat', total.fat),
      ],
    );
  }

  Widget _macro(BuildContext context, String label, double grams) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('${macroStr(grams)} g',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _MealSection extends ConsumerWidget {
  final MealGroup group;
  final String day;
  const _MealSection({required this.group, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Text(group.meal.label,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (!group.isEmpty)
                Text('${kcalStr(group.subtotal.kcal)} kcal',
                    style: theme.textTheme.bodySmall),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => addFoodToMeal(context, day, group.meal),
              ),
            ],
          ),
        ),
        for (final e in group.items) _EntryTile(view: e, day: day),
        if (group.isEmpty)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

/// A track-by-day ad-hoc meal group: header with rename / save-as-recipe /
/// delete, plus the +/✓ edit-mode control.
class _GroupSection extends ConsumerWidget {
  final GroupView group;
  final String day;
  const _GroupSection({required this.group, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = ref.watch(activeGroupProvider) == group.id;

    Future<void> reopenAndAdd() async {
      await ref.read(activeGroupProvider.notifier).reopen(group.id);
      if (context.mounted) addFoodByDay(context, ref, day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _rename(context, ref),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(group.name,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('${kcalStr(group.subtotal.kcal)} kcal',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) {
                  switch (v) {
                    case 'rename':
                      _rename(context, ref);
                    case 'split':
                      showSplitMealSheet(context, group);
                    case 'recipe':
                      _saveAsRecipe(context, ref);
                    case 'delete':
                      _delete(ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(
                      value: 'split', child: Text('Split across days')),
                  PopupMenuItem(value: 'recipe', child: Text('Save as recipe')),
                  PopupMenuItem(value: 'delete', child: Text('Delete meal')),
                ],
              ),
              if (isActive)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Finish meal',
                  icon: Icon(Icons.check, size: 22, color: theme.colorScheme.primary),
                  onPressed: () => ref.read(activeGroupProvider.notifier).end(),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Add to this meal',
                  icon: const Icon(Icons.add, size: 22),
                  onPressed: reopenAndAdd,
                ),
            ],
          ),
        ),
        for (final e in group.items) _EntryTile(view: e, day: day),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: group.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename meal'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(dbProvider).renameEntryGroup(group.id, name);
    }
  }

  Future<void> _saveAsRecipe(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(recipeRepositoryProvider).create(
          name: group.name,
          servings: 1,
          items: [
            for (final e in group.items)
              RecipeShareItem(
                name: e.name,
                grams: e.grams,
                kcal100: e.entry.sKcal100,
                protein100: e.entry.sProtein100,
                carb100: e.entry.sCarb100,
                fat100: e.entry.sFat100,
              ),
          ],
        );
    messenger.showAutoSnackBar(
        SnackBar(content: Text('Saved "${group.name}" to recipes')));
  }

  Future<void> _delete(WidgetRef ref) async {
    if (ref.read(activeGroupProvider) == group.id) {
      await ref.read(activeGroupProvider.notifier).end();
    }
    await ref.read(dbProvider).deleteEntryGroup(group.id);
  }
}

class _EntryTile extends ConsumerWidget {
  final EntryView view;
  final String day;
  const _EntryTile({required this.view, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('entry-${view.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) async {
        await ref.read(diaryRepositoryProvider).deleteEntry(view.id);
        await ref.read(dbProvider).pruneEmptyGroups(day);
      },
      child: ListTile(
        dense: true,
        title: Text(view.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${gramsStr(view.grams)} g'),
        trailing: Text('${kcalStr(view.nutrition.kcal)} kcal'),
        onTap: () => showEditEntrySheet(context, ref, view.entry),
      ),
    );
  }
}
