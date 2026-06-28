import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../core/snackbar.dart';
import '../../data/db/database.dart';
import '../../domain/meal_times.dart';
import '../../domain/nutrition.dart';
import '../../domain/ocr_ingredient.dart';
import '../../domain/recipe_share.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../food/food_picker_screen.dart';
import '../food/image_source_sheet.dart';

/// Photograph or pick image(s) of an ingredient list, OCR them, and open the
/// review screen. Shared by the day-screen capture menu and the recipes screen.
Future<void> startOcrMealFlow(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final source = await pickImageSource(context);
  if (source == null || !context.mounted) return;
  final picker = ImagePicker();
  // Camera takes one shot; gallery allows several (a list can span pages).
  final files = source == ImageSource.camera
      ? [await picker.pickImage(source: ImageSource.camera)].nonNulls.toList()
      : await picker.pickMultiImage();
  if (files.isEmpty || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  final ocr = ref.read(ocrServiceProvider);
  final all = <OcrIngredient>[];
  for (final f in files) {
    try {
      all.addAll(await ocr.ingredientsFromImage(f.path));
    } catch (_) {
      /* skip unreadable image */
    }
  }
  navigator.pop(); // close the loading dialog

  if (all.isEmpty) {
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrNoIngredients)));
    return;
  }
  navigator.push(
    MaterialPageRoute(builder: (_) => OcrMealScreen(ingredients: all)),
  );
}

class _Item {
  final OcrIngredient parsed;
  Food? matched;
  double? gramsOverride;
  _Item(this.parsed);
}

/// Review screen for a meal parsed from recipe screenshots. Each ingredient is
/// a placeholder: swipe → to pick its food (keeping the parsed amount/unit),
/// ← to remove. Then save as a recipe or log it to a day.
class OcrMealScreen extends ConsumerStatefulWidget {
  final List<OcrIngredient> ingredients;
  const OcrMealScreen({super.key, required this.ingredients});

  @override
  ConsumerState<OcrMealScreen> createState() => _OcrMealScreenState();
}

class _OcrMealScreenState extends ConsumerState<OcrMealScreen> {
  late final List<_Item> _items = widget.ingredients.map(_Item.new).toList();
  final _name = TextEditingController();
  bool _nameInit = false;

  @override
  void initState() {
    super.initState();
    _autoMatch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nameInit) {
      _nameInit = true;
      _name.text = AppLocalizations.of(context).ocrDefaultMealName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Pre-match ingredients whose name was matched to a food before.
  Future<void> _autoMatch() async {
    final db = ref.read(dbProvider);
    for (var i = 0; i < _items.length; i++) {
      final food = await db.mappedFoodForOcr(
        normalizeOcrName(_items[i].parsed.name),
      );
      if (food != null && mounted) setState(() => _items[i].matched = food);
    }
  }

  double? _grams(_Item it) {
    if (it.gramsOverride != null) return it.gramsOverride;
    final known = it.parsed.gramsIfKnown;
    if (known != null) return known;
    final serving = it.matched?.servingG;
    if (serving != null) return serving * it.parsed.amount;
    return null;
  }

  Nutrition? _nutrition(_Item it) {
    final g = _grams(it);
    if (it.matched == null || g == null) return null;
    return Nutrition.fromPer100g(
      kcal100: it.matched!.kcal100,
      protein100: it.matched!.protein100,
      carb100: it.matched!.carb100,
      fat100: it.matched!.fat100,
      grams: g,
    );
  }

  List<_Item> get _ready =>
      _items.where((it) => it.matched != null && _grams(it) != null).toList();

  Future<void> _match(int i) async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) => FoodPickerScreen(
          title: _items[i].parsed.name,
          initialQuery: _items[i].parsed.name,
        ),
      ),
    );
    if (food == null || !mounted) return;
    // Persist + remember the mapping so this name auto-matches next time.
    final persisted = await ref
        .read(foodRepositoryProvider)
        .ensurePersisted(food);
    await ref
        .read(dbProvider)
        .setOcrMapping(normalizeOcrName(_items[i].parsed.name), persisted.id);
    if (mounted) setState(() => _items[i].matched = persisted);
  }

  Future<void> _addIngredient() async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) =>
            FoodPickerScreen(title: AppLocalizations.of(context).addIngredient),
      ),
    );
    if (food == null || !mounted) return;
    final persisted = await ref
        .read(foodRepositoryProvider)
        .ensurePersisted(food);
    if (!mounted) return;
    setState(() {
      _items.add(
        _Item(
          OcrIngredient(
            name: persisted.name,
            amount: persisted.servingG ?? 100,
            unit: AmountUnit.grams,
            rawUnit: 'g',
          ),
        )..matched = persisted,
      );
    });
  }

  Future<void> _editGrams(int i) async {
    final l10n = AppLocalizations.of(context);
    final c = TextEditingController(
      text: _grams(_items[i])?.let(gramsStr) ?? '',
    );
    double? g;
    try {
      g = await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_items[i].matched?.name ?? _items[i].parsed.name),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(suffixText: 'g'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                double.tryParse(c.text.replaceAll(',', '.')),
              ),
              child: Text(l10n.actionSet),
            ),
          ],
        ),
      );
    } finally {
      c.dispose();
    }
    if (g != null && mounted) setState(() => _items[i].gramsOverride = g);
  }

  Future<void> _saveRecipe() async {
    final ready = _ready;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (ready.isEmpty) {
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrNeedMatch)));
      return;
    }
    await ref
        .read(recipeRepositoryProvider)
        .create(
          name: _name.text.trim().isEmpty
              ? l10n.ocrDefaultMealName
              : _name.text.trim(),
          servings: 1,
          items: [
            for (final it in ready)
              RecipeShareItem(
                name: it.matched!.name,
                grams: _grams(it)!,
                kcal100: it.matched!.kcal100,
                protein100: it.matched!.protein100,
                carb100: it.matched!.carb100,
                fat100: it.matched!.fat100,
              ),
          ],
        );
    if (mounted) Navigator.of(context).pop();
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrSavedToRecipes)));
  }

  Future<void> _logToDay() async {
    final ready = _ready;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (ready.isEmpty) {
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrNeedMatch)));
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    final day = DayKey.of(picked);
    final dayLbl = dayLabel(context, day);
    final db = ref.read(dbProvider);
    final diary = ref.read(diaryRepositoryProvider);
    final gid = await db.createEntryGroup(
      day,
      _name.text.trim().isEmpty ? l10n.ocrDefaultMealName : _name.text.trim(),
    );
    final meal =
        (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
            .inferNow();
    for (final it in ready) {
      await diary.logSnapshot(
        name: it.matched!.name,
        kcal100: it.matched!.kcal100,
        protein100: it.matched!.protein100,
        carb100: it.matched!.carb100,
        fat100: it.matched!.fat100,
        grams: _grams(it)!,
        meal: meal,
        day: day,
        groupId: gid,
      );
    }
    if (mounted) Navigator.of(context).pop();
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.loggedTo(dayLbl))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final total = Nutrition.sum(_items.map(_nutrition).whereType<Nutrition>());
    final matched = _ready.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrReviewTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ocrAddIngredientFab',
        onPressed: _addIngredient,
        icon: const Icon(Symbols.add_rounded),
        label: Text(l10n.addIngredient),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saveRecipe,
                  child: Text(l10n.ocrSaveAsRecipe),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _logToDay,
                  child: Text(l10n.ocrLogToDay),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.ocrMealName,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.ocrMatched('$matched', '${_items.length}'),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  l10n.kcalValue(kcalStr(total.kcal)),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              l10n.ocrSwipeHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _items.length,
              itemBuilder: (context, i) => _row(context, i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int i) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final it = _items[i];
    final n = _nutrition(it);
    final amountLabel = it.parsed.unit != null
        ? '${gramsStr(it.parsed.amount)} ${it.parsed.unit!.label}'
        : '${gramsStr(it.parsed.amount)} ${it.parsed.rawUnit}';
    final g = _grams(it);

    return Dismissible(
      key: ValueKey('ocr-$i-${it.parsed.name}'),
      background: Container(
        color: theme.colorScheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Symbols.search_rounded),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Symbols.delete_rounded),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          await _match(i);
          return false;
        }
        return true;
      },
      onDismissed: (_) => setState(() => _items.removeAt(i)),
      child: ListTile(
        leading: Icon(
          it.matched != null ? Symbols.check_circle_rounded : Symbols.help_rounded,
          color: it.matched != null
              ? theme.colorScheme.primary
              : theme.disabledColor,
        ),
        title: Text(it.matched?.name ?? it.parsed.name),
        subtitle: Text(
          it.matched != null && it.matched!.name != it.parsed.name
              ? l10n.ocrFromSource(amountLabel, it.parsed.name)
              : it.matched == null
              ? l10n.ocrPickHintSub(amountLabel)
              : amountLabel,
        ),
        trailing: it.matched == null
            ? null
            : (n != null
                  ? Text(
                      l10n.kcalGrams(kcalStr(n.kcal), gramsStr(g!)),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall,
                    )
                  : TextButton(
                      onPressed: () => _editGrams(i),
                      child: Text(l10n.ocrSetGrams),
                    )),
        onTap: () => it.matched == null ? _match(i) : _editGrams(i),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
