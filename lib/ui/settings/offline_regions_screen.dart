import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/offline_manifest.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

String _mb(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';

class OfflineRegionsScreen extends ConsumerStatefulWidget {
  const OfflineRegionsScreen({super.key});

  @override
  ConsumerState<OfflineRegionsScreen> createState() =>
      _OfflineRegionsScreenState();
}

class _OfflineRegionsScreenState extends ConsumerState<OfflineRegionsScreen> {
  final Map<String, double> _progress = {};
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _download(OfflineManifest m, RegionInfo r) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _progress[r.code] = 0);
    try {
      await ref
          .read(offlinePackServiceProvider)
          .install(
            m,
            r,
            onProgress: (p) {
              if (mounted) setState(() => _progress[r.code] = p);
            },
          );
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionDownloaded(r.name))),
      );
    } catch (e) {
      messenger.showAutoSnackBar(
        SnackBar(content: Text(l10n.regionDownloadFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _progress.remove(r.code));
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(l10n.regionIntro),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.regionSearchHint,
                    border: const OutlineInputBorder(),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
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
                              progress: _progress[r.code],
                              onDownload: () => _download(manifest, r),
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
  final VoidCallback onRemove;

  const _RegionTile({
    required this.region,
    required this.installed,
    required this.progress,
    required this.onDownload,
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
      trailing = SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          value: progress == 0 ? null : progress,
          strokeWidth: 3,
        ),
      );
    } else if (!isInstalled) {
      trailing = IconButton(
        tooltip: l10n.regionTooltipDownload,
        icon: const Icon(Icons.download),
        onPressed: onDownload,
      );
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (updatable)
            TextButton(onPressed: onDownload, child: Text(l10n.regionUpdate))
          else
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
          IconButton(
            tooltip: l10n.regionTooltipRemove,
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      );
    }

    return ListTile(
      title: Text(region.name),
      subtitle: Text(
        isInstalled && !updatable
            ? l10n.regionSubtitleInstalled(subtitle)
            : updatable
            ? l10n.regionSubtitleUpdatable(subtitle)
            : subtitle,
      ),
      trailing: trailing,
    );
  }
}
