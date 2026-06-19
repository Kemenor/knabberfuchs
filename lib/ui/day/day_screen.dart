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
import '../recipes/ocr_meal_screen.dart';
import '../recipes/recipe_edit_screen.dart';
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
          onTap: () => _pickDate(context, day),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DayKey.label(day)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 22),
            ],
          ),
        ),
        leading: IconButton(
          tooltip: 'Previous day',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => shiftDay(-1),
        ),
        actions: [
          IconButton(
            tooltip: 'Next day',
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
            tooltip: 'Settings',
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
        data: (summary) => _DayBody(summary: summary),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'dayMore',
            tooltip: 'More',
            onPressed: () => _showMoreActions(context, day),
            child: const Icon(Icons.more_horiz),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'dayAddFood',
            onPressed: () => addFoodByDay(context, ref, day),
            icon: const Icon(Icons.add),
            label: const Text('Add food'),
          ),
        ],
      ),
    );
  }

  /// Jump to any date via the calendar picker.
  Future<void> _pickDate(BuildContext context, String day) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DayKey.parse(day),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ref.read(selectedDayProvider.notifier).set(DayKey.of(picked));
    }
  }

  /// Secondary "+" actions that don't belong on the primary Add food button.
  void _showMoreActions(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('New recipe'),
              subtitle: const Text('Build a reusable recipe'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Meal from ingredient list'),
              subtitle: const Text('Photograph a packaged ingredient list'),
              onTap: () {
                Navigator.pop(sheetCtx);
                startOcrMealFlow(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Push the add-food flow; the target group (active or a new time-named one) is
/// resolved at log time so empty groups never linger.
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
  const _DayBody({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = <Widget>[_SummaryCard(summary: summary)];

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
                  onTap: () => _editMeal(context, ref),
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
                    case 'edit':
                      _editMeal(context, ref);
                    case 'split':
                      showSplitMealSheet(context, group);
                    case 'recipe':
                      _saveAsRecipe(context, ref);
                    case 'delete':
                      _delete(ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit', child: Text('Edit meal')),
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

  void _editMeal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditMealSheet(group: group, day: day),
    );
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

/// Edit a meal: rename, reclassify its meal type, and back-date it (moving the
/// whole meal — header + entries — to another day/time).
class _EditMealSheet extends ConsumerStatefulWidget {
  final GroupView group;
  final String day;
  const _EditMealSheet({required this.group, required this.day});

  @override
  ConsumerState<_EditMealSheet> createState() => _EditMealSheetState();
}

class _EditMealSheetState extends ConsumerState<_EditMealSheet> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.group.name);
  late MealType _meal = widget.group.items.isNotEmpty
      ? widget.group.items.first.meal
      : MealType.snack;
  late DateTime _when = widget.group.group.createdAt;
  // Once the user edits the name by hand, stop auto-rewriting it on reclassify.
  bool _nameDirty = false;

  String get _timeLabel =>
      '${_when.hour.toString().padLeft(2, '0')}:${_when.minute.toString().padLeft(2, '0')}';
  String get _autoName => '${_meal.title} $_timeLabel';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _reclassify(MealType m) {
    setState(() {
      _meal = m;
      if (!_nameDirty) _nameCtrl.text = _autoName;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _when =
          DateTime(picked.year, picked.month, picked.day, _when.hour, _when.minute));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (picked != null) {
      setState(() {
        _when = DateTime(
            _when.year, _when.month, _when.day, picked.hour, picked.minute);
        if (!_nameDirty) _nameCtrl.text = _autoName;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final newDay = DayKey.of(_when);
    final db = ref.read(dbProvider);
    final health = ref.read(healthServiceProvider);
    await db.editEntryGroup(
          id: widget.group.id,
          name: name.isEmpty ? _autoName : name,
          day: newDay,
          time: _when,
          mealType: _meal,
        );
    // Re-sync Health Connect for both the source and destination day. The
    // day-screen listener only covers the selected day, so a cross-day move
    // would otherwise leave the meal double-counted on the old day. Each call
    // deletes that day's range and rewrites it; both are no-ops if sync is off.
    await health.maybeSyncDay(widget.day, await db.watchDay(widget.day).first);
    if (newDay != widget.day) {
      await health.maybeSyncDay(newDay, await db.watchDay(newDay).first);
      // Follow the meal to its new day.
      ref.read(selectedDayProvider.notifier).set(newDay);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit meal', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _nameDirty = true,
            ),
            const SizedBox(height: 16),
            Text('Meal type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final m in MealType.values)
                  ChoiceChip(
                    label: Text(m.title),
                    selected: _meal == m,
                    onSelected: (_) => _reclassify(m),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('When', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DayKey.label(DayKey.of(_when))),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(_timeLabel),
                  onPressed: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
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
