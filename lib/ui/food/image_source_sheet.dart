import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

/// Shared "Take a photo / Choose from gallery" chooser, so every image-capture
/// feature (AI scan, nutrition-label scan, ingredient-list OCR) behaves
/// identically. [cameraLabel] overrides the default "Take a photo" wording.
/// Returns the chosen [ImageSource], or null if dismissed.
Future<ImageSource?> pickImageSource(
  BuildContext context, {
  String? cameraLabel,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(cameraLabel ?? l10n.recognizeTakePhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.addChooseGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}
