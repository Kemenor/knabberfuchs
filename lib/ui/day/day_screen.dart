import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../domain/day_summary.dart';
import '../../domain/enums.dart';
import '../../domain/nutrition.dart';
import '../../providers.dart';
import '../add/add_food_screen.dart';
import '../food/log_food_sheet.dart';
import '../settings/settings_screen.dart';

class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final summaryAsync = ref.watch(daySummaryProvider);
    final groupByMeal = ref.watch(groupByMealProvider).asData?.value ?? true;

    void shiftDay(int by) =>
        ref.read(selectedDayProvider.notifier).shift(by);

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
        onPressed: () => _addFood(context, day, MealType.snack),
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
    );
  }
}

void _addFood(BuildContext context, String day, MealType meal) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AddFoodScreen(day: day, meal: meal)),
  );
}

class _DayBody extends ConsumerWidget {
  final DaySummary summary;
  final bool groupByMeal;
  const _DayBody({required this.summary, required this.groupByMeal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _SummaryCard(summary: summary),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Meals'), icon: Icon(Icons.restaurant)),
              ButtonSegment(value: false, label: Text('List'), icon: Icon(Icons.list)),
            ],
            selected: {groupByMeal},
            onSelectionChanged: (s) => ref
                .read(dbProvider)
                .setSetting('groupByMeal', s.first ? 'true' : 'false'),
          ),
        ),
        if (summary.entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: Text('Nothing logged yet.')),
          )
        else if (groupByMeal)
          ..._buildMeals(context)
        else
          ..._buildFlat(context),
      ],
    );
  }

  List<Widget> _buildMeals(BuildContext context) {
    return [
      for (final group in summary.meals)
        _MealSection(group: group, day: summary.day),
    ];
  }

  List<Widget> _buildFlat(BuildContext context) {
    return [
      for (final e in summary.entries) _EntryTile(view: e, day: summary.day),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  final DaySummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.total;
    final target = summary.kcalTarget;
    final remaining = summary.remaining;

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
                if (target != null)
                  Text(
                    summary.isOver
                        ? '${kcalStr(-remaining!)} over'
                        : '${kcalStr(remaining!)} left',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: summary.isOver
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (target != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: target == 0 ? 0 : (total.kcal / target).clamp(0.0, 1.0),
                  minHeight: 8,
                  color: summary.isOver ? theme.colorScheme.error : null,
                ),
              ),
              const SizedBox(height: 4),
              Text('Target ${kcalStr(target)} kcal',
                  style: theme.textTheme.bodySmall),
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
                onPressed: () => _addFood(context, day, group.meal),
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
      onDismissed: (_) =>
          ref.read(diaryRepositoryProvider).deleteEntry(view.id),
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
