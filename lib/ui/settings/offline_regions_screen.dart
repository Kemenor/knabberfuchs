import 'package:flutter/material.dart';
import '../../core/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/offline_manifest.dart';
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

  Future<void> _download(OfflineManifest m, RegionInfo r) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _progress[r.code] = 0);
    try {
      await ref.read(offlinePackServiceProvider).install(m, r,
          onProgress: (p) {
        if (mounted) setState(() => _progress[r.code] = p);
      });
      messenger.showAutoSnackBar(SnackBar(content: Text('${r.name} downloaded')));
    } catch (e) {
      messenger.showAutoSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      if (mounted) setState(() => _progress.remove(r.code));
    }
  }

  Future<void> _remove(String code, String name) async {
    await ref.read(offlinePackServiceProvider).remove(code);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showAutoSnackBar(SnackBar(content: Text('$name removed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manifestAsync = ref.watch(offlineManifestProvider);
    final installed = {
      for (final p in ref.watch(installedPacksProvider).asData?.value ?? const [])
        p.code: p
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Offline regions')),
      body: manifestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Could not load the region list.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(offlineManifestProvider),
                child: const Text('Retry'),
              ),
            ]),
          ),
        ),
        data: (manifest) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Download a country to search its packaged products offline. '
                'You can download several.',
              ),
            ),
            for (final r in manifest.regions)
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
    final isInstalled = installed != null;
    final updatable = isInstalled && installed!.version != region.version;
    final subtitle =
        '${(region.products / 1000).toStringAsFixed(region.products >= 1000 ? 0 : 1)}k products · ${_mb(region.size)} download';

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
        tooltip: 'Download',
        icon: const Icon(Icons.download),
        onPressed: onDownload,
      );
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (updatable)
            TextButton(onPressed: onDownload, child: const Text('Update'))
          else
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
          IconButton(
            tooltip: 'Remove',
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
            ? '$subtitle · installed'
            : updatable
                ? '$subtitle · update available'
                : subtitle,
      ),
      trailing: trailing,
    );
  }
}
