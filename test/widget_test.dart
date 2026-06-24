import 'package:calorie_tracker/app.dart';
import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/providers.dart';
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
}
