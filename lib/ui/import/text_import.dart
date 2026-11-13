import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/snackbar.dart';
import '../../core/text_prompt_dialog.dart';
import '../../domain/ai_block.dart';
import '../../domain/ocr_ingredient.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../recipes/ocr_meal_screen.dart';

/// Text that arrives from outside — pasted, or shared in from another app
/// (an AI app, a website, a note) — routed to where it belongs:
///
/// - a `CTR1:` recipe code imports as a recipe, as the QR/paste import always
///   did;
/// - anything else is read as an ingredient list (heading → name, "Serves 4" →
///   servings) and opens the review screen, which matches each line to the
///   user's foods and saves it as a recipe or logs it.
///
/// [day] is where "Log to day" logs: the Day screen passes the day on screen;
/// null (Recipes) asks for a day.
Future<void> handleImportedText(
  BuildContext context,
  WidgetRef ref,
  String text, {
  String? day,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final trimmed = text.trim();
  if (trimmed.isEmpty) return;

  final recipe = RecipeCodec.decode(trimmed);
  if (recipe != null) {
    await ref.read(recipeRepositoryProvider).importShare(recipe);
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.recipeImported(recipe.name))),
    );
    return;
  }

  // The structured answer an AI app gives when it follows the copied
  // instructions — items may carry their own estimates.
  final block = findAiBlock(trimmed);
  if (block != null && block.items.isNotEmpty) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => OcrMealScreen(
          ingredients: block.items,
          initialName: block.name ?? l10n.importedMealName,
          initialServings: block.servings,
          day: block.day ?? day,
          meal: block.meal,
        ),
      ),
    );
    return;
  }

  final list = parseIngredientText(trimmed);
  if (list.items.isEmpty) {
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.pasteNothingFound)));
    return;
  }
  navigator.push(
    MaterialPageRoute(
      builder: (_) => OcrMealScreen(
        ingredients: list.items,
        initialName: list.title ?? l10n.importedMealName,
        initialServings: list.servings,
        day: day,
      ),
    ),
  );
}

/// The paste dialog, pre-filled from the clipboard (the usual path: copy in
/// the AI app, come here), then [handleImportedText].
Future<void> startPasteFlow(
  BuildContext context,
  WidgetRef ref, {
  String? day,
}) async {
  final l10n = AppLocalizations.of(context);
  final clip = await Clipboard.getData(Clipboard.kTextPlain);
  if (!context.mounted) return;
  final text = await showTextPromptDialog(
    context,
    title: l10n.importTextTitle,
    confirmLabel: l10n.actionImport,
    cancelLabel: l10n.actionCancel,
    initial: clip?.text?.trim(),
    hintText: l10n.importTextHint,
    minLines: 4,
    maxLines: 10,
    outlined: true,
  );
  if (text == null || !context.mounted) return;
  await handleImportedText(context, ref, text, day: day);
}
