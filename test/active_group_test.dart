import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late ProviderContainer container;

  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [
      dbProvider.overrideWith((ref) => db),
      activeGroupProvider.overrideWith(
        () => ActiveGroupNotifier(now: () => now),
      ),
    ],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 6, 17, 12, 30);
    container = makeContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'ensureGroup auto-names a new group and reuses it within the timeout',
    () async {
      await db.setSetting('appLocale', 'en');
      final n = container.read(activeGroupProvider.notifier);

      final id = await n.ensureGroup('2026-06-17');
      final g = await db.entryGroupById(id);
      expect(g!.day, '2026-06-17');
      expect(g.name, 'Lunch 12:30'); // 12:30 is in the default lunch window
      expect(container.read(activeGroupProvider), id);

      now = now.add(const Duration(minutes: 14));
      expect(await n.ensureGroup('2026-06-17'), id);
    },
  );

  test('auto-name uses the stored app locale and inferred meal window', () async {
    await db.setSetting('appLocale', 'de');
    now = DateTime(2026, 6, 17, 8, 5);
    final n = container.read(activeGroupProvider.notifier);

    final id = await n.ensureGroup('2026-06-17');
    expect((await db.entryGroupById(id))!.name, 'Frühstück 08:05');
  });

  test('an expired group is not reused; a fresh one is created', () async {
    final n = container.read(activeGroupProvider.notifier);
    final id = await n.ensureGroup('2026-06-17');

    now = now.add(ActiveGroupNotifier.timeout + const Duration(minutes: 1));
    final id2 = await n.ensureGroup('2026-06-17');
    expect(id2, isNot(id));
    expect(container.read(activeGroupProvider), id2);
  });

  test('a group from another day is not reused even within the timeout', () async {
    final n = container.read(activeGroupProvider.notifier);
    final id = await n.ensureGroup('2026-06-17');

    now = now.add(const Duration(minutes: 5));
    final id2 = await n.ensureGroup('2026-06-18');
    expect(id2, isNot(id));
    expect((await db.entryGroupById(id2))!.day, '2026-06-18');
  });

  test('refreshTimeout clears an expired active group', () async {
    final n = container.read(activeGroupProvider.notifier);
    await n.ensureGroup('2026-06-17');
    expect(container.read(activeGroupProvider), isNotNull);

    now = now.add(const Duration(minutes: 10));
    await n.refreshTimeout();
    expect(container.read(activeGroupProvider), isNotNull); // still fresh

    now = now.add(const Duration(minutes: 10));
    await n.refreshTimeout();
    expect(container.read(activeGroupProvider), isNull);
  });

  test('a new notifier restores the persisted, unexpired group id', () async {
    final id = await container
        .read(activeGroupProvider.notifier)
        .ensureGroup('2026-06-17');
    container.dispose();

    container = makeContainer();
    container.read(activeGroupProvider.notifier); // triggers the async load
    var attempts = 0;
    while (container.read(activeGroupProvider) == null && attempts++ < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    expect(container.read(activeGroupProvider), id);
  });
}
