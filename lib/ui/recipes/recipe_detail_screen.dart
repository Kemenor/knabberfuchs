import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/food_icon.dart';
import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/meal_times.dart';
import '../../domain/nutrition.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recipeDeleteConfirm(_recipe.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(recipeRepositoryProvider).delete(_recipe.id);
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final share = _share;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name),
        actions: [
          if (share != null)
            IconButton(
              tooltip: l10n.actionEdit,
              icon: const Icon(Symbols.edit_rounded),
              onPressed: _edit,
            ),
          if (share != null)
            IconButton(
              tooltip: l10n.actionShare,
              icon: const Icon(Symbols.ios_share_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeShareScreen(share: share),
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(Symbols.delete_rounded),
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
                      for (var i = 0; i < share.items.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ListTile(
                          leading: Icon(
                            foodIconFor(share.items[i].name),
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(share.items[i].name),
                          subtitle: Text(
                            l10n.gramsValue(gramsStr(share.items[i].grams)),
                          ),
                          trailing: Text(
                            l10n.kcalValue(
                              kcalStr(share.items[i].nutrition.kcal),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: share == null
          ? null
          : FloatingActionButton.extended(
              heroTag: 'recipeLogPortionFab',
              onPressed: () => _showLogPortion(context, share),
              icon: const Icon(Symbols.event_available_rounded),
              label: Text(l10n.recipeLogPortion),
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

/// Load a [recipe]'s ingredients and open the "log a portion to a day" sheet.
/// Reused by the recipes-list swipe action.
Future<void> showLogPortionForRecipe(
  BuildContext context,
  WidgetRef ref,
  Recipe recipe,
) async {
  final repo = ref.read(recipeRepositoryProvider);
  final share = repo.toShare(recipe, await repo.items(recipe.id));
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogPortionSheet(share: share),
  );
}

class _NutritionCard extends StatelessWidget {
  final RecipeShare share;
  const _NutritionCard({required this.share});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final total = share.total;
    final per = share.perServing;
    final servingsStr = share.servings.toStringAsFixed(
      share.servings == share.servings.roundToDouble() ? 0 : 1,
    );
    return Column(
      children: [
        // Hero header: recipe name, servings, and whole-recipe kcal.
        Card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  share.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.recipeServings(servingsStr),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.kcalValue(kcalStr(total.kcal)),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      l10n.recipeWhole,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Per-serving: kcal headline + a Protein / Carbs / Fat macro row.
        Card(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.kcalValue(kcalStr(per.kcal)),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.recipePerServing(servingsStr),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Macro(label: l10n.macroProtein, grams: per.protein),
                    _Macro(label: l10n.macroCarbs, grams: per.carb),
                    _Macro(label: l10n.macroFat, grams: per.fat),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One Protein/Carbs/Fat column in the per-serving macro row.
class _Macro extends StatelessWidget {
  final String label;
  final double grams;
  const _Macro({required this.label, required this.grams});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            l10n.gramsValue(macroStr(grams)),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
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
  double _portions = 1;

  double get _oneServingGrams =>
      ref.read(recipeRepositoryProvider).portionGramsForServings(widget.share);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final grams = _oneServingGrams * _portions;
    final nutrition = Nutrition.fromPer100g(
      kcal100: widget.share.totalGrams == 0
          ? 0
          : widget.share.total.kcal / widget.share.totalGrams * 100,
      grams: grams,
    );

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
            Text(l10n.recipeLogPortionTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.calendar_today_rounded),
              title: Text(dayLabel(context, _day)),
              trailing: const Icon(Symbols.edit_rounded),
              onTap: _pickDay,
            ),
            const SizedBox(height: 4),
            Text(l10n.recipePortions, style: theme.textTheme.labelLarge),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _portions > 0.5
                      ? () => setState(() => _portions -= 0.5)
                      : null,
                  icon: const Icon(Symbols.remove_rounded),
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
                  icon: const Icon(Symbols.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (grams <= 0 || _saving) ? null : _log,
                child: Text(l10n.recipeLogToDay(dayLabel(context, _day))),
              ),
            ),
          ],
        ),
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

  bool _saving = false;

  Future<void> _log() async {
    if (_saving) return; // guard against a double-tap before the sheet pops
    setState(() => _saving = true);
    final grams = _oneServingGrams * _portions;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final label = dayLabel(context, _day);
    try {
      // Log the portion as its own meal group named after the recipe.
      final groupId = await ref
          .read(dbProvider)
          .createEntryGroup(_day, widget.share.name);
      final meal =
          (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
              .inferNow();
      await ref
          .read(recipeRepositoryProvider)
          .logPortionGrams(
            share: widget.share,
            grams: grams,
            meal: meal,
            day: _day,
            groupId: groupId,
          );
      // Land the user on the day they just logged to, so they see the meal.
      ref.read(selectedDayProvider.notifier).set(_day);
      ref.read(homeTabProvider.notifier).set(0); // Day tab
      // Pop the sheet (and the recipe-detail route, if we came from it) back to
      // the home shell so the Day tab is actually visible.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.loggedTo(label))));
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }
}
