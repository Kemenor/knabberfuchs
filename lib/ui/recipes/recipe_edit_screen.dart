import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/nutrition.dart';
import '../../domain/recipe_share.dart';
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
          builder: (_) => const FoodPickerScreen(title: 'Add ingredient')),
    );
    if (food == null || !mounted) return;
    final grams = await showAmountSheet(
      context,
      name: food.name,
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
      _items.add(RecipeShareItem(
        name: food.name,
        grams: grams,
        kcal100: food.kcal100,
        protein100: food.protein100,
        carb100: food.carb100,
        fat100: food.fat100,
      ));
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
      submitLabel: 'Save',
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

  Future<void> _save() async {
    final name = _name.text.trim();
    final servings = double.tryParse(_servings.text.replaceAll(',', '.')) ?? 1;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showAutoSnackBar(const SnackBar(content: Text('Give the recipe a name.')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showAutoSnackBar(
          const SnackBar(content: Text('Add at least one ingredient.')));
      return;
    }
    final repo = ref.read(recipeRepositoryProvider);
    if (widget.recipe == null) {
      await repo.create(name: name, servings: servings, items: _items);
    } else {
      await repo.update(
          id: widget.recipe!.id,
          name: name,
          servings: servings,
          items: _items);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'New recipe' : 'Edit recipe'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Recipe name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servings,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            decoration: const InputDecoration(
              labelText: 'Servings (portions this makes)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${kcalStr(total.kcal)} kcal total',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _items.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_items[i].name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${gramsStr(_items[i].grams)} g · '
                  '${kcalStr(_items[i].nutrition.kcal)} kcal'),
              onTap: () => _editIngredient(i),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _items.removeAt(i)),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('Add ingredient'),
          ),
        ],
      ),
    );
  }
}
