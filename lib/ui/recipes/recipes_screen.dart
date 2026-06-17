import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/ocr_ingredient.dart';
import '../../domain/recipe_share.dart';
import '../../providers.dart';
import '../scan/scan_screen.dart';
import 'ocr_meal_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_edit_screen.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    Future<void> importFromQr() async {
      final messenger = ScaffoldMessenger.of(context);
      final text = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => const ScanScreen(
            formats: [BarcodeFormat.qrCode],
            title: 'Scan recipe QR',
            allowManual: false,
          ),
        ),
      );
      if (text == null) return;
      final share = RecipeCodec.decode(text);
      if (share == null) {
        messenger.showAutoSnackBar(
            const SnackBar(content: Text('That QR code is not a recipe.')));
        return;
      }
      await ref.read(recipeRepositoryProvider).importShare(share);
      messenger.showAutoSnackBar(
          SnackBar(content: Text('Imported "${share.name}"')));
    }

    Future<void> importFromPhotos() async {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final files = await openFiles(acceptedTypeGroups: const [
        XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp']),
      ]);
      if (files.isEmpty || !context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final ocr = ref.read(ocrServiceProvider);
      final all = <OcrIngredient>[];
      for (final f in files) {
        try {
          all.addAll(await ocr.ingredientsFromImage(f.path));
        } catch (_) {/* skip unreadable image */}
      }
      navigator.pop(); // close the loading dialog

      if (all.isEmpty) {
        messenger.showAutoSnackBar(const SnackBar(
            content: Text('No ingredients found in those images.')));
        return;
      }
      navigator.push(MaterialPageRoute(
          builder: (_) => OcrMealScreen(ingredients: all)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            tooltip: 'Create from photo(s)',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: importFromPhotos,
          ),
          IconButton(
            tooltip: 'Import from QR',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: importFromQr,
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No recipes yet.\nCreate one to reuse meals, share them, '
                  'or batch-cook and split across days.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: recipes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = recipes[i];
              return ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(r.name),
                subtitle: Text('${r.servings.toStringAsFixed(r.servings == r.servings.roundToDouble() ? 0 : 1)} servings'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New recipe'),
      ),
    );
  }
}
