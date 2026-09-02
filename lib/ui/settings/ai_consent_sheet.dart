import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// One-time disclosure the user must accept before the Gemini API key field
/// and the link to Google AI Studio appear.
///
/// Why a gate at all: a Gemini key is a **developer** credential on the user's
/// own Google Cloud account, and Google positions the API for professional use
/// rather than consumer use. Recruiting people into that with a bare "Get an
/// API key" button was doing them a disservice — so the app now states what it
/// means first and only then hands over the link (2026-08-30).
///
/// Deliberately **not** a timed gate. A countdown before Accept is an
/// artificial gate (ETHOS: no dark patterns) and collides with WCAG 2.2.1;
/// worse, it buys the appearance of informed consent, not the substance. The
/// checkbox is a real affirmative act and costs a fast reader nothing.
///
/// Returns true when the user accepted.
Future<bool> showAiConsentSheet(BuildContext context, WidgetRef ref) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AiConsentSheet(),
  );
  if (accepted != true) return false;
  final db = ref.read(dbProvider);
  await db.setSetting(geminiConsentSetting, '$geminiConsentVersion');
  // Stamped so a later disclosure change can tell how old the acceptance is.
  await db.setSetting(
    geminiConsentAtSetting,
    DateTime.now().toUtc().toIso8601String(),
  );
  return true;
}

class _AiConsentSheet extends StatefulWidget {
  const _AiConsentSheet();

  @override
  State<_AiConsentSheet> createState() => _AiConsentSheetState();
}

class _AiConsentSheetState extends State<_AiConsentSheet> {
  bool _understood = false;

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
        // The sheet has to stay usable at large text scales, so it scrolls
        // rather than clipping the bullets or the checkbox.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aiConsentTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              _Point(Symbols.cloud_upload_rounded, l10n.aiConsentPhoto),
              _Point(Symbols.key_rounded, l10n.aiConsentOwnKey),
              _Point(Symbols.database_rounded, l10n.aiConsentDataUse),
              _Point(Symbols.credit_card_rounded, l10n.aiConsentBilling),
              _Point(Symbols.phone_android_rounded, l10n.aiConsentLocal),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _understood,
                onChanged: (v) => setState(() => _understood = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.aiConsentCheck,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Disabled until the box is ticked: the tick *is* the
                  // consent, so Accept must not be reachable without it.
                  onPressed: _understood
                      ? () => Navigator.pop(context, true)
                      : null,
                  icon: const Icon(Symbols.auto_awesome_rounded),
                  label: Text(l10n.aiConsentAccept),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.actionCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One disclosure bullet: icon + wrapping text, sized to survive a large text
/// scale (no fixed heights, nothing truncated).
class _Point extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Point(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
