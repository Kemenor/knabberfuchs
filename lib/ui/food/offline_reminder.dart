import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/snackbar.dart';
import '../../data/repositories/food_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../settings/offline_regions_screen.dart';

/// Shown at most once per app session.
bool _remindedThisSession = false;

/// Prepare a gentle nudge — a SnackBar, never a popup — to download an offline
/// region after an *online* barcode hit (so the user avoids Open Food Facts API
/// calls). Returns a callback to fire once the post-scan UI (e.g. the log sheet)
/// has settled, or null if no nudge applies (not online, already shown, or a
/// pack is already installed). Captures messenger/navigator up front so it
/// survives the navigation that follows the scan.
VoidCallback? offlinePackReminder(
    BuildContext context, WidgetRef ref, BarcodeSource source) {
  if (source != BarcodeSource.online || _remindedThisSession) return null;
  final installed =
      ref.read(installedPacksProvider).asData?.value ?? const [];
  if (installed.isNotEmpty) return null;

  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final l10n = AppLocalizations.of(context);
  return () {
    if (_remindedThisSession) return;
    _remindedThisSession = true;
    messenger.showAutoSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(l10n.offlineReminderText),
      action: SnackBarAction(
        label: l10n.offlineReminderAction,
        onPressed: () => navigator.push(MaterialPageRoute(
            builder: (_) => const OfflineRegionsScreen())),
      ),
    ));
  };
}
