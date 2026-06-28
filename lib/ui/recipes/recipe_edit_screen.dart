import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/nutrition.dart';
import '../../domain/food_name.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../food/food_picker_screen.dart';
import '../food/log_food_sheet.dart';

/// Create or edit a recipe: name, servings, and ingredients (food + grams).
/// Pass [recipe] to edit an existing one.
class RecipeEditScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;
  const RecipeEditScreen({super.key, this.recipe});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _name = TextEditingController();
  final _servings = TextEditingController(text: '2');
  final List<RecipeShareItem> _items = [];

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    if (r != null) {
      _name.text = r.name;
      _servings.text = gramsStr(r.servings);
      _loadItems(r);
    }
  }

  Future<void> _loadItems(Recipe r) async {
    final repo = ref.read(recipeRepositoryProvider);
    final share = repo.toShare(r, await repo.items(r.id));
    if (mounted) setState(() => _items.addAll(share.items));
  }

  @override
  void dispose() {
    _name.dispose();
    _servings.dispose();
    super.dispose();
  }

  Nutrition get _total => Nutrition.sum(_items.map((i) => i.nutrition));

  Future<void> _addIngredient() async {
    // Same components as the add-food flow: shared picker (search/scan/custom)
    // + the amount sheet (unit selector, quick-picks, serving).
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) =>
            FoodPickerScreen(title: AppLocalizations.of(context).addIngredient),
      ),
    );
    if (food == null || !mounted) return;
    final foodName = food.localizedNameOf(context);
    final grams = await showAmountSheet(
      context,
      name: foodName,
      brand: food.brand,
      kcal100: food.kcal100,
      protein100: food.protein100,
      carb100: food.carb100,
      fat100: food.fat100,
      servingG: food.servingG,
      servingLabel: food.servingLabel,
    );
    if (grams == null || !mounted) return;
    setState(() {
      _items.add(
        RecipeShareItem(
          name: foodName,
          grams: grams,
          kcal100: food.kcal100,
          protein100: food.protein100,
          carb100: food.carb100,
          fat100: food.fat100,
        ),
      );
    });
  }

  Future<void> _editIngredient(int i) async {
    final item = _items[i];
    final grams = await showAmountSheet(
      context,
      name: item.name,
      kcal100: item.kcal100,
      protein100: item.protein100,
      carb100: item.carb100,
      fat100: item.fat100,
      initialGrams: item.grams,
      submitLabel: AppLocalizations.of(context).actionSave,
    );
    if (grams == null || !mounted) return;
    setState(() {
      _items[i] = RecipeShareItem(
        name: item.name,
        grams: grams,
        kcal100: item.kcal100,
        protein100: item.protein100,
        carb100: item.carb100,
        fat100: item.fat100,
      );
    });
  }

  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return; // guard against a double-tap before the screen pops
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    final servings = double.tryParse(_servings.text.replaceAll(',', '.')) ?? 1;
    final l10n = AppLocalizations.of(context);
    if (name.isEmpty) {
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.recipeNeedName)));
      return;
    }
    if (_items.isEmpty) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.recipeNeedIngredient)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(recipeRepositoryProvider);
      if (widget.recipe == null) {
        await repo.create(name: name, servings: servings, items: _items);
      } else {
        await repo.update(
          id: widget.recipe!.id,
          name: name,
          servings: servings,
          items: _items,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.genericError('$e'))),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? l10n.recipeNew : l10n.recipeEdit),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recipeSaveFab',
        onPressed: _saving ? null : _save,
        icon: const Icon(Symbols.check_rounded),
        label: Text(l10n.actionSave),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.recipeName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servings,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.recipeServingsField,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.ingredients,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                l10n.kcalTotal(kcalStr(total.kcal)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _items.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                _items[i].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.gramsKcal(
                  gramsStr(_items[i].grams),
                  kcalStr(_items[i].nutrition.kcal),
                ),
              ),
              onTap: () => _editIngredient(i),
              trailing: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Symbols.close_rounded, size: 20),
                onPressed: () => setState(() => _items.removeAt(i)),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Symbols.add_rounded),
            label: Text(l10n.addIngredient),
          ),
        ],
      ),
    );
  }
}
