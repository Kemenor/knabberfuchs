import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/db/database.dart';
import '../../data/offline/offline_pack_service.dart';
import '../../domain/offline_manifest.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

String _mb(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';

class OfflineRegionsScreen extends ConsumerStatefulWidget {
  const OfflineRegionsScreen({super.key, this.initialCountryTag});

  /// When set (e.g. from the post-scan offline nudge), the screen opens
  /// pre-filtered to the region whose OFF `country_tag` matches this value.
  final String? initialCountryTag;

  @override
  ConsumerState<OfflineRegionsScreen> createState() =>
      _OfflineRegionsScreenState();
}

class _OfflineRegionsScreenState extends ConsumerState<OfflineRegionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// Pre-fill from [OfflineRegionsScreen.initialCountryTag] runs once, after the
  /// manifest is available; afterwards the user owns the search box.
  bool _appliedInitial = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _download(OfflineManifest m, RegionInfo r) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      // Through the shared queue, so a region the auto-updater is already
      // fetching isn't downloaded twice, and its ring shows here too.
      await ref.read(packInstallQueueProvider.notifier).install(m, r);
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionDownloaded(r.name))),
      );
    } on InstallCancelledException {
      // User aborted — the vanishing progress ring is feedback enough.
    } catch (e) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionDownloadFailed('$e'))),
      );
    }
  }

  /// Queue every outdated region at once (the queue runs them one by one)
  /// and report once at the end rather than a snackbar per region.
  Future<void> _updateAll(OfflineManifest m, List<RegionInfo> outdated) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final queue = ref.read(packInstallQueueProvider.notifier);
    final updated = <String>[];
    Object? error;
    await Future.wait([
      for (final r in outdated)
        queue
            .install(m, r)
            .then(
              (_) => updated.add(r.name),
              onError: (Object e) {
                if (e is! InstallCancelledException) error ??= e;
              },
            ),
    ]);
    if (updated.isNotEmpty) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionsAutoUpdated(updated.join(', ')))),
      );
    }
    if (error != null) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionDownloadFailed('$error'))),
      );
    }
  }

  Future<void> _remove(String code, String name) async {
    // Capture messenger + l10n before the await (the convention), not after.
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(offlinePackServiceProvider).remove(code);
    if (mounted) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionRemoved(name))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final manifestAsync = ref.watch(offlineManifestProvider);
    final progress = ref.watch(packInstallQueueProvider);
    final installed = {
      for (final p
          in ref.watch(installedPacksProvider).asData?.value ?? const [])
        p.code: p,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsOfflineRegions)),
      body: manifestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.regionLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(offlineManifestProvider),
                  child: Text(l10n.actionRetry),
                ),
              ],
            ),
          ),
        ),
        data: (manifest) {
          // Deep-link from the scan nudge: pre-fill the search box with the
          // matching region's name, once, so the list opens already filtered.
          if (!_appliedInitial && widget.initialCountryTag != null) {
            _appliedInitial = true;
            for (final r in manifest.regions) {
              if (r.countryTag == widget.initialCountryTag) {
                _query = r.name;
                _searchCtrl.text = r.name;
                break;
              }
            }
          }
          final q = _query.trim().toLowerCase();
          final regions =
              manifest.regions
                  .where((r) => q.isEmpty || r.name.toLowerCase().contains(q))
                  .toList()
                ..sort((a, b) {
                  // Installed first, then alphabetical by name.
                  final ai = installed.containsKey(a.code);
                  final bi = installed.containsKey(b.code);
                  if (ai != bi) return ai ? -1 : 1;
                  return a.name.compareTo(b.name);
                });
          // From the whole manifest, not the filtered list: the search box
          // shouldn't hide that updates are waiting.
          final outdated = [
            for (final r in manifest.regions)
              if (installed[r.code] case final p?
                  when p.version != r.version && !progress.containsKey(r.code))
                r,
          ];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(l10n.regionIntro),
              ),
              if (outdated.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _updateAll(manifest, outdated),
                      icon: const Icon(Symbols.update_rounded),
                      label: Text(l10n.regionUpdateAll(outdated.length)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Symbols.search_rounded),
                    hintText: l10n.regionSearchHint,
                    border: const OutlineInputBorder(),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.a11yClearSearch,
                            icon: const Icon(Symbols.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: regions.isEmpty
                    ? Center(
                        child: Text(
                          l10n.regionNoMatch(_query),
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView(
                        children: [
                          for (final r in regions)
                            _RegionTile(
                              region: r,
                              installed: installed[r.code],
                              progress: progress[r.code],
                              onDownload: () => _download(manifest, r),
                              onCancel: () => ref
                                  .read(packInstallQueueProvider.notifier)
                                  .cancel(r.code),
                              onRemove: () => _remove(r.code, r.name),
                            ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              manifest.attribution,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final RegionInfo region;
  final InstalledPack? installed;
  final double? progress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  const _RegionTile({
    required this.region,
    required this.installed,
    required this.progress,
    required this.onDownload,
    required this.onCancel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isInstalled = installed != null;
    final updatable = isInstalled && installed!.version != region.version;
    final subtitle = l10n.regionSubtitle(
      (region.products / 1000).toStringAsFixed(region.products >= 1000 ? 0 : 1),
      _mb(region.size),
    );

    Widget trailing;
    if (progress != null) {
      trailing = IconButton(
        tooltip: l10n.actionCancel,
        onPressed: onCancel,
        icon: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: progress == 0 ? null : progress,
                strokeWidth: 3,
              ),
            ),
            const Icon(Symbols.close_rounded, size: 14),
          ],
        ),
      );
    } else if (!isInstalled) {
      trailing = IconButton(
        tooltip: l10n.regionTooltipDownload,
        icon: const Icon(Symbols.download_rounded),
        onPressed: onDownload,
      );
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (updatable)
            TextButton(onPressed: onDownload, child: Text(l10n.regionUpdate))
          else
            Icon(
              Symbols.check_circle_rounded,
              color: theme.colorScheme.primary,
            ),
          IconButton(
            tooltip: l10n.regionTooltipRemove,
            icon: const Icon(Symbols.delete_rounded),
            onPressed: onRemove,
          ),
        ],
      );
    }

    return ListTile(
      title: Text(region.name),
      subtitle: Text(
        isInstalled && !updatable
            ? l10n.regionSubtitleInstalled(
                subtitle,
                DateFormat(
                  'd MMM',
                  Localizations.localeOf(context).languageCode,
                ).format(installed!.installedAt.toLocal()),
              )
            : updatable
            ? l10n.regionSubtitleUpdatable(subtitle)
            : subtitle,
      ),
      trailing: trailing,
    );
  }
}
