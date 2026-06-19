import 'package:drift/drift.dart' show Value;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/date_x.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/meal_times.dart';
import '../../providers.dart';
import 'offline_regions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final defaultMin = ref.watch(defaultMinProvider).asData?.value;
    final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
    final fixedMeals = ref.watch(groupByMealProvider).asData?.value ?? false;
    final healthSync =
        ref.watch(healthSyncEnabledProvider).asData?.value ?? false;

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
              const SizedBox(height: 8),
              ExpansionTile(
                leading: const Icon(Icons.event_repeat),
                title: const Text('Customize per day'),
                subtitle: const Text('Training days and weekends can differ'),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
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
                ],
              ),
              const Divider(),
              const _SectionHeader('Logging'),
              SwitchListTile(
                title: const Text('Fixed meals'),
                subtitle: const Text(
                    'On: log into Breakfast / Lunch / Dinner / Snacks.\n'
                    'Off: meals are grouped automatically as you add.'),
                isThreeLine: true,
                value: fixedMeals,
                onChanged: (v) =>
                    db.setSetting('groupByMeal', v ? 'true' : 'false'),
              ),
              if (!fixedMeals) ...[
                const ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text('Meal times'),
                  subtitle: Text(
                      'Auto-labels each entry by the time you log it. '
                      'Anything outside these windows counts as a snack.'),
                  isThreeLine: true,
                ),
                for (final m in const [
                  MealType.breakfast,
                  MealType.lunch,
                  MealType.dinner
                ])
                  _MealTimeRow(meal: m),
                const SizedBox(height: 8),
              ],
              const Divider(),
              const _SectionHeader('Food data'),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('Offline regions'),
                subtitle: const Text(
                    'Download country product databases for offline search'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const OfflineRegionsScreen())),
              ),
              const Divider(),
              const _SectionHeader('Health Connect'),
              SwitchListTile(
                secondary: const Icon(Icons.favorite_border),
                title: const Text('Sync to Health Connect'),
                subtitle: const Text(
                    'Write logged calories & macros to Health Connect'),
                value: healthSync,
                onChanged: (v) => _toggleHealthSync(context, ref, v),
              ),
              if (healthSync)
                ExpansionTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Meal times'),
                  subtitle: const Text(
                      'When each meal is timestamped in Health Connect'),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                          'Entries are written to Health Connect at the start '
                          'of their meal window, so calories land at a sensible '
                          'time of day.'),
                    ),
                    _MealTimeRow(meal: MealType.breakfast),
                    _MealTimeRow(meal: MealType.lunch),
                    _MealTimeRow(meal: MealType.dinner),
                  ],
                ),
              const Divider(),
              const _SectionHeader('Data & backup'),
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
              const Divider(),
              const _SectionHeader('About'),
              const AboutListTile(
                icon: Icon(Icons.info_outline),
                applicationName: 'Knabberfuchs',
                applicationVersion: '0.1.0',
                aboutBoxChildren: [
                  SizedBox(height: 4),
                  Text('Ad-free, no subscriptions. Data from Open Food Facts '
                      'and USDA FoodData Central.'),
                  SizedBox(height: 20),
                  _OpenFoodFactsThanks(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _toggleHealthSync(
    BuildContext context, WidgetRef ref, bool value) async {
  final messenger = ScaffoldMessenger.of(context);
  final db = ref.read(dbProvider);
  final health = ref.read(healthServiceProvider);

  if (!value) {
    await db.setSetting('healthSync', 'false');
    await health.refreshEnabled(db);
    messenger.showAutoSnackBar(
        const SnackBar(content: Text('Health Connect sync turned off.')));
    return;
  }

  if (!await health.isAvailable()) {
    messenger.showAutoSnackBar(const SnackBar(
        content: Text('Health Connect is not available on this device.')));
    return;
  }
  final granted = await health.requestPermissions();
  if (!granted) {
    messenger.showAutoSnackBar(const SnackBar(
        content: Text('Health Connect permission was not granted.')));
    return;
  }
  await db.setSetting('healthSync', 'true');
  await health.refreshEnabled(db);
  // Sync the selected day immediately so the user sees data right away.
  final day = ref.read(selectedDayProvider);
  await health.syncDay(day, await db.watchDay(day).first);
  messenger.showAutoSnackBar(const SnackBar(
      content: Text('Health Connect sync on — today pushed.')));
}

Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(backupServiceProvider).shareBackup();
  } catch (e) {
    messenger.showAutoSnackBar(SnackBar(content: Text('Export failed: $e')));
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
    messenger.showAutoSnackBar(const SnackBar(content: Text('Backup restored.')));
  } catch (e) {
    messenger.showAutoSnackBar(SnackBar(content: Text('Import failed: $e')));
  }
}

/// A heartfelt thank-you to Open Food Facts, shown in the About box, with a
/// link to their donation page.
class _OpenFoodFactsThanks extends StatelessWidget {
  const _OpenFoodFactsThanks();

  static final _donateUrl =
      Uri.parse('https://world.openfoodfacts.org/donate-to-open-food-facts');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('Thanks to Open Food Facts',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Knabberfuchs is built on Open Food Facts — a free, open, '
          'crowdsourced food database kept alive by volunteers around the '
          'world. Without their work, this app simply would not exist.\n\n'
          'If Knabberfuchs is useful to you, please consider supporting them.',
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: () =>
                launchUrl(_donateUrl, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.favorite_border, size: 18),
            label: const Text('Donate to Open Food Facts'),
          ),
        ),
      ],
    );
  }
}

String _fmtMins(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// A meal's [start]–[end] window with two tappable time buttons.
class _MealTimeRow extends ConsumerWidget {
  final MealType meal;
  const _MealTimeRow({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(mealTimesProvider).asData?.value ?? MealTimes.defaults;
    final db = ref.read(dbProvider);
    final start = t.startOf(meal);
    final end = t.endOf(meal);

    Future<void> pick(bool isStart) async {
      final cur = isStart ? start : end;
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60),
      );
      if (picked == null) return;
      final mins = picked.hour * 60 + picked.minute;
      await db.setSetting(
          isStart ? MealTimes.startKey(meal) : MealTimes.endKey(meal), '$mins');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(meal.label)),
          OutlinedButton(
              onPressed: () => pick(true), child: Text(_fmtMins(start))),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), child: Text('–')),
          OutlinedButton(
              onPressed: () => pick(false), child: Text(_fmtMins(end))),
        ],
      ),
    );
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
