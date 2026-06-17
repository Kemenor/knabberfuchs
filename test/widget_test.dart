import 'package:calorie_tracker/app.dart';
import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Day screen renders empty state with the Add button',
      (tester) async {
    // Override the live DB-backed streams with completed streams so the smoke
    // test is deterministic (no leaked timers, no plugin channels). The real
    // DB wiring is covered by database_test.dart.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStartupProvider.overrideWith((ref) async {}),
          daySummaryProvider.overrideWith(
            (ref) => Stream.value(
              DaySummary(day: DayKey.today(), entries: const []),
            ),
          ),
          groupByMealProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const CalorieApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Add food'), findsOneWidget);
    // Meal mode (overridden true): empty day shows the four meal sections.
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Snacks'), findsOneWidget);
  });
}
