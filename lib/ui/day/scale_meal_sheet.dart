import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/snackbar.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Sheet to scale a whole meal by a factor — multiplies every entry's grams
/// (and so kcal/macros). Mainly for "I only ate part of it" (downscaling).
Future<void> showScaleMealSheet(BuildContext context, GroupView group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ScaleSheet(group: group),
  );
}

class _ScaleSheet extends ConsumerStatefulWidget {
  final GroupView group;
  const _ScaleSheet({required this.group});

  @override
  ConsumerState<_ScaleSheet> createState() => _ScaleSheetState();
}

class _ScaleSheetState extends ConsumerState<_ScaleSheet> {
  double _factor = 1.0;

  int get _pct => (_factor * 100).round();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentKcal = widget.group.subtotal.kcal;
    final newKcal = currentKcal * _factor;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mealMenuScale, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(widget.group.group.name,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$_pct%',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${kcalStr(currentKcal)} → ${kcalStr(newKcal)} kcal',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            Slider(
              value: _factor,
              min: 0.1,
              max: 2.0,
              divisions: 38, // 5% steps
              label: '$_pct%',
              onChanged: (v) => setState(() => _factor = v),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final f in const [0.25, 0.5, 0.75, 1.5, 2.0])
                  ChoiceChip(
                    label: Text('${(f * 100).round()}%'),
                    selected: (_factor - f).abs() < 0.001,
                    onSelected: (_) => setState(() => _factor = f),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _factor == 1.0 ? null : _apply,
                child: Text(l10n.scaleMealApply('$_pct')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final pct = '$_pct';
    await ref
        .read(diaryRepositoryProvider)
        .scaleGroup(groupId: widget.group.group.id, factor: _factor);
    if (mounted) Navigator.of(context).pop();
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.scaleMealDone(pct))));
  }
}
