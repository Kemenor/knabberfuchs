import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/support_email.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/meal_times.dart';
import '../../domain/meal_type_i18n.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'offline_regions_screen.dart';

/// HealthKit on iOS, Health Connect on Android — for user-facing labels.
String _healthStore() => Platform.isIOS ? 'Apple Health' : 'Health Connect';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final defaultMin = ref.watch(defaultMinProvider).asData?.value;
    final defaultMax = ref.watch(defaultMaxProvider).asData?.value;
    final healthSync =
        ref.watch(healthSyncEnabledProvider).asData?.value ?? false;

    final l10nTop = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10nTop.navSettings)),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10nTop.genericError('$e'))),
        data: (targets) {
          final l10n = AppLocalizations.of(context);
          final showTrends =
              ref.watch(showTrendsProvider).asData?.value ?? true;
          Target rowFor(int wd) => targets.firstWhere((t) => t.weekday == wd);
          return ListView(
            children: [
              _SectionHeader(l10n.settingsSectionLanguage),
              const _LanguagePicker(),
              const Divider(),
              _SectionHeader(l10n.settingsDisplay),
              SwitchListTile(
                secondary: const Icon(Icons.insights_outlined),
                title: Text(l10n.settingsShowTrends),
                subtitle: Text(l10n.settingsShowTrendsSub),
                value: showTrends,
                onChanged: (v) =>
                    db.setSetting('showTrends', v ? 'true' : 'false'),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsTargets),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l10n.settingsTargetsHelp),
              ),
              _TargetRow(
                label: l10n.settingsTargetDefault,
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
                title: Text(l10n.settingsCustomizePerDay),
                subtitle: Text(l10n.settingsCustomizePerDaySub),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (var wd = 0; wd < 7; wd++)
                    _TargetRow(
                      // Localized weekday name (Mon=0…Sun=6); 2024-01-01 was a
                      // Monday, so offset by wd from it.
                      label: DateFormat.EEEE(
                        Localizations.localeOf(context).languageCode,
                      ).format(DateTime(2024, 1, 1).add(Duration(days: wd))),
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
              _SectionHeader(l10n.settingsLogging),
              ExpansionTile(
                leading: const Icon(Icons.schedule),
                title: Text(l10n.settingsMealTimes),
                subtitle: Text(l10n.settingsMealTimesSub),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(l10n.settingsMealTimesHelp),
                  ),
                  const _MealTimeRow(meal: MealType.breakfast),
                  const _MealTimeRow(meal: MealType.lunch),
                  const _MealTimeRow(meal: MealType.dinner),
                ],
              ),
              const Divider(),
              _SectionHeader(l10n.settingsFoodData),
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(l10n.settingsOfflineRegions),
                subtitle: Text(l10n.settingsOfflineRegionsSub),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OfflineRegionsScreen(),
                  ),
                ),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsAi),
              const _AiKeyTile(),
              const Divider(),
              _SectionHeader(l10n.settingsHealthConnect(_healthStore())),
              SwitchListTile(
                secondary: const Icon(Icons.favorite_border),
                title: Text(l10n.settingsHealthSync(_healthStore())),
                subtitle: Text(l10n.settingsHealthSyncSub(_healthStore())),
                value: healthSync,
                onChanged: (v) => _toggleHealthSync(context, ref, v),
              ),
              if (healthSync)
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  dense: true,
                  title: Text(l10n.settingsHealthTimeNote),
                  subtitle: Text(l10n.settingsHealthTimeNoteSub),
                ),
              const Divider(),
              _SectionHeader(l10n.settingsDataBackup),
              ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: Text(l10n.settingsExport),
                subtitle: Text(l10n.settingsExportSub),
                onTap: () => _exportBackup(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.settingsImport),
                subtitle: Text(l10n.settingsImportSub),
                onTap: () => _importBackup(context, ref),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsAbout),
              const _AboutTile(),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.settingsContactDev),
                subtitle: Text(l10n.settingsContactDevSub),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final locale = Localizations.localeOf(context).toString();
                  final ok = await contactDeveloper(locale: locale);
                  if (!ok) {
                    messenger.showAutoSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.settingsContactDevNoApp(supportEmail),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _toggleHealthSync(
  BuildContext context,
  WidgetRef ref,
  bool value,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final db = ref.read(dbProvider);
  final health = ref.read(healthServiceProvider);

  if (!value) {
    await db.setSetting('healthSync', 'false');
    await health.refreshEnabled(db);
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.healthSyncOff(_healthStore()))));
    return;
  }

  if (!await health.isAvailable()) {
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.healthUnavailable(_healthStore()))));
    return;
  }
  final granted = await health.requestPermissions();
  if (!granted) {
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.healthNoPermission(_healthStore()))),
    );
    return;
  }
  await db.setSetting('healthSync', 'true');
  await health.refreshEnabled(db);
  // Sync the selected day immediately so the user sees data right away.
  final day = ref.read(selectedDayProvider);
  await health.syncDay(day, await db.watchDay(day).first);
  messenger.showAutoSnackBar(SnackBar(content: Text(l10n.healthSyncOn(_healthStore()))));
}

Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  try {
    await ref
        .read(backupServiceProvider)
        .shareBackup(subject: l10n.backupShareSubject);
  } catch (e) {
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.backupExportFailed('$e'))),
    );
  }
}

Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final file = await openFile(
    acceptedTypeGroups: [
      const XTypeGroup(label: 'Backup', extensions: ['zip']),
    ],
  );
  if (file == null || !context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.backupReplaceTitle),
      content: Text(l10n.backupReplaceBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.actionImport),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await ref.read(backupServiceProvider).restoreFromZip(file.path);
    messenger.showAutoSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  } catch (e) {
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.backupImportFailed('$e'))),
    );
  }
}

/// A heartfelt thank-you to Open Food Facts, shown in the About box, with a
/// link to their donation page.
/// About entry — shows the real app version+build (so testers can report it)
/// and opens the standard about dialog with a "view licenses" button.
class _AboutTile extends ConsumerWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final version = ref.watch(appVersionProvider).asData?.value;
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Knabberfuchs'),
      subtitle: version == null ? null : Text(version),
      onTap: () => showAboutDialog(
        context: context,
        applicationName: 'Knabberfuchs',
        applicationVersion: version,
        children: [
          const SizedBox(height: 4),
          Text(l10n.settingsAboutBody),
          const SizedBox(height: 20),
          const _OpenFoodFactsThanks(),
        ],
      ),
    );
  }
}

class _OpenFoodFactsThanks extends StatelessWidget {
  const _OpenFoodFactsThanks();

  static final _donateUrl = Uri.parse(
    'https://world.openfoodfacts.org/donate-to-open-food-facts',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              l10n.offThanksTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(l10n.offThanksBody),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final ok = await launchUrl(
                  _donateUrl,
                  mode: LaunchMode.externalApplication,
                );
                if (!ok) {
                  messenger.showAutoSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenLink)),
                  );
                }
              } catch (_) {
                messenger.showAutoSnackBar(
                  SnackBar(content: Text(l10n.couldNotOpenLink)),
                );
              }
            },
            icon: const Icon(Icons.favorite_border, size: 18),
            label: Text(l10n.offDonate),
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
        isStart ? MealTimes.startKey(meal) : MealTimes.endKey(meal),
        '$mins',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mealTypeLabel(meal, Localizations.localeOf(context).languageCode),
            ),
          ),
          OutlinedButton(
            onPressed: () => pick(true),
            child: Text(_fmtMins(start)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          OutlinedButton(
            onPressed: () => pick(false),
            child: Text(_fmtMins(end)),
          ),
        ],
      ),
    );
  }
}

/// Language override: System default + the four supported locales. Writes the
/// 'appLocale' setting, which drives [localeProvider] → MaterialApp.locale.
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(dbProvider);
    final current =
        ref.watch(localeProvider).asData?.value?.languageCode ?? 'system';
    final options = <String, String>{
      'system': l10n.languageSystem,
      'en': l10n.languageEnglish,
      'de': l10n.languageGerman,
      'fr': l10n.languageFrench,
      'it': l10n.languageItalian,
    };
    return ExpansionTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.settingsLanguage),
      subtitle: Text(options[current] ?? options['system']!),
      children: [
        RadioGroup<String>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) db.setSetting('appLocale', v);
          },
          child: Column(
            children: [
              for (final e in options.entries)
                RadioListTile<String>(value: e.key, title: Text(e.value)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            l10n.languageMachineNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Optional Google Gemini key (the user's own free-tier key) for cloud food
/// recognition. Empty = the on-device classifier stays the default.
class _AiKeyTile extends ConsumerStatefulWidget {
  const _AiKeyTile();
  @override
  ConsumerState<_AiKeyTile> createState() => _AiKeyTileState();
}

class _AiKeyTileState extends ConsumerState<_AiKeyTile> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  bool _loaded = false;
  bool _onDeviceOnly = false;
  String _model = 'gemini-2.5-flash';

  @override
  void initState() {
    super.initState();
    final db = ref.read(dbProvider);
    db.getSetting(geminiKeySetting).then((v) {
      if (mounted) {
        setState(() {
          _ctrl.text = v ?? '';
          _loaded = true;
        });
      }
    });
    db.getSetting(aiOnDeviceOnlySetting).then((v) {
      if (mounted) setState(() => _onDeviceOnly = v == 'true');
    });
    db.getSetting(geminiModelSetting).then((v) {
      if (mounted && v != null) setState(() => _model = v);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiKeyDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            enabled: _loaded,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.aiKeyLabel,
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (v) {
              setState(() {}); // toggle visibility follows the key field
              ref
                  .read(dbProvider)
                  .setSetting(
                    geminiKeySetting,
                    v.trim().isEmpty ? null : v.trim(),
                  );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final ok = await launchUrl(
                    Uri.parse('https://aistudio.google.com/apikey'),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    messenger.showAutoSnackBar(
                      SnackBar(content: Text(l10n.couldNotOpenLink)),
                    );
                  }
                } catch (_) {
                  messenger.showAutoSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenLink)),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(l10n.aiKeyGet),
            ),
          ),
          // Engine choice only matters once a key exists; until then every scan
          // is on-device anyway.
          if (_loaded && _ctrl.text.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.aiOnDeviceOnlyTitle),
                subtitle: Text(l10n.aiOnDeviceOnlySubtitle),
                value: _onDeviceOnly,
                onChanged: (v) {
                  setState(() => _onDeviceOnly = v);
                  ref
                      .read(dbProvider)
                      .setSetting(aiOnDeviceOnlySetting, v ? 'true' : null);
                },
              ),
            ),
            if (!_onDeviceOnly) ...[
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _model,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.aiModelLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'gemini-2.5-flash',
                    child: Text(l10n.aiModelReliable),
                  ),
                  DropdownMenuItem(
                    value: 'gemini-3.5-flash',
                    child: Text(l10n.aiModelAccurate),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _model = v);
                  ref.read(dbProvider).setSetting(geminiModelSetting, v);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.aiModelNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ],
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
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
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
    final l10n = AppLocalizations.of(context);
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
              hint: hintMin ?? l10n.settingsTargetMin,
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
              hint: hintMax ?? l10n.settingsTargetMax,
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
    text: widget.initial == null ? '' : widget.initial!.toStringAsFixed(0),
  );

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
      decoration: InputDecoration(isDense: true, hintText: widget.hint ?? '—'),
      onChanged: (v) {
        final parsed = v.trim().isEmpty ? null : double.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
