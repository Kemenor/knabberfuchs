import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gemini_error.dart';
import '../../data/ml/gemini_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Shown when an AI estimate failed for a reason the user can actually fix —
/// a rejected key, a model their key can't reach, a spent quota.
///
/// Mirrors the missing-key dialog (same shape, same route into Settings): a
/// key that is *wrong* is the same class of problem as a key that is *absent*,
/// and deserves the same treatment. It's a dialog rather than a snackbar
/// because the capture flows open a modal sheet immediately afterwards, which
/// would draw straight over a snackbar (FEEDBACK.md, 2026-08-27).
///
/// Returns true when the user left for Settings — the caller must then abandon
/// its flow rather than open a sheet on top of the Settings tab.
Future<bool> showGeminiProblemDialog(
  BuildContext context,
  WidgetRef ref,
  GeminiFailure failure,
) async {
  final l10n = AppLocalizations.of(context);
  final goToSettings = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(l10n.geminiProblemTitle),
      content: Text(geminiFailureMessage(l10n, failure)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: Text(l10n.actionContinueManually),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogCtx).pop(true),
          child: Text(l10n.actionGoToSettings),
        ),
      ],
    ),
  );
  if (goToSettings != true || !context.mounted) return false;
  ref.read(homeTabProvider.notifier).set(HomeTab.settings);
  ref.read(settingsScrollProvider.notifier).request(settingsSectionAi);
  return true;
}
