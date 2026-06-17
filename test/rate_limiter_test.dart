import 'package:calorie_tracker/data/sources/rate_limiter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenBucket', () {
    test('allows a full burst up to capacity without waiting', () async {
      double clock = 0;
      final tb = TokenBucket(
        capacity: 2,
        window: const Duration(seconds: 1),
        now: () => clock,
        sleep: (d) async => clock += d.inMilliseconds,
      );
      await tb.acquire();
      await tb.acquire();
      expect(clock, 0, reason: 'first `capacity` tokens are free');
    });

    test('waits for refill once the bucket is empty', () async {
      double clock = 0;
      final tb = TokenBucket(
        capacity: 2,
        window: const Duration(seconds: 1), // 1 token per 500ms
        now: () => clock,
        sleep: (d) async => clock += d.inMilliseconds,
      );
      await tb.acquire();
      await tb.acquire();
      await tb.acquire(); // must wait ~500ms for one token
      expect(clock, closeTo(500, 1));
    });

    test('serializes concurrent acquisitions under the limit', () async {
      double clock = 0;
      final tb = TokenBucket(
        capacity: 1,
        window: const Duration(seconds: 1), // 1 token per 1000ms
        now: () => clock,
        sleep: (d) async => clock += d.inMilliseconds,
      );
      // 3 concurrent: 1 free, then +1000ms, then +1000ms.
      await Future.wait([tb.acquire(), tb.acquire(), tb.acquire()]);
      expect(clock, closeTo(2000, 2));
    });

    test('available reflects refill', () async {
      double clock = 0;
      final tb = TokenBucket(
        capacity: 10,
        window: const Duration(minutes: 1),
        now: () => clock,
        sleep: (d) async => clock += d.inMilliseconds,
      );
      expect(tb.available, 10);
      await tb.acquire();
      expect(tb.available, 9);
      clock += 6000; // 6s -> +1 token (10/min)
      expect(tb.available, 10);
    });
  });
}
