import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/offline_manifest.dart';
import 'offline_pack_service.dart';

/// The one path every region-pack install goes through — taps on the Offline
/// regions screen and the background [PackAutoUpdater] alike.
///
/// State is `code -> progress (0..1)` for every region that is queued or
/// downloading (0 = waiting / not started), so the screen draws the same ring
/// whoever started the install. Installs run **one at a time**: a pack is
/// held in memory while it is verified and unpacked (the biggest are ~57 MB
/// gzipped), and two at once on a phone is asking for trouble. A region that
/// is already queued is never queued twice — the caller gets the pending
/// install's future instead.
class PackInstallQueue extends Notifier<Map<String, double>> {
  PackInstallQueue(this._serviceOf);

  /// How to reach the service from this notifier's [ref] — injected so this
  /// file stays free of the app's provider graph (providers.dart wires it).
  final OfflinePackService Function(Ref ref) _serviceOf;
  final Map<String, Future<void>> _pending = {};
  final Map<String, CancellationToken> _cancels = {};
  Future<void> _tail = Future.value();

  @override
  Map<String, double> build() => const {};

  bool isQueued(String code) => _pending.containsKey(code);

  /// Queue [region] for install; completes when it is installed. Throws what
  /// [OfflinePackService.install] throws — [InstallCancelledException] after
  /// [cancel], or the download / checksum error.
  Future<void> install(OfflineManifest manifest, RegionInfo region) {
    final existing = _pending[region.code];
    if (existing != null) return existing;

    final token = CancellationToken();
    _cancels[region.code] = token;
    state = {...state, region.code: 0};

    final run = _tail.then(
      (_) => _serviceOf(ref).install(
        manifest,
        region,
        cancelToken: token,
        onProgress: (p) {
          if (_pending.containsKey(region.code)) {
            state = {...state, region.code: p};
          }
        },
      ),
    );
    // The chain must survive a failed install, or one bad download would
    // wedge every install queued behind it.
    _tail = run.then((_) {}, onError: (_) {});

    final tracked = run.whenComplete(() {
      _pending.remove(region.code);
      _cancels.remove(region.code);
      state = {...state}..remove(region.code);
    });
    _pending[region.code] = tracked;
    return tracked;
  }

  /// Abort a queued or running install. A queued one never starts: the
  /// service checks the token before downloading anything.
  void cancel(String code) => _cancels[code]?.cancel();
}
