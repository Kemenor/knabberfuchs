import 'package:drift/drift.dart' show Value;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_x.dart';
import '../../data/db/database.dart';
import '../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final defaultTarget = ref.watch(defaultTargetProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (targets) {
          double? kcalFor(int wd) =>
              targets.firstWhere((t) => t.weekday == wd).kcal;
          return ListView(
            children: [
              const _SectionHeader('Calorie targets'),
              ListTile(
                title: const Text('Default daily target'),
                subtitle: const Text('Used when a weekday has no value'),
                trailing: SizedBox(
                  width: 110,
                  child: _TargetField(
                    key: const ValueKey('default-target'),
                    initial: defaultTarget,
                    onChanged: (v) => db.setSetting(
                        'defaultKcalTarget', v?.toStringAsFixed(0)),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Per weekday (training days can be higher)'),
              ),
              for (var wd = 0; wd < 7; wd++)
                ListTile(
                  title: Text(kWeekdayNames[wd]),
                  trailing: SizedBox(
                    width: 110,
                    child: _TargetField(
                      key: ValueKey('target-$wd'),
                      initial: kcalFor(wd),
                      hint: defaultTarget?.toStringAsFixed(0),
                      onChanged: (v) => db.setTarget(
                          wd, TargetsCompanion(kcal: Value(v))),
                    ),
                  ),
                ),
              const Divider(),
              const _SectionHeader('Integrations'),
              const ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('Health Connect sync'),
                subtitle: Text('Coming soon'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Export backup'),
                subtitle: const Text('Share a .zip (JSON + CSV)'),
                onTap: () => _exportBackup(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Import backup'),
                subtitle: const Text('Restore from a .zip (replaces all data)'),
                onTap: () => _importBackup(context, ref),
              ),
              const AboutListTile(
                icon: Icon(Icons.info_outline),
                applicationName: 'Knabberfuchs',
                applicationVersion: '0.1.0',
                aboutBoxChildren: [
                  Text('Ad-free, no subscriptions. Data from Open Food Facts '
                      'and USDA FoodData Central.'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(backupServiceProvider).shareBackup();
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}

Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final file = await openFile(
    acceptedTypeGroups: [
      const XTypeGroup(label: 'Backup', extensions: ['zip']),
    ],
  );
  if (file == null || !context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Replace all data?'),
      content: const Text(
          'Importing will replace your current entries, custom foods, '
          'recipes, targets, and settings with the backup contents.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import')),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await ref.read(backupServiceProvider).restoreFromZip(file.path);
    messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

/// A small numeric field that reports a parsed kcal value (or null when empty).
class _TargetField extends StatefulWidget {
  final double? initial;
  final String? hint;
  final ValueChanged<double?> onChanged;
  const _TargetField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.hint,
  });

  @override
  State<_TargetField> createState() => _TargetFieldState();
}

class _TargetFieldState extends State<_TargetField> {
  late final TextEditingController _c = TextEditingController(
      text: widget.initial == null ? '' : widget.initial!.toStringAsFixed(0));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint ?? '—',
        suffixText: 'kcal',
      ),
      onChanged: (v) {
        final parsed = v.trim().isEmpty ? null : double.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
