import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/snackbar.dart';
import '../../data/ml/food_classifier.dart';
import '../../data/ml/gemini_service.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'image_source_sheet.dart';
import 'quick_add_sheet.dart';

/// Acquires a meal photo for AI recognition — the camera/gallery chooser, then
/// the system image picker (down-scaled). Overridable in tests so the
/// screenshot harness can feed a bundled photo without driving the native picker.
final mealImagePickerProvider =
    Provider<Future<Uint8List?> Function(BuildContext)>((ref) {
  return (context) async {
    final source = await pickImageSource(context);
    if (source == null || !context.mounted) return null;
    final img = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (img == null) return null;
    return img.readAsBytes();
  };
});

/// Photo → on-device dish guess → Free add. Pick a photo, classify it with the
/// AIY food model, let the user confirm which guess it is, estimate the
/// calories from the local catalog, and open the Free add sheet prefilled.
/// Returns true if an item was logged.
Future<bool> startRecognizeFoodFlow(
  BuildContext context,
  WidgetRef ref, {
  required String day,
  required MealType meal,
  Future<int?> Function()? resolveGroup,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final bytes = await ref.read(mealImagePickerProvider)(context);
  if (bytes == null || !context.mounted) return false;

  // Cloud path: if the user configured a (free-tier) Gemini key, use it for a
  // richer estimate — dish + grams + macros. Falls back to on-device on any
  // failure so the feature still works offline / when the key is bad.
  final db = ref.read(dbProvider);
  final geminiKey = await db.getSetting(geminiKeySetting);
  final onDeviceOnly = await db.getSetting(aiOnDeviceOnlySetting) == 'true';
  final noGeminiKey = geminiKey == null || geminiKey.trim().isEmpty;
  if (geminiKey != null && geminiKey.trim().isNotEmpty && !onDeviceOnly) {
    if (!context.mounted) return false;
    final preferredModel = await db.getSetting(geminiModelSetting);
    if (!context.mounted) return false;
    // Optional hint: let the user add a short description to disambiguate the
    // photo before sending. Dismissing the sheet cancels the whole flow.
    final hint = await _askGeminiHint(context, bytes);
    if (hint == null || !context.mounted) return false;
    // Cancel pops the dialog itself and raises this flag; an in-flight request
    // can't be aborted, but the service polls the flag so the photo is never
    // re-sent to the fallback model, and the late result must be discarded
    // without touching the navigator — the pop below would otherwise take
    // whatever route is on top.
    var cancelled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      // canPop:false blocks the hardware back button too, so the matching
      // navigator.pop() always closes this dialog, not the screen beneath it.
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: _GeminiLoadingDialog(
          onCancel: () {
            cancelled = true;
            Navigator.of(dialogCtx).pop();
          },
        ),
      ),
    );
    GeminiFoodResult? r;
    try {
      r = await ref
          .read(geminiServiceProvider)
          .recognizeFood(
            bytes,
            geminiKey.trim(),
            preferredModel: preferredModel,
            description: hint,
            isCancelled: () => cancelled,
          );
    } catch (_) {}
    if (cancelled) return false;
    if (context.mounted) navigator.pop();
    if (!context.mounted) return false;
    if (r != null) {
      return await showQuickAddSheet(
            context,
            ref,
            day: day,
            meal: meal,
            resolveGroup: resolveGroup,
            initialName: r.name,
            initialKcal: r.kcal.round(),
            initialProtein: r.protein,
            initialCarb: r.carb,
            initialFat: r.fat,
            initialWeight: r.grams,
            sourceLabel: l10n.recognizeByGemini,
          ) ==
          true;
    }
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.geminiFailed)));
    // fall through to the on-device classifier
  }
  if (!context.mounted) return false;

  showDialog(
    context: context,
    barrierDismissible: false,
    // canPop:false blocks the hardware back button so the matching
    // navigator.pop() always closes this dialog, not a route underneath it.
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
  List<FoodGuess> guesses;
  try {
    guesses = await ref.read(foodClassifierProvider).classify(bytes);
  } catch (_) {
    guesses = const [];
  }
  if (context.mounted) navigator.pop(); // close loading
  if (!context.mounted) return false;

  String? chosen;
  if (guesses.isEmpty) {
    // On-device drew a blank — the best moment to point at the (free) cloud
    // path, which also handles drinks the on-device model can't.
    messenger.showAutoSnackBar(
      SnackBar(
        content: Text(noGeminiKey ? l10n.recognizeGeminiNudge : l10n.recognizeNoGuess),
      ),
    );
  } else {
    chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _GuessSheet(image: bytes, guesses: guesses, showGeminiNudge: noGeminiKey),
    );
    if (chosen == null || !context.mounted) return false; // dismissed
  }

  // chosen == '' → "none of these"/no guesses → Free add with no name.
  final name = (chosen != null && chosen.isNotEmpty) ? chosen : null;
  final kcal = name == null
      ? null
      : await ref.read(foodRepositoryProvider).estimateKcalForLabel(name);
  if (!context.mounted) return false;
  final added = await showQuickAddSheet(
    context,
    ref,
    day: day,
    meal: meal,
    resolveGroup: resolveGroup,
    initialName: name,
    initialKcal: kcal,
    sourceLabel: name != null ? l10n.recognizeByOnDevice : null,
  );
  return added == true;
}

/// Optional pre-send hint sheet (Gemini path): shows the chosen photo + a free-
/// text field so the user can disambiguate an ambiguous meal before Gemini sees
/// it. Returns the (possibly empty) hint when "Estimate" is tapped, or null if
/// the sheet is dismissed (which cancels the whole flow).
Future<String?> _askGeminiHint(BuildContext context, Uint8List image) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _GeminiHintSheet(image: image),
  );
}

class _GeminiHintSheet extends StatefulWidget {
  final Uint8List image;
  const _GeminiHintSheet({required this.image});

  @override
  State<_GeminiHintSheet> createState() => _GeminiHintSheetState();
}

class _GeminiHintSheetState extends State<_GeminiHintSheet> {
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
            Text(l10n.geminiHintTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: l10n.a11ySelectedPhoto,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (v) => Navigator.pop(context, v),
              decoration: InputDecoration(
                labelText: l10n.geminiHintLabel,
                hintText: l10n.geminiHintExample,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, _ctrl.text),
                icon: const Icon(Symbols.auto_awesome_rounded),
                label: Text(l10n.geminiHintEstimate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading dialog shown while polling Gemini. Cycles through reassuring status
/// lines so a slow request doesn't look frozen, and after ~13 s adds a "Gemini
/// is busy" note. The model fallback (preferred → 2.5) is transparent.
/// [onCancel] must both dismiss this dialog and abort the flow — the request
/// itself can't be cancelled, only its result ignored.
class _GeminiLoadingDialog extends StatefulWidget {
  final VoidCallback onCancel;
  const _GeminiLoadingDialog({required this.onCancel});

  @override
  State<_GeminiLoadingDialog> createState() => _GeminiLoadingDialogState();
}

class _GeminiLoadingDialogState extends State<_GeminiLoadingDialog> {
  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final messages = [
      l10n.geminiThinking1,
      l10n.geminiThinking2,
      l10n.geminiThinking3,
      l10n.geminiThinking4,
      l10n.geminiThinking5,
      l10n.geminiThinking6,
    ];
    final msg = messages[_step % messages.length];
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(semanticsLabel: l10n.a11yAnalysing),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                msg,
                key: ValueKey(msg),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            // After ~13 s, reassure that it's just slow/busy (not frozen).
            if (_step >= 6)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.geminiSlow,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onCancel,
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuessSheet extends StatelessWidget {
  final Uint8List image;
  final List<FoodGuess> guesses;
  final bool showGeminiNudge;
  const _GuessSheet({
    required this.image,
    required this.guesses,
    this.showGeminiNudge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: l10n.a11ySelectedPhoto,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.recognizeLooksLike, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final g in guesses)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Symbols.restaurant_rounded),
                title: Text(g.label),
                trailing: Text(
                  '${(g.score * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () => Navigator.pop(context, g.label),
              ),
            const Divider(),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ''),
              icon: const Icon(Symbols.edit_rounded),
              label: Text(l10n.recognizeNoneManual),
            ),
            if (showGeminiNudge)
              Padding(
                padding: const EdgeInsets.only(top: 4),
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
          ],
        ),
      ),
    );
  }
}
