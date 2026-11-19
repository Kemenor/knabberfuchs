import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/snackbar.dart';
import '../../domain/ai_block.dart';
import '../../domain/ai_instructions.dart' show AiTask;
import '../../domain/ocr_ingredient.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../ai/ai_helper_screen.dart' show aiInstructionsFor;
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
///
/// It carries the whole AI round trip (PLAN "AI bridge"): two short steps and
/// the prompt to copy — the meal prompt on the Day screen ([day] set), the
/// recipe prompt from Recipes — and when the user comes back from their AI
/// app with its answer on the clipboard, the answer fills the field.
Future<void> startPasteFlow(
  BuildContext context,
  WidgetRef ref, {
  String? day,
}) async {
  final clip = await Clipboard.getData(Clipboard.kTextPlain);
  if (!context.mounted) return;
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _PasteDialog(
      initial: clip?.text?.trim(),
      task: day == null ? AiTask.adaptRecipe : AiTask.logMeal,
    ),
  );
  if (text == null || !context.mounted) return;
  await handleImportedText(context, ref, text, day: day);
}

class _PasteDialog extends ConsumerStatefulWidget {
  const _PasteDialog({required this.initial, required this.task});

  final String? initial;
  final AiTask task;

  @override
  ConsumerState<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends ConsumerState<_PasteDialog>
    with WidgetsBindingObserver {
  // Owned here so it is disposed with the route (see text_prompt_dialog.dart).
  late final _ctrl = TextEditingController(text: widget.initial);

  /// The prompt last copied; null until the user copies it. While set, coming
  /// back to the app takes the clipboard as the AI's answer.
  String? _prompt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _prompt != null) _takeAnswer();
  }

  Future<void> _takeAnswer() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim();
    if (!mounted || text == null || text.isEmpty || text == _prompt) return;
    setState(() => _ctrl.text = text);
  }

  Future<void> _copyPrompt() async {
    final prompt = await aiInstructionsFor(context, ref, widget.task);
    await Clipboard.setData(ClipboardData(text: prompt));
    // Whatever was pre-filled is stale now — the answer will replace it.
    if (mounted) {
      setState(() {
        _prompt = prompt;
        _ctrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final copied = _prompt != null;
    final forDay = widget.task == AiTask.logMeal;
    return AlertDialog(
      title: Text(forDay ? l10n.capturePaste : l10n.importTextTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              forDay ? l10n.aiPasteStepsLog : l10n.aiPasteStepsRecipe,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                onPressed: _copyPrompt,
                icon: Icon(
                  copied ? Symbols.check_rounded : Symbols.content_copy_rounded,
                  size: 18,
                ),
                label: Text(copied ? l10n.aiPromptCopied : l10n.aiCopyPrompt),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: forDay ? l10n.aiPasteHint : l10n.importTextHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(l10n.actionImport),
        ),
      ],
    );
  }
}
