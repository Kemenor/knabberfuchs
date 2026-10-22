import 'dart:async';

import 'package:calorie_tracker/data/offline/offline_pack_service.dart';
import 'package:calorie_tracker/domain/offline_manifest.dart';

/// Holds every install open until the test releases it, recording the order
/// installs *start* in — which is what the queue promises about.
class GatedPackService extends OfflinePackService {
  GatedPackService(super.db, super.store);

  final started = <String>[];
  final gates = <String, Completer<void>>{};
  final progressOf = <String, void Function(double)>{};

  @override
  Future<void> install(
    OfflineManifest manifest,
    RegionInfo region, {
    void Function(double progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) throw InstallCancelledException();
    started.add(region.code);
    progressOf[region.code] = onProgress ?? (_) {};
    await (gates[region.code] = Completer<void>()).future;
    if (cancelToken?.isCancelled ?? false) throw InstallCancelledException();
  }
}
