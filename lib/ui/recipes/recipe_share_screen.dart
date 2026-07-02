import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';

/// Shows a scannable QR for the recipe plus share-as-image and share-as-text.
/// Fully serverless — the QR/payload is self-contained (calories + macros).
class RecipeShareScreen extends StatefulWidget {
  final RecipeShare share;
  const RecipeShareScreen({super.key, required this.share});

  @override
  State<RecipeShareScreen> createState() => _RecipeShareScreenState();
}

class _RecipeShareScreenState extends State<RecipeShareScreen> {
  final _qrKey = GlobalKey();

  Future<void> _shareImage(String subject) async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/recipe_qr.png');
    await file.writeAsBytes(data.buffer.asUint8List());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    final share = widget.share;
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
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Semantics(
                    image: true,
                    label: l10n.a11yQrCode(share.name),
                    child: QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      size: 260,
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(share.name, style: theme.textTheme.titleMedium),
              Text(
                l10n.shareMeta(
                  share.items.length,
                  share.servings,
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
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          _shareImage(l10n.shareSubject(share.name)),
                      icon: const Icon(Symbols.image_rounded),
                      label: Text(l10n.shareAsImage),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text: payload,
                          subject: l10n.shareSubject(share.name),
                        ),
                      ),
                      icon: const Icon(Symbols.notes_rounded),
                      label: Text(l10n.shareAsText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
