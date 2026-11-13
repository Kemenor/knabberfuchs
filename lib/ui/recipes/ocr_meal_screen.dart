import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../core/snackbar.dart';
import '../../core/text_prompt_dialog.dart';
import '../../data/db/database.dart';
import '../../domain/meal_times.dart';
import '../../domain/day_summary.dart' show snapshotMicros100;
import '../../domain/nutrition.dart';
import '../../domain/ocr_ingredient.dart';
import '../../domain/recipe_share.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../food/food_picker_screen.dart';
import '../food/image_source_sheet.dart';

/// Photograph or pick image(s) of an ingredient list, OCR them, and open the
/// review screen. Shared by the day-screen capture menu (which passes its
/// [day], so "Log to day" logs there) and the recipes screen.
Future<void> startOcrMealFlow(
  BuildContext context,
  WidgetRef ref, {
  String? day,
}) async {
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
    // canPop:false blocks the hardware back button too, so the matching
    // navigator.pop() always closes this dialog, not the screen beneath it.
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.a11yAnalysing),
      ),
    ),
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
    MaterialPageRoute(
      builder: (_) => OcrMealScreen(ingredients: all, day: day),
    ),
  );
}

class _Item {
  static int _nextId = 0;

  /// Stable widget-key identity — list indexes shift when a row is dismissed.
  final int id = _nextId++;
  final OcrIngredient parsed;
  Food? matched;

  /// Best guess for a name never matched before — shown, never used until
  /// the user confirms it (a wrong silent match would log wrong numbers).
  Food? suggested;
  double? gramsOverride;
  _Item(this.parsed);
}

/// Review screen for a meal parsed from recipe screenshots or pasted / shared
/// text. Each ingredient is a placeholder: swipe → to pick its food (keeping
/// the parsed amount/unit), ← to remove. Then save as a recipe or log it.
class OcrMealScreen extends ConsumerStatefulWidget {
  final List<OcrIngredient> ingredients;

  /// The name the text gave itself (a heading), else the default meal name.
  final String? initialName;

  /// "Serves 4" from the text, else 1.
  final double? initialServings;

  /// Where "Log to day" logs — the Day screen's day on screen. Null (opened
  /// from Recipes) asks for a day, starting at the day selected in Day.
  final String? day;

  const OcrMealScreen({
    super.key,
    required this.ingredients,
    this.initialName,
    this.initialServings,
    this.day,
  });

  @override
  ConsumerState<OcrMealScreen> createState() => _OcrMealScreenState();
}

class _OcrMealScreenState extends ConsumerState<OcrMealScreen> {
  late final List<_Item> _items = widget.ingredients.map(_Item.new).toList();
  final _name = TextEditingController();
  // Servings for "Save as recipe" — askable at creation, not only when
  // re-editing the saved recipe afterwards (feedback 2026-07-06). Defaults to
  // 1: the scanned list is usually "what I ate", unlike the recipe editor's 2.
  late final _servings = TextEditingController(
    text: gramsStr(widget.initialServings ?? 1),
  );
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
      _name.text =
          widget.initialName ?? AppLocalizations.of(context).ocrDefaultMealName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _servings.dispose();
    super.dispose();
  }

  /// Pre-match ingredients whose name was matched to a food before; for the
  /// rest, look up a best guess to offer.
  Future<void> _autoMatch() async {
    final db = ref.read(dbProvider);
    final foods = ref.read(foodRepositoryProvider);
    for (final it in List.of(_items)) {
      final food = await db.mappedFoodForOcr(normalizeOcrName(it.parsed.name));
      if (!mounted) return;
      if (food != null) {
        setState(() => it.matched = food);
        continue;
      }
      final guess = await foods.suggestFor(it.parsed.name);
      if (guess != null && mounted && it.matched == null) {
        setState(() => it.suggested = guess);
      }
    }
  }

  /// Accept the suggestion: persisted and remembered like a manual match.
  Future<void> _confirmSuggestion(_Item it) async {
    final guess = it.suggested;
    if (guess == null) return;
    await _remember(it, guess);
  }

  Future<void> _remember(_Item it, Food food) async {
    final persisted = await ref
        .read(foodRepositoryProvider)
        .ensurePersisted(food);
    await ref
        .read(dbProvider)
        .setOcrMapping(normalizeOcrName(it.parsed.name), persisted.id);
    if (mounted) {
      setState(() {
        it.matched = persisted;
        it.suggested = null;
      });
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

  /// Servings for the saved recipe; blank/invalid/zero falls back to 1
  /// (matching the pre-field behavior).
  double get _servingsValue {
    final v = double.tryParse(_servings.text.replaceAll(',', '.'));
    return (v == null || v <= 0) ? 1 : v;
  }

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
    await _remember(_items[i], food);
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
    final text = await showTextPromptDialog(
      context,
      title: _items[i].matched?.name ?? _items[i].parsed.name,
      confirmLabel: l10n.actionSet,
      cancelLabel: l10n.actionCancel,
      initial: _grams(_items[i])?.let(gramsStr) ?? '',
      suffixText: 'g',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    );
    final g = text == null ? null : double.tryParse(text.replaceAll(',', '.'));
    if (g != null && mounted) setState(() => _items[i].gramsOverride = g);
  }

  bool _saving = false;

  Future<void> _saveRecipe() async {
    if (_saving) return; // guard against a double-tap before the screen pops
    final ready = _ready;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (ready.isEmpty) {
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrNeedMatch)));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(recipeRepositoryProvider)
          .create(
            name: _name.text.trim().isEmpty
                ? l10n.ocrDefaultMealName
                : _name.text.trim(),
            servings: _servingsValue,
            items: [
              for (final it in ready)
                RecipeShareItem(
                  name: it.matched!.name,
                  grams: _grams(it)!,
                  kcal100: it.matched!.kcal100,
                  protein100: it.matched!.protein100,
                  carb100: it.matched!.carb100,
                  fat100: it.matched!.fat100,
                  micros100: snapshotMicros100(it.matched!),
                ),
            ],
          );
      if (mounted) Navigator.of(context).pop();
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.ocrSavedToRecipes)),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logToDay() async {
    final ready = _ready;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (ready.isEmpty) {
      messenger.showAutoSnackBar(SnackBar(content: Text(l10n.ocrNeedMatch)));
      return;
    }
    // The Day screen's day on screen; from Recipes, ask — starting at the day
    // selected in Day, not always today.
    var day = widget.day;
    if (day == null) {
      final picked = await showDatePicker(
        context: context,
        initialDate: DayKey.parse(ref.read(selectedDayProvider)),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked == null || !mounted) return;
      day = DayKey.of(picked);
    }
    // Same double-tap guard as _saveRecipe: the sequential log awaits keep the
    // button live long enough to log the whole meal twice.
    if (_saving) return;
    setState(() => _saving = true);
    final dayLbl = dayLabel(context, day);
    final db = ref.read(dbProvider);
    final diary = ref.read(diaryRepositoryProvider);
    final meal =
        (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
            .inferNow();
    try {
      // Like every other add: into the meal group that's active on that day,
      // else a new one — named after this meal rather than the clock.
      final gid = await ref
          .read(activeGroupProvider.notifier)
          .ensureGroup(
            day,
            name: _name.text.trim().isEmpty
                ? l10n.ocrDefaultMealName
                : _name.text.trim(),
          );
      for (final it in ready) {
        // logFood keeps the food link, the tracked micros and the usage
        // bump — the snapshot-only path dropped all three.
        await diary.logFood(
          food: it.matched!,
          grams: _grams(it)!,
          meal: meal,
          day: day,
          groupId: gid,
        );
      }
      // Health sync is driven by the Day screen for the day it shows; a meal
      // logged to another day would otherwise wait until that day is viewed.
      await ref
          .read(healthServiceProvider)
          .maybeSyncDay(day, await db.watchDay(day).first);
      if (mounted) Navigator.of(context).pop();
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.loggedTo(dayLbl))),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
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
                  onPressed: _saving ? null : _saveRecipe,
                  child: Text(l10n.ocrSaveAsRecipe),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _logToDay,
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.ocrMealName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 104,
                  child: TextField(
                    controller: _servings,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.recipeServingsField,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
        ? '${gramsStr(it.parsed.amount)} ${it.parsed.unit!.localizedLabel(l10n)}'
        : '${gramsStr(it.parsed.amount)} ${it.parsed.rawUnit}';
    final g = _grams(it);

    return Dismissible(
      key: ValueKey('ocr-${it.id}'),
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
      child: it.matched == null && it.suggested != null
          // A best guess: named, offered, never counted until confirmed.
          ? ListTile(
              leading: Icon(
                Symbols.lightbulb_rounded,
                color: theme.colorScheme.secondary,
              ),
              title: Text(it.suggested!.name),
              subtitle: Text(l10n.ocrSuggestedFor(amountLabel, it.parsed.name)),
              trailing: TextButton(
                onPressed: () => _confirmSuggestion(it),
                child: Text(l10n.ocrUseSuggestion),
              ),
              onTap: () => _match(i),
            )
          : ListTile(
              leading: Icon(
                it.matched != null
                    ? Symbols.check_circle_rounded
                    : Symbols.help_rounded,
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
