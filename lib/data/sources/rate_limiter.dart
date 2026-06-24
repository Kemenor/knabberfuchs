import 'dart:async';
import 'dart:math' as math;

/// A continuously-refilling token bucket used to stay under an API's
/// requests-per-window limit (e.g. Open Food Facts: 10 searches / 15 product
/// reads per minute per IP).
///
/// [acquire] resolves immediately when a token is available, otherwise it waits
/// just long enough for the bucket to refill one. Concurrent acquisitions are
/// serialized so callers never race past the limit.
///
/// The clock and sleep are injectable for deterministic tests.
class TokenBucket {
  final int capacity;
  final Duration window;
  final double Function() _nowMs;
  final Future<void> Function(Duration) _sleep;

  double _tokens;
  double _lastMs;
  Future<void> _tail = Future<void>.value();

  TokenBucket({
    required this.capacity,
    required this.window,
    double Function()? now,
    Future<void> Function(Duration)? sleep,
  }) : _nowMs = now ?? _defaultNow,
       _sleep = sleep ?? Future.delayed,
       _tokens = capacity.toDouble(),
       _lastMs = (now ?? _defaultNow)();

  static double _defaultNow() =>
      DateTime.now().millisecondsSinceEpoch.toDouble();

  double get _ratePerMs => capacity / window.inMilliseconds;

  void _refill() {
    final now = _nowMs();
    final elapsed = now - _lastMs;
    if (elapsed > 0) {
      _tokens = math.min(capacity.toDouble(), _tokens + elapsed * _ratePerMs);
      _lastMs = now;
    }
  }

  /// Milliseconds until at least one token is available (0 = now).
  double _waitMs() {
    _refill();
    if (_tokens >= 1) return 0;
    return (1 - _tokens) / _ratePerMs;
  }

  /// Current whole tokens available (after refill). Exposed for UI hints.
  int get available {
    _refill();
    return _tokens.floor();
  }

  Future<void> acquire() {
    final prev = _tail;
    final completer = Completer<void>();
    _tail = completer.future;
    return prev
        .then((_) async {
          while (true) {
            final wait = _waitMs();
            if (wait <= 0) {
              _tokens -= 1;
              return;
            }
            await _sleep(Duration(milliseconds: wait.ceil()));
          }
        })
        .whenComplete(completer.complete);
  }

  /// Run [action] once a token is available.
  Future<T> run<T>(Future<T> Function() action) async {
    await acquire();
    return action();
  }
}
