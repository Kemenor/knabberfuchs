import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Loading dialog shown while polling Gemini (photo scan and describe-meal
/// flows). Cycles through reassuring status lines so a slow request doesn't
/// look frozen, and after ~13 s adds a "Gemini is busy" note. The model
/// fallback (preferred → 2.5) is transparent. [onCancel] must both dismiss
/// this dialog and abort the flow — the request itself can't be cancelled,
/// only its result ignored.
class GeminiLoadingDialog extends StatefulWidget {
  final VoidCallback onCancel;
  const GeminiLoadingDialog({super.key, required this.onCancel});

  @override
  State<GeminiLoadingDialog> createState() => _GeminiLoadingDialogState();
}

class _GeminiLoadingDialogState extends State<GeminiLoadingDialog> {
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
