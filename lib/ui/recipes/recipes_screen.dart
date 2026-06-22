import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/snackbar.dart';
import '../../domain/recipe_share.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    Future<void> importFromQr() async {
      final messenger = ScaffoldMessenger.of(context);
      final text = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => ScanScreen(
            formats: const [BarcodeFormat.qrCode],
            title: l10n.scanRecipeQr,
            allowManual: false,
          ),
        ),
      );
      if (text == null) return;
      final share = RecipeCodec.decode(text);
      if (share == null) {
        messenger.showAutoSnackBar(
            SnackBar(content: Text(l10n.qrNotRecipe)));
        return;
      }
      await ref.read(recipeRepositoryProvider).importShare(share);
      messenger.showAutoSnackBar(
          SnackBar(content: Text(l10n.recipeImported(share.name))));
    }

    // One menu for every way to create a recipe, replacing the old bare FAB +
    // two unlabeled app-bar icons.
    void showCreateMenu() {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetCtx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.createBuildManually),
                subtitle: Text(l10n.createBuildManuallySub),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const RecipeEditScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: Text(l10n.createFromList),
                subtitle: Text(l10n.createFromListSub),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  startOcrMealFlow(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(l10n.createFromQr),
                subtitle: Text(l10n.createFromQrSub),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  importFromQr();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipesTitle)),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError('$e'))),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.recipesEmpty,
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
                subtitle: Text(l10n.recipeServings(r.servings
                    .toStringAsFixed(
                        r.servings == r.servings.roundToDouble() ? 0 : 1))),
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
        onPressed: showCreateMenu,
        icon: const Icon(Icons.add),
        label: Text(l10n.recipeNew),
      ),
    );
  }
}
