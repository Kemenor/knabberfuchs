import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../core/status_color.dart';
import '../../domain/day_summary.dart';
import '../../domain/enums.dart';
import '../../domain/meal_type_i18n.dart';
import '../../domain/meal_times.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../add/add_food_screen.dart';
import '../food/log_food_sheet.dart';
import '../food/quick_add_sheet.dart';
import '../food/recognize_food_flow.dart';
import '../recipes/ocr_meal_screen.dart';
import 'scale_meal_sheet.dart';
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
    final l10n = AppLocalizations.of(context);

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
              Text(dayLabel(context, day)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 22),
            ],
          ),
        ),
        leading: IconButton(
          tooltip: l10n.dayPreviousDay,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => shiftDay(-1),
        ),
        actions: [
          IconButton(
            tooltip: l10n.dayNextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => shiftDay(1),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
        data: (summary) => _DayBody(summary: summary),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'dayCapture',
            tooltip: l10n.quickAdd,
            onPressed: () => _showCaptureMenu(context, ref, day),
            child: const Icon(Icons.bolt),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'dayAddFood',
            onPressed: () => addFoodByDay(context, ref, day),
            icon: const Icon(Icons.add),
            label: Text(l10n.dayAddFood),
          ),
        ],
      ),
    );
  }

  /// Photo-based capture menu: AI dish recognition or an ingredient-list OCR.
  void _showCaptureMenu(BuildContext context, WidgetRef ref, String day) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(l10n.quickAdd),
              subtitle: Text(l10n.quickAddSubtitle),
              onTap: () {
                Navigator.pop(sheetCtx);
                quickAddByDay(context, ref, day);
              },
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_weak),
              title: Text(l10n.captureScanAi),
              subtitle: Text(l10n.captureScanAiSub),
              onTap: () {
                Navigator.pop(sheetCtx);
                recognizeFoodByDay(context, ref, day);
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(l10n.createFromList),
              subtitle: Text(l10n.createFromListSub),
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

/// AI photo recognition that logs into [day]'s active (or new) meal group.
Future<void> recognizeFoodByDay(
  BuildContext context,
  WidgetRef ref,
  String day,
) async {
  final meal = (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
      .inferNow();
  await startRecognizeFoodFlow(
    context,
    ref,
    day: day,
    meal: meal,
    resolveGroup: () => ref.read(activeGroupProvider.notifier).ensureGroup(day),
  );
}

/// Free add (name + calories) that logs into [day]'s active (or new) group.
Future<void> quickAddByDay(
  BuildContext context,
  WidgetRef ref,
  String day,
) async {
  final meal = (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
      .inferNow();
  await showQuickAddSheet(
    context,
    ref,
    day: day,
    meal: meal,
    resolveGroup: () => ref.read(activeGroupProvider.notifier).ensureGroup(day),
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
      children.add(
        Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Text(
              AppLocalizations.of(context).dayEmptyHint,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
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

String _rangeLabel(AppLocalizations l10n, DaySummary s) {
  final mn = s.kcalMin, mx = s.kcalMax;
  if (mn != null && mx != null) {
    return l10n.targetRangeBoth(kcalStr(mn), kcalStr(mx));
  }
  if (mx != null) return l10n.targetRangeMax(kcalStr(mx));
  if (mn != null) return l10n.targetRangeMin(kcalStr(mn));
  return '';
}

class _SummaryCard extends StatelessWidget {
  final DaySummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final total = summary.total;
    final status = summary.status;
    final color = statusColor(theme.colorScheme, status);
    final kcalBar = summary.barFractionFor(TargetMetric.kcal);
    final statusText = switch (status) {
      TargetStatus.over => l10n.targetOver(kcalStr(-summary.remainingToMax!)),
      TargetStatus.under => l10n.targetToGo(kcalStr(summary.shortOfMin!)),
      TargetStatus.inRange =>
        summary.kcalMax != null
            ? l10n.targetLeft(kcalStr(summary.remainingToMax!))
            : l10n.targetMinReached,
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
                Text(
                  kcalStr(total.kcal),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(l10n.unitKcal, style: theme.textTheme.titleMedium),
                const Spacer(),
                if (summary.hasTarget)
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (kcalBar != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: kcalBar,
                  minHeight: 8,
                  color: status == TargetStatus.over
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
            ],
            if (summary.hasTarget) ...[
              const SizedBox(height: 4),
              Text(
                _rangeLabel(l10n, summary),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            _MacroRow(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final DaySummary summary;
  const _MacroRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _macro(context, TargetMetric.protein, l10n.macroProtein),
        _macro(context, TargetMetric.carb, l10n.macroCarbs),
        _macro(context, TargetMetric.fat, l10n.macroFat),
      ],
    );
  }

  /// One macro: its gram total, a thin progress bar when the macro has a target
  /// (status-colored), and the label. Targetless macros stay plain — a reserved
  /// gap keeps the three labels aligned. Mirrors the kcal bar above.
  Widget _macro(BuildContext context, TargetMetric metric, String label) {
    final theme = Theme.of(context);
    final value = summary.valueFor(metric);
    final frac = summary.barFractionFor(metric);
    final status = summary.statusForMetric(metric);
    final color = frac == null ? null : statusColor(theme.colorScheme, status);
    return Expanded(
      child: Column(
        children: [
          Text(
            '${macroStr(value)} g',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 4,
            child: frac == null
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 4,
                        color: status == TargetStatus.over
                            ? theme.colorScheme.error
                            : null,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
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
    final l10n = AppLocalizations.of(context);
    final isActive = ref.watch(activeGroupProvider) == group.id;
    final isCollapsed = ref.watch(collapsedGroupsProvider).contains(group.id);

    Future<void> reopenAndAdd() async {
      await ref.read(activeGroupProvider.notifier).reopen(group.id);
      if (context.mounted) addFoodByDay(context, ref, day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: isCollapsed ? l10n.mealExpand : l10n.mealCollapse,
                icon: Icon(
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 22,
                ),
                onPressed: () =>
                    ref.read(collapsedGroupsProvider.notifier).toggle(group.id),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _editMeal(context, ref),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          group.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${kcalStr(group.subtotal.kcal)} kcal',
                        style: theme.textTheme.bodySmall,
                      ),
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
                    case 'scale':
                      showScaleMealSheet(context, group);
                    case 'split':
                      showSplitMealSheet(context, group);
                    case 'recipe':
                      _saveAsRecipe(context, ref);
                    case 'delete':
                      _delete(ref);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.mealMenuEdit)),
                  PopupMenuItem(
                    value: 'scale',
                    child: Text(l10n.mealMenuScale),
                  ),
                  PopupMenuItem(
                    value: 'split',
                    child: Text(l10n.mealMenuSplit),
                  ),
                  PopupMenuItem(
                    value: 'recipe',
                    child: Text(l10n.mealMenuSaveRecipe),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.mealMenuDelete),
                  ),
                ],
              ),
              if (isActive)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.mealFinish,
                  icon: Icon(
                    Icons.check,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => ref.read(activeGroupProvider.notifier).end(),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.mealAddTo,
                  icon: const Icon(Icons.add, size: 22),
                  onPressed: reopenAndAdd,
                ),
            ],
          ),
        ),
        if (!isCollapsed)
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
    final l10n = AppLocalizations.of(context);
    await ref
        .read(recipeRepositoryProvider)
        .create(
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
      SnackBar(content: Text(l10n.mealSavedToRecipes(group.name))),
    );
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
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.group.name,
  );
  late MealType _meal = widget.group.items.isNotEmpty
      ? widget.group.items.first.meal
      : MealType.snack;
  late DateTime _when = widget.group.group.createdAt;
  // Once the user edits the name by hand, stop auto-rewriting it on reclassify.
  bool _nameDirty = false;

  String get _timeLabel =>
      '${_when.hour.toString().padLeft(2, '0')}:${_when.minute.toString().padLeft(2, '0')}';
  String get _autoName =>
      '${mealTypeTitle(_meal, Localizations.localeOf(context).languageCode)} '
      '$_timeLabel';

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
      setState(
        () => _when = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _when.hour,
          _when.minute,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (picked != null) {
      setState(() {
        _when = DateTime(
          _when.year,
          _when.month,
          _when.day,
          picked.hour,
          picked.minute,
        );
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
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editMealTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: false,
              decoration: InputDecoration(
                labelText: l10n.editMealName,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _nameDirty = true,
            ),
            const SizedBox(height: 16),
            Text(l10n.editMealType, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final m in MealType.values)
                  ChoiceChip(
                    label: Text(
                      mealTypeTitle(
                        m,
                        Localizations.localeOf(context).languageCode,
                      ),
                    ),
                    selected: _meal == m,
                    onSelected: (_) => _reclassify(m),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.editMealWhen, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(dayLabel(context, DayKey.of(_when))),
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
                FilledButton(onPressed: _save, child: Text(l10n.actionSave)),
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
