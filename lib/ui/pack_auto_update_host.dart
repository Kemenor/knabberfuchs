import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/snackbar.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';

/// Wraps the app shell and keeps installed offline region packs fresh: asks
/// the [PackAutoUpdater] after the first frame and on every resume (it
/// decides whether a check is due), and says which regions were updated.
class PackAutoUpdateHost extends ConsumerStatefulWidget {
  const PackAutoUpdateHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PackAutoUpdateHost> createState() => _PackAutoUpdateHostState();
}

class _PackAutoUpdateHostState extends ConsumerState<PackAutoUpdateHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // After first paint: the check must never delay the app appearing.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  /// A resume can land mid-update; it must not await the same run again, or
  /// its result would be announced twice.
  bool _checking = false;

  Future<void> _check() async {
    if (!mounted || _checking) return;
    _checking = true;
    // Capture before the await (the convention): an update can take minutes.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final List<String> updated;
    try {
      updated = await ref.read(packAutoUpdaterProvider).runIfDue();
    } finally {
      _checking = false;
    }
    if (updated.isEmpty || !mounted) return;
    messenger.showAutoSnackBar(
      SnackBar(content: Text(l10n.regionsAutoUpdated(updated.join(', ')))),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
