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
    final defaultMin = ref.watch(defaultMinProvider).asData?.value;
    final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
    final trackByMeal = ref.watch(groupByMealProvider).asData?.value ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (targets) {
          Target rowFor(int wd) => targets.firstWhere((t) => t.weekday == wd);
          return ListView(
            children: [
              const _SectionHeader('Calorie targets'),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Set a minimum, a maximum, or both. A minimum helps if you '
                  'need to make sure you eat enough. Leave blank to use the default.',
                ),
              ),
              _TargetRow(
                label: 'Default',
                keyPrefix: 'default',
                initialMin: defaultMin,
                initialMax: defaultMax,
                onMin: (v) =>
                    db.setSetting('defaultKcalMin', v?.toStringAsFixed(0)),
                onMax: (v) =>
                    db.setSetting('defaultKcalMax', v?.toStringAsFixed(0)),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Per weekday (training days can differ)'),
              ),
              for (var wd = 0; wd < 7; wd++)
                _TargetRow(
                  label: kWeekdayNames[wd],
                  keyPrefix: 'wd$wd',
                  initialMin: rowFor(wd).kcalMin,
                  initialMax: rowFor(wd).kcalMax,
                  hintMin: defaultMin?.toStringAsFixed(0),
                  hintMax: defaultMax?.toStringAsFixed(0),
                  onMin: (v) =>
                      db.setTarget(wd, TargetsCompanion(kcalMin: Value(v))),
                  onMax: (v) =>
                      db.setTarget(wd, TargetsCompanion(kcalMax: Value(v))),
                ),
              const Divider(),
              const _SectionHeader('Logging'),
              SwitchListTile(
                title: const Text('Track by meal'),
                subtitle: const Text(
                    'Off: log straight to the day without picking a meal'),
                value: trackByMeal,
                onChanged: (v) =>
                    db.setSetting('groupByMeal', v ? 'true' : 'false'),
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

/// A weekday/default row with a Min and a Max calorie field.
class _TargetRow extends StatelessWidget {
  final String label;
  final String keyPrefix;
  final double? initialMin;
  final double? initialMax;
  final String? hintMin;
  final String? hintMax;
  final ValueChanged<double?> onMin;
  final ValueChanged<double?> onMax;

  const _TargetRow({
    required this.label,
    required this.keyPrefix,
    required this.initialMin,
    required this.initialMax,
    required this.onMin,
    required this.onMax,
    this.hintMin,
    this.hintMax,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 2,
            child: _TargetField(
              key: ValueKey('$keyPrefix-min'),
              initial: initialMin,
              hint: hintMin ?? 'min',
              onChanged: onMin,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('–'),
          ),
          Expanded(
            flex: 2,
            child: _TargetField(
              key: ValueKey('$keyPrefix-max'),
              initial: initialMax,
              hint: hintMax ?? 'max',
              onChanged: onMax,
            ),
          ),
        ],
      ),
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
      ),
      onChanged: (v) {
        final parsed = v.trim().isEmpty ? null : double.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
