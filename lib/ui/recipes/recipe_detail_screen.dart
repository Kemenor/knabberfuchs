import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/meal_times.dart';
import '../../domain/nutrition.dart';
import '../../domain/recipe_share.dart';
import '../../providers.dart';
import 'recipe_edit_screen.dart';
import 'recipe_share_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late Recipe _recipe = widget.recipe;
  RecipeShare? _share;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(recipeRepositoryProvider);
    final fresh = await ref.read(dbProvider).recipeById(_recipe.id) ?? _recipe;
    final items = await repo.items(_recipe.id);
    if (mounted) {
      setState(() {
        _recipe = fresh;
        _share = repo.toShare(fresh, items);
      });
    }
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RecipeEditScreen(recipe: _recipe)),
    );
    if (changed == true) await _load();
  }

  Future<void> _delete() async {
    await ref.read(recipeRepositoryProvider).delete(_recipe.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final share = _share;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name),
        actions: [
          if (share != null)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _edit,
            ),
          if (share != null)
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.ios_share),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecipeShareScreen(share: share),
              )),
            ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: share == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _NutritionCard(share: share),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Ingredients',
                      style: theme.textTheme.titleMedium),
                ),
                for (final i in share.items)
                  ListTile(
                    dense: true,
                    title: Text(i.name),
                    subtitle: Text('${gramsStr(i.grams)} g'),
                    trailing: Text('${kcalStr(i.nutrition.kcal)} kcal'),
                  ),
              ],
            ),
      floatingActionButton: share == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showLogPortion(context, share),
              icon: const Icon(Icons.event_available),
              label: const Text('Log portion to a day'),
            ),
    );
  }

  void _showLogPortion(BuildContext context, RecipeShare share) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LogPortionSheet(share: share),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final RecipeShare share;
  const _NutritionCard({required this.share});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = share.total;
    final per = share.perServing;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Whole recipe', style: theme.textTheme.labelMedium),
            Text(
              '${kcalStr(total.kcal)} kcal · ${gramsStr(share.totalGrams)} g',
              style: theme.textTheme.titleLarge,
            ),
            const Divider(height: 20),
            Text('Per serving (${share.servings.toStringAsFixed(0)})',
                style: theme.textTheme.labelMedium),
            Text(
              '${kcalStr(per.kcal)} kcal · '
              'P ${macroStr(per.protein)}  C ${macroStr(per.carb)}  F ${macroStr(per.fat)}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Choose a day, meal, and number of portions, then log a scaled snapshot.
/// Reopen to log further portions onto other days (batch-cooking).
class _LogPortionSheet extends ConsumerStatefulWidget {
  final RecipeShare share;
  const _LogPortionSheet({required this.share});

  @override
  ConsumerState<_LogPortionSheet> createState() => _LogPortionSheetState();
}

class _LogPortionSheetState extends ConsumerState<_LogPortionSheet> {
  String _day = DayKey.today();
  MealType _meal = MealType.dinner;
  double _portions = 1;

  double get _oneServingGrams =>
      ref.read(recipeRepositoryProvider).portionGramsForServings(widget.share);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fixedMeals = ref.watch(groupByMealProvider).asData?.value ?? false;
    final grams = _oneServingGrams * _portions;
    final nutrition = Nutrition.fromPer100g(
      kcal100: widget.share.totalGrams == 0
          ? 0
          : widget.share.total.kcal / widget.share.totalGrams * 100,
      grams: grams,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log a portion', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(DayKey.label(_day)),
            trailing: const Icon(Icons.edit),
            onTap: _pickDay,
          ),
          const SizedBox(height: 4),
          Text('Portions', style: theme.textTheme.labelLarge),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _portions > 0.5
                    ? () => setState(() => _portions -= 0.5)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '${_portions.toStringAsFixed(_portions == _portions.roundToDouble() ? 0 : 1)} '
                  '(${gramsStr(grams)} g · ${kcalStr(nutrition.kcal)} kcal)',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _portions += 0.5),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (fixedMeals) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in MealType.values)
                  ChoiceChip(
                    label: Text(m.label),
                    selected: _meal == m,
                    onSelected: (_) => setState(() => _meal = m),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: grams <= 0 ? null : _log,
              child: Text('Log to ${DayKey.label(_day)}'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay() async {
    final initial = DayKey.parse(_day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _day = DayKey.of(picked));
  }

  Future<void> _log() async {
    final grams = _oneServingGrams * _portions;
    final messenger = ScaffoldMessenger.of(context);
    final label = DayKey.label(_day);
    final fixedMeals = ref.read(groupByMealProvider).asData?.value ?? false;
    // Track-by-day: log the portion as its own meal group named after the recipe.
    final groupId = fixedMeals
        ? null
        : await ref.read(dbProvider).createEntryGroup(_day, widget.share.name);
    final meal = fixedMeals
        ? _meal
        : (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
            .inferNow();
    await ref.read(recipeRepositoryProvider).logPortionGrams(
          share: widget.share,
          grams: grams,
          meal: meal,
          day: _day,
          groupId: groupId,
        );
    if (mounted) Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text('Logged to $label')));
  }
}
