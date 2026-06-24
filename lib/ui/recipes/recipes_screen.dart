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

    // Decode a shared payload (from QR or pasted text) and import it.
    // [messenger] is captured before the await so there's no context-after-gap.
    Future<void> applyImport(
      ScaffoldMessengerState messenger,
      String? text,
    ) async {
      final share = text == null ? null : RecipeCodec.decode(text.trim());
      if (share == null) {
        messenger.showAutoSnackBar(SnackBar(content: Text(l10n.qrNotRecipe)));
        return;
      }
      await ref.read(recipeRepositoryProvider).importShare(share);
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.recipeImported(share.name))),
      );
    }

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
      await applyImport(messenger, text);
    }

    Future<void> importFromText() async {
      final messenger = ScaffoldMessenger.of(context);
      final controller = TextEditingController();
      String? text;
      try {
        text = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.importTextTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.importTextHint,
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: Text(l10n.actionImport),
              ),
            ],
          ),
        );
      } finally {
        controller.dispose();
      }
      if (text == null || text.trim().isEmpty) return;
      await applyImport(messenger, text);
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
                  );
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
              ListTile(
                leading: const Icon(Icons.content_paste),
                title: Text(l10n.createFromText),
                subtitle: Text(l10n.createFromTextSub),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  importFromText();
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
                child: Text(l10n.recipesEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            itemCount: recipes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = recipes[i];
              final theme = Theme.of(context);
              return Dismissible(
                key: ValueKey('recipe-${r.id}'),
                // Swipe → log a portion; swipe ← delete. Both perform their
                // action and return false (the recipes stream redraws the list).
                background: Container(
                  color: theme.colorScheme.primaryContainer,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.event_available,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                secondaryBackground: Container(
                  color: theme.colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (dir) async {
                  if (dir == DismissDirection.startToEnd) {
                    await showLogPortionForRecipe(context, ref, r);
                    return false;
                  }
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.recipeDeleteConfirm(r.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.actionCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.actionDelete),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(recipeRepositoryProvider).delete(r.id);
                  }
                  return false;
                },
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(r.name),
                  subtitle: Text(
                    l10n.recipeServings(
                      r.servings.toStringAsFixed(
                        r.servings == r.servings.roundToDouble() ? 0 : 1,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recipesNewFab',
        onPressed: showCreateMenu,
        icon: const Icon(Icons.add),
        label: Text(l10n.recipeNew),
      ),
    );
  }
}
