import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_x.dart';
import '../../core/format.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Sheet to split a meal group into equal portions across several days.
Future<void> showSplitMealSheet(BuildContext context, GroupView group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SplitSheet(group: group),
  );
}

class _SplitSheet extends ConsumerStatefulWidget {
  final GroupView group;
  const _SplitSheet({required this.group});

  @override
  ConsumerState<_SplitSheet> createState() => _SplitSheetState();
}

class _SplitSheetState extends ConsumerState<_SplitSheet> {
  late List<String> _days = [
    widget.group.group.day,
    DayKey.shift(widget.group.group.day, 1),
  ];

  int get _n => _days.length;

  void _setCount(int n) {
    n = n.clamp(2, 10);
    setState(() {
      if (n > _days.length) {
        while (_days.length < n) {
          _days.add(DayKey.shift(_days.last, 1));
        }
      } else {
        _days = _days.sublist(0, n);
      }
    });
  }

  Future<void> _pickDay(int i) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DayKey.parse(_days[i]),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _days[i] = DayKey.of(picked));
  }

  Future<void> _split() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await ref.read(diaryRepositoryProvider).splitGroupAcrossDays(
          groupId: widget.group.id,
          days: _days,
        );
    if (mounted) Navigator.of(context).pop();
    messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.splitInto('$_n'))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final perPortionKcal = widget.group.subtotal.kcal / _n;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.splitTitle(widget.group.name),
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            l10n.splitDescription,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.recipePortions, style: theme.textTheme.labelLarge),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: _n > 2 ? () => _setCount(_n - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_n', style: theme.textTheme.titleLarge),
              ),
              IconButton.filledTonal(
                onPressed: _n < 10 ? () => _setCount(_n + 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text(l10n.splitKcalEach(kcalStr(perPortionKcal)),
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (var i = 0; i < _days.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, size: 20),
              title: Text(DayKey.label(_days[i])),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () => _pickDay(i),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _split,
              child: Text(l10n.splitInto('$_n')),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
