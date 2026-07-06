import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/food_icon.dart';
import '../../core/format.dart';
import '../../core/metric_labels.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Read-only per-meal nutrition breakdown (grilled 2026-07-03): the meal's
/// totals for kcal + every enabled tracked nutrient, then each ingredient with
/// its own stats. Editing stays on the Day screen — this page only answers
/// "how much protein was breakfast?". Watches the live day summary so edits
/// made after opening (or a deleted meal) resolve instead of going stale.
class MealDetailScreen extends ConsumerWidget {
  final int groupId;
  const MealDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(dayGroupViewsProvider);
    final enabled =
        ref.watch(trackedNutrientsProvider).asData?.value ??
        defaultTrackedNutrients;

    GroupView? group;
    for (final g in groups) {
      if (g.id == groupId) group = g;
    }
    // Meal deleted while open (e.g. via a lagging snackbar action) — leave.
    if (group == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final subtotal = group.subtotal;

    // Distinct photos across the group's entries (AI-recognized items carry
    // one), resolved against the photos dir. Files can be gone after a backup
    // restore on another device — each image hides itself on load error.
    final photoDir = ref.watch(mealPhotoDirProvider).asData?.value;
    final photos = photoDir == null
        ? const <File>[]
        : [
            for (final name in {
              for (final it in group.items)
                if (it.entry.photoPath != null) it.entry.photoPath!,
            })
              File('$photoDir/$name'),
          ];

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          if (photos.isNotEmpty) _PhotoBanner(photos: photos),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.kcalValue(kcalStr(subtotal.kcal)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final m in TargetMetric.values)
                    if (m != TargetMetric.kcal && enabled.contains(m))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(metricLabel(l10n, m)),
                            Text(
                              l10n.gramsValue(
                                gramsStr(metricValue(subtotal, m)),
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              l10n.ingredients.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  _IngredientTile(view: group.items[i], enabled: enabled),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The meal's photo(s) above the totals card: one photo fills the width, more
/// become a horizontal strip. Tapping opens the full-screen viewer. A missing
/// file renders nothing (errorBuilder), so a dangling photoPath after a
/// backup restore leaves the page clean.
class _PhotoBanner extends StatelessWidget {
  final List<File> photos;
  const _PhotoBanner({required this.photos});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget photo(File f, {double? width}) => Semantics(
      label: l10n.a11yMealPhotoOpen,
      button: true,
      image: true,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _PhotoViewerScreen(file: f)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            f,
            height: 180,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

    if (photos.length == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: photo(photos.first, width: double.infinity),
      );
    }
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => photo(photos[i], width: 240),
      ),
    );
  }
}

/// Full-screen, zoomable view of a meal photo (dark, like a gallery).
class _PhotoViewerScreen extends StatelessWidget {
  final File file;
  const _PhotoViewerScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.file(
            file,
            fit: BoxFit.contain,
            semanticLabel: l10n.a11yMealPhoto,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final EntryView view;
  final Set<TargetMetric> enabled;
  const _IngredientTile({required this.view, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final spans = nutrientSpans(l10n, view.nutrition, enabled);
    return ListTile(
      leading: Icon(foodIconFor(view.name), color: theme.colorScheme.primary),
      title: Text(view.name),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: l10n.gramsValue(gramsStr(view.grams))),
            if (spans.isNotEmpty) ...[const TextSpan(text: ' · '), ...spans],
          ],
        ),
      ),
      trailing: Text(l10n.kcalValue(kcalStr(view.nutrition.kcal))),
    );
  }
}
