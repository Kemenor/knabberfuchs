import 'dart:convert';

import 'package:calorie_tracker/data/backup.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/weight.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  const day = '2026-11-13';
  DateTime at(int h, [int m = 0]) => DateTime(2026, 11, 13, h, m);

  test(
    'count this one moves the flag; editing to another day drops it',
    () async {
      final first = await db.addWeight(day: day, at: at(7), kg: 86.9);
      final second = await db.addWeight(day: day, at: at(12), kg: 87.6);
      var rows = await db.watchWeighInsForDay(day).first;
      expect(countingWeighIn(rows)!.id, first);

      await db.setCountsForDay(second);
      rows = await db.watchWeighInsForDay(day).first;
      expect(countingWeighIn(rows)!.id, second);
      expect(rows.where((r) => r.countsForDay), hasLength(1));

      await db.setCountsForDay(first);
      rows = await db.watchWeighInsForDay(day).first;
      expect(rows.where((r) => r.countsForDay).single.id, first);

      // Moving the chosen one to yesterday: it no longer counts anywhere.
      await db.updateWeight(
        first,
        day: '2026-11-12',
        at: DateTime(2026, 11, 12, 7),
        kg: 86.5,
      );
      final moved = await db.bodyMeasurementById(first);
      expect(
        (moved!.day, moved.value, moved.countsForDay),
        ('2026-11-12', 86.5, false),
      );
    },
  );

  test('remove: manual rows go, Health rows are only hidden', () async {
    final manual = await db.addWeight(day: day, at: at(7), kg: 86.9);
    final fromHealth = await db.addWeight(
      day: day,
      at: at(6),
      kg: 87.1,
      source: MeasurementSource.health,
      externalId: 'hc-1',
    );
    await db.setCountsForDay(fromHealth);
    await db.removeWeight(manual);
    await db.removeWeight(fromHealth);

    expect(await db.watchWeighInsForDay(day).first, isEmpty);
    expect(await db.watchWeights().first, isEmpty);
    final all = await db.allBodyMeasurements();
    expect(all.single.id, fromHealth);
    expect((all.single.hidden, all.single.countsForDay), (true, false));
  });

  test(
    'backup carries weigh-ins (hidden ones too) and a weights CSV',
    () async {
      await db.addWeight(day: day, at: at(7, 5), kg: 86.9);
      final h = await db.addWeight(
        day: day,
        at: at(6),
        kg: 87.1,
        source: MeasurementSource.health,
        externalId: 'hc-1',
      );
      await db.removeWeight(h); // hidden
      final map = await buildBackupMap(db, exportedAt: DateTime(2026, 11, 13));
      final json = jsonDecode(jsonEncode(map)) as Map<String, dynamic>;

      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(fresh.close);
      await fresh.addWeight(day: '2026-01-01', at: DateTime(2026), kg: 99);
      await restoreBackupMap(fresh, json);
      final restored = await fresh.allBodyMeasurements();
      expect(restored.map((r) => (r.value, r.source, r.hidden)), [
        (87.1, MeasurementSource.health, true),
        (86.9, MeasurementSource.manual, false),
      ]);
      expect(restored.first.externalId, 'hc-1');
      expect(restored.last.measuredAt, at(7, 5));

      expect(
        buildWeightsCsv(await db.allBodyMeasurements()),
        'day,time,weight_kg,source,counts_for_day\n'
        '2026-11-13,07:05,86.90,manual,',
      );

      // An older export without the section restores to no weigh-ins.
      await restoreBackupMap(fresh, {...json}..remove('bodyMeasurements'));
      expect(await fresh.allBodyMeasurements(), isEmpty);
    },
  );

  test('Health import dedupes by record id, removed ones stay out', () async {
    final at = DateTime(2026, 11, 13, 6, 30);
    expect(
      await db.addHealthWeight(at: at, kg: 87.1, externalId: 'hc-9'),
      isTrue,
    );
    expect(
      await db.addHealthWeight(at: at, kg: 87.1, externalId: 'hc-9'),
      isFalse,
    );
    final row = (await db.watchWeights().first).single;
    expect((row.day, row.source), ('2026-11-13', MeasurementSource.health));

    await db.removeWeight(row.id); // hidden, keeps its id
    expect(
      await db.addHealthWeight(at: at, kg: 87.1, externalId: 'hc-9'),
      isFalse,
    );
    expect(await db.watchWeights().first, isEmpty);
  });
}
