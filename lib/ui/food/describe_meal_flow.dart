import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/date_label.dart';
import '../../core/snackbar.dart';
import '../../data/ml/gemini_service.dart';
import '../../domain/meal_times.dart';
import '../../domain/ocr_ingredient.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../recipes/ocr_meal_screen.dart';
import 'gemini_loading_dialog.dart';

/// "Describe meal": type what you ate, no photo (grilled 2026-07-03).
/// With a Gemini key the description comes back ITEMIZED and logs as one meal
/// group with an entry per component. Keyless (or when Gemini fails) the same
/// text feeds the local catalog matcher instead — the OCR-ingredient review
/// screen with per-line pickers — so the flow works offline with real
/// nutrition data. Returns true when something was logged directly.
Future<bool> startDescribeMealFlow(
  BuildContext context,
  WidgetRef ref, {
  required String day,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final db = ref.read(dbProvider);
  final geminiKey = await ref.read(geminiKeyStoreProvider).read();
  final hasKey = geminiKey != null;
  if (!context.mounted) return false;

  final description = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DescribeMealSheet(showKeyNudge: !hasKey),
  );
  if (description == null || description.trim().isEmpty) return false;
  if (!context.mounted) return false;

  if (hasKey) {
    final preferredModel = await db.getSetting(geminiModelSetting);
    if (!context.mounted) return false;
    var cancelled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      // canPop:false blocks the hardware back button too, so the matching
      // navigator.pop() always closes this dialog, not the screen beneath it.
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: GeminiLoadingDialog(
          onCancel: () {
            cancelled = true;
            Navigator.of(dialogCtx).pop();
          },
        ),
      ),
    );
    GeminiMealResult? r;
    try {
      r = await ref
          .read(geminiServiceProvider)
          .estimateMealFromText(
            description,
            geminiKey,
            preferredModel: preferredModel,
            isCancelled: () => cancelled,
          );
    } catch (_) {}
    if (cancelled) return false;
    if (context.mounted) navigator.pop();
    if (!context.mounted) return false;
    if (r != null) {
      final dayLbl = dayLabel(context, day);
      await _logItemized(ref, day: day, result: r, l10n: l10n);
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.loggedTo(dayLbl))),
      );
      return true;
    }
    // Gemini unreachable/non-food — degrade to the local matcher below.
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.geminiFailed)));
    if (!context.mounted) return false;
  }

  final items = _parseTypedLines(description);
  if (items.isEmpty) {
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.describeMealNoLines)),
    );
    return false;
  }
  navigator.push(
    MaterialPageRoute(builder: (_) => OcrMealScreen(ingredients: items)),
  );
  return false; // the review screen logs on its own terms
}

/// Log an itemized Gemini estimate as one meal group, one snapshot entry per
/// component. Gemini returns per-portion TOTALS; entries store per-100 g, so
/// scale by the (possibly estimated) grams.
Future<void> _logItemized(
  WidgetRef ref, {
  required String day,
  required GeminiMealResult result,
  required AppLocalizations l10n,
}) async {
  final db = ref.read(dbProvider);
  final diary = ref.read(diaryRepositoryProvider);
  final meal = (ref.read(mealTimesProvider).asData?.value ?? MealTimes.defaults)
      .inferNow();
  final gid = await db.createEntryGroup(
    day,
    result.name?.isNotEmpty == true ? result.name! : l10n.ocrDefaultMealName,
  );
  for (final item in result.items) {
    final grams = (item.grams != null && item.grams! > 0) ? item.grams! : 100.0;
    final factor = grams / 100.0;
    await diary.logSnapshot(
      name: item.name,
      kcal100: item.kcal / factor,
      protein100: item.protein == null ? null : item.protein! / factor,
      carb100: item.carb == null ? null : item.carb! / factor,
      fat100: item.fat == null ? null : item.fat! / factor,
      grams: grams,
      meal: meal,
      day: day,
      groupId: gid,
    );
  }
}

/// Parse typed description lines into matchable ingredients. Reuses the OCR
/// line grammar ("Reis 150 g") but is forgiving where OCR must be strict: a
/// line without a trailing amount+unit is kept as a count-style ingredient
/// ("1 x") instead of dropped — the review screen resolves its grams via the
/// matched food's serving size or a manual entry.
List<OcrIngredient> _parseTypedLines(String description) {
  final out = <OcrIngredient>[];
  for (final raw in description.split(RegExp(r'[\n,;]+'))) {
    final line = raw.trim();
    if (line.length < 2) continue;
    final parsed = parseIngredientLines([line]);
    out.add(
      parsed.isNotEmpty
          ? parsed.first
          : OcrIngredient(name: line, amount: 1, unit: null, rawUnit: 'x'),
    );
  }
  return out;
}

class _DescribeMealSheet extends StatefulWidget {
  final bool showKeyNudge;
  const _DescribeMealSheet({required this.showKeyNudge});

  @override
  State<_DescribeMealSheet> createState() => _DescribeMealSheetState();
}

class _DescribeMealSheetState extends State<_DescribeMealSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
            Text(l10n.describeMealTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.describeMealLabel,
                hintText: l10n.describeMealExample,
                border: const OutlineInputBorder(),
              ),
            ),
            if (widget.showKeyNudge)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Symbols.auto_awesome_rounded,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.recognizeGeminiNudge,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _ctrl.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, _ctrl.text),
                icon: const Icon(Symbols.edit_note_rounded),
                label: Text(l10n.geminiHintEstimate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
