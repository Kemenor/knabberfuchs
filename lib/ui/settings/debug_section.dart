import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/snackbar.dart';
import '../../data/debug/debug_tools.dart';
import '../../providers.dart';

/// Hidden developer/tester section (FEEDBACK.md 2026-07-03), unlocked by
/// long-pressing the app name in the About dialog. Deliberately English-only
/// (never store-advertised, DEBUG-labelled) — the one sanctioned exception to
/// the no-hardcoded-strings rule.
class DebugSection extends ConsumerWidget {
  const DebugSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fakeKcal = ref.watch(debugFakeActivityProvider).asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'DEBUG',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Symbols.science_rounded),
                title: const Text('Load test data'),
                subtitle: const Text('Seed 3 weeks of demo meals + a recipe'),
                onTap: () => _seed(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.history_rounded),
                title: const Text('Shift diary back…'),
                subtitle: const Text('Age all entries by N days'),
                onTap: () => _shift(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.bolt_rounded),
                title: const Text('Fake activity kcal…'),
                subtitle: Text(
                  fakeKcal == null
                      ? 'Off — real health-store reads apply'
                      : 'Pretending ${fakeKcal.round()} kcal burned today '
                            '(ignores the health toggle)',
                ),
                onTap: () => _fakeActivity(context, ref, fakeKcal),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.database_rounded),
                title: const Text('Database inspector'),
                subtitle: const Text('Schema version, row counts, file size'),
                onTap: () => _inspect(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.ios_share_rounded),
                title: const Text('Export database'),
                subtitle: const Text('Share a snapshot of the raw .sqlite'),
                onTap: () => _export(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.monitor_heart_rounded),
                title: const Text('Health sync status'),
                subtitle: const Text('Flags, availability, last sync outcome'),
                onTap: () => _healthStatus(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(
                  Symbols.delete_forever_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Clear all data',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Factory reset: diary, foods, settings'),
                onTap: () => _clearAll(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Symbols.visibility_off_rounded),
                title: const Text('Hide debug menu'),
                onTap: () => ref.read(dbProvider).setSetting('debugMenu', null),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _seed(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final n = await seedTestData(ref.read(dbProvider));
    messenger.showAutoSnackBar(
      SnackBar(content: Text('Seeded $n entries over 21 days')),
    );
  }

  Future<void> _shift(BuildContext context, WidgetRef ref) async {
    final days = await _askNumber(
      context,
      title: 'Shift diary back',
      suffix: 'days',
      initial: '30',
    );
    if (days == null || days == 0) return;
    await shiftDiary(ref.read(dbProvider), days.round());
    ref.read(selectedDayProvider.notifier).today();
  }

  Future<void> _fakeActivity(
    BuildContext context,
    WidgetRef ref,
    double? current,
  ) async {
    final kcal = await _askNumber(
      context,
      title: 'Fake activity kcal',
      suffix: 'kcal',
      initial: current?.round().toString() ?? '450',
      helper: 'Empty or 0 turns the override off.',
    );
    if (kcal == null) return;
    await ref
        .read(dbProvider)
        .setSetting('debugFakeActivityKcal', kcal > 0 ? '$kcal' : null);
  }

  Future<void> _inspect(BuildContext context, WidgetRef ref) async {
    final stats = await dbStats(ref.read(dbProvider));
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Database'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in stats.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      const SizedBox(width: 24),
                      Text(
                        e.value,
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await exportDbSnapshot(ref.read(dbProvider));
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], subject: 'Knabberfuchs debug DB'),
      );
    } catch (e) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text('Export failed: ${e.runtimeType}')),
      );
    }
  }

  Future<void> _healthStatus(BuildContext context, WidgetRef ref) async {
    final health = ref.read(healthServiceProvider);
    final available = await health.isAvailable();
    if (!context.mounted) return;
    String fmt(DateTime? t) => t == null
        ? '—'
        : '${t.hour.toString().padLeft(2, '0')}:'
              '${t.minute.toString().padLeft(2, '0')}';
    final lines = {
      'store available': '$available',
      'write-sync enabled': '${health.enabled}',
      'energy read enabled': '${health.energyReadEnabled}',
      'last sync': health.lastSyncDay == null
          ? 'none this session'
          : '${health.lastSyncDay} at ${fmt(health.lastSyncAt)}',
      'last sync error': health.lastSyncError ?? 'none',
    };
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Health sync'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in lines.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${e.key}: ${e.value}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'Deletes the whole diary, recipes, foods and settings — and the '
          "app's records in the health store if sync was on. Cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = ref.read(dbProvider);
    final health = ref.read(healthServiceProvider);
    final packs = ref.read(offlinePackServiceProvider);
    // Grilled 2026-07-03: a true factory reset also clears our records from
    // the health store, so a reinstall doesn't double them on resync.
    if (health.enabled) await health.deleteAll();
    await wipeAllData(db, packs: packs);
    await health.refreshEnabled(db);
    ref.read(selectedDayProvider.notifier).today();
    messenger.showAutoSnackBar(
      const SnackBar(content: Text('All data cleared')),
    );
  }

  /// Small shared number-input dialog. Returns null on cancel.
  Future<double?> _askNumber(
    BuildContext context, {
    required String title,
    required String suffix,
    required String initial,
    String? helper,
  }) async {
    final ctrl = TextEditingController(text: initial);
    try {
      return await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(suffixText: suffix, helperText: helper),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0,
              ),
              child: const Text('Set'),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }
}
