import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/snackbar.dart';
import '../../data/ml/food_classifier.dart';
import '../../data/ml/gemini_service.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'image_source_sheet.dart';
import 'quick_add_sheet.dart';

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
  final source = await pickImageSource(context);
  if (source == null || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final img = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    imageQuality: 85,
  );
  if (img == null || !context.mounted) return false;
  final bytes = await img.readAsBytes();
  if (!context.mounted) return false;

  // Cloud path: if the user configured a (free-tier) Gemini key, use it for a
  // richer estimate — dish + grams + macros. Falls back to on-device on any
  // failure so the feature still works offline / when the key is bad.
  final db = ref.read(dbProvider);
  final geminiKey = await db.getSetting(geminiKeySetting);
  final onDeviceOnly = await db.getSetting(aiOnDeviceOnlySetting) == 'true';
  if (geminiKey != null && geminiKey.trim().isNotEmpty && !onDeviceOnly) {
    if (!context.mounted) return false;
    final preferredModel = await db.getSetting(geminiModelSetting);
    if (!context.mounted) return false;
    showDialog(
      context: context,
      barrierDismissible: false,
      // canPop:false blocks the hardware back button too, so the matching
      // navigator.pop() always closes this dialog, not the screen beneath it.
      builder: (_) =>
          const PopScope(canPop: false, child: _GeminiLoadingDialog()),
    );
    GeminiFoodResult? r;
    try {
      r = await ref
          .read(geminiServiceProvider)
          .recognizeFood(
            bytes,
            geminiKey.trim(),
            preferredModel: preferredModel,
          );
    } catch (_) {}
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
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.recognizeNoGuess)));
  } else {
    chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _GuessSheet(image: bytes, guesses: guesses),
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

/// Loading dialog shown while polling Gemini. Cycles through reassuring status
/// lines so a slow request doesn't look frozen, and after ~13 s adds a "Gemini
/// is busy" note. The model fallback (preferred → 2.5) is transparent.
class _GeminiLoadingDialog extends StatefulWidget {
  const _GeminiLoadingDialog();

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
            const CircularProgressIndicator(),
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
          ],
        ),
      ),
    );
  }
}

class _GuessSheet extends StatelessWidget {
  final Uint8List image;
  final List<FoodGuess> guesses;
  const _GuessSheet({required this.image, required this.guesses});

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
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.recognizeLooksLike, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final g in guesses)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.restaurant),
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
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.recognizeNoneManual),
            ),
          ],
        ),
      ),
    );
  }
}
