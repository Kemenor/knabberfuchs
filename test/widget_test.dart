import 'package:calorie_tracker/app.dart';
import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Home shell renders the Day tab with the bottom nav + Add button',
    (tester) async {
      // Override every live DB-backed stream the three tabs read, so the smoke
      // test is deterministic (no leaked timers, no plugin channels). The shell
      // builds all tabs (IndexedStack), hence Recipes/Settings streams too.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appStartupProvider.overrideWith((ref) async {}),
            daySummaryProvider.overrideWith(
              (ref) => Stream.value(
                DaySummary(day: DayKey.today(), entries: const []),
              ),
            ),
            recipesProvider.overrideWith(
              (ref) => Stream.value(const <Recipe>[]),
            ),
            targetsProvider.overrideWith(
              (ref) => Stream.value([
                for (var wd = 0; wd < 7; wd++) Target(weekday: wd),
              ]),
            ),
            // Keep the optional Trends tab off so the smoke test stays on the
            // three core tabs (and doesn't touch the real DB).
            showTrendsProvider.overrideWith((ref) => Stream.value(false)),
          ],
          child: const CalorieApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Bottom nav destinations are present (Recipes/Settings are now tabs).
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // The visible Day tab shows its header, FAB, and empty-state hint.
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Add food'), findsOneWidget);
      expect(find.textContaining('Tap + to start a meal'), findsOneWidget);
    },
  );

  test(
    'daySummaryProvider and trendsProvider compose over a real in-memory DB',
    () async {
      // Unlike the smoke test above, override ONLY the DB so the real provider
      // graph (settings streams -> resolved targets -> summary/trends) runs.
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [dbProvider.overrideWith((ref) => db)],
      );
      addTearDown(container.dispose);

      final today = DayKey.today();
      await db.setSetting('defaultKcalMax', '2000');
      await db.addEntry(
        EntriesCompanion.insert(
          day: today,
          mealType: MealType.lunch,
          grams: 200,
          sName: 'Rice',
          sKcal100: 130,
        ),
      );

      // Keep the stream providers alive, then poll until the async settings
      // streams have fed the resolved target through (same pattern as
      // active_group_test).
      final daySub = container.listen(daySummaryProvider, (_, _) {});
      final trendSub = container.listen(trendsProvider, (_, _) {});
      addTearDown(daySub.close);
      addTearDown(trendSub.close);

      DaySummary? summary;
      var attempts = 0;
      while (attempts++ < 100) {
        summary = container.read(daySummaryProvider).asData?.value;
        if (summary != null && summary.kcalMax == 2000) break;
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      expect(summary, isNotNull);
      expect(summary!.day, today);
      expect(summary.entries, hasLength(1));
      expect(summary.total.kcal, closeTo(260, 0.001)); // 130 kcal/100 g * 200 g
      expect(summary.kcalMax, 2000); // defaultKcalMax resolved via targets glue
      expect(summary.status, TargetStatus.inRange);

      List<DayTrend>? trends;
      attempts = 0;
      while (attempts++ < 100) {
        trends = container.read(trendsProvider).asData?.value;
        if (trends != null && trends.isNotEmpty && trends.last.kcal > 0) break;
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      expect(trends, isNotNull);
      expect(trends!, hasLength(7)); // default week window, gap-filled
      expect(DayKey.of(trends.last.date), today); // window ends today
      expect(trends.last.kcal, closeTo(260, 0.001));
      for (final t in trends.take(6)) {
        expect(t.kcal, 0); // empty days are gap-filled with zero
      }
    },
  );
}
