import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/support_email.dart';
import '../../domain/enums.dart';
import '../../domain/meal_times.dart';
import '../../domain/meal_type_i18n.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'offline_regions_screen.dart';
import 'targets_screen.dart';

/// HealthKit on iOS, Health Connect on Android — for user-facing labels.
String _healthStore() => Platform.isIOS ? 'Apple Health' : 'Health Connect';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final healthSync =
        ref.watch(healthSyncEnabledProvider).asData?.value ?? false;

    final l10nTop = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10nTop.navSettings)),
      body: targetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10nTop.genericError('$e'))),
        data: (_) {
          final l10n = AppLocalizations.of(context);
          final showTrends =
              ref.watch(showTrendsProvider).asData?.value ?? true;
          return ListView(
            children: [
              _SectionHeader(l10n.settingsTheme),
              const _SettingsCard(children: [_ThemePicker()]),
              _SectionHeader(l10n.settingsSectionLanguage),
              const _SettingsCard(children: [_LanguagePicker()]),
              _SectionHeader(l10n.settingsTypeface),
              const _SettingsCard(children: [_TypefacePicker()]),
              _SectionHeader(l10n.settingsDisplay),
              _SettingsCard(
                children: [
                  SwitchListTile(
                    contentPadding: _cardRowPadding,
                    secondary: const Icon(Symbols.insights_rounded),
                    title: Text(l10n.settingsShowTrends),
                    subtitle: Text(l10n.settingsShowTrendsSub),
                    value: showTrends,
                    onChanged: (v) =>
                        db.setSetting('showTrends', v ? 'true' : 'false'),
                  ),
                  ListTile(
                    contentPadding: _cardRowPadding,
                    leading: const Icon(Symbols.flag_rounded),
                    title: Text(l10n.settingsTargets),
                    subtitle: Text(l10n.settingsTargetsSub),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TargetsScreen()),
                    ),
                  ),
                ],
              ),
              _SectionHeader(l10n.settingsLogging),
              _SettingsCard(
                children: [
                  ExpansionTile(
                    tilePadding: _cardRowPadding,
                    leading: const Icon(Symbols.schedule_rounded),
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
                ],
              ),
              _SectionHeader(l10n.settingsFoodData),
              _SettingsCard(
                children: [
                  ListTile(
                    contentPadding: _cardRowPadding,
                    leading: const Icon(Symbols.public_rounded),
                    title: Text(l10n.settingsOfflineRegions),
                    subtitle: Text(l10n.settingsOfflineRegionsSub),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OfflineRegionsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              _SectionHeader(l10n.settingsAi),
              const _SettingsCard(children: [_AiKeyTile()]),
              _SectionHeader(l10n.settingsHealthConnect(_healthStore())),
              _SettingsCard(
                children: [
                  SwitchListTile(
                    contentPadding: _cardRowPadding,
                    secondary: const Icon(Symbols.favorite_border_rounded),
                    title: Text(l10n.settingsHealthSync(_healthStore())),
                    subtitle: Text(l10n.settingsHealthSyncSub(_healthStore())),
                    value: healthSync,
                    onChanged: (v) => _toggleHealthSync(context, ref, v),
                  ),
                  if (healthSync)
                    ListTile(
                      contentPadding: _cardRowPadding,
                      leading: const Icon(Symbols.info_rounded),
                      dense: true,
                      title: Text(l10n.settingsHealthTimeNote),
                      subtitle: Text(l10n.settingsHealthTimeNoteSub),
                    ),
                ],
              ),
              _SectionHeader(l10n.settingsDataBackup),
              _SettingsCard(
                children: [
                  ListTile(
                    contentPadding: _cardRowPadding,
                    leading: const Icon(Symbols.upload_rounded),
                    title: Text(l10n.settingsExport),
                    subtitle: Text(l10n.settingsExportSub),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => _exportBackup(context, ref),
                  ),
                  ListTile(
                    contentPadding: _cardRowPadding,
                    leading: const Icon(Symbols.download_rounded),
                    title: Text(l10n.settingsImport),
                    subtitle: Text(l10n.settingsImportSub),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => _importBackup(context, ref),
                  ),
                ],
              ),
              _SectionHeader(l10n.settingsAbout),
              _SettingsCard(
                children: [
                  const _AboutTile(),
                  ListTile(
                    contentPadding: _cardRowPadding,
                    leading: const Icon(Symbols.mail_rounded),
                    title: Text(l10n.settingsContactDev),
                    subtitle: Text(l10n.settingsContactDevSub),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final locale = Localizations.localeOf(
                        context,
                      ).toString();
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
      contentPadding: _cardRowPadding,
      leading: const Icon(Symbols.info_rounded),
      title: const Text('Knabberfuchs'),
      subtitle: version == null ? null : Text(version),
      trailing: const Icon(Symbols.chevron_right_rounded),
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
            Icon(Symbols.favorite_rounded, size: 18, color: theme.colorScheme.primary),
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
            icon: const Icon(Symbols.favorite_border_rounded, size: 18),
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
    return FuchsbauChoicePicker<String>(
      icon: Symbols.translate_rounded,
      title: l10n.settingsLanguage,
      value: current,
      options: {
        'system': l10n.languageSystem,
        'en': l10n.languageEnglish,
        'de': l10n.languageGerman,
        'fr': l10n.languageFrench,
        'it': l10n.languageItalian,
      },
      onChanged: (v) => db.setSetting('appLocale', v),
      footnote: l10n.languageMachineNote,
    );
  }
}

/// Typeface override (DESIGN.md §2 accessibility picker): Figtree / System /
/// Atkinson Hyperlegible / OpenDyslexic. Writes the 'appFont' setting (the enum
/// `name`), which drives [fontProvider] → the theme's fontFamily.
class _TypefacePicker extends ConsumerWidget {
  const _TypefacePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(dbProvider);
    final current = ref.watch(fontProvider).asData?.value ?? FuchsbauFont.figtree;
    return FuchsbauChoicePicker<FuchsbauFont>(
      icon: Symbols.text_fields_rounded,
      title: l10n.settingsTypeface,
      value: current,
      options: {for (final f in FuchsbauFont.values) f: f.label},
      // Per-option helper subtitles (accessibility intent); names stay proper nouns.
      subtitles: {
        FuchsbauFont.figtree: l10n.typefaceDefault,
        FuchsbauFont.atkinsonHyperlegible: l10n.typefaceLowVision,
        FuchsbauFont.openDyslexic: l10n.typefaceDyslexia,
      },
      onChanged: (f) => db.setSetting('appFont', f.name),
    );
  }
}

/// Light / dark / follow-system. Writes the 'appThemeMode' setting, which drives
/// [themeModeProvider] → MaterialApp.themeMode. Collapsible radio list to match
/// the Language and Typeface pickers.
class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(dbProvider);
    final current =
        ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;
    return FuchsbauChoicePicker<ThemeMode>(
      icon: Symbols.brightness_6_rounded,
      title: l10n.settingsTheme,
      value: current,
      options: {
        ThemeMode.system: l10n.themeSystem,
        ThemeMode.light: l10n.themeLight,
        ThemeMode.dark: l10n.themeDark,
      },
      onChanged: (v) => db.setSetting(
        'appThemeMode',
        v == ThemeMode.system ? null : v.name,
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                tooltip: _obscure
                    ? l10n.a11yShowApiKey
                    : l10n.a11yHideApiKey,
                icon: Icon(
                  _obscure ? Symbols.visibility_rounded : Symbols.visibility_off_rounded,
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
              icon: const Icon(Symbols.open_in_new_rounded, size: 16),
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

/// Consistent horizontal inset for rows living inside a [_SettingsCard], so
/// leading icons/labels align with the card's content padding.
const _cardRowPadding = EdgeInsets.symmetric(horizontal: 12);

/// Groups a section's rows inside a single white [Card], inserting a hairline
/// divider between consecutive rows. Card fill/border/radius come from the
/// theme — do not override them here.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      rows.add(children[i]);
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(children: rows),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

