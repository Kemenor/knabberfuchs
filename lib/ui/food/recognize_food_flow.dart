import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/snackbar.dart';
import '../../data/ml/gemini_service.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'gemini_loading_dialog.dart';
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

/// Photo → Gemini estimate → prefilled Quick add. Gemini-only since the
/// on-device classifier was removed (uniformly negative feedback; FEEDBACK.md
/// 2026-07-03): keyless users get the key nudge plus a plain Quick add sheet,
/// so the tap still ends in a logged meal. Returns true if an item was logged.
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
  final db = ref.read(dbProvider);
  final geminiKey = await ref.read(geminiKeyStoreProvider).read();
  if (!context.mounted) return false;

  if (geminiKey == null) {
    // No key → explain how to unlock the feature instead of dropping into a
    // plain Quick add (testers misread that as the scan having "worked").
    final goToSettings = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.recognizeKeyMissingTitle),
        content: Text(l10n.recognizeKeyMissingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.actionGoToSettings),
          ),
        ],
      ),
    );
    if (goToSettings == true && context.mounted) {
      ref.read(homeTabProvider.notifier).set(HomeTab.settings);
      ref.read(settingsScrollProvider.notifier).request(settingsSectionAi);
    }
    return false;
  }

  final bytes = await ref.read(mealImagePickerProvider)(context);
  if (bytes == null || !context.mounted) return false;
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
      child: GeminiLoadingDialog(
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
          geminiKey,
          preferredModel: preferredModel,
          description: hint,
          isCancelled: () => cancelled,
        );
  } catch (_) {}
  if (cancelled) return false;
  if (context.mounted) navigator.pop();
  if (!context.mounted) return false;
  if (r == null) {
    // No on-device fallback anymore — land in a blank Quick add so the
    // photo effort still ends in a manual entry.
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.geminiFailed)));
  }
  return await showQuickAddSheet(
        context,
        ref,
        day: day,
        meal: meal,
        resolveGroup: resolveGroup,
        initialName: r?.name,
        initialKcal: r?.kcal.round(),
        initialProtein: r?.protein,
        initialCarb: r?.carb,
        initialFat: r?.fat,
        initialWeight: r?.grams,
        sourceLabel: r == null ? null : l10n.recognizeByGemini,
        // Kept even when recognition failed — it's still a photo of the meal
        // being logged, and Meal detail can show it.
        photoBytes: bytes,
      ) ==
      true;
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
