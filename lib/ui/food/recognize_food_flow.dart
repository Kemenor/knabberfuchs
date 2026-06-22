import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/snackbar.dart';
import '../../data/ml/food_classifier.dart';
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
  final img = await ImagePicker()
      .pickImage(source: source, maxWidth: 1024, imageQuality: 85);
  if (img == null || !context.mounted) return false;
  final bytes = await img.readAsBytes();
  if (!context.mounted) return false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
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
  final added = await showQuickAddSheet(context, ref,
      day: day,
      meal: meal,
      resolveGroup: resolveGroup,
      initialName: name,
      initialKcal: kcal);
  return added == true;
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
                trailing: Text('${(g.score * 100).round()}%',
                    style: theme.textTheme.bodySmall),
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
