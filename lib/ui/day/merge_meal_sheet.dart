import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Sheet to merge a meal group into another group of the same day: pick the
/// target from a list; the source's entries move over and the source is
/// deleted (the inverse of split).
Future<void> showMergeMealSheet(BuildContext context, GroupView group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MergeSheet(group: group),
  );
}

class _MergeSheet extends ConsumerStatefulWidget {
  final GroupView group;
  const _MergeSheet({required this.group});

  @override
  ConsumerState<_MergeSheet> createState() => _MergeSheetState();
}

class _MergeSheetState extends ConsumerState<_MergeSheet> {
  List<(EntryGroup, double)>? _targets; // (group, subtotal kcal)
  bool _merging = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// The day's other groups with their subtotal kcal, so two same-named
  /// "Snack" groups are still distinguishable in the picker.
  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final groups = await db.watchGroups(widget.group.group.day).first;
    final targets = <(EntryGroup, double)>[];
    for (final g in groups) {
      if (g.id == widget.group.id) continue;
      final items = await db.entriesForGroup(g.id);
      final kcal = items.fold<double>(
        0,
        (sum, e) => sum + e.grams * e.sKcal100 / 100,
      );
      targets.add((g, kcal));
    }
    if (mounted) setState(() => _targets = targets);
  }

  Future<void> _merge(EntryGroup target) async {
    if (_merging) return; // guard against a double-tap before the sheet pops
    setState(() => _merging = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(diaryRepositoryProvider)
          .mergeGroups(fromGroupId: widget.group.id, toGroupId: target.id);
      if (mounted) Navigator.of(context).pop();
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.mergedInto(target.name))),
      );
    } catch (_) {
      if (mounted) setState(() => _merging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final targets = _targets;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mergeTitle(widget.group.name),
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(l10n.mergeDescription, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (targets == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (targets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.mergeNoOtherMeals,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else
              for (final (g, kcal) in targets)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.restaurant_rounded, size: 20),
                  title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    '${kcalStr(kcal)} kcal',
                    style: theme.textTheme.bodySmall,
                  ),
                  enabled: !_merging,
                  onTap: () => _merge(g),
                ),
          ],
        ),
      ),
    );
  }
}
