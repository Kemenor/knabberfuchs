import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';

/// Shows a scannable QR for the recipe plus a text/file share fallback.
/// Fully serverless — the QR/payload is self-contained (calories + macros).
class RecipeShareScreen extends StatelessWidget {
  final RecipeShare share;
  const RecipeShareScreen({super.key, required this.share});

  @override
  Widget build(BuildContext context) {
    final payload = RecipeCodec.encode(share);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareTitle(share.name))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 260,
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(share.name, style: theme.textTheme.titleMedium),
              Text(
                l10n.shareMeta(
                  '${share.items.length}',
                  share.servings.toStringAsFixed(0),
                  '${payload.length}',
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.shareScanHint,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text: payload,
                    subject: l10n.shareSubject(share.name),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: Text(l10n.shareAsText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
